package middleware

import (
	"github.com/gin-gonic/gin"
)

const (
	XUserOauthListTag = `x-user-oauth-list`
	XUserOauthTag     = `x-user-list-tag`
	XUserInfoTag      = `x-user-info-key`
	XUserIDTag        = `x-user-id-key`
	XLangTag          = `x-lang-tag`

	UserSessionTag = `omni-session-id`

	OathMD  = `oauth`
	AdminMD = `admin`
)

var middlewares map[string]gin.HandlerFunc

func init() {
	middlewares = make(map[string]gin.HandlerFunc)
}

func Register(name string, middleware gin.HandlerFunc) {
	middlewares[name] = middleware
}

func Get(name string) gin.HandlerFunc {
	return middlewares[name]
}
