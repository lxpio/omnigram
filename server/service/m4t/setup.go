package m4t

import (
	"context"
	"errors"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/middleware"
	grpc "google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

var (
	remoteServer  *grpcServer
	cachedSpeaker *Speakers //存储远端m4t-server中 speaker 信息
)

func Initialize(ctx context.Context, cf *conf.Config) {

	remoteServer = &grpcServer{remoteAddr: cf.M4tOptions.RemoteAddr}

	cachedSpeaker = &Speakers{}

}

// Setup reg router
func Setup(router *gin.Engine) {

	// if err := mng.Load(); err != nil {
	// 	log.E(`load model failed: `, err.Error())
	// 	os.Exit(1)
	// }
	oauthMD := middleware.Get(middleware.OathMD)

	// router.POST("/m4t/tts/wav", fakettsHandler)
	router.POST("/m4t/pcm/stream", oauthMD, ttsStreamHandler)

	router.GET("/m4t/tts/speakers", oauthMD, getSpeakersHandler)

	router.POST("/m4t/tts/speakers", oauthMD, postSpeakerHandler)

	router.DELETE("/m4t/tts/speakers/:audio_id", oauthMD, delSpeakerHandler)
}

func Close() {

}

type grpcServer struct {
	remoteAddr string
	sync.RWMutex
}

func (g *grpcServer) update(addr string) error {

	if len(addr) <= 5 {
		return errors.New("address is illegal")
	}
	//try connect to remote
	_, err := grpc.Dial(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return err
	}

	g.Lock()
	defer g.Unlock()
	g.remoteAddr = addr
	return nil
}

func (g *grpcServer) addr() string {

	g.RLock()
	defer g.RUnlock()
	return g.remoteAddr
}
