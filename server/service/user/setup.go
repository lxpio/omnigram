package user

import (
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"

	"github.com/hashicorp/golang-lru/v2/expirable"
)

var (
	// orm *gorm.DB

	sessionCache  *expirable.LRU[string, *schema.Session]
	userInfoCache *expirable.LRU[string, *schema.User]
	// kv  schema.KV
)

func init() {
	userInfoCache = expirable.NewLRU[string, *schema.User](15, nil, time.Second*300)
	sessionCache = expirable.NewLRU[string, *schema.Session](15, nil, time.Second*300)

	middleware.Register(middleware.OathMD, OauthMiddleware)
	middleware.Register(middleware.AdminMD, AdminMiddleware)
}

// Setup reg router
func Setup(router *gin.Engine) {

	oauthMD := middleware.Get(middleware.OathMD)
	adminMD := middleware.Get(middleware.AdminMD)

	router.POST("/auth/login", loginHandle)
	router.POST("/auth/token", getAccessTokenHandle)

	router.POST("/auth/logout", oauthMD, logoutHandle)

	router.DELETE("/auth/accounts/:user_id/apikeys/:key_id", oauthMD, deleteAPIKeyHandle)
	router.POST("/auth/accounts/:user_id/apikeys", oauthMD, createAPIKeyHandle)
	router.GET(`/auth/accounts/:user_id/apikeys`, oauthMD, getAPIKeysHandle)

	router.POST(`/auth/accounts/:user_id/reset`, oauthMD, resetPasswordHandle)

	router.GET("/user/userinfo", oauthMD, getUserInfoHandle) //获取用户信息

	router.POST(`/admin/accounts`, oauthMD, adminMD, createAccountHandle)            //创建用户
	router.GET(`/admin/accounts`, oauthMD, adminMD, listAccountHandle)               //获取用户列表
	router.GET(`/admin/accounts/:user_id`, oauthMD, adminMD, getAccountHandle)       //获取用户信息（这里是关联接口获取
	router.DELETE(`/admin/accounts/:user_id`, oauthMD, adminMD, deleteAccountHandle) //删除用户

}
