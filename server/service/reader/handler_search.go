package reader

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/schema"
)

func enhancedSearchHandle(c *gin.Context) {
	q := c.Query("q")
	format := c.Query("format")
	language := c.Query("language")
	tag := c.Query("tag")
	author := c.Query("author")
	sortBy := c.DefaultQuery("sort", "ctime")
	order := c.DefaultQuery("order", "desc")
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	allowedSorts := map[string]string{
		"title": "title", "author": "author", "ctime": "ctime",
		"utime": "utime", "rating": "rating",
	}
	sortCol, ok := allowedSorts[sortBy]
	if !ok {
		sortCol = "ctime"
	}
	if order != "asc" {
		order = "desc"
	}

	query := orm.Model(&schema.Book{})

	// FTS5 search
	if q != "" {
		query = query.Where("id IN (SELECT book_id FROM books_fts WHERE books_fts MATCH ?)", q)
	}

	// Filters
	if format != "" {
		ft := schema.ParseFileType("." + format)
		if ft != schema.UnkownFile {
			query = query.Where("file_type = ?", ft)
		}
	}
	if language != "" {
		query = query.Where("language = ?", language)
	}
	if tag != "" {
		query = query.Where("id IN (SELECT book_id FROM book_tag_ships WHERE tag = ?)", tag)
	}
	if author != "" {
		query = query.Where("author LIKE ?", "%"+author+"%")
	}

	var total int64
	query.Count(&total)

	var books []schema.Book
	query.Order(sortCol + " " + order).
		Offset((page - 1) * pageSize).
		Limit(pageSize).
		Find(&books)

	schema.Success(c, gin.H{
		"data":      books,
		"total":     total,
		"page":      page,
		"page_size": pageSize,
	})
}
