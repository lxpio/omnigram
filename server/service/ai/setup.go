package ai

import (
	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
)

func Setup(router *gin.Engine) {
	oauthMD := middleware.Get(middleware.OathMD)
	adminMD := middleware.Get(middleware.AdminMD)

	sys := router.Group("/sys")
	sys.GET("/ai/status", oauthMD, aiStatusHandle)
	sys.PUT("/ai/config", oauthMD, adminMD, aiConfigHandle)
}

// @Summary Get AI service status
// @Description Check if the AI service is enabled and configured
// @Tags AI
// @Produce json
// @Security BearerAuth
// @Success 200 {object} object{data=object{enabled=bool,provider=string,model=string,status=string}}
// @Router /sys/ai/status [get]
func aiStatusHandle(c *gin.Context) {
	opts := conf.GetConfig().AIOptions
	status := "disabled"
	if opts.Enabled {
		status = "enabled"
	}
	schema.Success(c, gin.H{
		"enabled":  opts.Enabled,
		"provider": opts.Provider,
		"model":    opts.Model,
		"status":   status,
	})
}

// @Summary Update AI configuration
// @Description Update AI service configuration (admin only)
// @Tags AI
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body conf.AIOptions true "AI configuration"
// @Success 200 {object} object{data=conf.AIOptions}
// @Failure 400 {object} schema.ErrorResponse
// @Failure 500 {object} schema.ErrorResponse
// @Router /sys/ai/config [put]
func aiConfigHandle(c *gin.Context) {
	var req conf.AIOptions
	if err := c.ShouldBindJSON(&req); err != nil {
		schema.Error(c, 400, "VALIDATION_ERROR", err.Error())
		return
	}

	cf := conf.GetConfig()
	cf.AIOptions = req

	if err := cf.Save(); err != nil {
		schema.Error(c, 500, "CONFIG_ERROR", err.Error())
		return
	}

	schema.Success(c, req)
}
