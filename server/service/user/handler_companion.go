package user

import (
	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
)

// @Summary Get companion profile
// @Description Get the AI companion personality configuration for the current user
// @Tags User
// @Produce json
// @Security BearerAuth
// @Success 200 {object} schema.CompanionProfile
// @Failure 404 {object} utils.Response
// @Router /user/companion [get]
func getCompanionHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	profile, err := schema.GetCompanionProfile(store.Store(), userID)
	if err != nil {
		// Return default profile if none exists
		c.JSON(200, &schema.CompanionProfile{
			UserID:      userID,
			Name:        "TARS",
			Proactivity: 50,
			Style:       50,
			Depth:       50,
			Warmth:      50,
		})
		return
	}

	c.JSON(200, profile)
}

// @Summary Update companion profile
// @Description Create or update the AI companion personality configuration
// @Tags User
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body schema.CompanionProfile true "Companion profile"
// @Success 200 {object} schema.CompanionProfile
// @Failure 400 {object} utils.Response
// @Router /user/companion [put]
func updateCompanionHandle(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	profile := &schema.CompanionProfile{}
	if err := c.ShouldBindJSON(profile); err != nil {
		c.JSON(400, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	profile.UserID = userID

	if err := schema.SaveCompanionProfile(store.Store(), profile); err != nil {
		c.JSON(500, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	c.JSON(200, profile)
}
