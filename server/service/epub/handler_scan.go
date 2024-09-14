package epub

import (
	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/utils"
)

// ScanStatus 获取当前扫描状态
func getScanStatusHandle(c *gin.Context) {
	log.I(`获取当前扫描状态数据`)
	states := manager.Status()

	c.JSON(200, utils.SUCCESS.WithData(states))

}

// stopScan 停止当前扫描
func stopScanHandle(c *gin.Context) {

	log.I(`停止当前扫描`)
	manager.Stop()

	c.JSON(200, utils.SUCCESS.WithData(manager.Status()))

}

// runScanHandle 执行目录扫描
func runScanHandle(c *gin.Context) {

	if manager.IsRunning() {
		log.I(`扫描未完成，放弃执行...`)
		c.JSON(200, utils.ErrScannerIsRunning)
		return
	}

	req := &struct {
		Refresh   bool `json:"refresh"`
		MaxThread int  `json:"max_thread" binding:"gte=1"`
	}{}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	manager.Start(req.MaxThread, req.Refresh)

	c.JSON(200, utils.SUCCESS.WithData(manager.Status()))

}
