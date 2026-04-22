package tts

import (
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/lxpio/omnigram/server/log"
	"go.uber.org/zap/zapcore"
)

func TestMain(m *testing.M) {
	// Initialize global logger so log.W/log.I calls inside Voices() don't nil-panic.
	dir, err := os.MkdirTemp("", "tts-test-log")
	if err != nil {
		panic(err)
	}
	log.Init(dir, zapcore.InfoLevel)
	code := m.Run()
	os.RemoveAll(dir)
	os.Exit(code)
}

func TestSidecarVoicesFetchOpenAIEnvelope(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/v1/voices" {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"data":[
			{"id":"zh-CN-XiaoxiaoNeural","name":"Xiaoxiao","language":"zh-CN","gender":"female"},
			{"id":"af_heart","name":"Heart","language":"en","gender":"female"}
		]}`))
	}))
	defer srv.Close()

	p := NewSidecarProvider("kokoro", srv.URL, 2*time.Second)
	voices := p.Voices()

	if len(voices) != 2 {
		t.Fatalf("expected 2 voices, got %d", len(voices))
	}
	if voices[0].ID != "zh-CN-XiaoxiaoNeural" || voices[0].Language != "zh-CN" {
		t.Fatalf("unexpected first voice: %+v", voices[0])
	}

	// Second call should hit cache — we verify by shutting down the server.
	srv.Close()
	cached := p.Voices()
	if len(cached) != 2 {
		t.Fatalf("expected cached voices, got %d", len(cached))
	}
}

func TestSidecarVoicesFetchQwenEnvelope(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"voices":[
			{"id":"serena","name":"serena","language":"auto","description":"x"},
			{"id":"uncle_fu","name":"uncle_fu","language":"auto"}
		]}`))
	}))
	defer srv.Close()

	p := NewSidecarProvider("qwen3", srv.URL, 2*time.Second)
	voices := p.Voices()
	if len(voices) != 2 || voices[0].ID != "serena" {
		t.Fatalf("unexpected voices: %+v", voices)
	}
}

func TestSidecarVoicesFetchBareList(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`[{"id":"v1","name":"Voice One","locale":"ja-JP"}]`))
	}))
	defer srv.Close()

	p := NewSidecarProvider("kokoro", srv.URL, 2*time.Second)
	voices := p.Voices()
	if len(voices) != 1 || voices[0].ID != "v1" || voices[0].Language != "ja-JP" {
		t.Fatalf("unexpected voices: %+v", voices)
	}
}

func TestSidecarVoicesFallbackOnError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, "boom", http.StatusInternalServerError)
	}))
	defer srv.Close()

	p := NewSidecarProvider("kokoro", srv.URL, 2*time.Second)
	voices := p.Voices()
	if len(voices) != len(fallbackVoices) {
		t.Fatalf("expected fallback (%d voices), got %d", len(fallbackVoices), len(voices))
	}
}

func TestSidecarVoicesFallbackOnUnreachable(t *testing.T) {
	p := NewSidecarProvider("kokoro", "http://127.0.0.1:1", 500*time.Millisecond)
	voices := p.Voices()
	if len(voices) != len(fallbackVoices) {
		t.Fatalf("expected fallback when unreachable, got %d", len(voices))
	}
}
