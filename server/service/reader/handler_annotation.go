package reader

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"gorm.io/gorm/clause"
)

// listAnnotationsHandle GET /reader/books/:book_id/annotations
func listAnnotationsHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	var annotations []schema.Annotation
	if err := orm.Where("user_id = ? AND book_id = ?", userID, bookID).
		Order("ctime DESC").
		Find(&annotations).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}
	schema.Success(c, annotations)
}

// createAnnotationHandle POST /reader/books/:book_id/annotations
func createAnnotationHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	var ann schema.Annotation
	if err := c.ShouldBindJSON(&ann); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	ann.UserID = userID
	ann.BookID = bookID

	if err := orm.Create(&ann).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}

	schema.Success(c, ann)
}

// updateAnnotationHandle PUT /reader/books/:book_id/annotations/:annotation_id
func updateAnnotationHandle(c *gin.Context) {
	annotationID := c.Param("annotation_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	var existing schema.Annotation
	if err := orm.First(&existing, "id = ? AND user_id = ?", annotationID, userID).Error; err != nil {
		schema.Error(c, http.StatusNotFound, "NOT_FOUND", "Annotation not found")
		return
	}

	var req struct {
		Content      *string `json:"content"`
		SelectedText *string `json:"selected_text"`
		CFI          *string `json:"cfi"`
		PageNumber   *int    `json:"page_number"`
		Position     *string `json:"position"`
		Color        *string `json:"color"`
		Chapter      *string `json:"chapter"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	updates := map[string]any{}
	if req.Content != nil {
		updates["content"] = *req.Content
	}
	if req.SelectedText != nil {
		updates["selected_text"] = *req.SelectedText
	}
	if req.CFI != nil {
		updates["cfi"] = *req.CFI
	}
	if req.PageNumber != nil {
		updates["page_number"] = *req.PageNumber
	}
	if req.Position != nil {
		updates["position"] = *req.Position
	}
	if req.Color != nil {
		updates["color"] = *req.Color
	}
	if req.Chapter != nil {
		updates["chapter"] = *req.Chapter
	}

	if len(updates) > 0 {
		if err := orm.Model(&existing).Updates(updates).Error; err != nil {
			schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
			return
		}
	}

	orm.First(&existing, "id = ?", annotationID)
	schema.Success(c, existing)
}

// deleteAnnotationHandle DELETE /reader/books/:book_id/annotations/:annotation_id
func deleteAnnotationHandle(c *gin.Context) {
	annotationID := c.Param("annotation_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	if err := orm.Where("id = ? AND user_id = ?", annotationID, userID).Delete(&schema.Annotation{}).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}

	schema.Success(c, gin.H{"id": annotationID, "deleted": true})
}

// updateBookRatingHandle PUT /reader/books/:book_id/rating
func updateBookRatingHandle(c *gin.Context) {
	bookID := c.Param("book_id")

	var req struct {
		Rating float32 `json:"rating"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	if err := orm.Model(&schema.Book{}).Where("id = ?", bookID).Update("rating", req.Rating).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}

	schema.Success(c, gin.H{"book_id": bookID, "rating": req.Rating})
}

// syncAnnotationsHandle POST /sync/annotations
func syncAnnotationsHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	var req struct {
		DeviceID     string              `json:"device_id"`
		LastSyncTime int64               `json:"last_sync_time"`
		Annotations  []schema.Annotation `json:"annotations"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	// upsert client annotations
	for i := range req.Annotations {
		req.Annotations[i].UserID = userID
		if req.DeviceID != "" {
			req.Annotations[i].DeviceID = req.DeviceID
		}
		if err := orm.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "id"}},
			DoUpdates: clause.AssignmentColumns([]string{"content", "selected_text", "cfi", "page_number", "position", "color", "chapter", "utime"}),
		}).Create(&req.Annotations[i]).Error; err != nil {
			log.E("sync annotation upsert failed: ", err)
		}
	}

	// return server annotations newer than last_sync_time
	var serverAnnotations []schema.Annotation
	orm.Where("user_id = ? AND utime > ?", userID, req.LastSyncTime).Find(&serverAnnotations)

	schema.Success(c, gin.H{
		"annotations": serverAnnotations,
		"sync_time":   currentTimeMillis(),
	})
}

func currentTimeMillis() int64 {
	return time.Now().UnixMilli()
}
