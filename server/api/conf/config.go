package conf

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/lxpio/omnigram/server/api/store"
	"go.uber.org/zap/zapcore"
	"gopkg.in/yaml.v2"
)

var (
	Version = ""
)

// Config 定义 配置结构图
type Config struct {

	//APIAddr , default: 0.0.0.0:8080
	APIAddr string `yaml:"api_addr" json:"api_addr"`

	LogLevel zapcore.Level `yaml:"log_level" json:"log_level"`

	LogDir string `yaml:"log_dir" json:"log_dir"`

	MetaDataPath string `yaml:"metadata_path" json:"metadata_path"`

	M4tOptions M4tOptions `yaml:"m4t_options" json:"m4t_options"`

	DBOption *store.Opt `yaml:"db_options" json:"db_options"`

	ModelOptions []ModelOptions `yaml:"model_options" json:"model_options"`

	EpubOptions EpubOptions `yaml:"epub_options" json:"epub_options"`

	filePath string `yaml:"-" json:"-"`
}

func InitConfig(path string) (*Config, error) {

	f, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("cannot read config file: %w", err)
	}

	cf := defaultConfig(path)

	if err := yaml.Unmarshal(f, cf); err != nil {
		return nil, fmt.Errorf("cannot unmarshal config file: %w", err)
	}

	if cf.DBOption == nil {
		cf.DBOption = &store.Opt{
			Driver:   "sqlite3",
			Host:     filepath.Join(cf.MetaDataPath, "db"),
			LogLevel: cf.LogLevel,
		}

		err = os.Mkdir(cf.DBOption.Host, 0755)
	}
	cf.DBOption.LogLevel = cf.LogLevel

	if cf.M4tOptions.RemoteAddr == `` {
		cf.M4tOptions.RemoteAddr = `localhost:50051`
	}

	return cf, err
}

func defaultConfig(path string) *Config {
	cf := &Config{
		APIAddr:      "0.0.0.0:8080",
		LogLevel:     zapcore.InfoLevel,
		LogDir:       "./logs",
		MetaDataPath: "./metadata",
		filePath:     path,
	}
	return cf
}

func (c *Config) Save() error {

	// Convert struct to YAML
	yamlData, err := yaml.Marshal(&c)
	if err != nil {
		return fmt.Errorf("error marshalling config: %v ", err)

	}

	// Save YAML data to a file
	err = os.WriteFile(c.filePath, yamlData, 0644)
	if err != nil {
		return fmt.Errorf("error save config file: %v", err)

	}
	return nil
}

type EpubOptions struct {
	DataPath           string `json:"data_path" yaml:"data_path"`
	SaveCoverBesideSrc bool   `json:"save_cover_beside_src" yaml:"save_cover_beside_src"`
	MaxEpubSize        int64  `json:"max_epub_size" yaml:"max_epub_size"`
}

type M4tOptions struct {
	RemoteAddr string `json:"remote_addr" yaml:"remote_addr"`
}
