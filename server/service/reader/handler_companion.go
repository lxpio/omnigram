package reader

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
)

// --- Companion Chat Endpoints ---

// @Summary Get companion chat history for a book
// @Description Returns companion conversation messages for a specific book
// @Tags AI
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param limit query int false "Limit" default(50)
// @Param offset query int false "Offset" default(0)
// @Success 200 {array} schema.CompanionChat
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/companion/chat [get]
func listCompanionChatHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	var chats []schema.CompanionChat
	query := orm.Where("user_id = ? AND book_id = ?", userID, bookID).Order("ctime ASC")

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))
	if limit < 1 || limit > 200 {
		limit = 50
	}
	query = query.Limit(limit).Offset(offset)

	if err := query.Find(&chats).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}
	schema.Success(c, chats)
}

// @Summary Add companion chat messages
// @Description Bulk add companion chat messages (client → server sync)
// @Tags AI
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param request body []schema.CompanionChat true "Chat messages"
// @Success 200 {object} map[string]int
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/companion/chat [post]
func addCompanionChatHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	var messages []schema.CompanionChat
	if err := c.ShouldBindJSON(&messages); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	for i := range messages {
		messages[i].UserID = userID
		messages[i].BookID = bookID
	}

	if err := orm.Create(&messages).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}

	schema.Success(c, gin.H{"added": len(messages)})
}

// --- Margin Notes Endpoints ---

// @Summary Get margin notes for a book chapter
// @Description Returns AI-generated margin notes (cross-book connections) for a chapter
// @Tags AI
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param chapter query string false "Chapter name filter"
// @Success 200 {array} schema.MarginNote
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/margin-notes [get]
func listMarginNotesHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	query := orm.Where("user_id = ? AND book_id = ?", userID, bookID)

	if chapter := c.Query("chapter"); chapter != "" {
		query = query.Where("chapter = ?", chapter)
	}

	query = query.Where("dismissed = false").Order("confidence DESC")

	var notes []schema.MarginNote
	if err := query.Find(&notes).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}
	schema.Success(c, notes)
}

// @Summary Upsert margin notes
// @Description Create or update margin notes (client → server sync)
// @Tags AI
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param request body []schema.MarginNote true "Margin notes"
// @Success 200 {object} map[string]int
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/margin-notes [post]
func syncMarginNotesHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	var notes []schema.MarginNote
	if err := c.ShouldBindJSON(&notes); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	synced := 0
	for _, note := range notes {
		note.UserID = userID
		note.BookID = bookID
		if err := orm.Create(&note).Error; err != nil {
			continue
		}
		synced++
	}

	schema.Success(c, gin.H{"synced": synced})
}

// @Summary Update margin note feedback
// @Description Mark a margin note as dismissed or helpful
// @Tags AI
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param note_id path int true "Note ID"
// @Param request body object{dismissed=bool,helpful=bool} true "Feedback"
// @Success 200 {object} schema.MarginNote
// @Failure 404 {object} schema.ErrorResponse
// @Router /reader/margin-notes/{note_id} [patch]
func updateMarginNoteFeedbackHandle(c *gin.Context) {
	noteID := c.Param("note_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	var note schema.MarginNote
	if err := orm.Where("id = ? AND user_id = ?", noteID, userID).First(&note).Error; err != nil {
		schema.Error(c, http.StatusNotFound, "NOT_FOUND", "Margin note not found")
		return
	}

	var req struct {
		Dismissed *bool `json:"dismissed"`
		Helpful   *bool `json:"helpful"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	if req.Dismissed != nil {
		note.Dismissed = *req.Dismissed
	}
	if req.Helpful != nil {
		note.Helpful = *req.Helpful
	}

	orm.Save(&note)
	schema.Success(c, note)
}
