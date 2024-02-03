package conf

import (
	"gopkg.in/yaml.v2"
)

type LLMType int

const (
	ModelUnknown  LLMType = 0   //
	ModelOpenAI   LLMType = 100 //
	ModelFSChat   LLMType = 200 //
	ModelLLaMACPP LLMType = 300 //
	ModelGPT4All  LLMType = 400 //
)

type ModelType = string

const (
	GPT4      ModelType = `gpt-4`         //
	GPT4_0314 ModelType = `gpt-4-0314`    //
	LLaMA_7B  ModelType = `ggml-llama-7b` //
	// ModelLLaMACPP ModelType = 300               //
	VICUNA_13B ModelType = `ggml-vicuna-13b` //
)

// modelMap store the model name -> model type maps
var modelMap map[ModelType]LLMType

func init() {
	modelMap = map[ModelType]LLMType{
		"gpt-4":               ModelOpenAI,
		"gpt-4-0314":          ModelOpenAI,
		"gpt-4-32k":           ModelOpenAI,
		"gpt-4-32k-0314":      ModelOpenAI,
		"gpt-3.5-turbo":       ModelOpenAI,
		"gpt-3.5-turbo-0301":  ModelOpenAI,
		"text-ada-001":        ModelOpenAI,
		"ada":                 ModelOpenAI,
		"text-babbage-001":    ModelOpenAI,
		"babbage":             ModelOpenAI,
		"text-curie-001":      ModelOpenAI,
		"curie":               ModelOpenAI,
		"davinci":             ModelOpenAI,
		"text-davinci-003":    ModelOpenAI,
		"text-davinci-002":    ModelOpenAI,
		"code-davinci-002":    ModelOpenAI,
		"code-davinci-001":    ModelOpenAI,
		"code-cushman-002":    ModelOpenAI,
		"code-cushman-001":    ModelOpenAI,
		"ggml-llama-7b":       ModelLLaMACPP,
		"ggml-llama-13b":      ModelLLaMACPP,
		"ggml-vicuna-13b":     ModelLLaMACPP,
		"vicuna-13b-v1.5-16k": ModelFSChat,
	}
}

func GetModelType(model ModelType) LLMType {

	t, ok := modelMap[model]

	if ok {
		return t
	}
	return ModelUnknown
}

type ModelOptions struct {
	Name     ModelType   `yaml:"name"`
	Settings interface{} `yaml:"parameters"`
}

// takes interface, marshals back to []byte, then unmarshals to desired struct
func UnmarshalPlugin(pluginIn, pluginOut interface{}) error {

	b, err := yaml.Marshal(pluginIn)
	if err != nil {
		return err
	}
	return yaml.Unmarshal(b, pluginOut)
}
