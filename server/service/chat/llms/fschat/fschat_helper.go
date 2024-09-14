package fschat

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"github.com/lxpio/omnigram/server/service/chat/llms"
	"github.com/lxpio/omnigram/server/service/chat/llms/schema"
)

// var (
// 	StreamPrefixDATA  = []byte("data: ")
// 	StreamPrefixERROR = []byte("error: ")
// 	StreamDataDONE    = []byte("[DONE]")
// )

// var lineDelimiter = []byte{0} // line delimiter

type MultipartFormDataRequestBody interface {
	ToMultipartFormData() (*bytes.Buffer, string, error)
}

func call[T any](ctx context.Context, client *FSChat, method string, p string, body interface{}, resp T, cb schema.SreamCallBack) (T, error) {
	req, err := client.build(ctx, method, p, body)
	if err != nil {
		return resp, err
	}
	err = execute(client, req, &resp, cb)

	return resp, err
}

func execute[T any](client *FSChat, req *http.Request, response *T, cb schema.SreamCallBack) error {
	if client.HTTPClient == nil {
		client.HTTPClient = http.DefaultClient
	}
	httpres, err := client.HTTPClient.Do(req)
	if err != nil {
		return err
	}
	if httpres.StatusCode >= 400 {
		defer httpres.Body.Close()
		return client.apiError(httpres)
	}
	if cb != nil {
		go listen(httpres, cb)
		return nil
	}
	defer httpres.Body.Close()
	if err := json.NewDecoder(httpres.Body).Decode(response); err != nil {
		return fmt.Errorf("failed to decode response to %T: %v", response, err)
	}
	return nil
}

type fschatResp struct {
	Text      string       `json:"text,omitempty"`
	ErrorCode int          `json:"error_code"`
	Usage     schema.Usage `json:"usage,omitempty"`

	FinishReason string `json:"finish_reason,omitempty"`
}

// https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#event_stream_format
func listen(res *http.Response, cb schema.SreamCallBack) {

	var rErr error

	defer func() {

		cb(nil, true, rErr)

		res.Body.Close()
	}()

	r := bufio.NewReader(res.Body)

	for {

		line, err := r.ReadSlice(0)

		if err != nil {
			if err != io.EOF {
				rErr = err
			}

			return
		}

		if len(line) == 0 {
			continue
		}

		entry := fschatResp{}

		if err := json.Unmarshal(line[:len(line)-1], &entry); err != nil {
			rErr = err
			return
		}

		if entry.ErrorCode != 0 {
			rErr = fmt.Errorf(entry.Text)
			return
		}

		msg := schema.BuildAIMessage(entry.Text)

		retD := &schema.ChatResponse{
			ID: "todo",
			// Created: 0,
			Choices: []schema.Choice{{
				FinishReason: entry.FinishReason,
			}},
			Usage: entry.Usage,
		}

		if entry.FinishReason != `` {
			retD.Choices[0].Message = &msg
			cb(retD, false, nil)
		} else {
			retD.Choices[0].Delta = &msg
			cb(retD, false, nil)
		}

	}

}

func (l *FSChat) endpoint(p string) (string, error) {

	if len(l.Endpoints) == 0 {
		return ``, errors.New(`无可用模型地址`)
	}
	// 生成随机索引
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	index := r.Intn(len(l.Endpoints))

	return strings.Join([]string{l.Endpoints[index], strings.TrimLeft(p, "/")}, "/"), nil
}

func (l *FSChat) build(ctx context.Context, method, p string, body interface{}) (req *http.Request, err error) {
	endpoint, err := l.endpoint(p)
	if err != nil {
		return nil, err
	}
	r, contenttype, err := l.bodyToReader(body)
	if err != nil {
		return nil, fmt.Errorf("failed to build request buf from given body: %v", err)
	}
	req, err = http.NewRequest(method, endpoint, r)
	if err != nil {
		return nil, fmt.Errorf("failed to init request: %v", err)
	}
	req.Header.Add("Content-Type", contenttype)
	// req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", l.APIKey))
	// if l.Organization != "" {
	// 	req.Header.Add("OpenAI-Organization", l.Organization)
	// }
	if ctx != nil {
		req = req.WithContext(ctx)
	}
	return req, nil
}

func (l *FSChat) bodyToReader(body interface{}) (io.Reader, string, error) {
	var r io.Reader
	switch v := body.(type) {
	// case io.Reader:
	// 	r = v
	case nil:
		r = nil
	case MultipartFormDataRequestBody: // TODO: Refactor
		buf, ct, err := v.ToMultipartFormData()
		if err != nil {
			return nil, "", err
		}
		return buf, ct, nil
	default:
		b, err := json.Marshal(body)
		if err != nil {
			return nil, "", err
		}

		r = bytes.NewBuffer(b)
	}
	return r, "application/json", nil
}

func (l *FSChat) apiError(res *http.Response) error {

	return fmt.Errorf("status: %s, status_code: %d", res.Status, res.StatusCode)

}

func (l *FSChat) defaultChatRequest(prompt string, options ...llms.CallOption) *schema.ChatRequest {

	opts := llms.InitCallOptions(options...)

	msg := schema.Message{Role: `user`, Content: prompt}

	req := &schema.ChatRequest{
		Model:       l.Model,
		Messages:    []schema.Message{msg},
		Temperature: float32(opts.Temperature),
		TopP:        1,
		N:           1,
		Stream:      false,
		// StreamCallback: ,
		Stop:             opts.StopWords,
		MaxTokens:        opts.MaxTokens,
		PresencePenalty:  0,
		FrequencyPenalty: 0,
		LogitBias:        nil,
		User:             "",
	}

	if opts.CallBackFn != nil {
		req.Stream = true
		req.StreamCallback = opts.CallBackFn
	}

	return req
}
