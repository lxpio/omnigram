package store

import (
	"context"
	"strconv"
	"time"

	"github.com/lxpio/omnigram/server/api/log"
	"go.uber.org/zap/zapcore"
	"gorm.io/driver/mysql"
	"gorm.io/driver/postgres"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
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

// OpenDB 直接打开数据库连接 如果失败立即返回错误
func OpenDB(opt *Opt) (*gorm.DB, error) {

	db, err := gorm.Open(opt.DSN(), &gorm.Config{})
	if err != nil {
		// log.E(`链接数据库失败：`,, err.Error())
		log.I(`链接数据库异常:`, opt.String())
	}
	if opt.LogLevel == zapcore.DebugLevel {
		db = db.Debug()
	}
	return db, nil

}

// WaitDB 打开数据库连接，如果失败则一直尝试重连直到成功为止
func WaitDB(ctx context.Context, opt *Opt) (*gorm.DB, error) {

	var store *gorm.DB
	var err error

	f := func() error {
		db, err := gorm.Open(opt.DSN(), &gorm.Config{})
		if err != nil {
			log.I(`链接数据库异常:`, opt.String())
			return err
		}

		if opt.LogLevel == zapcore.DebugLevel {
			db = db.Debug()
		}

		store = db
		return nil
	}

	err = Wait(ctx, 30, f)

	return store, err
}

// Wait 等待某个函数执行成功
func Wait(ctx context.Context, sleep time.Duration, f func() error) error {

	if err := f(); err == nil {
		return nil
	}
	for {

		ticker := time.NewTicker(time.Second * sleep)

		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			if err := f(); err == nil {
				return nil
			}

		}
	}

}

// DSN return gorm v2 Dialector
func (opt *Opt) DSN() gorm.Dialector {
	switch {
	case opt.Driver == `postgres`:
		return opt.PGDSN()
	case opt.Driver == `mysql`:
		return opt.MySQLDSN()
	case opt.Driver == `sqlite3`:
		return opt.SQLiteDSN()
	}

	log.F(`unknown driver: ` + opt.Driver)
	return nil

}

// PGDSN  转换为 PG 连接字符串
//
//	postgres://jack:secret@pg.example.com:5432/mydb?sslmode=verify-ca
//
// postgres://jack:secret@foo.example.com:5432,bar.example.com:5432/mydb
func (opt *Opt) PGDSN() gorm.Dialector {

	// dsn := "host=" + opt.Host + " port=" + strconv.Itoa(opt.Port) + " user=" + opt.User + " dbname=" + opt.DBName + " password=" + opt.Passwd + " sslmode=" + opt.SSLMode
	dsn := `postgres://` + opt.User + `:` + opt.Passwd + `@` + opt.Host

	if opt.Port != 0 { //这里默认如果端口未么有添加写认为端口地址存储在HOST目录
		dsn += `:` + strconv.Itoa(opt.Port)
	}

	if opt.SSLMode == `` {
		opt.SSLMode = `disable`
	}

	dsn += `/` + opt.DBName + `?sslmode=` + opt.SSLMode + `&` + opt.Args

	return postgres.Open(dsn)
}

// MySQLDSN  转换为 mysql 连接字符串
func (opt *Opt) MySQLDSN() gorm.Dialector {

	if opt.Args == "" {
		opt.Args = `charset=utf8&parseTime=True&loc=Local`
	}

	dsn := opt.User + `:` + opt.Passwd + `@tcp(` + opt.Host + ":" + strconv.Itoa(opt.Port) + ")/" + opt.DBName + "?" + opt.Args
	return mysql.Open(dsn)
}

// SQLiteDSN  返回 sqlite 数据库连接字符
func (opt *Opt) SQLiteDSN() gorm.Dialector {

	return sqlite.Open(opt.Host)
}

func (opt *Opt) String() string {
	if opt.Driver == DRSQLite {
		return "driver=" + string(opt.Driver) + " path=" + opt.Host
	}
	return "driver=" + string(opt.Driver) + " host=" + opt.Host + " port=" + strconv.Itoa(opt.Port) + " user=" + opt.User + " dbname=" + opt.DBName + " password=xxxxxx sslmode=" + opt.SSLMode
}
