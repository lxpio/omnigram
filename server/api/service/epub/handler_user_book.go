package epub

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/api/service/epub/schema"
	"github.com/lxpio/omnigram/server/api/log"
	"github.com/lxpio/omnigram/server/api/middleware"
	"github.com/lxpio/omnigram/server/api/utils"
)

// PersonalBooksHandle 获取用户喜欢的书籍列表
/**
 * @api {get} /book/fav Get User Favorite Books
 * @apiName FavBookHandle
 * @apiGroup book
 * @apiDescription Get Personal liked , reading, and marked books.
 *
 * @apiHeader {String} Authorization Users unique auth key.
 *
 * @apiSuccess {Boolean} chatserver     Always set to Bearer.
 * @apiSuccess {Number} expires_in     Number of seconds that the included access token is valid for.
 * @apiSuccess {String} refresh_token  Issued if the original scope parameter included offline_access.
 * @apiSuccess {String} access_token   Issued for the scopes that were requested.
 */
func FavBookHandle(c *gin.Context) {

	userID := c.GetInt64(middleware.XUserIDTag)

	req := &struct {
		Limit  int `form:"limit"`
		Offset int `form:"offset"`
	}{10, 0}

	if err := c.ShouldBind(req); err != nil {
		log.I(`请求参数异常`, err)
		c.JSON(400, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	likes, err := schema.LikedBooks(orm, userID, req.Offset, req.Limit)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	c.JSON(200, utils.SUCCESS.WithData(likes))
}

// PersonalBooksHandle 获取用户喜欢的书籍列表
/**
 * @api {get} /book/personal Get User Personal Books
 * @apiName PersonalBooksHandle
 * @apiGroup book
 * @apiDescription Get Personal liked , reading, and marked books.
 *
 * @apiHeader {String} Authorization Users unique auth key.
 *
 * @apiSuccess {Boolean} chatserver     Always set to Bearer.
 * @apiSuccess {Number} expires_in     Number of seconds that the included access token is valid for.
 * @apiSuccess {String} refresh_token  Issued if the original scope parameter included offline_access.
 * @apiSuccess {String} access_token   Issued for the scopes that were requested.
 */
func PersonalBooksHandle(c *gin.Context) {

	userID := c.GetInt64(middleware.XUserIDTag)

	readings, err := schema.ReadingBooks(orm, userID, 0, 20)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	likes, err := schema.LikedBooks(orm, userID, 0, 20)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	c.JSON(200, utils.SUCCESS.WithData(map[string][]schema.ProgressBook{
		"readings": readings,
		"likes":    likes,
	}))

}

// 获取个人阅读进度
func getReadBookHandle(c *gin.Context) {
	id, err := strconv.Atoi(c.Param(`book_id`))
	if err != nil || id < 1 {
		log.E(`图书ID为空`)
		c.JSON(200, utils.ErrReqArgs)
		return
	}

	userID := c.GetInt64(middleware.XUserIDTag)

	p := schema.ReadProgress{UserID: userID, BookID: int64(id)}
	err = p.First(orm)

	if err != nil {
		log.E(`创建阅读进度失败：`, err)
		c.JSON(200, utils.ErrInnerServer)
		return
	}

	c.JSON(200, utils.SUCCESS.WithData(p))

}
