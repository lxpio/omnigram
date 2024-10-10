package service

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/service/m4t"
	"github.com/lxpio/omnigram/server/service/reader"
	"github.com/lxpio/omnigram/server/service/sys"
	"github.com/lxpio/omnigram/server/service/user"
)

func Initialize(ctx context.Context) {

	sys.Initialize(ctx)

	reader.Initialize(ctx)

	m4t.Initialize(ctx)
}

func Setup(router *gin.Engine) {

	user.Setup(router)
	reader.Setup(router)
	sys.Setup(router)
	m4t.Setup(router)
}

func Close() {

	m4t.Close()
}
