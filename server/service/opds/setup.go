package opds

import (
	"encoding/xml"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/service/webdav"
	"github.com/lxpio/omnigram/server/store"
)

// Setup registers OPDS routes
func Setup(router *gin.Engine) {
	opds := router.Group("/opds", webdav.BasicAuthMiddleware())

	opds.GET("", catalogHandler)
	opds.GET("/new", newBooksHandler)
	opds.GET("/popular", popularBooksHandler)
	opds.GET("/authors", authorsHandler)
	opds.GET("/authors/:name", authorBooksHandler)
	opds.GET("/tags/:tag", tagBooksHandler)
	opds.GET("/shelves", shelvesHandler)
	opds.GET("/shelves/:shelf_id", shelfBooksHandler)
	opds.GET("/search", searchHandler)
	opds.GET("/download/:book_id", downloadHandler)
}

func writeAtomFeed(c *gin.Context, feed *Feed) {
	feed.XMLNS = AtomNS
	data, err := xml.MarshalIndent(feed, "", "  ")
	if err != nil {
		c.String(http.StatusInternalServerError, "XML marshal error")
		return
	}
	c.Data(http.StatusOK, "application/atom+xml; charset=utf-8", append([]byte(xml.Header), data...))
}

func nowAtom() string {
	return time.Now().UTC().Format(AtomTime)
}

func fileTypeMime(ft schema.FileType) string {
	switch ft {
	case schema.EPUB:
		return "application/epub+zip"
	case schema.PDF:
		return "application/pdf"
	case schema.MOBI:
		return "application/x-mobipocket-ebook"
	default:
		return "application/octet-stream"
	}
}

func bookToEntry(b schema.Book) Entry {
	entry := Entry{
		ID:      "urn:omnigram:book:" + b.ID,
		Title:   b.Title,
		Updated: nowAtom(),
		Link: []Link{
			{Href: "/opds/download/" + b.ID, Type: fileTypeMime(b.FileType), Rel: FileRel},
		},
	}
	if b.Author != "" {
		entry.Author = &Author{Name: b.Author}
	}
	if b.Description != "" {
		entry.Summary = &Summary{Type: "text", Text: b.Description}
	}
	return entry
}

// catalogHandler — root navigation feed
func catalogHandler(c *gin.Context) {
	feed := &Feed{
		ID:      "urn:omnigram:catalog",
		Title:   "Omnigram OPDS Catalog",
		Updated: nowAtom(),
		Author:  &Author{Name: "Omnigram"},
		Link: []Link{
			{Href: "/opds", Type: DirMime, Rel: "self"},
			{Href: "/opds/search?q={searchTerms}", Type: "application/opensearchdescription+xml", Rel: "search"},
		},
		Entry: []Entry{
			{ID: "urn:omnigram:new", Title: "New Books", Updated: nowAtom(),
				Link: []Link{{Href: "/opds/new", Type: AcqMime, Rel: DirRel}}},
			{ID: "urn:omnigram:popular", Title: "Popular Books", Updated: nowAtom(),
				Link: []Link{{Href: "/opds/popular", Type: AcqMime, Rel: DirRel}}},
			{ID: "urn:omnigram:authors", Title: "Authors", Updated: nowAtom(),
				Link: []Link{{Href: "/opds/authors", Type: DirMime, Rel: DirRel}}},
			{ID: "urn:omnigram:shelves", Title: "Shelves", Updated: nowAtom(),
				Link: []Link{{Href: "/opds/shelves", Type: DirMime, Rel: DirRel}}},
		},
	}
	writeAtomFeed(c, feed)
}

// newBooksHandler — latest 50 books
func newBooksHandler(c *gin.Context) {
	db := store.FileStore()
	var books []schema.Book
	if err := db.Order("ctime DESC").Limit(50).Find(&books).Error; err != nil {
		log.E("opds new books: ", err)
	}

	entries := make([]Entry, len(books))
	for i, b := range books {
		entries[i] = bookToEntry(b)
	}

	writeAtomFeed(c, &Feed{
		ID: "urn:omnigram:new", Title: "New Books", Updated: nowAtom(), Entry: entries,
	})
}

// popularBooksHandler — top 50 by visits
func popularBooksHandler(c *gin.Context) {
	db := store.FileStore()
	var books []schema.Book
	if err := db.Order("count_visit DESC").Limit(50).Find(&books).Error; err != nil {
		log.E("opds popular books: ", err)
	}

	entries := make([]Entry, len(books))
	for i, b := range books {
		entries[i] = bookToEntry(b)
	}

	writeAtomFeed(c, &Feed{
		ID: "urn:omnigram:popular", Title: "Popular Books", Updated: nowAtom(), Entry: entries,
	})
}

// authorsHandler — list distinct authors
func authorsHandler(c *gin.Context) {
	db := store.FileStore()
	type authorRow struct {
		Author string
		Count  int64
	}
	var rows []authorRow
	db.Model(&schema.Book{}).Select("author, COUNT(*) as count").
		Where("author != ''").Group("author").Order("count DESC").Scan(&rows)

	entries := make([]Entry, len(rows))
	for i, r := range rows {
		entries[i] = Entry{
			ID:    "urn:omnigram:author:" + r.Author,
			Title: fmt.Sprintf("%s (%d)", r.Author, r.Count),
			Updated: nowAtom(),
			Link: []Link{{Href: "/opds/authors/" + r.Author, Type: AcqMime, Rel: DirRel}},
		}
	}

	writeAtomFeed(c, &Feed{
		ID: "urn:omnigram:authors", Title: "Authors", Updated: nowAtom(), Entry: entries,
	})
}

// authorBooksHandler — books by author
func authorBooksHandler(c *gin.Context) {
	name := c.Param("name")
	db := store.FileStore()
	var books []schema.Book
	db.Where("author = ?", name).Find(&books)

	entries := make([]Entry, len(books))
	for i, b := range books {
		entries[i] = bookToEntry(b)
	}

	writeAtomFeed(c, &Feed{
		ID: "urn:omnigram:author:" + name, Title: "Books by " + name, Updated: nowAtom(), Entry: entries,
	})
}

// tagBooksHandler — books by tag
func tagBooksHandler(c *gin.Context) {
	tag := c.Param("tag")
	db := store.FileStore()
	var books []schema.Book
	db.Raw(`SELECT b.* FROM books b INNER JOIN book_tag_ships t ON b.id = t.book_id WHERE t.tag = ?`, tag).Scan(&books)

	entries := make([]Entry, len(books))
	for i, b := range books {
		entries[i] = bookToEntry(b)
	}

	writeAtomFeed(c, &Feed{
		ID: "urn:omnigram:tag:" + tag, Title: "Tag: " + tag, Updated: nowAtom(), Entry: entries,
	})
}

// shelvesHandler — list user shelves
func shelvesHandler(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	db := store.FileStore()
	var shelves []schema.Shelf
	db.Where("user_id = ?", userID).Find(&shelves)

	entries := make([]Entry, len(shelves))
	for i, s := range shelves {
		entries[i] = Entry{
			ID:      fmt.Sprintf("urn:omnigram:shelf:%d", s.ID),
			Title:   s.Name,
			Updated: nowAtom(),
			Link:    []Link{{Href: fmt.Sprintf("/opds/shelves/%d", s.ID), Type: AcqMime, Rel: DirRel}},
		}
		if s.Description != "" {
			entries[i].Summary = &Summary{Type: "text", Text: s.Description}
		}
	}

	writeAtomFeed(c, &Feed{
		ID: "urn:omnigram:shelves", Title: "Shelves", Updated: nowAtom(), Entry: entries,
	})
}

// shelfBooksHandler — books in a shelf
func shelfBooksHandler(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	shelfID := c.Param("shelf_id")
	db := store.FileStore()

	// verify ownership
	var count int64
	db.Model(&schema.Shelf{}).Where("id = ? AND user_id = ?", shelfID, userID).Count(&count)
	if count == 0 {
		writeAtomFeed(c, &Feed{ID: "urn:omnigram:shelf:" + shelfID, Title: "Not Found", Updated: nowAtom()})
		return
	}

	var books []schema.Book
	db.Raw(`SELECT b.* FROM books b INNER JOIN shelf_books sb ON b.id = sb.book_id WHERE sb.shelf_id = ? ORDER BY sb.sort_order ASC`, shelfID).Scan(&books)

	entries := make([]Entry, len(books))
	for i, b := range books {
		entries[i] = bookToEntry(b)
	}

	writeAtomFeed(c, &Feed{
		ID: "urn:omnigram:shelf:" + shelfID, Title: "Shelf", Updated: nowAtom(), Entry: entries,
	})
}

// searchHandler — search books by query
func searchHandler(c *gin.Context) {
	q := c.Query("q")
	db := store.FileStore()
	var books []schema.Book
	db.Where("title LIKE ? OR author LIKE ?", "%"+q+"%", "%"+q+"%").Limit(50).Find(&books)

	entries := make([]Entry, len(books))
	for i, b := range books {
		entries[i] = bookToEntry(b)
	}

	writeAtomFeed(c, &Feed{
		ID: "urn:omnigram:search", Title: "Search: " + q, Updated: nowAtom(), Entry: entries,
	})
}

// downloadHandler — serve book file
func downloadHandler(c *gin.Context) {
	bookID := c.Param("book_id")
	db := store.FileStore()

	book, err := schema.FirstBookById(db, bookID)
	if err != nil {
		c.String(http.StatusNotFound, "Book not found")
		return
	}

	if _, err := os.Stat(book.Path); os.IsNotExist(err) {
		c.String(http.StatusNotFound, "File not found")
		return
	}

	// increment download count
	db.Model(book).UpdateColumn("count_download", book.CountDownload+1)

	c.Header("Content-Type", fileTypeMime(book.FileType))
	c.File(book.Path)
}
