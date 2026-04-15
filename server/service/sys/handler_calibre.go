package sys

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
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

// CalibreImportRequest is the request body for the Calibre import API.
type CalibreImportRequest struct {
	CalibrePath string `json:"calibre_path" binding:"required"`
}

// CalibreImportResult is the response body for the Calibre import API.
type CalibreImportResult struct {
	Total    int      `json:"total"`
	Imported int      `json:"imported"`
	Skipped  int      `json:"skipped"`
	Errors   int      `json:"errors"`
	Messages []string `json:"messages,omitempty"`
}

// @Summary Import Calibre library
// @Description Import books from a Calibre library directory (admin only). Reads metadata.db and copies book files.
// @Tags System
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body CalibreImportRequest true "Calibre library path"
// @Success 200 {object} CalibreImportResult
// @Failure 400 {object} utils.Response
// @Failure 500 {object} utils.Response
// @Router /sys/import/calibre [post]
func importCalibreHandle(c *gin.Context) {
	var req CalibreImportRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	metadataDB := filepath.Join(req.CalibrePath, "metadata.db")
	if _, err := os.Stat(metadataDB); os.IsNotExist(err) {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage("metadata.db not found at "+metadataDB))
		return
	}

	cf := conf.GetConfig()
	result, err := RunCalibreImport(c.Request.Context(), req.CalibrePath, cf.EpubOptions.DataPath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	c.JSON(http.StatusOK, result)
}

// RunCalibreImport performs the actual Calibre library import.
func RunCalibreImport(ctx context.Context, calibrePath, dataPath string) (*CalibreImportResult, error) {
	metadataDB := filepath.Join(calibrePath, "metadata.db")
	cdb, err := gorm.Open(sqlite.Open(metadataDB+"?mode=ro"), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to open Calibre DB: %w", err)
	}

	uploadDir := filepath.Join(dataPath, "upload")
	os.MkdirAll(uploadDir, 0755)

	targetDB := store.FileStore()

	var cbooks []calibreBook
	cdb.Find(&cbooks)

	result := &CalibreImportResult{Total: len(cbooks)}

	for _, cb := range cbooks {
		var authors []string
		cdb.Raw(`SELECT a.name FROM authors a JOIN books_authors_link l ON a.id = l.author WHERE l.book = ?`, cb.ID).Scan(&authors)

		var tags []string
		cdb.Raw(`SELECT t.name FROM tags t JOIN books_tags_link l ON t.id = l.tag WHERE l.book = ?`, cb.ID).Scan(&tags)

		var series string
		cdb.Raw(`SELECT s.name FROM series s JOIN books_series_link l ON s.id = l.series WHERE l.book = ? LIMIT 1`, cb.ID).Scan(&series)

		var publisher string
		cdb.Raw(`SELECT p.name FROM publishers p JOIN books_publishers_link l ON p.id = l.publisher WHERE l.book = ? LIMIT 1`, cb.ID).Scan(&publisher)

		var description string
		cdb.Raw(`SELECT text FROM comments WHERE book = ? LIMIT 1`, cb.ID).Scan(&description)

		var rating float32
		cdb.Raw(`SELECT r.rating FROM ratings r JOIN books_ratings_link l ON r.id = l.rating WHERE l.book = ? LIMIT 1`, cb.ID).Scan(&rating)
		rating = rating / 2

		var language string
		cdb.Raw(`SELECT l.lang_code FROM languages l JOIN books_languages_link bl ON l.id = bl.lang_code WHERE bl.book = ? LIMIT 1`, cb.ID).Scan(&language)

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

		var dataRows []calibreData
		cdb.Where("book = ?", cb.ID).Find(&dataRows)

		if len(dataRows) == 0 {
			result.Skipped++
			continue
		}

		// Pick best format: EPUB > PDF > MOBI > AZW3 > first available
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

		ext := "." + strings.ToLower(bestData.Format)
		srcFile := filepath.Join(calibrePath, cb.Path, bestData.Name+ext)

		if _, err := os.Stat(srcFile); os.IsNotExist(err) {
			log.W("Calibre import: file missing:", srcFile)
			result.Skipped++
			continue
		}

		author := strings.Join(authors, ", ")
		var count int64
		targetDB.Model(&schema.Book{}).Where("title = ? AND author = ?", cb.Title, author).Count(&count)
		if count > 0 {
			result.Skipped++
			continue
		}

		destFile := filepath.Join(uploadDir, bestData.Name+ext)
		if err := copyFileUtil(srcFile, destFile); err != nil {
			log.E("Calibre import: copy error:", err.Error())
			result.Errors++
			result.Messages = append(result.Messages, fmt.Sprintf("copy error for '%s': %v", cb.Title, err))
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

		// Read cover from Calibre and set it on the book for BadgerDB storage
		coverSrc := filepath.Join(calibrePath, cb.Path, "cover.jpg")
		if coverBytes, err := os.ReadFile(coverSrc); err == nil {
			book.SetCoverData(coverBytes)
			book.CoverURL = "cover.jpg"
		}

		// Use book.Save() which handles both DB creation and cover storage to BadgerDB
		if _, err := book.Save(ctx); err != nil {
			log.E("Calibre import: save error for", cb.Title, ":", err.Error())
			result.Errors++
			result.Messages = append(result.Messages, fmt.Sprintf("save error for '%s': %v", cb.Title, err))
			continue
		}

		result.Imported++
		log.I("Calibre import: OK:", cb.Title, "-", author)
	}

	return result, nil
}

func copyFileUtil(src, dst string) error {
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
