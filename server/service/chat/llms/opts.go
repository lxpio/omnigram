package llms

import "github.com/lxpio/omnigram/server/service/chat/llms/schema"

// CallOption is a function that configures a CallOptions.
type CallOption func(*CallOptions)

// CallOptions is a set of options for LLM.Call.
type CallOptions struct {
	// Model is the model to use.
	Model string `json:"model"`
	// MaxTokens is the maximum number of tokens to generate.
	MaxTokens int `json:"max_tokens"`
	// Temperature is the temperature for sampling, between 0 and 1.
	Temperature float64 `json:"temperature"`
	// StopWords is a list of words to stop on.
	StopWords []string `json:"stop_words"`

	CallBackFn schema.SreamCallBack `json:"-"`
}

func InitCallOptions(opts ...CallOption) CallOptions {
	callOpts := CallOptions{
		Model:       "",
		MaxTokens:   7000,
		Temperature: 0.7,
		StopWords:   []string{},
	}

	for _, o := range opts {
		o(&callOpts)
	}

	return callOpts

}

func ChatCallback(resp chan *schema.ChatResponse, done chan error) schema.SreamCallBack {

	return func(r *schema.ChatResponse, d bool, e error) {
		if d {
			done <- e
		} else {
			resp <- r
		}
	}
}

// WithSreamCallBack is an option for LLM.Call. callback func not nil llm will using stream response
func WithSreamCallBack(cb schema.SreamCallBack) CallOption {
	return func(o *CallOptions) {
		o.CallBackFn = cb
	}
}

// WithModel is an option for LLM.Call.
func WithModel(model string) CallOption {
	return func(o *CallOptions) {
		o.Model = model
	}
}

// WithMaxTokens is an option for LLM.Call.
func WithMaxTokens(maxTokens int) CallOption {
	return func(o *CallOptions) {
		o.MaxTokens = maxTokens
	}
}

// WithTemperature is an option for LLM.Call.
func WithTemperature(temperature float64) CallOption {
	return func(o *CallOptions) {
		o.Temperature = temperature
	}
}

// WithStopWords is an option for LLM.Call.
func WithStopWords(stopWords []string) CallOption {
	return func(o *CallOptions) {
		o.StopWords = stopWords
	}
}

// WithOptions is an option for LLM.Call.
func WithOptions(options CallOptions) CallOption {
	return func(o *CallOptions) {
		(*o) = options
	}
}
