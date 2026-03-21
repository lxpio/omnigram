package reader

import (
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
)

// recordSessionHandle POST /reader/sessions
func recordSessionHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	var req schema.ReadingSession
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, 400, "VALIDATION_ERROR", err.Error())
		return
	}

	req.UserID = userID

	if err := orm.Create(&req).Error; err != nil {
		schema.Error(c, 500, "DB_ERROR", err.Error())
		return
	}

	schema.Success(c, req)
}

// statsOverviewHandle GET /reader/stats/overview
func statsOverviewHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	var totalBooks int64
	orm.Model(&schema.Book{}).Count(&totalBooks)

	var totalTime int64
	orm.Model(&schema.ReadingSession{}).Where("user_id = ?", userID).Select("COALESCE(SUM(duration), 0)").Scan(&totalTime)

	var booksRead int64
	orm.Model(&schema.ReadingSession{}).Where("user_id = ?", userID).Distinct("book_id").Count(&booksRead)

	schema.Success(c, gin.H{
		"total_books":          totalBooks,
		"total_reading_seconds": totalTime,
		"books_read":           booksRead,
	})
}

// statsDailyHandle GET /reader/stats/daily?from=2026-01-01&to=2026-03-21
func statsDailyHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	from := c.Query("from")
	to := c.Query("to")

	type dailyStat struct {
		Date     string `json:"date"`
		Duration int64  `json:"duration"`
		Sessions int64  `json:"sessions"`
	}

	var stats []dailyStat
	query := orm.Model(&schema.ReadingSession{}).
		Select("DATE(start_time/1000, 'unixepoch') as date, SUM(duration) as duration, COUNT(*) as sessions").
		Where("user_id = ?", userID).
		Group("date").Order("date ASC")

	if from != "" {
		query = query.Where("start_time >= ?", dateToMillis(from))
	}
	if to != "" {
		query = query.Where("start_time <= ?", dateToMillis(to)+86400000)
	}

	query.Scan(&stats)
	schema.Success(c, stats)
}

// statsTopBooksHandle GET /reader/stats/books?limit=10
func statsTopBooksHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	if limit < 1 || limit > 50 {
		limit = 10
	}

	type bookStat struct {
		BookID   string `json:"book_id"`
		Title    string `json:"title"`
		Author   string `json:"author"`
		Duration int64  `json:"duration"`
		Sessions int64  `json:"sessions"`
	}

	var stats []bookStat
	orm.Raw(`SELECT s.book_id, b.title, b.author, SUM(s.duration) as duration, COUNT(*) as sessions
		FROM reading_sessions s LEFT JOIN books b ON s.book_id = b.id
		WHERE s.user_id = ? GROUP BY s.book_id ORDER BY duration DESC LIMIT ?`, userID, limit).Scan(&stats)

	schema.Success(c, stats)
}

func dateToMillis(dateStr string) int64 {
	t, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return 0
	}
	return t.UnixMilli()
}
