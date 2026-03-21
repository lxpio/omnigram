package reader

import (
	"os"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/schema"
	"gorm.io/gorm"
)

// batchDeleteHandle POST /reader/books/batch/delete
func batchDeleteHandle(c *gin.Context) {
	var req struct {
		BookIDs     []string `json:"book_ids" binding:"required"`
		DeleteFiles bool     `json:"delete_files"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, 400, "VALIDATION_ERROR", err.Error())
		return
	}

	var deleted int
	for _, bookID := range req.BookIDs {
		book, err := schema.FirstBookById(orm, bookID)
		if err != nil {
			continue
		}

		err = orm.Transaction(func(tx *gorm.DB) error {
			if err := tx.Where("book_id = ?", bookID).Delete(&schema.BookTagShip{}).Error; err != nil {
				return err
			}
			if err := tx.Where("book_id = ?", bookID).Delete(&schema.ReadProgress{}).Error; err != nil {
				return err
			}
			if err := tx.Where("book_id = ?", bookID).Delete(&schema.FavBook{}).Error; err != nil {
				return err
			}
			if err := tx.Where("book_id = ?", bookID).Delete(&schema.ShelfBook{}).Error; err != nil {
				return err
			}
			if err := tx.Where("user_id IS NOT NULL AND book_id = ?", bookID).Delete(&schema.Annotation{}).Error; err != nil {
				return err
			}
			return tx.Delete(book).Error
		})
		if err != nil {
			continue
		}

		if req.DeleteFiles && book.Path != "" {
			os.Remove(book.Path)
		}
		deleted++
	}

	schema.Success(c, gin.H{"deleted": deleted})
}

// batchTagHandle POST /reader/books/batch/tag
func batchTagHandle(c *gin.Context) {
	var req struct {
		BookIDs []string `json:"book_ids" binding:"required"`
		Tags    []string `json:"tags" binding:"required"`
		Action  string   `json:"action" binding:"required"` // "add", "remove", "set"
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, 400, "VALIDATION_ERROR", err.Error())
		return
	}

	var updated int
	for _, bookID := range req.BookIDs {
		switch req.Action {
		case "set":
			orm.Where("book_id = ?", bookID).Delete(&schema.BookTagShip{})
			for _, tag := range req.Tags {
				orm.FirstOrCreate(&schema.BookTagShip{BookID: bookID, Tag: tag}, schema.BookTagShip{BookID: bookID, Tag: tag})
			}
		case "add":
			for _, tag := range req.Tags {
				orm.FirstOrCreate(&schema.BookTagShip{BookID: bookID, Tag: tag}, schema.BookTagShip{BookID: bookID, Tag: tag})
			}
		case "remove":
			orm.Where("book_id = ? AND tag IN ?", bookID, req.Tags).Delete(&schema.BookTagShip{})
		}
		updated++
	}

	schema.Success(c, gin.H{"updated": updated})
}

// batchShelfHandle POST /reader/books/batch/shelf
func batchShelfHandle(c *gin.Context) {
	var req struct {
		BookIDs []string `json:"book_ids" binding:"required"`
		ShelfID int64    `json:"shelf_id" binding:"required"`
		Action  string   `json:"action" binding:"required"` // "add" or "remove"
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, 400, "VALIDATION_ERROR", err.Error())
		return
	}

	var updated int
	for _, bookID := range req.BookIDs {
		switch req.Action {
		case "add":
			sb := schema.ShelfBook{ShelfID: req.ShelfID, BookID: bookID}
			orm.Where("shelf_id = ? AND book_id = ?", req.ShelfID, bookID).FirstOrCreate(&sb)
		case "remove":
			orm.Where("shelf_id = ? AND book_id = ?", req.ShelfID, bookID).Delete(&schema.ShelfBook{})
		}
		updated++
	}

	schema.Success(c, gin.H{"updated": updated})
}
