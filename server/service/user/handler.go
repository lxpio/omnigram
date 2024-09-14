package user

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/service/user/schema"
	"github.com/lxpio/omnigram/server/utils"
)

func loginHandle(c *gin.Context) {
}

func logoutHandle(c *gin.Context) {

}

func getUserInfoHandle(c *gin.Context) {

	userID := c.GetInt64(middleware.XUserIDTag)

	key := userKeyPrefix + strconv.FormatInt(userID, 10)

	if user, ok := userInfoCache.Get(key); ok {
		c.JSON(200, utils.SUCCESS.WithData(user))
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

	c.JSON(200, utils.SUCCESS.WithData(user))
}

func createAPIKeyHandle(c *gin.Context) {

	userID := c.GetInt64(middleware.XUserIDTag)

	token := schema.NewAPIToken(userID)

	if err := token.Save(orm); err != nil {
		log.E(`创建APIKey失败：`, err.Error())
		c.JSON(500, utils.ErrSaveToken)
		return
	}

	c.JSON(200, utils.SUCCESS.WithData(token.APIKey))

}

// DELETE /user/apikeys/:id
func deleteAPIKeyHandle(c *gin.Context) {

	id := c.Param(`id`)

	if err := schema.DeleteAPIKey(orm, id); err != nil {
		log.E(`删除APIKey失败：`, err.Error())
		c.JSON(500, utils.ErrDeleteToken)
		return
	}

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
func getAPIKeyHandle(c *gin.Context) {

	req := struct {
		UserName  string `json:"username"`
		Password  string `json:"password"`
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
		log.E(`用户或者账号密码不对`, u.UserName)
		c.JSON(404, utils.ErrGetTokens)
		return
	}

	key, err := schema.GetAPIKeyByUserID(orm, u.ID)

	if err != nil {
		log.E(`获取APIKey失败：`, err.Error())
		c.JSON(500, utils.ErrGetTokens)
		return
	}

	log.D(`account_token:`, key.APIKey)

	c.JSON(200, utils.SUCCESS.WithData(struct {
		TokenType    string `json:"token_type"`
		ExpiresIn    int    `json:"expired_in"`
		RefreshToken string `json:"refresh_token"`
		AccessToken  string `json:"access_token"`
	}{"Bearer", 3600, "", key.APIKey}))
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

	c.JSON(200, utils.SUCCESS.WithData(keys))

}

func createAccountHandle(c *gin.Context) {
	panic(`TODO`)
}

// listAccountHandle list accounts
func listAccountHandle(c *gin.Context) {

	users, err := schema.AllUsers(orm)

	if err != nil {
		log.E(`获取用户列表失败：`, err.Error())
		c.JSON(500, utils.ErrGetTokens)
		return
	}

	c.JSON(200, utils.SUCCESS.WithData(users))

}
func getAccountHandle(c *gin.Context) {
	panic(`TODO`)
}
func deleteAccountHandle(c *gin.Context) {
	panic(`TODO`)
}
