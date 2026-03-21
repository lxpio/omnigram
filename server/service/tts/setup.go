package tts

import (
	"context"
	"io"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/utils"
)

var manager *TTSManager
var worker *AudiobookWorker

// Initialize sets up the TTS providers based on config.
func Initialize(ctx context.Context) {
	cf := conf.GetConfig()

	var primary TTSProvider
	var fallback TTSProvider

	timeout, err := time.ParseDuration(cf.TTSOptions.Timeout)
	if err != nil {
		timeout = 120 * time.Second
	}

	switch cf.TTSOptions.Provider {
	case "kokoro", "sidecar":
		if cf.TTSOptions.SidecarURL != "" {
			primary = NewSidecarProvider("kokoro", cf.TTSOptions.SidecarURL, timeout)
			log.I("TTS: using Kokoro sidecar at " + cf.TTSOptions.SidecarURL)
		}
		fallback = NewEdgeTTSProvider()
	case "edge":
		primary = NewEdgeTTSProvider()
	default:
		primary = NewEdgeTTSProvider()
		log.I("TTS: defaulting to Edge TTS")
	}

	manager = NewTTSManager(primary, fallback, timeout)

	worker = NewAudiobookWorker(manager)
	worker.Start()
}

// Setup registers TTS HTTP routes.
func Setup(router *gin.Engine) {
	oauthMD := middleware.Get(middleware.OathMD)

	router.POST("/tts/synthesize", oauthMD, synthesizeHandler)
	router.GET("/tts/voices", oauthMD, voicesHandler)
	router.GET("/tts/health", oauthMD, healthHandler)

	router.POST("/tts/audiobook/:book_id", oauthMD, createAudiobookHandler)
	router.POST("/tts/audiobook/:book_id/chapter/:idx", oauthMD, createChapterHandler)
	router.GET("/tts/tasks/:id", oauthMD, getTaskHandler)
	router.GET("/tts/tasks/:id/stream", oauthMD, streamTaskHandler)
	router.GET("/tts/audiobook/:book_id", oauthMD, getAudiobookHandler)
	router.GET("/tts/audiobook/:book_id/:chapter", oauthMD, downloadChapterHandler)
	router.DELETE("/tts/audiobook/:book_id", oauthMD, deleteAudiobookHandler)
}

// Close cleans up TTS resources.
func Close() {
	if worker != nil {
		worker.Stop()
	}
}

// synthesizeHandler handles text-to-speech synthesis requests.
func synthesizeHandler(c *gin.Context) {
	var req struct {
		Text     string  `json:"text" binding:"required"`
		Voice    string  `json:"voice"`
		Speed    float64 `json:"speed"`
		Format   string  `json:"format"`
		Language string  `json:"language"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	opts := DefaultSynthesisOptions()
	if req.Voice != "" {
		opts.Voice = req.Voice
	}
	if req.Speed > 0 {
		opts.Speed = req.Speed
	}
	if req.Format != "" {
		opts.Format = req.Format
	}
	if req.Language != "" {
		opts.Language = req.Language
	}

	reader, err := manager.Synthesize(c.Request.Context(), req.Text, opts)
	if err != nil {
		log.E("TTS synthesis failed: " + err.Error())
		c.JSON(http.StatusInternalServerError, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}
	defer reader.Close()

	contentType := "audio/mpeg"
	switch opts.Format {
	case "wav":
		contentType = "audio/wav"
	case "ogg":
		contentType = "audio/ogg"
	}

	c.Header("Content-Type", contentType)
	c.Header("Transfer-Encoding", "chunked")
	c.Header("Cache-Control", "no-cache")
	c.Status(http.StatusOK)
	c.Stream(func(w io.Writer) bool {
		buf := make([]byte, 8192)
		n, err := reader.Read(buf)
		if n > 0 {
			w.Write(buf[:n])
			return true
		}
		if err != nil {
			return false
		}
		return true
	})
}

// voicesHandler returns available voices.
func voicesHandler(c *gin.Context) {
	if manager == nil || manager.primary == nil {
		c.JSON(http.StatusOK, utils.SUCCESS.WithData([]Voice{}))
		return
	}
	voices := manager.primary.Voices()
	c.JSON(http.StatusOK, utils.SUCCESS.WithData(voices))
}

// healthHandler checks TTS provider health.
func healthHandler(c *gin.Context) {
	if manager == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"status": "unavailable"})
		return
	}
	if err := manager.HealthCheck(c.Request.Context()); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"status": "unhealthy", "error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "healthy"})
}
