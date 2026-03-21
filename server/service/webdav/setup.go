package webdav

import (
	"net/http"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
	davlib "golang.org/x/net/webdav"
)

var davHandler *davlib.Handler

// Initialize 初始化 WebDAV 服务
func Initialize() {
	cf := conf.GetConfig()

	booksRoot := cf.EpubOptions.DataPath
	syncRoot := filepath.Join(cf.MetaDataPath, "sync")

	// 确保目录存在
	os.MkdirAll(booksRoot, 0755)
	os.MkdirAll(syncRoot, 0755)

	davHandler = &davlib.Handler{
		Prefix:     "/dav",
		FileSystem: NewOmnigramFS(booksRoot, syncRoot),
		LockSystem: davlib.NewMemLS(),
		Logger: func(r *http.Request, err error) {
			if err != nil {
				log.E("WebDAV ", r.Method, " ", r.URL.Path, " error: ", err)
			}
		},
	}

	log.I("WebDAV initialized: books=", booksRoot, " sync=", syncRoot)
}

// Setup 注册 WebDAV 路由
func Setup(router *gin.Engine) {
	dav := router.Group("/dav", BasicAuthMiddleware())
	dav.Any("/*path", gin.WrapH(davHandler))
}

// BasicAuthMiddleware WebDAV/OPDS 共用的 HTTP Basic Auth
func BasicAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		username, password, ok := c.Request.BasicAuth()
		if !ok {
			c.Header("WWW-Authenticate", `Basic realm="Omnigram"`)
			c.AbortWithStatus(401)
			return
		}

		user, err := schema.FirstUserByAccount(store.Store(), username)
		if err != nil || !user.VerifyPassword(password) {
			c.Header("WWW-Authenticate", `Basic realm="Omnigram"`)
			c.AbortWithStatus(401)
			return
		}

		c.Set(middleware.XUserIDTag, user.ID)
		c.Set(middleware.XUserInfoTag, user)
		c.Next()
	}
}
