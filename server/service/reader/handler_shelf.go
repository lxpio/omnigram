package reader

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"gorm.io/gorm"
)

// listShelvesHandle GET /reader/shelves
// @Summary List shelves
// @Description Get all shelves for the current user
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Success 200 {object} object{data=[]schema.Shelf}
// @Router /reader/shelves [get]
func listShelvesHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	var shelves []schema.Shelf
	if err := orm.Where("user_id = ?", userID).Order("sort_order ASC, ctime DESC").Find(&shelves).Error; err != nil {
		schema.InternalError(c, err)
		return
	}

	// count books per shelf — single GROUP BY query instead of N+1
	type shelfCount struct {
		ShelfID int64 `gorm:"column:shelf_id"`
		Count   int64 `gorm:"column:count"`
	}
	var counts []shelfCount
	if err := orm.Model(&schema.ShelfBook{}).
		Select("shelf_id, COUNT(*) as count").
		Group("shelf_id").
		Find(&counts).Error; err != nil {
		log.E("count shelf books failed: ", err)
	}
	countMap := make(map[int64]int64)
	for _, sc := range counts {
		countMap[sc.ShelfID] = sc.Count
	}
	for i := range shelves {
		shelves[i].BookCount = int(countMap[shelves[i].ID])
	}

	schema.Success(c, shelves)
}

// createShelfHandle POST /reader/shelves
// @Summary Create shelf
// @Description Create a new book shelf
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body object{name=string,description=string,cover_url=string,sort_order=int} true "Shelf details"
// @Success 200 {object} object{data=schema.Shelf}
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/shelves [post]
func createShelfHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	var req struct {
		Name        string `json:"name" binding:"required"`
		Description string `json:"description"`
		CoverURL    string `json:"cover_url"`
		SortOrder   int    `json:"sort_order"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	shelf := schema.Shelf{
		UserID:      userID,
		Name:        req.Name,
		Description: req.Description,
		CoverURL:    req.CoverURL,
		SortOrder:   req.SortOrder,
	}

	if err := orm.Create(&shelf).Error; err != nil {
		schema.InternalError(c, err)
		return
	}

	schema.Success(c, shelf)
}

// getShelfHandle GET /reader/shelves/:shelf_id
// @Summary Get shelf details
// @Description Get shelf details with its books
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param shelf_id path int true "Shelf ID"
// @Success 200 {object} object{data=object{shelf=schema.Shelf,books=[]schema.Book}}
// @Failure 404 {object} schema.ErrorResponse
// @Router /reader/shelves/{shelf_id} [get]
func getShelfHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	shelfID, err := strconv.ParseInt(c.Param("shelf_id"), 10, 64)
	if err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", "invalid shelf_id")
		return
	}

	var shelf schema.Shelf
	if err := orm.First(&shelf, "id = ? AND user_id = ?", shelfID, userID).Error; err != nil {
		schema.Error(c, http.StatusNotFound, "NOT_FOUND", "Shelf not found")
		return
	}

	var books []schema.Book
	if err := orm.Raw(
		`SELECT b.* FROM books b INNER JOIN shelf_books sb ON b.id = sb.book_id WHERE sb.shelf_id = ? ORDER BY sb.sort_order ASC`,
		shelfID,
	).Scan(&books).Error; err != nil {
		log.E("query shelf books failed: ", err)
	}

	schema.Success(c, gin.H{"shelf": shelf, "books": books})
}

// updateShelfHandle PUT /reader/shelves/:shelf_id
// @Summary Update shelf
// @Description Update shelf details
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param shelf_id path int true "Shelf ID"
// @Param request body object{name=string,description=string,cover_url=string,sort_order=int} true "Shelf details"
// @Success 200 {object} object{data=schema.Shelf}
// @Failure 400 {object} schema.ErrorResponse
// @Failure 404 {object} schema.ErrorResponse
// @Router /reader/shelves/{shelf_id} [put]
func updateShelfHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	shelfID := c.Param("shelf_id")

	var req struct {
		Name        *string `json:"name"`
		Description *string `json:"description"`
		CoverURL    *string `json:"cover_url"`
		SortOrder   *int    `json:"sort_order"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	updates := map[string]any{}
	if req.Name != nil {
		updates["name"] = *req.Name
	}
	if req.Description != nil {
		updates["description"] = *req.Description
	}
	if req.CoverURL != nil {
		updates["cover_url"] = *req.CoverURL
	}
	if req.SortOrder != nil {
		updates["sort_order"] = *req.SortOrder
	}

	if len(updates) > 0 {
		if err := orm.Model(&schema.Shelf{}).Where("id = ? AND user_id = ?", shelfID, userID).Updates(updates).Error; err != nil {
			schema.InternalError(c, err)
			return
		}
	}

	var shelf schema.Shelf
	if err := orm.First(&shelf, "id = ? AND user_id = ?", shelfID, userID).Error; err != nil {
		schema.InternalError(c, err)
		return
	}
	schema.Success(c, shelf)
}

// deleteShelfHandle DELETE /reader/shelves/:shelf_id
// @Summary Delete shelf
// @Description Delete a book shelf
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param shelf_id path int true "Shelf ID"
// @Success 200 {object} object{data=object{id=int,deleted=bool}}
// @Failure 404 {object} schema.ErrorResponse
// @Router /reader/shelves/{shelf_id} [delete]
func deleteShelfHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	shelfID := c.Param("shelf_id")

	err := orm.Transaction(func(tx *gorm.DB) error {
		if err := tx.Where("shelf_id = ?", shelfID).Delete(&schema.ShelfBook{}).Error; err != nil {
			return err
		}
		return tx.Where("id = ? AND user_id = ?", shelfID, userID).Delete(&schema.Shelf{}).Error
	})
	if err != nil {
		schema.InternalError(c, err)
		return
	}

	schema.Success(c, gin.H{"id": shelfID, "deleted": true})
}

// addBooksToShelfHandle POST /reader/shelves/:shelf_id/books
// @Summary Add books to shelf
// @Description Add one or more books to a shelf
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param shelf_id path int true "Shelf ID"
// @Param request body object{book_ids=[]string} true "Book IDs to add"
// @Success 200 {object} object{data=object{added=int}}
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/shelves/{shelf_id}/books [post]
func addBooksToShelfHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	shelfID, err := strconv.ParseInt(c.Param("shelf_id"), 10, 64)
	if err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", "invalid shelf_id")
		return
	}

	// verify ownership
	var count int64
	if err := orm.Model(&schema.Shelf{}).Where("id = ? AND user_id = ?", shelfID, userID).Count(&count).Error; err != nil {
		schema.InternalError(c, err)
		return
	}
	if count == 0 {
		schema.Error(c, http.StatusNotFound, "NOT_FOUND", "Shelf not found")
		return
	}

	var req struct {
		BookIDs []string `json:"book_ids" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	entries := make([]schema.ShelfBook, len(req.BookIDs))
	for i, bid := range req.BookIDs {
		entries[i] = schema.ShelfBook{ShelfID: shelfID, BookID: bid}
	}

	// ignore duplicates
	for i := range entries {
		if err := orm.Where("shelf_id = ? AND book_id = ?", entries[i].ShelfID, entries[i].BookID).FirstOrCreate(&entries[i]).Error; err != nil {
			schema.InternalError(c, err)
			return
		}
	}

	schema.Success(c, gin.H{"added": len(req.BookIDs)})
}

// removeBooksFromShelfHandle DELETE /reader/shelves/:shelf_id/books
// @Summary Remove books from shelf
// @Description Remove one or more books from a shelf
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param shelf_id path int true "Shelf ID"
// @Param request body object{book_ids=[]string} true "Book IDs to remove"
// @Success 200 {object} object{data=object{removed=int}}
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/shelves/{shelf_id}/books [delete]
func removeBooksFromShelfHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	shelfID := c.Param("shelf_id")

	// verify ownership
	var count int64
	if err := orm.Model(&schema.Shelf{}).Where("id = ? AND user_id = ?", shelfID, userID).Count(&count).Error; err != nil {
		schema.InternalError(c, err)
		return
	}
	if count == 0 {
		schema.Error(c, http.StatusNotFound, "NOT_FOUND", "Shelf not found")
		return
	}

	var req struct {
		BookIDs []string `json:"book_ids" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	if err := orm.Where("shelf_id = ? AND book_id IN ?", shelfID, req.BookIDs).Delete(&schema.ShelfBook{}).Error; err != nil {
		schema.InternalError(c, err)
		return
	}

	schema.Success(c, gin.H{"removed": len(req.BookIDs)})
}
