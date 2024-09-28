package user

import (
	"net"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/service/user/schema"
	"github.com/lxpio/omnigram/server/utils"
)

const (
	// apiKeyPrefix  = "api-key:"
	cacheKeyUser    = "/user/apikeys/"
	cacheKeySession = `/user/sessions/`
)

// OauthMiddleware 认证中间件，如果seesion 合法将用户ID存入上下文
func OauthMiddleware(c *gin.Context) {

	//获取到了APIKEY，校验APIKEY合法性
	if apiKey := getAPIKey(c); apiKey != `` {

		key := cacheKeyUser + apiKey

		if info, ok := userInfoCache.Get(key); ok {

			c.Set(middleware.XUserIDTag, info.ID)
			c.Set(middleware.XUserInfoTag, info)
			c.Next()
			return

		}

		handleSession(c, apiKey)
		return
		//校验APIKey合法性
		// if token, err := schema.FirstTokenByAPIKey(orm, apiKey); err == nil {

		// 	if info, err1 := schema.FirstUserByID(orm, token.UserID); err1 == nil {
		// 		//Credential 信息需要抹掉
		// 		info.Credential = ``
		// 		userInfoCache.Add(key, info)
		// 		c.Set(middleware.XUserIDTag, info.ID)
		// 		c.Set(middleware.XUserInfoTag, info)
		// 		c.Next()
		// 		return
		// 	}

		// }

	} else {
		//获取到了session，校验session合法性
		if session := getSession(c); session != `` {
			handleSession(c, session)

		}
	}

	c.AbortWithStatusJSON(http.StatusUnauthorized, utils.ErrUnauthorized)
	//校验session 合法性,这了没有做细节的处理，因为当前主要以APIKey为准.
	// handleSession(c)
}

func handleSession(c *gin.Context, sess string) {

	session, err := getSessionData(sess)
	if err != nil {
		log.E(`session 获取失败: `, err)
		c.AbortWithStatusJSON(http.StatusUnauthorized, utils.ErrUnauthorized)
		return
	}
	//校验session 合法性
	//获取相对时间
	diff := (time.Now().Unix() - session.UTime)
	// diff := time.Since(session.UTime) / 1000 / 1000 / 1000

	if diff-int64(session.Duration) > 0 {

		log.E(`session has expired `, session.Session)
		// 删除
		c.SetCookie(middleware.UserSessionTag, "", -1, "/", "", true, true)
		// session.Clean(srv.orm)
		c.AbortWithStatusJSON(http.StatusUnauthorized, utils.ErrSessionTimeout)
		return
	}

	//session 有效时间小于1分钟 刷新session
	if diff > 60 {

		if err := orm.Table(`sessions`).Where(`id = ?`, session.Session).Update(`utime`, time.Now()).Error; err != nil {
			log.E("刷新session失败: ", err)
		}
		sessionCache.Remove(cacheKeySession + session.Session)
		log.D("刷新session")

	}

	c.Set(middleware.XUserInfoTag, session.UserInfo)
	c.Set(middleware.XUserIDTag, session.UserInfo.ID)
	c.Set(middleware.UserSessionTag, session.Session)

	c.Next()
}

func AdminMiddleware(c *gin.Context) {

	info, ok := c.Get(middleware.XUserInfoTag)
	if !ok {
		c.AbortWithStatusJSON(http.StatusForbidden, utils.ErrForbidden)
		return
	}

	user, ok := info.(*schema.User)

	if !ok || user.RoleID != 1 {

		log.D("userID: ", user.RoleID)
		c.AbortWithStatusJSON(http.StatusForbidden, utils.ErrForbidden)
		return
	}
	//简化处理，user ID 为1的即管理员
	log.D("userID: ", user.RoleID)

	c.Next()

}

// parseSessionUser 获取session 关联的用户信息，
func getSessionData(id string) (*schema.Session, error) {

	key := cacheKeySession + id

	if raw, ok := sessionCache.Get(key); ok {
		log.D(`hit cachekey: `, key)
		return raw, nil
	}

	sess, err := schema.FirstSessionByID(orm, id)

	if err == nil {
		sessionCache.Add(key, sess)
	}

	return sess, nil

}

func getSession(c *gin.Context) string {
	id, err := c.Cookie(middleware.UserSessionTag)
	if err != nil {
		return ``
	}
	return id
}

func getAPIKey(c *gin.Context) string {

	//get  Bearer token Authorization
	authHeader := c.GetHeader("Authorization")

	// Check if the Authorization header is empty or doesn't start with "Bearer "
	if authHeader == "" || len(authHeader) < 7 || authHeader[:7] != "Bearer " {
		return ""

	}
	return authHeader[7:]

}

// func CORSMiddleware(c *gin.Context) {

// 	c.Header("Access-Control-Allow-Origin", "192.168.1.201")
// 	// c.Header("Access-Control-Allow-Credentials", "true")
// 	// c.Header("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
// 	// c.Header("Access-Control-Allow-Methods", "POST,HEAD,PATCH, OPTIONS, GET, PUT")

// 	if c.Request.Method == "OPTIONS" {
// 		c.AbortWithStatus(204)
// 		return
// 	}

// 	c.Next()
// }

func getHostName(c *gin.Context) string {
	host, _, err := net.SplitHostPort(c.Request.Host)

	if err != nil {
		log.I(`区分端口失败： `, c.Request.Host)
		host = c.Request.Host
	}

	return host
}
