package sys

import (
	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/utils"
)

// @Summary Get scan status
// @Description Get the current library scan status (admin only)
// @Tags System
// @Produce json
// @Security BearerAuth
// @Success 200 {object} object{running=bool,count=int,last_scan_time=string}
// @Router /sys/scan/status [get]
func getScanStatusHandle(c *gin.Context) {
	log.I(`获取当前扫描状态数据`)
	states := manager.Status()

	c.JSON(200, states)

}

// @Summary Stop library scan
// @Description Stop a running library scan (admin only)
// @Tags System
// @Produce json
// @Security BearerAuth
// @Success 200 {object} object{running=bool,count=int}
// @Router /sys/scan/stop [post]
func stopScanHandle(c *gin.Context) {

	log.I(`停止当前扫描`)
	manager.Stop()

	c.JSON(200, manager.Status())

}

// @Summary Start library scan
// @Description Start scanning the library directory for books (admin only)
// @Tags System
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body object{refresh=bool,max_thread=int} true "Scan options"
// @Success 200 {object} object{running=bool,count=int}
// @Failure 400 {object} utils.Response
// @Router /sys/scan/run [post]
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
		log.I(`用户登录参数异常`, err.Error())
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	manager.Start(req.MaxThread, req.Refresh)

	c.JSON(200, manager.Status())

}
