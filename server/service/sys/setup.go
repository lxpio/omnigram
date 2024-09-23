package sys

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/service/epub/selfhost"
	"github.com/lxpio/omnigram/server/service/model"
	"github.com/lxpio/omnigram/server/store"
	"gorm.io/gorm"
)

var (
	gcf     *conf.Config
	orm     *gorm.DB
	kv      store.KV
	manager *selfhost.ScannerManager
)

// func Initialize(ctx context.Context, cf *conf.Config) {

// }

func Initialize(ctx context.Context, cf *conf.Config) {

	gcf = cf

	model.Initialize(ctx, cf)

}

func GetManager() *selfhost.ScannerManager {
	return manager
}

// Setup reg router
func Setup(router *gin.Engine) {

	// if err := mng.Load(); err != nil {
	// 	log.E(`load model failed: `, err.Error())
	// 	os.Exit(1)
	// }

	oauthMD := middleware.Get(middleware.OathMD)

	adminMD := middleware.Get(middleware.AdminMD)

	router.GET("/sys/ping", getSysPingHandle) //获取系统心跳

	router.GET("/sys/info", oauthMD, getSysInfoHandle) //获取系统信息

	router.PUT("/sys/info", oauthMD, adminMD, updateSysInfoHandle) //更新系统信息

	router.GET("/scan/status", adminMD, getScanStatusHandle) //获取扫描状态
	router.POST("/scan/stop", adminMD, stopScanHandle)
	router.POST("/scan/run", adminMD, runScanHandle)

}

func Close() {

}
