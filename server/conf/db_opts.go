package conf

import (
	"go.uber.org/zap/zapcore"
)

// Driver 定义数据库类型
type Driver string

const (
	// DRPostgres driver name for pg
	DRPostgres Driver = "postgres"
	// DRMySQL driver name for mysql
	DRMySQL Driver = "mysql"
	// DRSqlite driver name for mysql
	DRSQLite Driver = "sqlite3"
)

// Opt PG 数据库配置
type Opt struct {
	Driver   Driver        `yaml:"driver" json:"driver"`       //数据库类型
	LogLevel zapcore.Level `yaml:"log_level" json:"log_level"` //日志等级
	Host     string        `yaml:"host" json:"host"`           //数据地址
	Port     int           `yaml:"port" json:"port"`           //端口
	User     string        `yaml:"user" json:"user"`           //用户名
	DBName   string        `yaml:"dbname" json:"dbname"`       //数据库名
	Passwd   string        `yaml:"passwd" json:"passwd"`       //密码
	SSLMode  string        `yaml:"sslmode" json:"sslmode"`     // disable, varify-full //SSL选项
	Args     string        `yaml:"args" json:"args"`           // charset=utf8 //额外选项
}
