package reader

import (
	"context"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/store"
	"gorm.io/gorm"
)

var (
	orm *gorm.DB
	kv  store.KV

	uploadPath string
)

// Setup reg router
func Setup(router *gin.Engine) {

	oauthMD := middleware.Get(middleware.OathMD)

	// adminMD := middleware.Get(middleware.AdminMD)

	book := router.Group("/reader", oauthMD)

	book.GET("/stats", GetBookStats)
	book.GET("/index", Index)
	book.GET("/search", SearchBook)
	book.GET("/recent", RecentBook)

	book.GET("/fav", FavBookHandle)
	book.GET("/personal", PersonalBooksHandle)
	// router.GET("/book/hot", HotBook)

	book.GET("/upload", bookUploadHandle)

	book.GET(`/download/books/:book_id`, bookDownloadHandle)

	book.GET("/books/:book_id", BookDetail)

	book.GET(`/books/:book_id/progress`, getReadBookHandle)
	book.PUT(`/books/:book_id/progress`, updateReadBookHandle)

	router.GET("/img/covers/*book_cover_path", oauthMD, coverImageHandle)
	// router.GET("/reader/books/:book_id/cover", oauthMD, coverImageByIDHandle)

	router.GET("/sync/full", oauthMD, syncFullHandle) //同步全量数据

	router.GET("/sync/delta", oauthMD, syncDeltaHandle) //同步增量数据
	// router.GET("/books/:book_id/delete", BookDelete)
	// router.GET("/books/:book_id/edit", BookEdit)

	// router.GET("/books/:book_id/push", BookPush)
	// router.GET("/books/:book_id/refer", BookRefer)
	// router.GET("/read/:book_id", BookRead)

}

func Initialize(ctx context.Context) {

	kv = store.GetKV()
	orm = store.FileStore()

}
