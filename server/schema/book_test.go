package schema_test

import (
	"path/filepath"
	"runtime"
	"testing"
	"time"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
)

func TestGetReadProcessBooks(t *testing.T) {
	//获取当前测试文件路径
	_, filename, _, _ := runtime.Caller(0)

	db, _ := store.OpenDB(&store.Opt{
		Driver: conf.DRPostgres,
		Host:   filepath.Join(filename, "../"),
	})

	data, err := schema.ReadingBooks(db, 1, 0, 10)

	if err != nil {
		t.Error(err)
	}

	// println(data.Total)

	println(data[0].Title)

}

func TestGenBookID(t *testing.T) {

	println(schema.GenBookID(time.Now()))
}
