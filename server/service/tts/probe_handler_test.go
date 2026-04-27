package tts

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
)

// fakeProvider lets us simulate fast/slow servers deterministically.
type fakeProvider struct {
	name       string
	delay      time.Duration
	body       []byte
	failOnCall bool
}

func (f *fakeProvider) Name() string                        { return f.name }
func (f *fakeProvider) Voices() []Voice                     { return nil }
func (f *fakeProvider) SupportsStreaming() bool             { return true }
func (f *fakeProvider) HealthCheck(_ context.Context) error { return nil }
func (f *fakeProvider) Synthesize(_ context.Context, _ string, _ SynthesisOptions) (io.ReadCloser, error) {
	if f.failOnCall {
		return nil, errors.New("synth failed")
	}
	time.Sleep(f.delay)
	return io.NopCloser(bytes.NewReader(f.body)), nil
}

func TestProbeReturnsFastTier(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	prov := &fakeProvider{
		name:  "fake-fast",
		delay: 100 * time.Millisecond,
		body:  bytes.Repeat([]byte{0}, 4096),
	}
	registerProbeHandlerForTest(r, prov, "test-build-1")

	body, _ := json.Marshal(map[string]any{"voice": "test", "language": "en-US"})
	req := httptest.NewRequest(http.MethodPost, "/tts/probe", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("status %d body %s", w.Code, w.Body.String())
	}

	var got struct {
		Code int                    `json:"code"`
		Data map[string]interface{} `json:"data"`
	}
	if err := json.NewDecoder(w.Body).Decode(&got); err != nil {
		t.Fatal(err)
	}
	fb, _ := got.Data["first_byte_ms"].(float64)
	if fb < 50 || fb > 1500 {
		t.Errorf("first_byte_ms = %v, expected 50–1500", fb)
	}
	if sb, _ := got.Data["server_build"].(string); sb != "test-build-1" {
		t.Errorf("server_build = %q, want test-build-1", sb)
	}
}

func TestProbeFailsGracefully(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	prov := &fakeProvider{name: "broken", failOnCall: true}
	registerProbeHandlerForTest(r, prov, "test-build-1")

	body, _ := json.Marshal(map[string]any{"voice": "x"})
	req := httptest.NewRequest(http.MethodPost, "/tts/probe", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusServiceUnavailable {
		t.Errorf("status = %d, want 503; body=%s", w.Code, strings.TrimSpace(w.Body.String()))
	}
}
