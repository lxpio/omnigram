package sys

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
)

var (
	manager *ScannerManager
)

func Initialize(ctx context.Context) {
	log.I(`Initialize sys service`)

	manager, _ = NewScannerManager(ctx)
}

// Setup reg router
func Setup(router *gin.Engine) {

	oauthMD := middleware.Get(middleware.OathMD)

	adminMD := middleware.Get(middleware.AdminMD)

	router.GET("/sys/ping", getSysPingHandle) //获取系统心跳

	router.GET("/sys/info", oauthMD, getSysInfoHandle) //获取系统信息

	router.PUT("/sys/info", oauthMD, adminMD, updateSysInfoHandle) //更新系统信息 TODO

	router.GET("/sys/scan/status", oauthMD, adminMD, getScanStatusHandle) //获取扫描状态
	router.POST("/sys/scan/stop", oauthMD, adminMD, stopScanHandle)
	router.POST("/sys/scan/run", oauthMD, adminMD, runScanHandle)

}
