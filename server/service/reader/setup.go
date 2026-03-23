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

	uploadPath string
)

// Setup reg router
func Setup(router *gin.Engine) {

	oauthMD := middleware.Get(middleware.OathMD)

	adminMD := middleware.Get(middleware.AdminMD)

	book := router.Group("/reader", oauthMD)

	book.GET("/stats", GetBookStats)
	book.GET("/index", Index)
	book.GET("/books", SearchBook)
	book.GET("/recent", RecentBook)

	book.GET("/fav", FavBookHandle)
	book.GET("/personal", PersonalBooksHandle)

	book.POST("/upload", bookUploadHandle)

	book.GET(`/download/books/:book_id`, bookDownloadHandle)

	book.GET("/books/:book_id", BookDetail)
	book.PUT("/books/:book_id", updateBookHandle)
	book.DELETE("/books/:book_id", deleteBookHandle)
	book.PUT("/books/:book_id/cover", uploadCoverHandle)

	book.GET(`/books/:book_id/progress`, getReadBookHandle)
	book.PUT(`/books/:book_id/progress`, updateReadBookHandle)

	router.GET("/img/covers/*book_cover_path", oauthMD, coverImageHandle)
	// router.GET("/reader/books/:book_id/cover", oauthMD, coverImageByIDHandle)

	router.POST("/sync/full", oauthMD, syncFullHandle) //同步全量数据

	router.POST("/sync/delta", oauthMD, syncDeltaHandle) //同步增量数据

	// Tags
	book.GET("/tags", listTagsHandle)
	book.POST("/tags", createTagHandle)
	book.DELETE("/tags/:tag_id", deleteTagHandle)

	// Shelves
	book.GET("/shelves", listShelvesHandle)
	book.POST("/shelves", createShelfHandle)
	book.GET("/shelves/:shelf_id", getShelfHandle)
	book.PUT("/shelves/:shelf_id", updateShelfHandle)
	book.DELETE("/shelves/:shelf_id", deleteShelfHandle)
	book.POST("/shelves/:shelf_id/books", addBooksToShelfHandle)
	book.DELETE("/shelves/:shelf_id/books", removeBooksFromShelfHandle)

	// Annotations
	book.PUT("/books/:book_id/rating", updateBookRatingHandle)
	book.GET("/books/:book_id/annotations", listAnnotationsHandle)
	book.POST("/books/:book_id/annotations", createAnnotationHandle)
	book.PUT("/books/:book_id/annotations/:annotation_id", updateAnnotationHandle)
	book.DELETE("/books/:book_id/annotations/:annotation_id", deleteAnnotationHandle)

	// Annotation sync
	router.POST("/sync/annotations", oauthMD, syncAnnotationsHandle)

	// AI results
	book.GET("/books/:book_id/ai", getBookAiHandle)
	book.GET("/books/:book_id/ai/cache", listAiCacheHandle)
	book.PUT("/books/:book_id/ai/cache", upsertAiCacheHandle)

	// AI cache bulk sync
	router.POST("/ai/cache/sync", oauthMD, syncAiCacheHandle)

	// Companion chat
	book.GET("/books/:book_id/companion/chat", listCompanionChatHandle)
	book.POST("/books/:book_id/companion/chat", addCompanionChatHandle)

	// Margin notes
	book.GET("/books/:book_id/margin-notes", listMarginNotesHandle)
	book.POST("/books/:book_id/margin-notes", syncMarginNotesHandle)
	router.PATCH("/margin-notes/:note_id", oauthMD, updateMarginNoteFeedbackHandle)

	// Enhanced search
	book.GET("/search", enhancedSearchHandle)

	// Reading sessions & stats
	book.POST("/sessions", recordSessionHandle)
	book.GET("/stats/overview", statsOverviewHandle)
	book.GET("/stats/daily", statsDailyHandle)
	book.GET("/stats/books", statsTopBooksHandle)

	// Batch operations
	book.POST("/books/batch/delete", adminMD, batchDeleteHandle)
	book.POST("/books/batch/tag", batchTagHandle)
	book.POST("/books/batch/shelf", batchShelfHandle)

	// router.GET("/books/:book_id/delete", BookDelete)
	// router.GET("/books/:book_id/edit", BookEdit)

	// router.GET("/books/:book_id/push", BookPush)
	// router.GET("/books/:book_id/refer", BookRefer)
	// router.GET("/read/:book_id", BookRead)

}

func Initialize(ctx context.Context) {

	orm = store.FileStore()

}
