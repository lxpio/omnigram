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
// @Summary List annotations
// @Description Get all annotations for a book
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Success 200 {object} object{data=[]schema.Annotation}
// @Router /reader/books/{book_id}/annotations [get]
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
// @Summary Create annotation
// @Description Create a new annotation (highlight, note, or bookmark)
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param request body schema.Annotation true "Annotation details"
// @Success 200 {object} object{data=schema.Annotation}
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/annotations [post]
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
// @Summary Update annotation
// @Description Update an existing annotation
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param annotation_id path int true "Annotation ID"
// @Param request body object{content=string,selected_text=string,cfi=string,page_number=int,position=number,color=string,chapter=string} true "Annotation fields to update"
// @Success 200 {object} object{data=schema.Annotation}
// @Failure 400 {object} schema.ErrorResponse
// @Failure 404 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/annotations/{annotation_id} [put]
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
// @Summary Delete annotation
// @Description Delete an annotation
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param annotation_id path int true "Annotation ID"
// @Success 200 {object} object{data=object{id=int,deleted=bool}}
// @Failure 404 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/annotations/{annotation_id} [delete]
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
// @Summary Rate book
// @Description Set a rating for a book (0-5)
// @Tags Reader
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Param request body object{rating=number} true "Book rating (0-5)"
// @Success 200 {object} object{data=object{book_id=string,rating=number}}
// @Failure 400 {object} schema.ErrorResponse
// @Router /reader/books/{book_id}/rating [put]
func updateBookRatingHandle(c *gin.Context) {
	bookID := c.Param("book_id")

	var req struct {
		Rating float32 `json:"rating"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	if req.Rating < 0 || req.Rating > 5 {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", "Rating must be between 0 and 5")
		return
	}

	if err := orm.Model(&schema.Book{}).Where("id = ?", bookID).Update("rating", req.Rating).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}

	schema.Success(c, gin.H{"book_id": bookID, "rating": req.Rating})
}

// syncAnnotationsHandle POST /sync/annotations
// @Summary Sync annotations
// @Description Synchronize annotations across devices
// @Tags Sync
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body object{device_id=string,last_sync_time=int,annotations=[]schema.Annotation} true "Sync request"
// @Success 200 {object} object{data=object{annotations=[]schema.Annotation,synced=int,sync_time=int}}
// @Failure 400 {object} schema.ErrorResponse
// @Router /sync/annotations [post]
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

	// upsert client annotations — only allow upserting own annotations
	synced := 0
	var failedIndices []int
	for i := range req.Annotations {
		req.Annotations[i].UserID = userID
		if req.DeviceID != "" {
			req.Annotations[i].DeviceID = req.DeviceID
		}
		// If annotation has an ID, verify it belongs to this user before updating
		if req.Annotations[i].ID > 0 {
			var existing schema.Annotation
			if err := orm.First(&existing, "id = ? AND user_id = ?", req.Annotations[i].ID, userID).Error; err != nil {
				// Not found or not owned — create as new instead
				req.Annotations[i].ID = 0
			}
		}
		if err := orm.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "id"}},
			DoUpdates: clause.AssignmentColumns([]string{"content", "selected_text", "cfi", "page_number", "position", "color", "chapter", "utime"}),
		}).Create(&req.Annotations[i]).Error; err != nil {
			log.E("sync annotation upsert failed: ", err)
			failedIndices = append(failedIndices, i)
		} else {
			synced++
		}
	}

	// return server annotations newer than last_sync_time
	var serverAnnotations []schema.Annotation
	orm.Where("user_id = ? AND utime > ?", userID, req.LastSyncTime).Find(&serverAnnotations)

	schema.Success(c, gin.H{
		"annotations":    serverAnnotations,
		"synced":         synced,
		"failed_indices": failedIndices,
		"sync_time":      currentTimeMillis(),
	})
}

func currentTimeMillis() int64 {
	return time.Now().UnixMilli()
}
