package server

import (
	"context"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/service"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"

	"go.uber.org/zap/zapcore"
)

type App struct {
	cf *conf.Config

	srv *http.Server //http server

	ctx context.Context
}

// NewAPPWithConfig with config
func NewAPPWithConfig(cf *conf.Config) *App {

	return &App{

		cf: cf,

		// srv: srv,
	}

}

// StartContext 启动
func (m *App) StartContext(ctx context.Context) error {

	m.ctx = ctx

	// m.mng.Load() may be slow，in order not to block the main process，
	// goroutine is used here, so we can use ctrl+c to terminate it
	go func() {

		var dbctx context.Context

		// 如果数据库为sqlite3，则将不同的模块子目录创建额外的sqlite3文件
		if m.cf.DBOption.Driver == store.DRSQLite {
			dbctx = m.ctx
		} else {
			db, err := store.OpenDB(m.cf.DBOption)
			if err != nil {
				log.E(`open db failed`, err)
				os.Exit(1)
			}
			dbctx = context.WithValue(m.ctx, utils.DBContextKey, db)
		}

		service.Initialize(dbctx, m.cf)

		log.I(`init http router...`)

		router := m.initGinRoute()

		m.srv = &http.Server{Addr: m.cf.APIAddr, Handler: router}
		log.I(`HTTP server address: `, m.cf.APIAddr)
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

func (m *App) initGinRoute() *gin.Engine {

	if m.cf.LogLevel == zapcore.DebugLevel {
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

func InitServerData(cf *conf.Config) {
	//初始化数据库连接

	service.InitData(cf)

}
