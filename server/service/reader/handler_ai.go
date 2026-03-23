package reader

import (
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
