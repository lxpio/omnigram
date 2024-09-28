package user

import (
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/service/user/schema"
	"github.com/lxpio/omnigram/server/utils"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

func loginHandle(c *gin.Context) {

	req := struct {
		UserName  string `json:"account" binding:"required"`
		Password  string `json:"password" binding:"required"`
		ClientID  string `json:"client_id"`
		GrantType string `json:"grant_type"`
	}{}

	if err := c.ShouldBind(&req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(400, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	u, err := schema.FirstUserByAccount(orm, req.UserName)

	if err != nil {
		log.E(`用户未找到用户失败：`, err.Error())
		c.JSON(404, utils.ErrGetTokens)
		return
	}

	if ok := u.VerifyPassword(req.Password); !ok {
		log.E(`用户或者账号密码不对`, u.Name)
		c.JSON(404, utils.ErrGetTokens)
		return
	}

	session := &schema.Session{
		Session:     "",
		UserID:      u.ID,
		RemoteIP:    c.ClientIP(),
		UserAgent:   c.GetHeader(`User-Agent`),
		DeviceID:    req.ClientID,
		DeviceModel: c.GetHeader(`x-device-model`),
		DeviceType:  c.GetHeader(`x-device-type`),
		DistrictId:  0,
		FromUrl:     "",
		Duration:    time.Minute * 60,
		UserInfo:    u,
	}

	if err := session.Save(orm); err != nil {
		log.E(`保存session失败：`, err.Error())
		c.JSON(500, utils.ErrSaveToken)

	}

	sessionCache.Add(cacheKeySession+session.Session, session)

	c.SetCookie(middleware.UserSessionTag, session.Session, 0, "/", getHostName(c), true, true)

	c.JSON(200, utils.SUCCESS)
}

func logoutHandle(c *gin.Context) {

	sessin := c.GetString(middleware.UserSessionTag)

	//delete session from db
	err := schema.DeleteSessionByID(orm, sessin)

	if err != nil {
		log.E(`删除session失败：`, err.Error())
		c.JSON(500, utils.ErrDeleteToken)
		return
	}

	userInfoCache.Remove(cacheKeySession + sessin)

	c.SetCookie(middleware.UserSessionTag, "", -1, "/", getHostName(c), true, true)

	c.JSON(200, utils.SUCCESS)

}

func getUserInfoHandle(c *gin.Context) {

	userID := c.GetInt64(middleware.XUserIDTag)

	key := cacheKeyUser + strconv.FormatInt(userID, 10)

	if user, ok := userInfoCache.Get(key); ok {
		c.JSON(200, user)
		return
	}

	user, err := schema.FirstUserByID(orm, userID)

	if err != nil {
		log.E(`获取用户信息失败：`, err.Error())
		c.JSON(404, utils.ErrGetUserInfo)
		return
	}
	//Credential 信息需要抹掉
	user.Credential = ``

	userInfoCache.Add(key, user)

	c.JSON(200, user)
}

func createAPIKeyHandle(c *gin.Context) {

	userID := c.GetInt64(middleware.XUserIDTag)

	token := schema.NewAPIToken(userID)

	if err := token.Save(orm); err != nil {
		log.E(`创建APIKey失败：`, err.Error())
		c.JSON(500, utils.ErrSaveToken)
		return
	}

	c.JSON(200, token)

}

// DELETE /user/apikeys/:id
func deleteAPIKeyHandle(c *gin.Context) {

	id := c.Param(`id`)

	if err := schema.DeleteAPIKey(orm, id); err != nil {
		log.E(`删除APIKey失败：`, err.Error())
		c.JSON(500, utils.ErrDeleteToken)
		return
	}

	c.JSON(200, utils.SUCCESS)

}

// getAPIKeyHandle get User Authorization
/**
 * @api {post} /user/oauth2/token Resource Owner Password Credentials
 * @apiName User Authorization
 * @apiGroup User
 * @apiDescription This is the Description.
 * It is multiline capable.
 *
 * @apiBody {String} username          UserName, or Email of the User.
 * @apiBody {String} password          Password of the user.
* @apiBody {String} [client_id]          client id.
 *
 * @apiSuccess {String} token_type     Always set to Bearer.
 * @apiSuccess {Number} expired_in     Number of seconds that the included access token is valid for.
 * @apiSuccess {String} refresh_token  Issued if the original scope parameter included offline_access.
 * @apiSuccess {String} access_token   Issued for the scopes that were requested.
*/
func getAccessTokenHandle(c *gin.Context) {

	req := struct {
		UserName  string `json:"account" binding:"required"`
		Password  string `json:"password" binding:"required"`
		ClientID  string `json:"client_id"`
		GrantType string `json:"grant_type"`
	}{}

	if err := c.ShouldBind(&req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(400, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	u, err := schema.FirstUserByAccount(orm, req.UserName)

	if err != nil {
		log.E(`用户未找到用户失败：`, err.Error())
		c.JSON(404, utils.ErrGetTokens)
		return
	}

	if ok := u.VerifyPassword(req.Password); !ok {
		log.E(`用户或者账号密码不对`, u.Name)
		c.JSON(404, utils.ErrGetTokens)
		return
	}

	session := &schema.Session{
		Session:     "",
		UserID:      u.ID,
		RemoteIP:    c.ClientIP(),
		UserAgent:   c.GetHeader(`User-Agent`),
		DeviceID:    req.ClientID,
		DeviceModel: c.GetHeader(`x-device-model`),
		DeviceType:  c.GetHeader(`x-device-type`),
		DistrictId:  0,
		FromUrl:     "",
		Duration:    time.Minute * 60,
		UserInfo:    u,
	}

	if err := session.Save(orm); err != nil {
		log.E(`保存session失败：`, err.Error())
		c.JSON(500, utils.ErrSaveToken)

	}

	sessionCache.Add(cacheKeySession+session.Session, session)

	c.JSON(200, struct {
		TokenType    string `json:"token_type"`
		ExpiresIn    int    `json:"expired_in"`
		RefreshToken string `json:"refresh_token"`
		AccessToken  string `json:"access_token"`
	}{"Bearer", int(session.Duration / time.Second), "", session.Session})
}

func getAPIKeysHandle(c *gin.Context) {

	userID := c.GetInt64(middleware.XUserIDTag)

	log.D(`userID`, userID)

	keys, err := schema.GetAPIKeysByUserID(orm, userID)

	if err != nil {
		log.E(`获取APIKey失败：`, err.Error())
		c.JSON(500, utils.ErrGetTokens)
		return
	}

	c.JSON(200, keys)

}

func resetPasswordHandle(c *gin.Context) {

	req := struct {
		Password string `json:"new_password" binding:"required"`
		Code     string `json:"code" binding:"required"`
	}{}

	if err := c.ShouldBind(&req); err != nil {
		log.I(`重置密码参数异常`, err)
		c.JSON(400, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	userID, err := strconv.ParseInt(c.Param("user_id"), 10, 64)

	if err != nil || userID == 0 {
		log.E(`从请求路径中获取获取用户ID失败：`, c.FullPath())
		c.JSON(500, utils.ErrParseUserID)
		return
	}

	u, err := schema.FirstUserByID(orm, userID)

	if err != nil {
		log.E(`获取用户失败：`, err.Error())
		c.JSON(404, utils.ErrNoFound)
		return
	}

	//todo verify code
	// if err := verifyCode(req.Code); err != nil {
	// 	log.E(`验证码错误：`, err.Error())
	// 	c.JSON(403, utils.ErrGetTokens)
	// 	return
	// }

	if err := u.ResetPassword(orm, req.Password); err != nil {
		log.E(`重置密码失败：`, err.Error())
		c.JSON(500, utils.ErrGetTokens)
		return
	}

	c.JSON(200, utils.SUCCESS)
}

func createAccountHandle(c *gin.Context) {
	req := struct {
		UserName string `json:"user_name" binding:"required"`
		Email    string `json:"email" binding:"required"`
		Password string `json:"password" binding:"required"`
	}{}

	if err := c.ShouldBind(&req); err != nil {
		log.I(`创建用户参数异常`, err)
		c.JSON(400, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	u := schema.User{
		Name:   req.UserName,
		Email:  req.Email,
		RoleID: 100,
	}

	if err := orm.Create(&u).Error; err != nil {
		log.E(`创建用户失败：`, err.Error())
		c.JSON(500, utils.ErrCreateUser)
	}

	c.JSON(200, u)

}

// listAccountHandle list accounts
func listAccountHandle(c *gin.Context) {

	users, err := schema.AllUsers(orm)

	if err != nil {
		log.E(`获取用户列表失败：`, err.Error())
		c.JSON(500, utils.ErrGetTokens)
		return
	}

	for i := range users {
		users[i].Credential = ""
	}

	data := map[string]interface{}{
		"items": users,
		"total": len(users),
	}

	c.JSON(200, data)

}
func getAccountHandle(c *gin.Context) {
	userID, err := strconv.ParseInt(c.Param("user_id"), 10, 64)

	if err != nil || userID == 0 {
		log.E(`从请求路径中获取获取用户ID失败：`, c.FullPath())
		c.JSON(500, utils.ErrParseUserID)
		return
	}

	u, err := schema.FirstUserByID(orm, userID)
	if err != nil {
		log.E(`获取用户失败：`, err.Error())
		c.JSON(404, utils.ErrNoFound)
		return
	}

	c.JSON(200, u)
}

func deleteAccountHandle(c *gin.Context) {

	userID, err := strconv.ParseInt(c.Param("user_id"), 10, 64)

	if err != nil || userID == 0 {
		log.E(`从请求路径中获取获取用户ID失败：`, c.FullPath())
		c.JSON(500, utils.ErrParseUserID)
		return
	}

	//检查是否被删除的用户是自己
	if userID == c.GetInt64(middleware.XUserIDTag) {
		log.E(`不能删除自己：`, userID)
		c.JSON(403, utils.ErrDeleteSeflf)
		return
	}

	u, err := schema.FirstUserByID(orm, userID)
	if err != nil {
		log.E(`获取用户失败：`, err.Error())
		c.JSON(404, utils.ErrNoFound)
		return
	}

	orm.Transaction(func(tx *gorm.DB) error {
		//删除用户
		if err = tx.Exec(`DELETE FROM users WHERE user_id = ?`, u.ID).Error; err != nil {
			return err
		}
		//删除用户的所有session
		var sessions []schema.Session
		if err = tx.Clauses(clause.Returning{Columns: []clause.Column{{Name: "session"}, {Name: "user_id"}}}).Where(`id = ?`, u.ID).
			Delete(&sessions).Error; err != nil {
			return err
		}

		//删除用户关联的所有apikey
		if err = tx.Exec(`DELETE FROM api_tokens WHERE user_id = ?`, u.ID).Error; err != nil {
			return err
		}

		for _, v := range sessions {
			//delete session from db
			sessionCache.Remove(cacheKeySession + v.Session)
		}

		//clean cache
		userInfoCache.Remove(cacheKeyUser + strconv.FormatInt(u.ID, 10))

		return nil
	})

	if err != nil {
		log.E(`删除session失败：`, err.Error())
		c.JSON(500, utils.ErrDeleteToken)
		return
	}

	c.JSON(200, utils.SUCCESS)

}
