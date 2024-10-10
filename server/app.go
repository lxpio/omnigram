package server

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/service"
	"github.com/lxpio/omnigram/server/store"

	"go.uber.org/zap/zapcore"
)

type App struct {
	srv *http.Server //http server

	ctx context.Context
}

// NewAPP with config
func NewAPP() *App {

	return &App{

		// srv: srv,
	}

}

// StartContext 启动
func (m *App) StartContext(ctx context.Context) error {

	m.ctx = ctx

	// 初始化数据库连接
	// store.Initialize(ctx) may be slow，in order not to block the main process，
	// goroutine is used here, so we can use ctrl+c to terminate it
	go func() {

		store.Initialize(ctx)

		service.Initialize(ctx)

		log.I(`init http router...`)
		cf := conf.GetConfig()

		router := m.initGinRoute(cf.LogLevel)

		m.srv = &http.Server{Addr: cf.APIAddr, Handler: router}
		log.I(`HTTP server address: `, cf.APIAddr)
		m.srv.ListenAndServe()

	}()

	return nil

}

// GracefulStop 退出，每个模块实现stop
func (m *App) GracefulStop() {

	if m.srv != nil {
		log.D(`quit http server...`)
		m.srv.Shutdown(m.ctx)
	}
	service.Close()

}

func (m *App) initGinRoute(level zapcore.Level) *gin.Engine {

	if level == zapcore.DebugLevel {
		gin.SetMode(gin.DebugMode)
	} else {
		gin.SetMode(gin.ReleaseMode)
	}

	// log.SetFlags(log.LstdFlags) // gin will disable log flags

	router := gin.Default()

	//这样设置默认可能是不安全的，因为头部字段可以伪造，需求前置的反向代理的xff 确保是对的
	router.SetTrustedProxies([]string{"0.0.0.0/0", "::"})

	service.Setup(router)

	return router
}

func InitServerData(ctx context.Context) {
	//初始化数据库连接
	cf := conf.GetConfig()
	store.InitStore(cf)
	schema.InitData()

}
