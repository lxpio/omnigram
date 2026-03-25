package reader

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"go.uber.org/zap/zapcore"
)

func init() {
	gin.SetMode(gin.TestMode)
	log.Init("stdout", zapcore.DebugLevel)
}

// setupTestRouter creates a minimal gin router with sync handlers (no middleware).
func setupTestRouter() *gin.Engine {
	r := gin.New()
	r.POST("/sync/full", syncFullHandle)
	r.POST("/sync/delta", syncDeltaHandle)
	r.POST("/sync/books/batch", batchPushBooksHandle)
	r.GET("/sync/version", syncVersionHandle)
	return r
}

// --- syncVersionHandle tests ---

func TestSyncVersionHandle_ReturnsVersion(t *testing.T) {
	router := setupTestRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/sync/version", nil)
	router.ServeHTTP(w, req)

	if w.Code != 200 {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var resp map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatal("failed to parse response:", err)
	}

	// Check required fields
	if resp["version"] == nil {
		t.Error("missing 'version' field")
	}
	if resp["min_client_version"] == nil {
		t.Error("missing 'min_client_version' field")
	}
	features, ok := resp["features"].([]interface{})
	if !ok || len(features) == 0 {
		t.Error("missing or empty 'features' field")
	}

	// Verify expected features
	featureSet := make(map[string]bool)
	for _, f := range features {
		featureSet[f.(string)] = true
	}
	expected := []string{"delta_sync", "batch_push", "server_time", "failed_indices", "tombstone_delete"}
	for _, e := range expected {
		if !featureSet[e] {
			t.Errorf("missing expected feature: %s", e)
		}
	}
}

// --- syncDeltaHandle tests ---

func TestSyncDeltaHandle_MissingParams(t *testing.T) {
	router := setupTestRouter()

	w := httptest.NewRecorder()
	// Send empty JSON — missing required "limit" and "utime" fields
	body := bytes.NewBufferString(`{}`)
	req, _ := http.NewRequest("POST", "/sync/delta", body)
	req.Header.Set("Content-Type", "application/json")
	router.ServeHTTP(w, req)

	if w.Code != 200 {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var resp map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatal("failed to parse response:", err)
	}

	// Should return validation error for missing required params
	if resp["code"] == nil {
		t.Error("expected error code in response for missing params")
	}
}

func TestSyncFullHandle_MissingParams(t *testing.T) {
	router := setupTestRouter()

	w := httptest.NewRecorder()
	body := bytes.NewBufferString(`{}`)
	req, _ := http.NewRequest("POST", "/sync/full", body)
	req.Header.Set("Content-Type", "application/json")
	router.ServeHTTP(w, req)

	if w.Code != 200 {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var resp map[string]interface{}
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatal("failed to parse response:", err)
	}

	if resp["code"] == nil {
		t.Error("expected error code for missing params")
	}
}

// --- batchPushBooksHandle tests ---

func TestBatchPushBooksHandle_EmptyBody(t *testing.T) {
	router := setupTestRouter()

	w := httptest.NewRecorder()
	body := bytes.NewBufferString(`{}`)
	req, _ := http.NewRequest("POST", "/sync/books/batch", body)
	req.Header.Set("Content-Type", "application/json")
	router.ServeHTTP(w, req)

	// Empty books array should still succeed (0 synced)
	if w.Code != 200 {
		// May return 400 for missing "books" field — both are acceptable
		if w.Code != 400 {
			t.Fatalf("expected 200 or 400, got %d", w.Code)
		}
	}
}

func TestBatchPushBooksHandle_InvalidJSON(t *testing.T) {
	router := setupTestRouter()

	w := httptest.NewRecorder()
	body := bytes.NewBufferString(`{invalid json}`)
	req, _ := http.NewRequest("POST", "/sync/books/batch", body)
	req.Header.Set("Content-Type", "application/json")
	router.ServeHTTP(w, req)

	if w.Code != 400 {
		t.Fatalf("expected 400 for invalid JSON, got %d", w.Code)
	}
}

// --- logSyncEvent tests ---

func TestLogSyncEvent_DoesNotPanic(t *testing.T) {
	// logSyncEvent should not panic even without full context
	gin.SetMode(gin.TestMode)
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	c.Request, _ = http.NewRequest("POST", "/test", nil)

	// Should not panic
	logSyncEvent(c, "test_action", 5, 2)
}

// --- FullSyncReq / DeltaSyncReq struct tests ---

func TestFullSyncReq_JSONBinding(t *testing.T) {
	data := `{"limit": 100, "until": 1711234567890, "file_type": 1}`
	var req FullSyncReq
	if err := json.Unmarshal([]byte(data), &req); err != nil {
		t.Fatal("failed to unmarshal:", err)
	}
	if req.Limit != 100 {
		t.Errorf("expected limit=100, got %d", req.Limit)
	}
	if req.Util != 1711234567890 {
		t.Errorf("expected until=1711234567890, got %d", req.Util)
	}
}

func TestDeltaSyncReq_JSONBinding(t *testing.T) {
	data := `{"limit": 500, "utime": 1711234567890, "file_type": 1}`
	var req DeltaSyncReq
	if err := json.Unmarshal([]byte(data), &req); err != nil {
		t.Fatal("failed to unmarshal:", err)
	}
	if req.Limit != 500 {
		t.Errorf("expected limit=500, got %d", req.Limit)
	}
	if req.Utime != 1711234567890 {
		t.Errorf("expected utime=1711234567890, got %d", req.Utime)
	}
}
