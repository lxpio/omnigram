package reader

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/service/ai"
)

// sanitizeSearchQuery cleans search input for PG tsvector plainto_tsquery
func sanitizeSearchQuery(q string) string {
	q = strings.TrimSpace(q)
	if q == "" {
		return ""
	}
	// Remove special characters that could cause issues
	replacer := strings.NewReplacer(
		`"`, ``, `'`, ``, `(`, ``, `)`, ``,
		`:`, ``, `^`, ``, `!`, ``, `&`, ``, `|`, ``,
	)
	return replacer.Replace(q)
}

// enhancedSearchHandle GET /reader/search
// @Summary Enhanced search
// @Description Search books with advanced filters and pagination. Supports text (tsvector) and semantic (pgvector) modes.
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param q query string false "Search query"
// @Param mode query string false "Search mode (text, semantic)" default(text)
// @Param format query string false "File format filter (epub, pdf, mobi)"
// @Param language query string false "Language filter"
// @Param tag query string false "Tag filter"
// @Param author query string false "Author filter"
// @Param sort query string false "Sort field (ctime, title, author, rating)" default(ctime)
// @Param order query string false "Sort order (asc, desc)" default(desc)
// @Param page query int false "Page number" default(1)
// @Param page_size query int false "Page size (1-100)" default(20)
// @Success 200 {object} object{data=[]schema.Book,total=int,page=int,page_size=int,mode=string}
// @Router /reader/search [get]
func enhancedSearchHandle(c *gin.Context) {
	q := c.Query("q")
	mode := c.DefaultQuery("mode", "text")
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
	usedMode := "text"

	// Semantic search via pgvector
	if q != "" && mode == "semantic" && ai.IsEmbeddingAvailable() {
		embedding, err := ai.GenerateEmbedding(c.Request.Context(), q)
		if err == nil && embedding != nil {
			vecStr := ai.FormatVector(embedding)
			query = query.Where("embedding IS NOT NULL").
				Order(fmt.Sprintf("embedding <=> '%s'", vecStr))
			usedMode = "semantic"
		} else {
			// Fallback to tsvector on embedding failure
			sanitized := sanitizeSearchQuery(q)
			if sanitized != "" {
				query = query.Where("search_vector @@ plainto_tsquery('simple', ?)", sanitized)
			}
		}
	} else if q != "" {
		// PG tsvector full-text search
		sanitized := sanitizeSearchQuery(q)
		if sanitized != "" {
			query = query.Where("search_vector @@ plainto_tsquery('simple', ?)", sanitized)
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
	if usedMode != "semantic" {
		query = query.Order(sortCol + " " + order)
	}
	query.Offset((page - 1) * pageSize).
		Limit(pageSize).
		Find(&books)

	schema.Success(c, gin.H{
		"data":      books,
		"total":     total,
		"page":      page,
		"page_size": pageSize,
		"mode":      usedMode,
	})
}
