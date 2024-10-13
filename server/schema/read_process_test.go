package schema_test

import (
	"path/filepath"
	"runtime"
	"testing"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
	"go.uber.org/zap/zapcore"
)

func TestReadProcess_Upsert(t *testing.T) {

	log.Init(`stdout`, zapcore.DebugLevel)
	//获取当前测试文件路径
	_, filename, _, _ := runtime.Caller(0)

	db, _ := store.OpenDB(&store.Opt{
		Driver: conf.DRSQLite,
		Host:   filepath.Join(filename, "../../../../build/test.db"),
	})

	// db.AutoMigrate(schema.ReadProcess{})

	p := schema.ReadProgress{UserID: 1, BookID: `1`, Progress: 0.7}

	err := p.Upsert(db)

	if err != nil {
		t.Error(err)
	}

	// data, err := schema.ReadingBooks(db, 1, 0, 10)

	// if err != nil {
	// 	t.Error(err)
	// }

	// // println(data.Total)

	// println(data[0].Title)

}
