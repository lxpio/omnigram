package ai

import (
	"context"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"go.uber.org/zap/zapcore"
)

// testdataDir returns the absolute path to the testdata directory.
func testdataDir() string {
	_, filename, _, _ := runtime.Caller(0)
	return filepath.Join(filepath.Dir(filename), "testdata")
}

func TestMain(m *testing.M) {
	// Initialize logger and config so tests don't panic on nil pointers.
	log.Init("stdout", zapcore.DebugLevel)
	_ = conf.InitTestConfig()
	os.Exit(m.Run())
}

// setupFakeAI starts a local HTTP server that replays fixture files.
// It returns the server and sets up conf + HTTPClient for tests.
//
// This is the core of the VCR approach:
//   - Fixtures in testdata/ are real AI API responses (recorded once)
//   - Tests replay them instantly, no AI API calls, no cost
//   - To re-record: call the real API, save response to testdata/
func setupFakeAI(t *testing.T, fixtures map[string]string) *httptest.Server {
	t.Helper()

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Match request path to fixture file
		fixture, ok := fixtures[r.URL.Path]
		if !ok {
			t.Errorf("unexpected request to %s", r.URL.Path)
			http.Error(w, "not found", 404)
			return
		}

		data, err := os.ReadFile(filepath.Join(testdataDir(), fixture))
		if err != nil {
			t.Fatalf("failed to read fixture %s: %v", fixture, err)
		}

		w.Header().Set("Content-Type", "application/json")
		w.Write(data)
	}))

	// Point AI config to our fake server
	cfg := conf.GetConfig()
	cfg.AIOptions = conf.AIOptions{
		Enabled:        true,
		Provider:       "test",
		BaseURL:        server.URL,
		APIKey:         "test-key",
		Model:          "test-model",
		EmbeddingModel: "test-embed",
	}

	// Inject test HTTP client (uses the fake server)
	HTTPClient = server.Client()

	t.Cleanup(func() {
		server.Close()
		HTTPClient = nil
	})

	return server
}

// setupFakeAIWithStatus returns a server that always responds with the given status code.
func setupFakeAIWithStatus(t *testing.T, statusCode int, body string) *httptest.Server {
	t.Helper()

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(statusCode)
		w.Write([]byte(body))
	}))

	cfg := conf.GetConfig()
	cfg.AIOptions = conf.AIOptions{
		Enabled:        true,
		Provider:       "test",
		BaseURL:        server.URL,
		APIKey:         "test-key",
		Model:          "test-model",
		EmbeddingModel: "test-embed",
	}

	HTTPClient = server.Client()

	t.Cleanup(func() {
		server.Close()
		HTTPClient = nil
	})

	return server
}

// ─── EnhanceMetadata Tests ──────────────────────────────────────────

func TestEnhanceMetadata_Success(t *testing.T) {
	setupFakeAI(t, map[string]string{
		"/chat/completions": "chat_completions.json",
	})

	result, err := EnhanceMetadata(context.Background(),
		"War and Peace", "Leo Tolstoy", "An epic novel about the French invasion of Russia")

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result == nil {
		t.Fatal("expected result, got nil")
	}

	// Structure assertions — verify the parsed fields are populated
	if result.Summary == "" {
		t.Error("expected non-empty summary")
	}
	if len(result.Tags) == 0 {
		t.Error("expected at least one tag")
	}
	if result.Language == "" {
		t.Error("expected non-empty language")
	}
	if result.Category == "" {
		t.Error("expected non-empty category")
	}

	// Sanity check: summary should be reasonable length
	if len(result.Summary) < 10 || len(result.Summary) > 1000 {
		t.Errorf("summary length %d seems wrong", len(result.Summary))
	}
}

func TestEnhanceMetadata_MalformedResponse(t *testing.T) {
	// AI returns plain text instead of JSON — should error gracefully
	setupFakeAI(t, map[string]string{
		"/chat/completions": "chat_completions_malformed.json",
	})

	result, err := EnhanceMetadata(context.Background(),
		"Unknown Book", "", "")

	if err == nil {
		t.Error("expected error for malformed AI response")
	}
	if result != nil {
		t.Error("expected nil result for malformed response")
	}
}

func TestEnhanceMetadata_Disabled(t *testing.T) {
	cfg := conf.GetConfig()
	cfg.AIOptions = conf.AIOptions{Enabled: false}

	result, err := EnhanceMetadata(context.Background(), "Test", "", "")

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result != nil {
		t.Error("expected nil result when AI is disabled")
	}
}

func TestEnhanceMetadata_APIError(t *testing.T) {
	setupFakeAIWithStatus(t, 500, `{"error":"internal server error"}`)

	result, err := EnhanceMetadata(context.Background(),
		"Test Book", "Author", "Description")

	if err == nil {
		t.Error("expected error for 500 response")
	}
	if result != nil {
		t.Error("expected nil result for API error")
	}
}

func TestEnhanceMetadata_RateLimited(t *testing.T) {
	setupFakeAIWithStatus(t, 429, `{"error":"rate limit exceeded"}`)

	_, err := EnhanceMetadata(context.Background(),
		"Test Book", "Author", "Description")

	if err == nil {
		t.Error("expected error for 429 response")
	}
}

// ─── GenerateEmbedding Tests ────────────────────────────────────────

func TestGenerateEmbedding_Success(t *testing.T) {
	setupFakeAI(t, map[string]string{
		"/embeddings": "embeddings.json",
	})

	embedding, err := GenerateEmbedding(context.Background(),
		"War and Peace by Leo Tolstoy")

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if embedding == nil {
		t.Fatal("expected embedding, got nil")
	}

	// Structure assertions
	if len(embedding) == 0 {
		t.Error("expected non-empty embedding vector")
	}

	// Sanity: embedding values should be small floats
	for i, v := range embedding {
		if v < -10 || v > 10 {
			t.Errorf("embedding[%d] = %f seems out of range", i, v)
		}
	}
}

func TestGenerateEmbedding_EmptyResponse(t *testing.T) {
	setupFakeAI(t, map[string]string{
		"/embeddings": "embeddings_empty.json",
	})

	_, err := GenerateEmbedding(context.Background(), "test text")

	if err == nil {
		t.Error("expected error for empty embedding response")
	}
}

func TestGenerateEmbedding_Disabled(t *testing.T) {
	cfg := conf.GetConfig()
	cfg.AIOptions = conf.AIOptions{Enabled: false}

	result, err := GenerateEmbedding(context.Background(), "test")

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result != nil {
		t.Error("expected nil when AI is disabled")
	}
}

func TestGenerateEmbedding_NoModel(t *testing.T) {
	cfg := conf.GetConfig()
	cfg.AIOptions = conf.AIOptions{Enabled: true, EmbeddingModel: ""}

	result, err := GenerateEmbedding(context.Background(), "test")

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result != nil {
		t.Error("expected nil when embedding model is not configured")
	}
}

func TestGenerateEmbedding_APIError(t *testing.T) {
	setupFakeAIWithStatus(t, 500, `{"error":"service unavailable"}`)

	_, err := GenerateEmbedding(context.Background(), "test text")

	if err == nil {
		t.Error("expected error for 500 response")
	}
}

// ─── FormatVector Tests ─────────────────────────────────────────────

func TestFormatVector(t *testing.T) {
	tests := []struct {
		name   string
		input  []float32
		expect string
	}{
		{"empty", []float32{}, "[]"},
		{"single", []float32{0.5}, "[0.5]"},
		{"multiple", []float32{0.1, -0.2, 0.3}, "[0.1,-0.2,0.3]"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := FormatVector(tt.input)
			if got != tt.expect {
				t.Errorf("FormatVector(%v) = %q, want %q", tt.input, got, tt.expect)
			}
		})
	}
}
