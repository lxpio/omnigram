package chat

import (
	"fmt"

	"github.com/lxpio/omnigram/server/api/service/chat/llms"

	"github.com/lxpio/omnigram/server/api/service/chat/llms/fschat"
	"github.com/lxpio/omnigram/server/api/service/chat/llms/openai"
	"github.com/lxpio/omnigram/server/api/conf"
	"github.com/lxpio/omnigram/server/api/log"
)

// Manager LLM model manager
type Manager struct {
	cf *conf.Config

	//ModelPath root mode path for llms
	// ModelPath string

	loadedModels map[string]llms.LLM

	// promptsTemplates map[string]*template.Template

	// promptsTemplates *prompts.Render
}

func NewModelManager(cf *conf.Config) *Manager {

	return &Manager{
		cf:           cf,
		loadedModels: map[string]llms.LLM{},

		// promptsTemplates: prompts.NewRender(cf.PromptPath),
	}
}

// Load using the configs in config file, load llm models to memory.
func (m *Manager) Load() error {

	for _, o := range m.cf.ModelOptions {

		//load
		modeType := conf.GetModelType(o.Name)

		switch modeType {
		// case llms.ModelOpenAI:
		// 	llm, err := openai.FromYaml(o)
		// 	if err != nil {
		// 		return err
		// 	}
		// 	m.loadedModels[o.Name] = llm
		// 	log.I(`loaded llama.cpp from `, o.Name)

		case conf.ModelFSChat:

			llm, err := fschat.FromYaml(o)
			if err != nil {

				return err
			}
			m.loadedModels[o.Name] = llm
		default:

			log.E(`model: ` + o.Name + ` not support`)
		}

	}

	//Reg all chain

	// chains.RegChain(chains.NewBaseChatChain())

	return nil

}

// Free clean all model in memory
func (m *Manager) Free() {

	for _, llm := range m.loadedModels {
		log.I(`free model: `, llm.Name())
		llm.Free()
	}

}

func (m *Manager) GetModel(modelName string) (llms.LLM, error) {
	panic(`todo`)
	// model, exists := m.loadedModels[modelName]
	// if !exists {
	// 	return nil, fmt.Errorf("model %s not found", modelName)
	// }

	// return model, nil

}

func (m *Manager) LLMChain(modelName string, chainName string) (llms.LLM, error) {

	model, exists := m.loadedModels[modelName]
	if !exists {
		return nil, fmt.Errorf("model %s not found", modelName)
	}
	//TODO
	// if c, ok := llmchain.GetChain(chainName); ok {
	// 	log.D(`using chain: `, chainName)
	// 	// c.WithLLM(model)
	// 	// return llms.New(model, c), nil
	// }

	return model, nil

}

// func (m *Manager) GetPrompt() *prompts.Render {

// 	return m.promptsTemplates

// }

func (m *Manager) ListModels() []string {
	ret := make([]string, len(m.loadedModels))

	i := 0
	for k := range m.loadedModels {
		ret[i] = k
		i++
	}
	return ret
}

// func (m *Manager) LoadLLaMACpp(opts llm.ModelOptions) (*llamacpp.LLaMACpp, error) {
// 	log.I(`loading model: `, opts.Model, ` with path: `, opts.ModelPath, `...`)
// 	ould not find a version that satisfies the requirement tb-nightly

// }

func (m *Manager) LoadOpenAI(modelName string, opts ...openai.ModelOption) (*openai.OpenAI, error) {

	return nil, fmt.Errorf("openai llm todo")
}
