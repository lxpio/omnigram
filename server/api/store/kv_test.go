package store

import (
	"bytes"
	"context"
	"os"
	"testing"

	"github.com/lxpio/omnigram/server/api/log"
	"go.uber.org/zap/zapcore"
)

func TestGetObject(t *testing.T) {

	log.Init(`stdout`, zapcore.DebugLevel)
	//get current dir
	dir, _ := os.Getwd()

	println(dir)

	//is conf dir
	kv, _ := OpenLocalDir(dir + `/../../`)

	data, err := kv.GetObject(context.TODO(), "conf", "conf.yaml")

	if err != nil {
		t.Error(err)
	}
	println(`read from file`)

	println(string(data.Data))

	//bytes to io.reader
	reader := bytes.NewReader(data.Data)

	err = kv.UploadObject(context.TODO(), "conf", "conf2.yaml", reader)

	if err != nil {
		t.Error(err)
	}

}

func TestListBuckets(t *testing.T) {

	log.Init(`stdout`, zapcore.DebugLevel)
	//get current dir
	dir, _ := os.Getwd()

	kv, _ := OpenLocalDir(dir + `/../../`)

	buckets, err := kv.ListBuckets(context.TODO())

	if err != nil {
		t.Error(err)
	}

	//遍历打印buckets
	for _, bucket := range buckets {
		println(bucket)
	}
}

func TestGetObjects(t *testing.T) {
	dir, _ := os.Getwd()

	reader, err := openFileAndRead(dir + `/../../conf/conf.yaml`)
	if err != nil {
		// 处理错误
		t.Error(err)
	}

	buf := new(bytes.Buffer)
	buf.ReadFrom(reader)
	println(buf.String())
}
