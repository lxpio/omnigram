package reader

import (
	"io"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
)

// FullSyncReq
type FullSyncReq struct {
	// 文件类型，文件类型
	FileType schema.FileType `json:"file_type,omitempty"`
	// 限制大小，数量限制
	Limit int64 `json:"limit" binding:"required,gte=0"`
	// 用户ID，用户ID
	UserID int64 `json:"user_id,omitempty"`
	// 更新时间，文件更新的时间
	Util int64 `json:"until" binding:"required,gt=0"`
}

// @Summary Full data sync
// @Description Synchronize all book data via SSE stream
// @Tags Sync
// @Accept json
// @Produce text/event-stream
// @Security BearerAuth
// @Param request body object{file_type=string,limit=int,until=int} true "Sync parameters"
// @Success 200 {object} object{books=[]schema.Book}
// @Router /sync/full [post]
func syncFullHandle(c *gin.Context) {
	req := &FullSyncReq{Limit: 5000}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	c.Header("Access-Control-Allow-Origin", "*")
	c.Header("Access-Control-Expose-Headers", "Content-Type")

	c.Header("Content-Type", "text/event-stream")
	c.Header("Cache-Control", "no-cache")
	c.Header("Connection", "keep-alive")
	c.Writer.Header().Set("Transfer-Encoding", "chunked")

	bookChan, err := schema.SyncFullBooks(store.FileStore(), req.Limit, req.Util, req.FileType)
	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	batchIdx := 0
	c.Stream(func(w io.Writer) bool {
		select {
		case books, ok := <-bookChan:
			if !ok {
				return false
			}
			// Include batch index for resume support (R-2)
			c.SSEvent("message", gin.H{"batch": batchIdx, "books": books})
			batchIdx++
			// Flush after each batch to prevent backpressure buildup (P-2)
			c.Writer.Flush()
			return true
		case <-c.Request.Context().Done():
			// Client disconnected — stop streaming
			return false
		}
	})

}

// DeltaSyncReq
type DeltaSyncReq struct {
	// 文件类型，文件类型
	FileType schema.FileType `json:"file_type,omitempty"`
	// 限制大小，数量限制
	Limit int64 `json:"limit" binding:"required,gte=0"`
	// 用户ID，用户ID
	UserID int64 `json:"user_id,omitempty"`
	// 更新时间，文件更新的时间
	Utime int64 `json:"utime" binding:"required,gt=0"`
}

// @Summary Delta data sync
// @Description Get books updated since a given timestamp
// @Tags Sync
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body object{file_type=string,limit=int,utime=int} true "Delta sync parameters"
// @Success 200 {object} object{books=[]schema.Book}
// @Router /sync/delta [post]
func syncDeltaHandle(c *gin.Context) {
	req := &DeltaSyncReq{Limit: 5000}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	recentBooks, err := schema.SyncDeltaBooks(store.FileStore(), req.Utime, req.FileType)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	c.JSON(200, recentBooks)
}

// batchPushBooksHandle POST /sync/books/batch
// @Summary Batch push book metadata
// @Description Push multiple book metadata updates in a single request (reduces N+1 HTTP calls)
// @Tags Sync
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body object{books=[]object} true "Batch book updates"
// @Success 200 {object} object{synced=int,failed_indices=[]int,server_time=int}
// @Failure 400 {object} schema.ErrorResponse
// @Router /sync/books/batch [post]
func batchPushBooksHandle(c *gin.Context) {
	var req struct {
		Books []schema.Book `json:"books"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	synced := 0
	var failedIndices []int
	for i, book := range req.Books {
		if err := orm.Model(&schema.Book{}).Where("id = ?", book.ID).
			Updates(map[string]interface{}{
				"title":       book.Title,
				"author":      book.Author,
				"description": book.Description,
				"rating":      book.Rating,
			}).Error; err != nil {
			log.E("batch push book failed: ", book.ID, err)
			failedIndices = append(failedIndices, i)
		} else {
			synced++
		}
	}

	// Audit log
	logSyncEvent(c, "batch_push_books", synced, len(failedIndices))

	c.JSON(200, gin.H{
		"synced":         synced,
		"failed_indices": failedIndices,
		"server_time":    time.Now().UnixMilli(),
	})
}

// syncVersionHandle GET /sync/version
// @Summary Get sync protocol version
// @Description Returns the server sync protocol version for client compatibility checking
// @Tags Sync
// @Produce json
// @Security BearerAuth
// @Success 200 {object} object{version=string,min_client_version=string,features=[]string}
// @Router /sync/version [get]
func syncVersionHandle(c *gin.Context) {
	c.JSON(200, gin.H{
		"version":            "2",
		"min_client_version": "1",
		"features": []string{
			"delta_sync",
			"batch_push",
			"server_time",
			"failed_indices",
			"tombstone_delete",
		},
	})
}

// logSyncEvent records a sync operation for audit purposes.
func logSyncEvent(c *gin.Context, action string, synced int, failed int) {
	userID := c.GetInt64(middleware.XUserIDTag)
	log.I("sync_audit",
		"user_id=", userID,
		"action=", action,
		"synced=", synced,
		"failed=", failed,
		"ip=", c.ClientIP(),
		"device=", c.GetHeader("x-device-id"),
	)
}
