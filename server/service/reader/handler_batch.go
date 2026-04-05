package reader

import (
	"os"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"gorm.io/gorm"
)

// batchDeleteHandle POST /reader/books/batch/delete
// @Summary Batch delete books
// @Description Delete multiple books at once (admin only)
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body object{book_ids=[]string,delete_files=bool} true "Books to delete"
// @Success 200 {object} object{data=object{deleted=int}}
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/batch/delete [post]
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
// @Summary Batch tag books
// @Description Add, remove, or set tags on multiple books
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body object{book_ids=[]string,tags=[]string,action=string} true "Batch tag operation (action: add/remove/set)"
// @Success 200 {object} object{data=object{updated=int}}
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/batch/tag [post]
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
				ts := schema.BookTagShip{BookID: bookID, Tag: tag}
				if err := orm.Where("book_id = ? AND tag = ?", bookID, tag).FirstOrCreate(&ts).Error; err != nil {
					log.E("[batch] upsert tag ", tag, " for book ", bookID, ": ", err)
					continue
				}
			}
		case "add":
			for _, tag := range req.Tags {
				ts := schema.BookTagShip{BookID: bookID, Tag: tag}
				if err := orm.Where("book_id = ? AND tag = ?", bookID, tag).FirstOrCreate(&ts).Error; err != nil {
					log.E("[batch] upsert tag ", tag, " for book ", bookID, ": ", err)
					continue
				}
			}
		case "remove":
			orm.Where("book_id = ? AND tag IN ?", bookID, req.Tags).Delete(&schema.BookTagShip{})
		}
		updated++
	}

	schema.Success(c, gin.H{"updated": updated})
}

// batchShelfHandle POST /reader/books/batch/shelf
// @Summary Batch shelf operation
// @Description Add or remove multiple books from a shelf
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body object{book_ids=[]string,shelf_id=int,action=string} true "Batch shelf operation (action: add/remove)"
// @Success 200 {object} object{data=object{updated=int}}
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/batch/shelf [post]
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
			if err := orm.Where("shelf_id = ? AND book_id = ?", req.ShelfID, bookID).FirstOrCreate(&sb).Error; err != nil {
				log.E("[batch] upsert shelf_book shelf=", req.ShelfID, " book=", bookID, ": ", err)
				continue
			}
		case "remove":
			orm.Where("shelf_id = ? AND book_id = ?", req.ShelfID, bookID).Delete(&schema.ShelfBook{})
		}
		updated++
	}

	schema.Success(c, gin.H{"updated": updated})
}
