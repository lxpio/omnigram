package fschat

import (
	"fmt"
	"net/http"
	"net/url"
	"strings"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
)

const DefaultVicunaAddr = `http://127.0.0.1:21002`

// CallOption is a function that configures a LLM.
type ModelOption func(*FSChat)

func FromYaml(opt conf.ModelOptions) (*FSChat, error) {

	client := defaultFSChat()

	err := conf.UnmarshalPlugin(opt.Settings, client)

	if err != nil {
		return nil, err
	}

	client.Model = opt.Name

	log.D(client.Endpoints)

	return client, nil

}

// WithAPIHost sets the APIHost that for openai default is https://api.openai.com
func WithAPIHost(o string) ModelOption {

	//todo verify o
	return func(p *FSChat) {
		p.Endpoints = verifyAPIHost(o)
	}
}

// WithModel sets the model for us.
func WithModel(o string) ModelOption {
	return func(p *FSChat) {
		p.Model = o
	}
}

// WithModel sets the model for us.
func WithHTTPClient(o *http.Client) ModelOption {
	return func(p *FSChat) {
		p.HTTPClient = o
	}
}

func defaultFSChat() *FSChat {
	return &FSChat{
		Model:     "vicuna-13b-v1.5-16k",
		Endpoints: []string{DefaultVicunaAddr},
	}
}

// 校验模型地址是否正确
func verifyAPIHost(api_hosts string) []string { // api_host = "http://127.0.0.1:21002,http://127.0.0.1:21003,http://127.0.0.1:21004"
	endpoints := strings.Split(api_hosts, `,`)
	addrs := []string{}
	for _, v := range endpoints {
		u, err := url.Parse(v)
		if err != nil {
			fmt.Print(`模型地址错误：`, v)
			continue
		}
		if u.Scheme == "" || u.Host == "" {
			fmt.Print(`模型地址错误：`, v)
			continue
		}
		// return strings.Join([]string{l.endpoints[index], strings.TrimLeft(p, "/")}, "/"), nil

		u.Path = strings.TrimRight(u.Path, "/")
		addrs = append(addrs, u.String())
	}
	return addrs
}
