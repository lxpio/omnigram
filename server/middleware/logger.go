package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
)

// RequestLogger 请求日志中间件
func RequestLogger() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		c.Next()
		log.I("request ",
			c.Request.Method, " ",
			c.Request.URL.Path, " ",
			c.Writer.Status(), " ",
			time.Since(start),
		)
	}
}
