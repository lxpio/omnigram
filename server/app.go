package server

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/service"
	"github.com/lxpio/omnigram/server/store"

	"go.uber.org/zap/zapcore"
)

type App struct {
	srv *http.Server

	ctx context.Context
}

// NewAPP with config
func NewAPP() *App {
	return &App{}
}

// StartContext 启动
func (m *App) StartContext(ctx context.Context) error {

	m.ctx = ctx

	go func() {

		store.Initialize(ctx)

		service.Initialize(ctx)

		log.I(`init http router...`)
		cf := conf.GetConfig()

		router := m.initGinRoute(cf.LogLevel)

		m.srv = &http.Server{Addr: cf.APIAddr, Handler: router}
		log.I(`HTTP server address: `, cf.APIAddr)

		// 在 goroutine 中启动 HTTP 服务
		go func() {
			if err := m.srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
				log.F(`Server failed to start: `, err)
			}
		}()

		// 等待中断信号
		quit := make(chan os.Signal, 1)
		signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
		<-quit
		log.I(`Shutting down server...`)

		// 给活跃请求 30 秒完成
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		if err := m.srv.Shutdown(shutdownCtx); err != nil {
			log.E(`Server forced to shutdown: `, err)
		}

		service.Close()
		store.Close()
		log.I(`Server exited`)
	}()

	return nil
}

// GracefulStop 退出
func (m *App) GracefulStop() {

	if m.srv != nil {
		log.D(`quit http server...`)
		m.srv.Shutdown(m.ctx)
	}
	service.Close()
	store.Close()
}

func (m *App) initGinRoute(level zapcore.Level) *gin.Engine {

	if level == zapcore.DebugLevel {
		gin.SetMode(gin.DebugMode)
	} else {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.Default()

	router.SetTrustedProxies([]string{"0.0.0.0/0", "::"})

	// 全局中间件
	router.Use(middleware.CORSMiddleware("*"))
	router.Use(middleware.RequestLogger())

	// 健康检查端点（无需认证）
	router.GET("/healthz", func(c *gin.Context) {
		sqlDB, err := store.FileStore().DB()
		if err != nil {
			c.JSON(503, gin.H{"status": "unhealthy", "error": "db connection failed"})
			return
		}
		if err := sqlDB.Ping(); err != nil {
			c.JSON(503, gin.H{"status": "unhealthy", "error": "db ping failed"})
			return
		}
		c.JSON(200, gin.H{"status": "healthy", "version": conf.Version})
	})

	service.Setup(router)

	return router
}

func InitServerData(ctx context.Context) {
	cf := conf.GetConfig()
	store.InitStore(cf)
	schema.InitData()
}
