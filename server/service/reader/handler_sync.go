package reader

import (
	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
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
	Utime int64 `json:"utime" binding:"required,gt=0"`
}

func syncFullHandle(c *gin.Context) {
	req := &FullSyncReq{Limit: 5000}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	recentBooks, err := schema.SyncFullBooks(store.FileStore(), req.Limit, req.Utime, req.FileType)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	c.JSON(200, recentBooks)

}

func syncDeltaHandle(c *gin.Context) {
	req := &FullSyncReq{Limit: 5000}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	recentBooks, err := schema.SyncFullBooks(store.FileStore(), req.Limit, req.Utime, req.FileType)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	c.JSON(200, recentBooks)
}
