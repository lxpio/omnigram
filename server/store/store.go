package store

import (
	"context"
	"os"
	"path/filepath"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"go.uber.org/zap/zapcore"

	"gorm.io/gorm"
)

var (
	omniDB *gorm.DB // 全局数据库（如果是postgres/mysql 则文件数据库为空
	fileDB *gorm.DB // 文件数据库(用户存储文件搜刮后数据)
	kv     KV       // 缓存KV数据

	isSqlite bool
)

func Initialize(ctx context.Context) {

	log.I(`初始化数据库连接`)

	cf := conf.GetConfig()

	InitStore(cf)

	log.I(`初始化KV库`)

	InitKV(cf)

}

func Close() {
	if kv != nil {
		log.I(`关闭KV库`)
		kv.Close()
	}

	if omniDB != nil {
		// omniDB
	}

	if fileDB != nil {
		// fileDB.Close()
	}
}

func InitStore(cf *conf.Config) {

	var err error

	// 如果数据库为sqlite3，则将不同的模块子目录创建额外的sqlite3文件
	if cf.DBOption.Driver == conf.DRSQLite {

		omniDB, err = openSQLite(cf.DBOption, cf.LogLevel, `omnigram.db`)
		if err != nil {
			log.E(`open omnigram db failed`, err)
			os.Exit(1)
		}

		fileDB, err = openSQLite(cf.DBOption, cf.LogLevel, `file_meta.db`)
		if err != nil {
			log.E(`open file_meta db failed`, err)
			os.Exit(1)
		}

	} else {

		omniDB, err = OpenDB(FromConfig(cf))
		if err != nil {
			log.E(`open db failed`, err)
			os.Exit(1)
		}
	}

	isSqlite = cf.DBOption.Driver == conf.DRSQLite

}

func InitKV(cf *conf.Config) {
	// var err error
	db, err := NewKV(cf.KVType, cf.MetaPath())

	if err != nil {
		// path/to/whatever does not exist
		panic(err)
	}

	kv = db
}

func GetKV() KV {
	return kv
}

func Store() *gorm.DB {

	return omniDB

}

func FileStore() *gorm.DB {
	if isSqlite {
		log.D(`使用sqlite3文件数据库 fileDB`)
		return fileDB
	}
	return omniDB
}

func openSQLite(opt *conf.Opt, logLevel zapcore.Level, dbname string) (*gorm.DB, error) {
	dbPath := filepath.Join(opt.Host, dbname)
	log.I(`初始化用户库: ` + dbPath)

	orm, err := OpenDB(&Opt{
		Driver:   conf.DRSQLite,
		Host:     dbPath,
		LogLevel: logLevel,
	})

	return orm, err
}
