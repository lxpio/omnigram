package model

import (
	"context"
	"os"
	"path/filepath"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/service/epub/selfhost"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
	"gorm.io/gorm"
)

var (
	// gcf     *conf.Config
	orm     *gorm.DB
	kv      store.KV
	manager *selfhost.ScannerManager
)

// func Initialize(ctx context.Context, cf *conf.Config) {

// }

func Initialize(ctx context.Context, cf *conf.Config) {

	var err error
	// gcf = cf

	if cf.DBOption.Driver == store.DRSQLite {
		dbPath := filepath.Join(cf.DBOption.Host, `epub.db`)
		log.I(`初始化数据库: ` + dbPath)

		var err error
		orm, err = store.OpenDB(&store.Opt{
			Driver:   store.DRSQLite,
			Host:     dbPath,
			LogLevel: cf.LogLevel,
		})

		if err != nil {
			log.E(`open user db failed`, err)
			os.Exit(1)
		}
	} else {
		orm = ctx.Value(utils.DBContextKey).(*gorm.DB)
	}

	log.I(`初始化扫描管理`)

	kv, err = store.OpenLocalDir(filepath.Join(cf.MetaDataPath, `epub`))

	if err != nil {
		// path/to/whatever does not exist
		panic(err)
	}

	manager, _ = selfhost.NewScannerManager(ctx, cf, kv, orm)

}

func GetManager() *selfhost.ScannerManager {
	return manager
}

func GetKV() store.KV {
	return kv
}

func GetORM() *gorm.DB {
	return orm
}
