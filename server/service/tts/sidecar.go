package tts

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"

	"github.com/lxpio/omnigram/server/log"
)

// voicesCacheTTL controls how long the provider caches the sidecar's voice list.
// The sidecar's voice catalog is effectively static between restarts, so a few
// minutes is plenty to absorb UI polling without staleness issues.
const voicesCacheTTL = 5 * time.Minute

// fallbackVoices is returned when the sidecar's /v1/voices endpoint is
// unreachable or malformed. Keeps the TTS feature usable with a known-good
// set of English voices (Kokoro default).
var fallbackVoices = []Voice{
	{ID: "af_heart", Name: "Heart", Language: "en", Gender: "female"},
	{ID: "af_star", Name: "Star", Language: "en", Gender: "female"},
	{ID: "am_adam", Name: "Adam", Language: "en", Gender: "male"},
}

// SidecarProvider implements TTSProvider for any OpenAI-compatible TTS sidecar.
type SidecarProvider struct {
	name    string
	baseURL string
	apiKey  string // optional, for authenticated APIs (e.g., OpenAI)
	client  *http.Client

	voicesMu     sync.RWMutex
	voicesCache  []Voice
	voicesExpiry time.Time
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

// NewSidecarProviderWithAuth creates a provider with API key authentication.
func NewSidecarProviderWithAuth(name, baseURL, apiKey string, timeout time.Duration) *SidecarProvider {
	return &SidecarProvider{
		name:    name,
		baseURL: baseURL,
		apiKey:  apiKey,
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
	if p.apiKey != "" {
		req.Header.Set("Authorization", "Bearer "+p.apiKey)
	}

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

// Voices queries the sidecar's /v1/voices endpoint (OpenAI-compatible), caching
// the result for voicesCacheTTL. On failure, returns fallbackVoices so the UI
// stays functional.
func (p *SidecarProvider) Voices() []Voice {
	p.voicesMu.RLock()
	if time.Now().Before(p.voicesExpiry) && len(p.voicesCache) > 0 {
		voices := p.voicesCache
		p.voicesMu.RUnlock()
		return voices
	}
	p.voicesMu.RUnlock()

	fetched, err := p.fetchVoices()
	if err != nil || len(fetched) == 0 {
		if err != nil {
			log.W("TTS: sidecar voices fetch failed (" + err.Error() + "), using fallback list")
		}
		return fallbackVoices
	}

	p.voicesMu.Lock()
	p.voicesCache = fetched
	p.voicesExpiry = time.Now().Add(voicesCacheTTL)
	p.voicesMu.Unlock()
	return fetched
}

func (p *SidecarProvider) fetchVoices() ([]Voice, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, "GET", p.baseURL+"/v1/voices", nil)
	if err != nil {
		return nil, err
	}
	if p.apiKey != "" {
		req.Header.Set("Authorization", "Bearer "+p.apiKey)
	}

	resp, err := p.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("voices endpoint returned %d", resp.StatusCode)
	}

	// Accept both OpenAI-style {"data": [...]} and a bare list (some sidecars).
	raw, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	type rawVoice struct {
		ID       string `json:"id"`
		Name     string `json:"name"`
		Language string `json:"language"`
		Locale   string `json:"locale"`
		Gender   string `json:"gender"`
		Preview  string `json:"preview"`
	}

	var list []rawVoice
	// Accept three common shapes:
	//   OpenAI:          {"data":[...]}
	//   Qwen3-TTS:       {"voices":[...]}
	//   Bare list:       [...]
	var envelope struct {
		Data   []rawVoice `json:"data"`
		Voices []rawVoice `json:"voices"`
	}
	if jsonErr := json.Unmarshal(raw, &envelope); jsonErr == nil {
		if len(envelope.Data) > 0 {
			list = envelope.Data
		} else if len(envelope.Voices) > 0 {
			list = envelope.Voices
		}
	}
	if len(list) == 0 {
		if jsonErr := json.Unmarshal(raw, &list); jsonErr != nil || len(list) == 0 {
			return nil, fmt.Errorf("unexpected voices payload")
		}
	}

	voices := make([]Voice, 0, len(list))
	for _, v := range list {
		if v.ID == "" {
			continue
		}
		name := v.Name
		if name == "" {
			name = v.ID
		}
		lang := v.Language
		if lang == "" {
			lang = v.Locale
		}
		voices = append(voices, Voice{
			ID:       v.ID,
			Name:     name,
			Language: lang,
			Gender:   v.Gender,
			Preview:  v.Preview,
		})
	}
	return voices, nil
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
