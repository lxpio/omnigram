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

	schema.Success(c, book)
}

// deleteBookHandle 删除书籍 DELETE /reader/books/:book_id
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
		tx.Where("book_id = ?", bookID).Delete(&schema.BookTagShip{})
		tx.Where("book_id = ?", bookID).Delete(&schema.ReadProgress{})
		tx.Where("book_id = ?", bookID).Delete(&schema.FavBook{})
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
