package reader

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/schema"
)

// listTagsHandle GET /reader/tags
func listTagsHandle(c *gin.Context) {
	type tagCount struct {
		Tag   string `json:"tag"`
		Count int64  `json:"count"`
	}
	var tags []tagCount
	if err := orm.Model(&schema.BookTagShip{}).
		Select("tag, COUNT(*) as count").
		Group("tag").
		Order("count DESC").
		Scan(&tags).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}
	schema.Success(c, tags)
}

// createTagHandle POST /reader/tags — 预创建标签（关联到所有匹配书籍时使用）
func createTagHandle(c *gin.Context) {
	var req struct {
		Tag    string `json:"tag" binding:"required"`
		BookID string `json:"book_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}
	if req.BookID != "" {
		ts := schema.BookTagShip{BookID: req.BookID, Tag: req.Tag}
		orm.Where("book_id = ? AND tag = ?", req.BookID, req.Tag).FirstOrCreate(&ts)
		schema.Success(c, ts)
		return
	}
	schema.Success(c, gin.H{"tag": req.Tag})
}

// deleteTagHandle DELETE /reader/tags/:tag_id — 按标签名删除所有关联
func deleteTagHandle(c *gin.Context) {
	tagName := c.Param("tag_id")
	if err := orm.Where("tag = ?", tagName).Delete(&schema.BookTagShip{}).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}
	schema.Success(c, gin.H{"tag": tagName, "deleted": true})
}
