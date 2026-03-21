package reader

import (
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/schema"
)

// sanitizeFTS5Query 清理 FTS5 查询输入，防止查询崩溃
func sanitizeFTS5Query(q string) string {
	replacer := strings.NewReplacer(
		`"`, ``, `*`, ``, `(`, ``, `)`, ``,
		`:`, ``, `^`, ``,
	)
	q = replacer.Replace(q)
	q = strings.TrimSpace(q)
	if q == "" {
		return ""
	}
	words := strings.Fields(q)
	result := make([]string, 0, len(words))
	for _, w := range words {
		upper := strings.ToUpper(w)
		if upper == "AND" || upper == "OR" || upper == "NOT" || upper == "NEAR" {
			continue
		}
		result = append(result, `"`+w+`"`)
	}
	if len(result) == 0 {
		return ""
	}
	return strings.Join(result, " ")
}

// enhancedSearchHandle GET /reader/search
// @Summary Enhanced search
// @Description Search books with advanced filters and pagination
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param q query string false "Search query"
// @Param format query string false "File format filter (epub, pdf, mobi)"
// @Param language query string false "Language filter"
// @Param tag query string false "Tag filter"
// @Param author query string false "Author filter"
// @Param sort query string false "Sort field (ctime, title, author, rating)" default(ctime)
// @Param order query string false "Sort order (asc, desc)" default(desc)
// @Param page query int false "Page number" default(1)
// @Param page_size query int false "Page size (1-100)" default(20)
// @Success 200 {object} object{data=[]schema.Book,total=int,page=int,page_size=int}
// @Router /reader/search [get]
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
		sanitized := sanitizeFTS5Query(q)
		if sanitized != "" {
			query = query.Where("id IN (SELECT book_id FROM books_fts WHERE books_fts MATCH ?)", sanitized)
		}
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
