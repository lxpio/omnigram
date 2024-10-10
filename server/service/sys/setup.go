package sys

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"

	"github.com/lxpio/omnigram/server/store"
	"gorm.io/gorm"
)

var (
	orm     *gorm.DB
	kv      store.KV
	manager *ScannerManager
)

func Initialize(ctx context.Context) {
	log.I(`Initialize sys service`)
	orm = store.FileStore()
	kv = store.GetKV()
	cf := conf.GetConfig()
	manager, _ = NewScannerManager(ctx, cf, kv, orm)
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

	router.PUT("/sys/info", oauthMD, adminMD, updateSysInfoHandle) //更新系统信息 TODO

	router.GET("/sys/scan/status", oauthMD, adminMD, getScanStatusHandle) //获取扫描状态
	router.POST("/sys/scan/stop", oauthMD, adminMD, stopScanHandle)
	router.POST("/sys/scan/run", oauthMD, adminMD, runScanHandle)

}
