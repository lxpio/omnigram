package sys

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/middleware"
)

var gcf *conf.Config

func Initialize(ctx context.Context, cf *conf.Config) {
	gcf = cf
}

// Setup reg router
func Setup(router *gin.Engine) {

	// if err := mng.Load(); err != nil {
	// 	log.E(`load model failed: `, err.Error())
	// 	os.Exit(1)
	// }

	oauthMD := middleware.Get(middleware.OathMD)

	adminMD := middleware.Get(middleware.AdminMD)

	router.GET("/sys/info", oauthMD, getSysInfoHandle)

	router.PATCH("/sys/info", oauthMD, adminMD, updateSysInfoHandle)

}

func Close() {

}
