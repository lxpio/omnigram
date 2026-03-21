package tts

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// SidecarProvider implements TTSProvider for any OpenAI-compatible TTS sidecar.
type SidecarProvider struct {
	name    string
	baseURL string
	client  *http.Client
}

// NewSidecarProvider creates a provider targeting a sidecar container.
func NewSidecarProvider(name, baseURL string, timeout time.Duration) *SidecarProvider {
	return &SidecarProvider{
		name:    name,
		baseURL: baseURL,
		client: &http.Client{
			Timeout: timeout,
		},
	}
}

func (p *SidecarProvider) Name() string { return p.name }

func (p *SidecarProvider) Synthesize(ctx context.Context, text string, opts SynthesisOptions) (io.ReadCloser, error) {
	body := map[string]any{
		"model":           p.name,
		"input":           text,
		"voice":           opts.Voice,
		"speed":           opts.Speed,
		"response_format": opts.Format,
	}

	jsonBody, err := json.Marshal(body)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", p.baseURL+"/v1/audio/speech", bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := p.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("sidecar request: %w", err)
	}
	if resp.StatusCode != http.StatusOK {
		resp.Body.Close()
		return nil, fmt.Errorf("TTS sidecar returned %d", resp.StatusCode)
	}
	return resp.Body, nil // caller must Close()
}

func (p *SidecarProvider) Voices() []Voice {
	// TODO: query sidecar /v1/voices endpoint if available
	return []Voice{
		{ID: "af_heart", Name: "Heart", Language: "en", Gender: "female"},
		{ID: "af_star", Name: "Star", Language: "en", Gender: "female"},
		{ID: "am_adam", Name: "Adam", Language: "en", Gender: "male"},
	}
}

func (p *SidecarProvider) SupportsStreaming() bool { return false }

func (p *SidecarProvider) HealthCheck(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, "GET", p.baseURL+"/health", nil)
	if err != nil {
		return err
	}
	resp, err := p.client.Do(req)
	if err != nil {
		return fmt.Errorf("sidecar health check: %w", err)
	}
	resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("sidecar health check returned %d", resp.StatusCode)
	}
	return nil
}
