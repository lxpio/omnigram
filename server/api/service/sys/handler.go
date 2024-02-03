package sys

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/api/service/m4t"
	"github.com/lxpio/omnigram/server/api/conf"
	"github.com/lxpio/omnigram/server/api/log"
	"github.com/lxpio/omnigram/server/api/utils"
)

type ServerConfig struct {
	Version     string `json:"version"`
	ChatEnabled bool   `json:"chat_enabled,omitempty"`
	M4tEnabled  bool   `json:"m4t_enabled,omitempty"`
	// ScanStatus   selfhost.ScanStatus `json:"scan_stats"`
	System       string `json:"system,omitempty"`
	Architecture string `json:"architecture,omitempty"`
	DocsDataPath string `json:"docs_data_path"`

	// DiskUsage int `json:"disk_usage"`

	M4tServerAddr string `json:"m4t_server_addr,omitempty"`
	OpenAIUrl     string `json:"openai_url,omitempty"`
	OpenAIApiKey  string `json:"openai_apikey,omitempty"`
}

// getSysInfoHandle get User Authorization
/**
 * @api {get} /sys/info Get Current Server Info
 * @apiName getSysInfoHandle
 * @apiGroup sys
 * @apiDescription Get server configs. if chat server has configed, or the
 * m4t service is support.
 *
 * @apiHeader {String} Authorization Users unique auth key.
 *
 * @apiSuccess {Boolean} chatserver     Always set to Bearer.
 * @apiSuccess {Number} expires_in     Number of seconds that the included access token is valid for.
 * @apiSuccess {String} refresh_token  Issued if the original scope parameter included offline_access.
 * @apiSuccess {String} access_token   Issued for the scopes that were requested.
 */
func getSysInfoHandle(c *gin.Context) {

	// mng := epub.GetManager()

	info := &ServerConfig{
		Version:       conf.Version,
		ChatEnabled:   true,
		M4tEnabled:    true,
		System:        "Linux", //TODO get real system info
		Architecture:  "AMD64", //TODO get real system info
		DocsDataPath:  gcf.EpubOptions.DataPath,
		M4tServerAddr: gcf.M4tOptions.RemoteAddr,
		// OpenAIUrl:     "",
		// OpenAIApiKey:  "",
	}

	c.JSON(http.StatusOK, utils.SUCCESS.WithData(info))

}

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

	c.JSON(http.StatusOK, utils.SUCCESS.WithData(info))

}
