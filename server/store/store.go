package store

import (
	"context"
	"os"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"

	"gorm.io/gorm"
)

var (
	omniDB *gorm.DB // 全局数据库
	kv     KV       // 缓存KV数据
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
}

func InitStore(cf *conf.Config) {

	var err error

	omniDB, err = OpenDB(FromConfig(cf))
	if err != nil {
		log.E(`open db failed`, err)
		os.Exit(1)
	}
}

func InitKV(cf *conf.Config) {
	db, err := NewKV(cf.KVType, cf.MetaPath())

	if err != nil {
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

// FileStore returns the same DB as Store() — unified PG database.
func FileStore() *gorm.DB {
	return omniDB
}
