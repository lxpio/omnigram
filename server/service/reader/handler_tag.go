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

// createTagHandle POST /reader/tags
func createTagHandle(c *gin.Context) {
	var req struct {
		Tag string `json:"tag" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}
	schema.Success(c, gin.H{"tag": req.Tag})
}

// deleteTagHandle DELETE /reader/tags/:tag_id
func deleteTagHandle(c *gin.Context) {
	tagID := c.Param("tag_id")
	if err := orm.Where("id = ?", tagID).Delete(&schema.BookTagShip{}).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}
	schema.Success(c, gin.H{"id": tagID, "deleted": true})
}
