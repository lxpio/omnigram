package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
)

type CompletionResult struct {
	Summary     string   `json:"summary,omitempty"`
	Tags        []string `json:"tags,omitempty"`
	Language    string   `json:"language,omitempty"`
	Description string   `json:"description,omitempty"`
	Category    string   `json:"category,omitempty"`
}

func EnhanceMetadata(ctx context.Context, title, author, description string) (*CompletionResult, error) {
	opts := conf.GetConfig().AIOptions
	if !opts.Enabled {
		return nil, nil
	}

	prompt := fmt.Sprintf(`Given this book:
Title: %s
Author: %s
Description: %s

Return JSON with: {"summary": "2-3 sentence summary", "tags": ["tag1", "tag2"], "language": "detected language code", "category": "genre/category"}
Only fill fields that can be reasonably inferred. Return valid JSON only.`, title, author, description)

	body := map[string]any{
		"model": opts.Model,
		"messages": []map[string]string{
			{"role": "system", "content": "You are a librarian. Respond with valid JSON only."},
			{"role": "user", "content": prompt},
		},
		"temperature": 0.3,
		"max_tokens":  500,
	}

	jsonBody, _ := json.Marshal(body)

	req, err := http.NewRequestWithContext(ctx, "POST", opts.BaseURL+"/chat/completions", bytes.NewReader(jsonBody))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	if opts.APIKey != "" {
		req.Header.Set("Authorization", "Bearer "+opts.APIKey)
	}

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	respBody, _ := io.ReadAll(resp.Body)
	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, err
	}

	if len(result.Choices) == 0 {
		return nil, fmt.Errorf("no response from AI")
	}

	var completion CompletionResult
	content := result.Choices[0].Message.Content
	if err := json.Unmarshal([]byte(content), &completion); err != nil {
		log.E("AI response parse failed: ", err, " content: ", content)
		return nil, err
	}

	return &completion, nil
}
