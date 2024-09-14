package chat

import (
	"context"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
)

var mng *Manager

func Initialize(ctx context.Context, cf *conf.Config) {
	mng = NewModelManager(cf)

}

// Setup reg router
func Setup(router *gin.Engine) {

	if err := mng.Load(); err != nil {
		log.E(`load model failed: `, err.Error())
		os.Exit(1)
	}

	// openAI compatible API endpoint
	router.POST("/v1/chat/completions", chatEndpointHandler())
	router.POST("/chat/completions", chatEndpointHandler())

	router.POST("/v1/edits", editEndpointHandler())
	router.POST("/edits", editEndpointHandler())

	router.POST("/v1/completions", completionEndpointHandler())
	router.POST("/completions", completionEndpointHandler())

	router.POST("/v1/embeddings", embeddingsEndpointHandler())
	router.POST("/embeddings", embeddingsEndpointHandler())

	// /v1/engines/{engine_id}/embeddings

	router.POST("/v1/engines/:model/embeddings", embeddingsEndpointHandler())

	router.GET("/v1/models", listModelsHandler())
	router.GET("/models", listModelsHandler())

}

func Close() {
	if mng != nil {
		log.D(`free all loaded models...`)
		mng.Free()
	}
}
