package fschat

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/lxpio/omnigram/server/service/chat/llms"
	"github.com/lxpio/omnigram/server/service/chat/llms/schema"
)

var _ llms.LLM = &FSChat{}

// TODO: FSChat 实现直接发送请求到 Vicuna 模型，当前系统是通过OPEN AI兼容接口请求，此类方法需要额外启动一个python的web后端，完成
// FSChat 实现以后后端可以少开启一个服务
type FSChat struct {
	Model string `json:"model" yaml:"model"`
	// APIKey issued by OpenAI console.

	// BaseURL of API including the version.
	// e.g., https://api.openai.com/v1
	Endpoints []string `json:"endpoints" yaml:"endpoints"`

	// HTTPClient (optional) to proxy HTTP request.
	// If nil, *http.DefaultClient will be used.
	HTTPClient *http.Client `json:"-" yaml:"-"`
}

// New return OpenAI compatiable client
func New(opts ...ModelOption) *FSChat {

	client := defaultFSChat()

	for _, fn := range opts {
		fn(client)
	}

	return client
}

// Call implements llms.LLM.
func (l *FSChat) Call(ctx context.Context, prompt string) (string, error) {

	req := l.defaultChatRequest(prompt)

	data, err := l.Chat(ctx, req)

	ret := ``
	if err != nil || data == nil {
		//TODO
		return ret, err
	}

	for _, v := range data.Choices {
		if v.Message != nil {
			ret += v.Message.Content
		}

	}

	return ret, nil
}

// Chat implements llms.LLM.
func (l *FSChat) Chat(ctx context.Context, req *schema.ChatRequest) (resp *schema.ChatResponse, err error) {

	if req.N > 1 {
		fmt.Printf(`current input N is %d , we will replace by 1 right now`, req.N)
	}

	prompt := l.PromptMessage(req.Messages)
	//TODO： 再统一的地方处理
	if req.MaxTokens == 0 {
		req.MaxTokens = 512
	}

	vreq := map[string]any{
		"model":          l.Model,
		"prompt":         prompt,
		"temperature":    req.Temperature,
		"top_p":          req.TopP,
		"max_new_tokens": req.MaxTokens,
		"stream":         req.Stream,
	}

	if req.StreamCallback != nil {
		req.Stream = true // Nosy ;)
		p := `/worker_generate_stream`
		return call(ctx, l, http.MethodPost, p, vreq, resp, req.StreamCallback)
	}

	p := `/worker_generate`

	vResp := fschatResp{}

	vResp, err = call(ctx, l, http.MethodPost, p, vreq, vResp, nil)

	if err != nil {
		return
	}

	//|| len(vResp.Text) < len(prompt)

	if vResp.ErrorCode != 0 {
		return nil, fmt.Errorf(vResp.Text)
	}

	msg := schema.BuildAIMessage(vResp.Text[len(prompt):])

	resp = &schema.ChatResponse{
		ID:      "TODO",
		Object:  "chat.completion",
		Created: time.Now().Unix(),
		Choices: []schema.Choice{
			{
				Index:        0,
				FinishReason: vResp.FinishReason,
				Message:      &msg,
			},
		},
		Usage: vResp.Usage,
	}

	return

}

// Completion implements llms.LLM.
func (*FSChat) Completion(ctx context.Context, req *schema.CompletionRequest) (*schema.CompletionResponse, error) {
	panic("unimplemented")
}

// Embeddings implements llms.LLM.
func (l *FSChat) Embeddings(ctx context.Context, req *schema.EmbeddingsRequest) (ret *schema.EmbeddingsResponse, err error) {
	p := `/worker_get_embeddings`

	retData := &struct {
		// Object    string      `json:"object"`
		Embedding [][]float32 `json:"embedding"`
		TokenNum  int         `json:"token_num"`
	}{}

	retData, err = call(ctx, l, http.MethodPost, p, req, retData, nil)

	if err != nil {
		return
	}

	ret = &schema.EmbeddingsResponse{
		Object: "embedding",
		Data:   []schema.EmbeddingData{},
		Usage:  schema.Usage{},
	}

	for i, v := range retData.Embedding {
		ret.Data = append(ret.Data, schema.EmbeddingData{
			Object:    "embedding",
			Embedding: v,
			Index:     i,
		})
	}

	return
}

// Free implements llms.LLM.
func (*FSChat) Free() {
	//Do Nothing
}

// Name implements llms.LLM.
func (l *FSChat) Name() string {
	return l.Model
}
