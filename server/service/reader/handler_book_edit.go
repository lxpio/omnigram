package reader

import (
	"context"
	"io"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
	"gorm.io/gorm"
)

// updateBookHandle 编辑书籍元数据 PUT /reader/books/:book_id
// @Summary Update book metadata
// @Description Update book metadata fields (title, author, description, etc.)
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param request body object{title=string,author=string,description=string,publisher=string,language=string,series=string,series_index=int,publish_date=string,rating=number,tags=[]string} true "Book metadata"
// @Success 200 {object} object{data=schema.Book}
// @Failure 400 {object} schema.ErrorResponse
// @Failure 404 {object} schema.ErrorResponse
// @Router /reader/books/{book_id} [put]
func updateBookHandle(c *gin.Context) {
	bookID := c.Param("book_id")

	var req struct {
		Title       *string   `json:"title"`
		Author      *string   `json:"author"`
		Description *string   `json:"description"`
		Publisher   *string   `json:"publisher"`
		Language    *string   `json:"language"`
		Series      *string   `json:"series"`
		SeriesIndex *string   `json:"series_index"`
		PublishDate *string   `json:"publish_date"`
		Rating      *float32  `json:"rating"`
		Tags        *[]string `json:"tags"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, 400, "VALIDATION_ERROR", err.Error())
		return
	}

	book, err := schema.FirstBookById(orm, bookID)
	if err != nil {
		schema.Error(c, 404, "NOT_FOUND", "Book not found")
		return
	}

	// 使用指针字段实现 partial update（nil = 不更新）
	updates := map[string]any{}
	if req.Title != nil {
		updates["title"] = *req.Title
	}
	if req.Author != nil {
		updates["author"] = *req.Author
	}
	if req.Description != nil {
		updates["description"] = *req.Description
	}
	if req.Publisher != nil {
		updates["publisher"] = *req.Publisher
	}
	if req.Language != nil {
		updates["language"] = *req.Language
	}
	if req.Series != nil {
		updates["series"] = *req.Series
	}
	if req.SeriesIndex != nil {
		updates["series_index"] = *req.SeriesIndex
	}
	if req.PublishDate != nil {
		updates["pubdate"] = *req.PublishDate
	}
	if req.Rating != nil {
		updates["rating"] = *req.Rating
	}

	if len(updates) > 0 {
		if err := orm.Model(book).Updates(updates).Error; err != nil {
			schema.Error(c, 500, "DB_ERROR", err.Error())
			return
		}
	}

	// 标签更新（如果提供）
	if req.Tags != nil {
		if err := updateBookTags(orm, bookID, *req.Tags); err != nil {
			log.E("update book tags failed: ", err)
		}
	}

	// 重新获取更新后的数据
	updatedBook, _ := schema.FirstBookById(orm, bookID)
	schema.Success(c, updatedBook)
}

// deleteBookHandle 删除书籍 DELETE /reader/books/:book_id
// @Summary Delete book
// @Description Delete a book and optionally its file
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param delete_file query bool false "Also delete the physical file" default(false)
// @Success 200 {object} object{data=object{id=string,deleted=bool}}
// @Failure 404 {object} schema.ErrorResponse
// @Router /reader/books/{book_id} [delete]
func deleteBookHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	deleteFile := c.Query("delete_file") == "true"

	book, err := schema.FirstBookById(orm, bookID)
	if err != nil {
		schema.Error(c, 404, "NOT_FOUND", "Book not found")
		return
	}

	// 事务包裹关联数据删除
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
		return tx.Delete(book).Error
	})
	if err != nil {
		schema.Error(c, 500, "DB_ERROR", err.Error())
		return
	}

	// 文件删除放在事务外（文件操作不可回滚）
	if deleteFile && book.Path != "" {
		os.Remove(book.Path)
	}

	// 删除封面
	store.GetKV().Delete(context.TODO(), schema.GetCoverBucket(book.Identifier), book.CoverURL)

	schema.Success(c, gin.H{"id": bookID, "deleted": true})
}

// uploadCoverHandle 上传封面 PUT /reader/books/:book_id/cover
// @Summary Upload book cover
// @Description Upload a custom cover image for a book (max 5MB, jpg/png/webp/gif)
// @Tags Reader
// @Accept multipart/form-data
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param cover formData file true "Cover image file"
// @Success 200 {object} object{data=object{cover_url=string}}
// @Failure 400 {object} schema.ErrorResponse
// @Failure 404 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/cover [put]
func uploadCoverHandle(c *gin.Context) {
	bookID := c.Param("book_id")

	book, err := schema.FirstBookById(orm, bookID)
	if err != nil {
		schema.Error(c, 404, "NOT_FOUND", "Book not found")
		return
	}

	file, header, err := c.Request.FormFile("cover")
	if err != nil {
		schema.Error(c, 400, "VALIDATION_ERROR", "No cover file provided")
		return
	}
	defer file.Close()

	// 限制封面大小 5MB
	if header.Size > 5*1024*1024 {
		schema.Error(c, 400, "VALIDATION_ERROR", "Cover file too large (max 5MB)")
		return
	}

	// 验证文件类型
	ct := header.Header.Get("Content-Type")
	if ct != "" && ct != "image/jpeg" && ct != "image/png" && ct != "image/webp" && ct != "image/gif" {
		schema.Error(c, 400, "VALIDATION_ERROR", "Invalid image type (allowed: jpeg, png, webp, gif)")
		return
	}

	data, err := io.ReadAll(file)
	if err != nil {
		schema.Error(c, 500, "IO_ERROR", err.Error())
		return
	}

	kv := store.GetKV()
	bucket := schema.GetCoverBucket(book.Identifier)

	if err := kv.CreateBucket(context.TODO(), bucket); err != nil {
		log.E("create cover bucket failed: ", err)
	}

	coverKey := book.CoverKey()
	if err := kv.Put(context.TODO(), bucket, coverKey, data); err != nil {
		schema.Error(c, 500, "STORAGE_ERROR", err.Error())
		return
	}

	// 更新封面 URL
	if book.CoverURL != coverKey {
		orm.Model(book).Update("cover_url", coverKey)
	}

	schema.Success(c, gin.H{"cover_url": coverKey})
}

// updateBookTags 更新书籍标签
func updateBookTags(db *gorm.DB, bookID string, tags []string) error {
	return db.Transaction(func(tx *gorm.DB) error {
		// 删除旧标签
		tx.Where("book_id = ?", bookID).Delete(&schema.BookTagShip{})

		// 插入新标签
		if len(tags) > 0 {
			newTags := make([]schema.BookTagShip, len(tags))
			for i, tag := range tags {
				newTags[i] = schema.BookTagShip{BookID: bookID, Tag: tag}
			}
			return tx.Create(&newTags).Error
		}
		return nil
	})
}
