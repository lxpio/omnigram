package reader

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/utils"
)

// BookAiResult represents the AI-generated metadata for a book.
type BookAiResult struct {
	BookID      string   `json:"book_id"`
	Summary     string   `json:"summary"`
	Tags        []string `json:"tags"`
	Language    string   `json:"language"`
	Category    string   `json:"category"`
	Description string   `json:"description"`
}

// @Summary Get AI enhancement results for a book
// @Description Returns AI-generated metadata (tags, summary, category) for a specific book
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Success 200 {object} BookAiResult
// @Failure 404 {object} utils.Response
// @Router /reader/books/{book_id}/ai [get]
func getBookAiHandle(c *gin.Context) {
	bookID := c.Param("book_id")

	book, err := schema.FirstBookById(orm, bookID)
	if err != nil {
		c.JSON(404, utils.ErrNoFound.WithMessage("Book not found"))
		return
	}

	result := BookAiResult{
		BookID:      bookID,
		Summary:     book.Description,
		Tags:        book.Tags,
		Language:    book.Language,
		Category:    book.Category,
		Description: book.Description,
	}

	c.JSON(200, result)
}

// --- AI Cache Sync Endpoints ---

// @Summary List cached AI results for a book
// @Description Returns all AI-generated cached results for a specific book
// @Tags AI
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Success 200 {array} schema.AiResult
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/ai/cache [get]
func listAiCacheHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64("user_id")

	var results []schema.AiResult
	if err := orm.Where("user_id = ? AND book_id = ?", userID, bookID).Find(&results).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}
	schema.Success(c, results)
}

// @Summary Upsert an AI cache result
// @Description Create or update an AI cache entry (client → server sync)
// @Tags AI
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param request body schema.AiResult true "AI result"
// @Success 200 {object} schema.AiResult
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/ai/cache [put]
func upsertAiCacheHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64("user_id")

	var req schema.AiResult
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	req.BookID = bookID
	req.UserID = userID

	// Upsert by unique key (result_type + cache_key)
	var existing schema.AiResult
	result := orm.Where("user_id = ? AND result_type = ? AND cache_key = ?", userID, req.ResultType, req.CacheKey).First(&existing)
	if result.Error == nil {
		// Update existing
		existing.Content = req.Content
		orm.Save(&existing)
		schema.Success(c, existing)
	} else {
		// Create new
		orm.Create(&req)
		schema.Success(c, req)
	}
}

// @Summary Batch sync AI cache results
// @Description Upload multiple AI cache entries at once (client → server bulk sync)
// @Tags AI
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body []schema.AiResult true "AI results array"
// @Success 200 {object} map[string]int "synced count"
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/ai/cache/sync [post]
func syncAiCacheHandle(c *gin.Context) {
	userID := c.GetInt64("user_id")

	var entries []schema.AiResult
	if err := c.ShouldBindJSON(&entries); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	synced := 0
	for _, entry := range entries {
		entry.UserID = userID
		var existing schema.AiResult
		result := orm.Where("user_id = ? AND result_type = ? AND cache_key = ?", userID, entry.ResultType, entry.CacheKey).First(&existing)
		if result.Error == nil {
			if entry.UTime > existing.UTime {
				existing.Content = entry.Content
				orm.Save(&existing)
				synced++
			}
		} else {
			orm.Create(&entry)
			synced++
		}
	}

	schema.Success(c, gin.H{"synced": synced, "total": len(entries)})
}
