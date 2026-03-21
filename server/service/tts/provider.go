package tts

import (
	"context"
	"io"
)

// TTSProvider defines the interface for all TTS engines.
type TTSProvider interface {
	Name() string
	Synthesize(ctx context.Context, text string, opts SynthesisOptions) (io.ReadCloser, error)
	Voices() []Voice
	SupportsStreaming() bool
	HealthCheck(ctx context.Context) error
}

// SynthesisOptions configures a single TTS synthesis call.
type SynthesisOptions struct {
	Voice      string
	Speed      float64
	Format     string // mp3, wav, ogg
	Language   string
	SampleRate int    // 44100 (default)
	BitRate    int    // 128 kbps (default)
	SSML       string // optional, reserved for future use
}

// Voice represents an available TTS voice.
type Voice struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Language string `json:"language"`
	Gender   string `json:"gender"`
	Preview  string `json:"preview"` // preview audio URL
}

// DefaultSynthesisOptions returns sensible defaults.
func DefaultSynthesisOptions() SynthesisOptions {
	return SynthesisOptions{
		Speed:      1.0,
		Format:     "mp3",
		SampleRate: 44100,
		BitRate:    128,
	}
}
