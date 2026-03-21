package sys

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/service/m4t"
	"github.com/lxpio/omnigram/server/utils"
)

//	{
//		"version": "0.0.1",
//		"system": "Linux",
//		"architecture": "AMD64",
//		"docs_data_path": "/data",
//		"disk_usage": "10/100T",
//		"m4t_support": true
//	  }
type ServerConfig struct {
	Version      string `json:"version"`
	System       string `json:"system,omitempty"`
	Architecture string `json:"architecture,omitempty"`
	M4tEnabled   bool   `json:"m4t_support,omitempty"`

	// ScanStatus   selfhost.ScanStatus `json:"scan_stats"`
	DocsDataPath string `json:"docs_data_path"`

	DiskUsage string `json:"disk_usage"`

	ChatEnabled   bool   `json:"chat_enabled,omitempty"`
	M4tServerAddr string `json:"m4t_server_addr,omitempty"`
	OllamaAddr    string `json:"ollama_addr,omitempty"`
	OpenAIUrl     string `json:"openai_url,omitempty"`
	OpenAIApiKey  string `json:"openai_apikey,omitempty"`
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
		Version:       conf.Version,
		ChatEnabled:   true,
		M4tEnabled:    true,
		System:        "Linux", //TODO get real system info
		Architecture:  "AMD64", //TODO get real system info
		DocsDataPath:  cf.EpubOptions.DataPath,
		M4tServerAddr: cf.M4tOptions.RemoteAddr,
		// OpenAIUrl:     "",
		// OpenAIApiKey:  "",
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
// @Param request body object{m4t_server_addr=string,openai_url=string,openai_apikey=string} true "System config"
// @Success 200 {object} object{version=string,system=string}
// @Failure 400 {object} utils.Response
// @Router /sys/info [put]
func updateSysInfoHandle(c *gin.Context) {

	// mng := epub.GetManager()

	req := struct {
		M4tServerAddr string `json:"m4t_server_addr"`
		OpenAIUrl     string `json:"openai_url"`
		OpenAIApiKey  string `json:"openai_apikey"`
		// GrantType     string `json:"grant_type"`
	}{}

	if err := c.ShouldBind(&req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(400, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	if err := m4t.UpdateRemote(req.M4tServerAddr); err != nil {
		log.I(`更新m4t server 失败`, err)
		c.JSON(200, utils.ErrUpdateM4tServerAddr.WithMessage(err.Error()))
		return
	}

	gcf := conf.GetConfig()

	gcf.M4tOptions.RemoteAddr = req.M4tServerAddr

	if err := gcf.Save(); err != nil {
		log.I(`更新m4t server 失败`, err)
		c.JSON(200, utils.ErrUpdateM4tServerAddr.WithMessage(err.Error()))
		return
	}

	info := &ServerConfig{
		Version:       conf.Version,
		ChatEnabled:   len(gcf.ModelOptions) > 0,
		M4tEnabled:    len(gcf.M4tOptions.RemoteAddr) > 0,
		System:        "Linux", //TODO get real system info
		Architecture:  "AMD64", //TODO get real system info
		DocsDataPath:  gcf.EpubOptions.DataPath,
		M4tServerAddr: gcf.M4tOptions.RemoteAddr,
		// OpenAIUrl:     "",
		// OpenAIApiKey:  "",
	}

	c.JSON(http.StatusOK, info)

}
