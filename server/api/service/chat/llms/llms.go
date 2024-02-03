package llms

import (
	"context"

	"github.com/lxpio/omnigram/server/api/service/chat/llms/schema"
)

// LLM common interface for lang model
type LLM interface {

	//Name return LLM Name
	Name() string

	//Free free model
	Free()

	//Call 实现最基本的输入输出。
	Call(ctx context.Context, prompt string) (string, error)

	//Chat chatGPT compatible chat/completions input/output
	Chat(ctx context.Context, req *schema.ChatRequest) (*schema.ChatResponse, error)

	//Chat chatGPT compatible completions input/output
	Completion(ctx context.Context, req *schema.CompletionRequest) (*schema.CompletionResponse, error)

	//Chat chatGPT compatible embeddings input/output
	Embeddings(ctx context.Context, req *schema.EmbeddingsRequest) (*schema.EmbeddingsResponse, error)
}
