package sys

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/utils"
)

type ServerConfig struct {
	Version      string `json:"version"`
	System       string `json:"system,omitempty"`
	Architecture string `json:"architecture,omitempty"`
	TTSEnabled   bool   `json:"tts_support,omitempty"`
	TTSProvider  string `json:"tts_provider,omitempty"`

	DocsDataPath string `json:"docs_data_path"`

	DiskUsage string `json:"disk_usage"`

	ChatEnabled bool   `json:"chat_enabled,omitempty"`
	OllamaAddr  string `json:"ollama_addr,omitempty"`
	OpenAIUrl   string `json:"openai_url,omitempty"`
	OpenAIApiKey string `json:"openai_apikey,omitempty"`
}

// @Summary Get system info
// @Description Get system configuration and status information
// @Tags System
// @Produce json
// @Security BearerAuth
// @Success 200 {object} object{version=string,system=string,architecture=string,docs_data_path=string,disk_usage=object}
// @Router /sys/info [get]
func getSysInfoHandle(c *gin.Context) {

	// mng := epub.GetManager()

	cf := conf.GetConfig()

	info := &ServerConfig{
		Version:      conf.Version,
		ChatEnabled:  true,
		TTSEnabled:   len(cf.TTSOptions.Provider) > 0,
		TTSProvider:  cf.TTSOptions.Provider,
		System:       "Linux", //TODO get real system info
		Architecture: "AMD64", //TODO get real system info
		DocsDataPath: cf.EpubOptions.DataPath,
	}

	c.JSON(http.StatusOK, info)

}

// @Summary System heartbeat
// @Description Check if the server is responsive
// @Tags System
// @Produce json
// @Success 200 {object} object{version=string,system=string,architecture=string}
// @Router /sys/ping [get]
func getSysPingHandle(c *gin.Context) {
	info := &ServerConfig{
		Version:      conf.Version,
		System:       "Linux", //TODO get real system info
		Architecture: "AMD64", //TODO get real system info
	}

	c.JSON(http.StatusOK, info)
}

// @Summary Update system config
// @Description Update system configuration (admin only)
// @Tags System
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body object{tts_provider=string,tts_sidecar_url=string,openai_url=string,openai_apikey=string} true "System config"
// @Success 200 {object} object{version=string,system=string}
// @Failure 400 {object} utils.Response
// @Router /sys/info [put]
func updateSysInfoHandle(c *gin.Context) {

	req := struct {
		TTSProvider  string `json:"tts_provider"`
		TTSSidecarURL string `json:"tts_sidecar_url"`
		OpenAIUrl    string `json:"openai_url"`
		OpenAIApiKey string `json:"openai_apikey"`
	}{}

	if err := c.ShouldBind(&req); err != nil {
		log.I(`参数异常`, err)
		c.JSON(400, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	gcf := conf.GetConfig()

	if req.TTSProvider != "" {
		gcf.TTSOptions.Provider = req.TTSProvider
	}
	if req.TTSSidecarURL != "" {
		gcf.TTSOptions.SidecarURL = req.TTSSidecarURL
	}

	if err := gcf.Save(); err != nil {
		log.I(`更新配置失败`, err)
		c.JSON(200, utils.ErrUpdateTTSConfig.WithMessage(err.Error()))
		return
	}

	info := &ServerConfig{
		Version:      conf.Version,
		ChatEnabled:  len(gcf.ModelOptions) > 0,
		TTSEnabled:   len(gcf.TTSOptions.Provider) > 0,
		TTSProvider:  gcf.TTSOptions.Provider,
		System:       "Linux", //TODO get real system info
		Architecture: "AMD64", //TODO get real system info
		DocsDataPath: gcf.EpubOptions.DataPath,
	}

	c.JSON(http.StatusOK, info)

}
