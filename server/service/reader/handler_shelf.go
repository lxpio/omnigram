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
func listShelvesHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	var shelves []schema.Shelf
	if err := orm.Where("user_id = ?", userID).Order("sort_order ASC, ctime DESC").Find(&shelves).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}

	// count books per shelf
	for i := range shelves {
		var count int64
		orm.Model(&schema.ShelfBook{}).Where("shelf_id = ?", shelves[i].ID).Count(&count)
		shelves[i].BookCount = int(count)
	}

	schema.Success(c, shelves)
}

// createShelfHandle POST /reader/shelves
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
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}

	schema.Success(c, shelf)
}

// getShelfHandle GET /reader/shelves/:shelf_id
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
			schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
			return
		}
	}

	var shelf schema.Shelf
	orm.First(&shelf, "id = ? AND user_id = ?", shelfID, userID)
	schema.Success(c, shelf)
}

// deleteShelfHandle DELETE /reader/shelves/:shelf_id
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
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}

	schema.Success(c, gin.H{"id": shelfID, "deleted": true})
}

// addBooksToShelfHandle POST /reader/shelves/:shelf_id/books
func addBooksToShelfHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	shelfID, err := strconv.ParseInt(c.Param("shelf_id"), 10, 64)
	if err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", "invalid shelf_id")
		return
	}

	// verify ownership
	var count int64
	orm.Model(&schema.Shelf{}).Where("id = ? AND user_id = ?", shelfID, userID).Count(&count)
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
	for _, e := range entries {
		orm.Where("shelf_id = ? AND book_id = ?", e.ShelfID, e.BookID).FirstOrCreate(&e)
	}

	schema.Success(c, gin.H{"added": len(req.BookIDs)})
}

// removeBooksFromShelfHandle DELETE /reader/shelves/:shelf_id/books
func removeBooksFromShelfHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	shelfID := c.Param("shelf_id")

	// verify ownership
	var count int64
	orm.Model(&schema.Shelf{}).Where("id = ? AND user_id = ?", shelfID, userID).Count(&count)
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
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}

	schema.Success(c, gin.H{"removed": len(req.BookIDs)})
}
