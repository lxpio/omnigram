package middleware

import (
	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
)

// BasicAuthMiddleware provides HTTP Basic Auth for OPDS and similar endpoints.
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

		c.Set(XUserIDTag, user.ID)
		c.Set(XUserInfoTag, user)
		c.Next()
	}
}
