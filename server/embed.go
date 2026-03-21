package server

import (
	"embed"
	"io/fs"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/schema"
)

//go:embed web/dist/*
var webUI embed.FS

func serveWebUI(c *gin.Context) {
	path := c.Request.URL.Path

	// 尝试提供静态文件（JS/CSS/图片）
	f, err := webUI.Open("web/dist" + path)
	if err == nil {
		f.Close()
		sub, _ := fs.Sub(webUI, "web/dist")
		c.FileFromFS(path, http.FS(sub))
		return
	}

	// SPA fallback — 所有路径返回 index.html
	indexFile, _ := webUI.ReadFile("web/dist/index.html")
	c.Data(200, "text/html", indexFile)
}

// registerWebUI 注册 Web UI 的 NoRoute 处理器
func registerWebUI(router *gin.Engine) {
	// API 前缀列表 — 这些路径不走 SPA fallback
	apiPrefixes := []string{"/auth/", "/reader/", "/admin/", "/sys/", "/m4t/", "/dav/", "/opds/", "/img/", "/user/", "/sync/", "/healthz"}

	router.NoRoute(func(c *gin.Context) {
		p := c.Request.URL.Path
		for _, prefix := range apiPrefixes {
			if strings.HasPrefix(p, prefix) {
				schema.Error(c, 404, "NOT_FOUND", "API endpoint not found")
				return
			}
		}
		serveWebUI(c)
	})
}
