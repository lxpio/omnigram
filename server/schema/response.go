package schema

import (
	"log"
	"math"
	"net/http"

	"github.com/gin-gonic/gin"
)

// ErrorResponse 统一错误响应格式
type ErrorResponse struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details any    `json:"details,omitempty"`
}

// PagedResponse 分页响应格式
type PagedResponse struct {
	Data       any   `json:"data"`
	Page       int   `json:"page"`
	PageSize   int   `json:"page_size"`
	TotalCount int64 `json:"total_count"`
	TotalPages int   `json:"total_pages"`
}

// Success 成功响应
func Success(c *gin.Context, data any) {
	c.JSON(200, gin.H{"data": data})
}

// SuccessPaged 分页成功响应
func SuccessPaged(c *gin.Context, data any, page, pageSize int, total int64) {
	c.JSON(200, PagedResponse{
		Data:       data,
		Page:       page,
		PageSize:   pageSize,
		TotalCount: total,
		TotalPages: int(math.Ceil(float64(total) / float64(pageSize))),
	})
}

// Error 错误响应
func Error(c *gin.Context, status int, code, message string) {
	c.JSON(status, ErrorResponse{Code: code, Message: message})
	c.Abort()
}

// InternalError returns a generic 500 response without leaking internal details.
// The actual error is logged server-side.
func InternalError(c *gin.Context, err error) {
	log.Printf("[ERROR] %s %s: %v", c.Request.Method, c.Request.URL.Path, err)
	Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "An internal error occurred")
}
