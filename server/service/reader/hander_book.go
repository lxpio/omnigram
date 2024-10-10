package reader

import (
	"context"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/utils"
)

func coverImageHandle(c *gin.Context) {

	coverPath := strings.TrimPrefix(c.Param(`book_cover_path`), `/`)

	ext := filepath.Ext(c.Param(`book_cover_path`))

	if ext != ".png" && ext != ".jpeg" && ext != ".jpg" {
		log.E(`图片路径ID为空：`, ext)
		ext = "jpg"
		c.JSON(404, utils.ErrReqArgs)
		return
	}

	log.I(`获取图片内容`, coverPath)

	obj, err := kv.GetObject(context.TODO(), schema.GetCoverBucket(coverPath), coverPath)

	if err != nil {
		log.E(`获取图片内容失败`, err.Error())
		c.JSON(http.StatusNotFound, utils.ErrNoFound)
		return
	}

	c.Data(200, "image/"+ext, obj.Data)

}

func BookDetail(c *gin.Context) {

	id, err := strconv.Atoi(c.Param(`book_id`))
	if err != nil || id < 1 {
		log.E(`图书ID为空`)
		c.JSON(200, utils.ErrReqArgs)
		return
	}

	// userID := c.GetInt64(middleware.XUserIDTag)

	book, err := schema.FirstBookById(orm, id)
	if err != nil {
		log.E(`获取图书失败`, err.Error())
		c.JSON(http.StatusNotFound, utils.ErrNoFound)
		return
	}

	c.JSON(http.StatusOK, book)

}

// BookUpload 上传文件
func bookUploadHandle(c *gin.Context) {
	//处理上传文件并存储到数据库

	file, err := c.FormFile("file")
	if err != nil {
		log.E(`上传文件失败：`, err)
		c.JSON(200, utils.ErrReqArgs)
		return
	}

	log.I(`上传文件成功：`, file.Filename)

	uploadfile := filepath.Join(uploadPath, file.Filename)

	//存储文件到上传目录
	if err := c.SaveUploadedFile(file, uploadfile); err != nil {
		log.E(`上传文件失败：`, err)
		c.JSON(http.StatusOK, utils.ErrSaveFile)
		return
	}

	//尝试解析文件
	book := &schema.Book{Path: uploadfile}

	if err := book.GetMetadataFromFile(); err != nil {
		log.E(`解析文件失败：`, err)
		c.JSON(http.StatusOK, utils.ErrParseEpubFile.WithMessage(err.Error()))
		return
	}

	if err := book.Save(context.Background(), orm, kv); err != nil {
		log.E(`录入文档失败`, err)
		c.JSON(http.StatusOK, utils.ErrSaveFile)
		return
	}

	c.JSON(http.StatusOK, utils.SUCCESS)
}

// BookDownload 下载图书
// /books/:book_id/download
func bookDownloadHandle(c *gin.Context) {

	id, err := strconv.Atoi(c.Param(`book_id`))
	if err != nil || id < 1 {
		log.E(`图书ID为空`)
		c.JSON(200, utils.ErrReqArgs)
		return
	}

	book, err := schema.FirstBookById(orm, id)

	if err != nil {
		log.E(`获取图书失败：`, err)
		c.JSON(200, utils.ErrNoFound)
		return
	}

	//读取书籍文件路径到io

	c.Header(`Content-Type`, `application/octet-stream`)
	c.Header("Content-Disposition", "attachment; filename="+book.Title+".epub")
	c.Header("Content-Transfer-Encoding", "binary")
	c.File(book.Path)

}

func RecentBook(c *gin.Context) {
	req := &struct {
		Recent int `json:"recent" binding:"required,gte=0"`
	}{
		Recent: 12,
	}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}
	recentBooks, err := schema.RecentBooks(orm, req.Recent, nil)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	c.JSON(200, recentBooks)

}

// SearchBook 模糊搜索
func SearchBook(c *gin.Context) {

	req := &schema.Query{}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	//过滤search 字段中特殊字符
	req.Search = strings.ReplaceAll(req.Search, ` `, ` `)

	recentBooks, err := schema.SearchBooks(orm, req)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	c.JSON(200, recentBooks)

}

// Index 返回 首页 随机ID书籍和最近添加到书籍集。
func Index(c *gin.Context) {

	req := &struct {
		Random int `form:"random" json:"random" binding:"required,gte=0,lt=30"`
		Recent int `form:"recent" json:"recent" binding:"required,gte=0,lt=30"`
	}{
		Random: 10,
		Recent: 12,
	}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	// userID := c.GetInt64(middleware.XUserIDTag)

	// readings, err := schema.ReadingBooks(orm, userID, 0, req.Random)

	// if err != nil {
	// 	log.I(`用户登录参数异常`, err)
	// 	c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
	// 	return
	// }

	// idList := make([]int64, 0)

	// for _, v := range readings {
	// 	idList = append(idList, v.ID)
	// }

	randBooks, err := schema.RandomBooks(orm, req.Random, nil)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	recentBooks, err := schema.RecentBooks(orm, req.Recent, nil)

	if err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	data := map[string]interface{}{
		// "reading": readings,
		"random": randBooks.Books,
		"recent": recentBooks.Books,
	}

	c.JSON(200, data)

}

// UserInfo GET /api/user/info
// 获取用户信息
func GetBookStats(c *gin.Context) {
	log.D(`获取书籍概览信息`)

	stats, err := schema.GetBookStats(orm)

	if err != nil {
		log.E(`获取数据信息失败`)
		c.JSON(404, utils.ErrNoFound)
	}

	c.JSON(200, stats)

}
