package openai

import (
	"net/http"
	"net/url"
)

const DefaultOpenAIAPIURL = `https://api.openai.com/v1`

// CallOption is a function that configures a LLM.
type ModelOption func(*OpenAI)

func defaultOpenAI() *OpenAI {
	return &OpenAI{
		APIHost: DefaultOpenAIAPIURL,
		APIKey:  "sk-xxxxxxxxxxx",
		Model:   "gpt-3.5-turbo",
	}
}

// WithAPIHost sets the APIHost that for openai default is https://api.openai.com
func WithAPIHost(o string) ModelOption {

	//todo verify o
	return func(p *OpenAI) {
		p.APIHost = o
	}
}

// WithToken sets the token that for openai client.
func WithToken(o string) ModelOption {
	return func(p *OpenAI) {
		p.APIKey = o
	}
}

// WithModel sets the model for us.
func WithModel(o string) ModelOption {
	return func(p *OpenAI) {
		p.Model = o
	}
}

// WithModel sets the model for us.
func WithHTTPClient(o *http.Client) ModelOption {
	return func(p *OpenAI) {
		p.HTTPClient = o
	}
}

// WithModel sets the model for us.
func WithProxy(o string) ModelOption {
	return func(p *OpenAI) {
		proxy, _ := url.Parse(o)
		h := &http.Client{Transport: &http.Transport{Proxy: http.ProxyURL(proxy)}}
		p.HTTPClient = h
	}
}
