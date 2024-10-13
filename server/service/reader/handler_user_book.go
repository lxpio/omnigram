package reader

import (
	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/utils"
	"gorm.io/gorm"
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

	c.JSON(200, likes)
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

	c.JSON(200, map[string][]schema.ProgressBook{
		"readings": readings,
		"likes":    likes,
	})

}

// 获取个人阅读进度
func getReadBookHandle(c *gin.Context) {
	id := c.Param(`book_id`)
	if id == `` {
		log.E(`图书ID为空`)
		c.JSON(400, utils.ErrReqArgs)
		return
	}

	userID := c.GetInt64(middleware.XUserIDTag)

	p := &schema.ReadProgress{UserID: userID, BookID: id}

	if err := p.First(orm); err != nil {

		if err == gorm.ErrRecordNotFound {
			p = schema.NewReadProgress(id, userID)

		} else {
			log.E(`创建阅读进度失败：`, err)
			c.JSON(200, utils.ErrInnerServer)
			return
		}

	}

	c.JSON(200, p)

}

func updateReadBookHandle(c *gin.Context) {

	id := c.Param(`book_id`)
	if id == `` {
		log.E(`图书ID为空`)
		c.JSON(400, utils.ErrReqArgs)
		return
	}
	req := &schema.ReadProgress{BookID: id}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	book, err := schema.FirstBookById(orm, id)

	if err != nil {
		log.E(`获取图书失败：`, err)

		if err != gorm.ErrRecordNotFound {
			c.JSON(500, utils.ErrInnerServer)
			return

		}

	}

	req.UserID = c.GetInt64(middleware.XUserIDTag)
	req.BookID = book.ID

	err = req.Upsert(orm)
	if err != nil {
		log.E(`创建阅读进度失败：`, err)
		c.JSON(500, utils.ErrInnerServer)
		return
	}

	c.JSON(200, req)

}
