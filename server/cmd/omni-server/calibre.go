package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/lxpio/omnigram/server/schema"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type calibreBook struct {
	ID          int     `gorm:"column:id"`
	Title       string  `gorm:"column:title"`
	Sort        string  `gorm:"column:sort"`
	Timestamp   string  `gorm:"column:timestamp"`
	Pubdate     string  `gorm:"column:pubdate"`
	SeriesIndex float64 `gorm:"column:series_index"`
	ISBN        string  `gorm:"column:isbn"`
	Path        string  `gorm:"column:path"`
}

func (calibreBook) TableName() string { return "books" }

type calibreData struct {
	ID               int    `gorm:"column:id"`
	Book             int    `gorm:"column:book"`
	Format           string `gorm:"column:format"`
	Name             string `gorm:"column:name"`
	UncompressedSize int64  `gorm:"column:uncompressed_size"`
}

func (calibreData) TableName() string { return "data" }

func importCalibre(calibrePath, dataPath string, targetDB *gorm.DB) {
	metadataDB := filepath.Join(calibrePath, "metadata.db")
	if _, err := os.Stat(metadataDB); os.IsNotExist(err) {
		fmt.Println("Error: metadata.db not found at", metadataDB)
		os.Exit(1)
	}

	cdb, err := gorm.Open(sqlite.Open(metadataDB+"?mode=ro"), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		fmt.Println("Error opening Calibre DB:", err)
		os.Exit(1)
	}

	uploadDir := filepath.Join(dataPath, "upload")
	os.MkdirAll(uploadDir, 0755)

	var cbooks []calibreBook
	cdb.Find(&cbooks)

	var imported, skipped, errors int

	for _, cb := range cbooks {
		// get authors
		var authors []string
		cdb.Raw(`SELECT a.name FROM authors a JOIN books_authors_link l ON a.id = l.author WHERE l.book = ?`, cb.ID).Scan(&authors)

		// get tags
		var tags []string
		cdb.Raw(`SELECT t.name FROM tags t JOIN books_tags_link l ON t.id = l.tag WHERE l.book = ?`, cb.ID).Scan(&tags)

		// get series
		var series string
		cdb.Raw(`SELECT s.name FROM series s JOIN books_series_link l ON s.id = l.series WHERE l.book = ? LIMIT 1`, cb.ID).Scan(&series)

		// get publisher
		var publisher string
		cdb.Raw(`SELECT p.name FROM publishers p JOIN books_publishers_link l ON p.id = l.publisher WHERE l.book = ? LIMIT 1`, cb.ID).Scan(&publisher)

		// get comment/description
		var description string
		cdb.Raw(`SELECT text FROM comments WHERE book = ? LIMIT 1`, cb.ID).Scan(&description)

		// get rating
		var rating float32
		cdb.Raw(`SELECT r.rating FROM ratings r JOIN books_ratings_link l ON r.id = l.rating WHERE l.book = ? LIMIT 1`, cb.ID).Scan(&rating)
		rating = rating / 2 // Calibre uses 0-10, convert to 0-5

		// get language
		var language string
		cdb.Raw(`SELECT l.lang_code FROM languages l JOIN books_languages_link bl ON l.id = bl.lang_code WHERE bl.book = ? LIMIT 1`, cb.ID).Scan(&language)

		// get identifiers (isbn, asin)
		var isbn, asin string
		type identifier struct {
			Type string
			Val  string
		}
		var identifiers []identifier
		cdb.Raw(`SELECT type, val FROM identifiers WHERE book = ?`, cb.ID).Scan(&identifiers)
		for _, id := range identifiers {
			switch id.Type {
			case "isbn":
				isbn = id.Val
			case "asin":
				asin = id.Val
			}
		}
		if isbn == "" {
			isbn = cb.ISBN
		}

		// get file data
		var dataRows []calibreData
		cdb.Where("book = ?", cb.ID).Find(&dataRows)

		if len(dataRows) == 0 {
			skipped++
			continue
		}

		// pick best format: EPUB > PDF > MOBI > first available
		var bestData calibreData
		formatPriority := map[string]int{"EPUB": 0, "PDF": 1, "MOBI": 2, "AZW3": 3}
		bestPrio := 999
		for _, d := range dataRows {
			if p, ok := formatPriority[d.Format]; ok && p < bestPrio {
				bestPrio = p
				bestData = d
			}
		}
		if bestData.ID == 0 {
			bestData = dataRows[0]
		}

		// source file path in Calibre library
		ext := "." + strings.ToLower(bestData.Format)
		srcFile := filepath.Join(calibrePath, cb.Path, bestData.Name+ext)

		if _, err := os.Stat(srcFile); os.IsNotExist(err) {
			fmt.Printf("  SKIP (file missing): %s\n", srcFile)
			skipped++
			continue
		}

		// check duplicate by title+author
		author := strings.Join(authors, ", ")
		var count int64
		targetDB.Model(&schema.Book{}).Where("title = ? AND author = ?", cb.Title, author).Count(&count)
		if count > 0 {
			skipped++
			continue
		}

		// copy file
		destFile := filepath.Join(uploadDir, bestData.Name+ext)
		if err := copyFile(srcFile, destFile); err != nil {
			fmt.Printf("  ERROR copying %s: %v\n", srcFile, err)
			errors++
			continue
		}

		fi, _ := os.Stat(destFile)

		book := &schema.Book{
			ID:          schema.GenBookID(time.Now()),
			Title:       cb.Title,
			Author:      author,
			Publisher:   publisher,
			Description: description,
			Language:    language,
			ISBN:        isbn,
			ASIN:        asin,
			Series:      series,
			Rating:      rating,
			Tags:        schema.Tags(tags),
			FileType:    schema.ParseFileType(ext),
			Path:        destFile,
			Size:        fi.Size(),
			Identifier:  fmt.Sprintf("calibre-%d", cb.ID),
		}

		if cb.Pubdate != "" {
			book.PublishDate = cb.Pubdate
		}
		if fmt.Sprintf("%.0f", cb.SeriesIndex) != "0" {
			book.SeriesIndex = fmt.Sprintf("%.0f", cb.SeriesIndex)
		}

		if err := book.Create(targetDB); err != nil {
			fmt.Printf("  ERROR importing '%s': %v\n", cb.Title, err)
			errors++
			continue
		}

		imported++
		fmt.Printf("  OK: %s - %s\n", cb.Title, author)

		// try to copy cover
		coverSrc := filepath.Join(calibrePath, cb.Path, "cover.jpg")
		if _, err := os.Stat(coverSrc); err == nil {
			coverDest := filepath.Join(uploadDir, fmt.Sprintf("calibre-%d-cover.jpg", cb.ID))
			copyFile(coverSrc, coverDest)
		}
	}

	fmt.Println("\n--- Calibre Import Report ---")
	fmt.Printf("Total:    %d\n", len(cbooks))
	fmt.Printf("Imported: %d\n", imported)
	fmt.Printf("Skipped:  %d\n", skipped)
	fmt.Printf("Errors:   %d\n", errors)
}

func copyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, in)
	return err
}
