package service

import (
	"context"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/api/service/chat"
	"github.com/lxpio/omnigram/server/api/service/epub"
	"github.com/lxpio/omnigram/server/api/service/m4t"
	"github.com/lxpio/omnigram/server/api/service/sys"
	"github.com/lxpio/omnigram/server/api/service/user"
	"github.com/lxpio/omnigram/server/api/conf"
	"github.com/lxpio/omnigram/server/api/log"
)

func Initialize(ctx context.Context, cf *conf.Config) {
	user.Initialize(ctx, cf)
	epub.Initialize(ctx, cf)
	chat.Initialize(ctx, cf)
	sys.Initialize(ctx, cf)
	m4t.Initialize(ctx, cf)
}

func Setup(router *gin.Engine) {

	user.Setup(router)
	chat.Setup(router)
	epub.Setup(router)
	sys.Setup(router)
	m4t.Setup(router)
}

func Close() {
	user.Close()
	chat.Close()
	epub.Close()
	sys.Close()
	m4t.Close()
}

func InitData(cf *conf.Config) error {
	if err := epub.InitData(cf); err != nil {
		log.E(err)
		os.Exit(1)
	}

	if err := user.InitData(cf); err != nil {
		log.E(err)
		os.Exit(1)
	}
	return nil
}
