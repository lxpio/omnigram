package tts

import (
	"context"
	"errors"
	"io"
)

// EdgeTTSProvider calls Microsoft Edge TTS free API directly.
// ⚠️ Non-official API, no SLA, may be rate-limited or discontinued.
type EdgeTTSProvider struct{}

func NewEdgeTTSProvider() *EdgeTTSProvider {
	return &EdgeTTSProvider{}
}

func (p *EdgeTTSProvider) Name() string { return "edge" }

func (p *EdgeTTSProvider) Synthesize(ctx context.Context, text string, opts SynthesisOptions) (io.ReadCloser, error) {
	// TODO: implement Edge TTS WebSocket protocol
	// Reference: github.com/pgupta56/edge-tts-go or similar Go library
	return nil, errors.New("Edge TTS not yet implemented; use as fallback placeholder")
}

func (p *EdgeTTSProvider) Voices() []Voice {
	return []Voice{
		{ID: "zh-CN-XiaoxiaoNeural", Name: "Xiaoxiao", Language: "zh-CN", Gender: "female"},
		{ID: "zh-CN-YunxiNeural", Name: "Yunxi", Language: "zh-CN", Gender: "male"},
		{ID: "en-US-JennyNeural", Name: "Jenny", Language: "en-US", Gender: "female"},
		{ID: "en-US-GuyNeural", Name: "Guy", Language: "en-US", Gender: "male"},
		{ID: "ja-JP-NanamiNeural", Name: "Nanami", Language: "ja-JP", Gender: "female"},
	}
}

func (p *EdgeTTSProvider) SupportsStreaming() bool { return false }

func (p *EdgeTTSProvider) HealthCheck(_ context.Context) error {
	// Edge TTS is external, always "available" from our side
	return nil
}
