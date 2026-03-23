package reader

import (
	"context"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/service/ai"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
)

// @Summary Get book cover image
// @Description Retrieve a book cover image by path
// @Tags Reader
// @Produce image/jpeg
// @Security BearerAuth
// @Param book_cover_path path string true "Cover image path"
// @Success 200 {file} binary "Cover image"
// @Failure 404 {object} utils.Response
// @Router /img/covers/{book_cover_path} [get]
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

	obj, err := store.GetKV().Get(context.TODO(), schema.GetCoverBucket(coverPath), coverPath)

	if err != nil {
		log.E(`获取图片内容失败`, err.Error())
		c.JSON(http.StatusNotFound, utils.ErrNoFound)
		return
	}

	c.Data(200, "image/"+ext, obj)

}

// @Summary Get book details
// @Description Get detailed information about a specific book
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Success 200 {object} schema.Book
// @Failure 404 {object} utils.Response
// @Router /reader/books/{book_id} [get]
func BookDetail(c *gin.Context) {

	id := c.Param(`book_id`)
	if id == `` {
		log.E(`图书ID为空`)
		c.JSON(400, utils.ErrReqArgs)
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

// @Summary Upload book
// @Description Upload a new book file (EPUB, PDF, etc.)
// @Tags Reader
// @Accept multipart/form-data
// @Produce json
// @Security BearerAuth
// @Param file formData file true "Book file"
// @Success 200 {object} utils.Response
// @Failure 400 {object} utils.Response
// @Router /reader/upload [post]
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

	if err := book.Save(context.Background()); err != nil {
		log.E(`录入文档失败`, err)
		c.JSON(http.StatusOK, utils.ErrSaveFile)
		return
	}

	// AI metadata enhancement
	go func() {
		if result, err := ai.EnhanceMetadata(context.Background(), book.Title, book.Author, book.Description); err == nil && result != nil {
			updates := map[string]any{}
			if result.Description != "" && book.Description == "" {
				updates["description"] = result.Description
			}
			if result.Category != "" && book.Category == "" {
				updates["category"] = result.Category
			}
			if result.Language != "" && book.Language == "" {
				updates["language"] = result.Language
			}
			if len(updates) > 0 {
				orm.Model(book).Updates(updates)
			}
			if len(result.Tags) > 0 && len(book.Tags) == 0 {
				for _, tag := range result.Tags {
					orm.FirstOrCreate(&schema.BookTagShip{BookID: book.ID, Tag: tag},
						schema.BookTagShip{BookID: book.ID, Tag: tag})
				}
			}
		}

		// Generate embedding for semantic search
		if ai.IsEmbeddingAvailable() {
			if err := ai.GenerateBookEmbedding(context.Background(), orm, book.ID, book.Title, book.Author, book.Description); err != nil {
				log.E("Failed to generate book embedding: ", err)
			}
		}
	}()

	c.JSON(http.StatusOK, utils.SUCCESS)
}

// @Summary Download book
// @Description Download the original book file
// @Tags Reader
// @Produce application/octet-stream
// @Security BearerAuth
// @Param book_id path string true "Book ID"
// @Success 200 {file} binary "Book file"
// @Failure 404 {object} utils.Response
// @Router /reader/download/books/{book_id} [get]
func bookDownloadHandle(c *gin.Context) {

	id := c.Param(`book_id`)
	if id == `` {
		log.E(`图书ID为空`)
		c.JSON(400, utils.ErrReqArgs)
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

// @Summary Get recent books
// @Description Get recently added or read books
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param recent query int false "Number of books to return" default(12)
// @Success 200 {array} schema.Book
// @Router /reader/recent [get]
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

// @Summary Search books
// @Description Search books by query parameters
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param search query string false "Search keyword"
// @Param category query string false "Category filter"
// @Param author query string false "Author filter"
// @Success 200 {array} schema.Book
// @Router /reader/books [get]
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

// @Summary Get library index
// @Description Get homepage data with random and recent books
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Param random query int false "Number of random books" default(6)
// @Param recent query int false "Number of recent books" default(12)
// @Success 200 {object} object{random=[]schema.Book,recent=[]schema.Book}
// @Router /reader/index [get]
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

// @Summary Get book statistics
// @Description Get aggregated library statistics
// @Tags Reader
// @Produce json
// @Security BearerAuth
// @Success 200 {object} schema.BookStats
// @Router /reader/stats [get]
func GetBookStats(c *gin.Context) {
	log.D(`获取书籍概览信息`)

	stats, err := schema.GetBookStats(orm)

	if err != nil {
		log.E(`获取数据信息失败`)
		c.JSON(404, utils.ErrNoFound)
	}

	c.JSON(200, stats)

}
