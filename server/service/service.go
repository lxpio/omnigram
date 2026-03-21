package service

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/service/ai"
	"github.com/lxpio/omnigram/server/service/opds"
	"github.com/lxpio/omnigram/server/service/reader"
	"github.com/lxpio/omnigram/server/service/sys"
	"github.com/lxpio/omnigram/server/service/tts"
	"github.com/lxpio/omnigram/server/service/user"
	"github.com/lxpio/omnigram/server/service/webdav"
)

func Initialize(ctx context.Context) {

	sys.Initialize(ctx)

	reader.Initialize(ctx)

	tts.Initialize(ctx)

	webdav.Initialize()
}

func Setup(router *gin.Engine) {

	user.Setup(router)
	reader.Setup(router)
	sys.Setup(router)
	tts.Setup(router)
	webdav.Setup(router)
	opds.Setup(router)
	ai.Setup(router)
}

func Close() {

	tts.Close()
}
