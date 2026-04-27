package tts

import (
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/schema"
)

type probeRequest struct {
	Voice    string  `json:"voice" binding:"required"`
	Speed    float64 `json:"speed"`
	Language string  `json:"language"`
}

// probeAssumedAudioMs is the rough audio duration of the locale fixtures
// produced by ProbeText at speed 1.0×. We avoid parsing audio headers and
// instead use this fixed estimate to compute RTF; clients only need a
// coarse tier classification (GREEN/YELLOW/RED), not exact timing.
const probeAssumedAudioMs = 5000

// probeHandler measures real-time synthesis cost for the user's voice and
// returns first-byte latency, total time, and an RTF estimate so the client
// can pick a capability tier.
//
// @Summary     TTS capability probe
// @Description Synchronously synthesize a fixed neutral text and report
// @Description first-byte latency + RTF. The client uses these to classify
// @Description the server into GREEN/YELLOW/RED/NA tiers and decide whether
// @Description to play live, pre-generate, or fall back to on-device TTS.
// @Tags        TTS
// @Accept      json
// @Produce     json
// @Security    BearerAuth
// @Param       body body probeRequest true "Probe request"
// @Success     200 {object} schema.ProbeResult
// @Failure     400 {object} schema.ErrorResponse
// @Failure     503 {object} schema.ErrorResponse
// @Router      /tts/probe [post]
func probeHandler(c *gin.Context) {
	if manager == nil || manager.primary == nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": 503, "message": "TTS not configured"})
		return
	}
	doProbe(c, manager.primary, conf.Version)
}

// doProbe is the testable core; production callers pass the live provider.
func doProbe(c *gin.Context, provider TTSProvider, build string) {
	var req probeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": err.Error()})
		return
	}
	if req.Speed == 0 {
		req.Speed = 1.0
	}

	text := ProbeText(req.Language)
	opts := DefaultSynthesisOptions()
	opts.Voice = req.Voice
	opts.Speed = req.Speed
	opts.Language = req.Language

	start := time.Now()
	rc, err := provider.Synthesize(c.Request.Context(), text, opts)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": 503, "message": err.Error()})
		return
	}
	defer rc.Close()

	buf := make([]byte, 4096)
	var firstByteMs int64
	for firstByteMs == 0 {
		n, rerr := rc.Read(buf)
		if n > 0 {
			firstByteMs = time.Since(start).Milliseconds()
		}
		if rerr == io.EOF {
			break
		}
		if rerr != nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{"code": 503, "message": rerr.Error()})
			return
		}
	}
	if _, err := io.Copy(io.Discard, rc); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"code": 503, "message": err.Error()})
		return
	}
	totalMs := time.Since(start).Milliseconds()

	rtf := float64(totalMs) / float64(probeAssumedAudioMs)
	if rtf <= 0 {
		rtf = 0.01
	}

	res := schema.ProbeResult{
		FirstByteMs:     firstByteMs,
		TotalMs:         totalMs,
		AudioDurationMs: probeAssumedAudioMs,
		RTF:             rtf,
		Voice:           req.Voice,
		Provider:        provider.Name(),
		ServerBuild:     strings.TrimSpace(build),
	}
	c.JSON(http.StatusOK, gin.H{"code": 200, "data": res})
}

// registerProbeHandlerForTest wires the handler to an arbitrary provider for tests.
func registerProbeHandlerForTest(r *gin.Engine, p TTSProvider, build string) {
	r.POST("/tts/probe", func(c *gin.Context) { doProbe(c, p, build) })
}
