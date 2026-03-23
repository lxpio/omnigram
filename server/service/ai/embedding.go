package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"gorm.io/gorm"
)

// GenerateEmbedding calls the OpenAI-compatible embedding API.
func GenerateEmbedding(ctx context.Context, text string) ([]float32, error) {
	opts := conf.GetConfig().AIOptions
	if !opts.Enabled || opts.EmbeddingModel == "" {
		return nil, nil
	}

	body := map[string]any{
		"model": opts.EmbeddingModel,
		"input": text,
	}

	jsonBody, _ := json.Marshal(body)

	req, err := http.NewRequestWithContext(ctx, "POST", opts.BaseURL+"/embeddings", bytes.NewReader(jsonBody))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	if opts.APIKey != "" {
		req.Header.Set("Authorization", "Bearer "+opts.APIKey)
	}

	resp, err := getHTTPClient().Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		respBody, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("embedding API returned status %d: %s", resp.StatusCode, string(respBody))
	}

	var result struct {
		Data []struct {
			Embedding []float32 `json:"embedding"`
		} `json:"data"`
	}

	respBody, _ := io.ReadAll(resp.Body)
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, err
	}

	if len(result.Data) == 0 {
		return nil, fmt.Errorf("no embedding returned")
	}

	log.D("Generated embedding with %d dimensions", len(result.Data[0].Embedding))
	return result.Data[0].Embedding, nil
}

// IsEmbeddingAvailable returns whether embedding generation is configured.
func IsEmbeddingAvailable() bool {
	opts := conf.GetConfig().AIOptions
	return opts.Enabled && opts.EmbeddingModel != ""
}

// FormatVector converts []float32 to pgvector string format [0.1,0.2,...].
func FormatVector(v []float32) string {
	var b strings.Builder
	b.WriteByte('[')
	for i, f := range v {
		if i > 0 {
			b.WriteByte(',')
		}
		fmt.Fprintf(&b, "%g", f)
	}
	b.WriteByte(']')
	return b.String()
}

// GenerateBookEmbedding generates and stores a book's embedding vector.
func GenerateBookEmbedding(ctx context.Context, db *gorm.DB, bookID string, title, author, description string) error {
	text := fmt.Sprintf("%s by %s. %s", title, author, description)
	embedding, err := GenerateEmbedding(ctx, text)
	if err != nil || embedding == nil {
		return err
	}
	vecStr := FormatVector(embedding)
	return db.Exec("UPDATE books SET embedding = ? WHERE id = ?", vecStr, bookID).Error
}
