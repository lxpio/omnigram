package store

import (
	"bufio"
	"bytes"
	"context"
	"io"
	"os"
	"path/filepath"

	"github.com/lxpio/omnigram/server/log"
)

var _ KV = &LocalDir{}

type LocalDir struct {
	root string
	// client *nutsdb.DB
	// bucket string
}

func OpenLocalDir(path string) (KV, error) {

	//如果path目标不存在则返回error，否则返回 LocalDir
	if _, err := os.Stat(path); os.IsNotExist(err) {
		log.E("path not exist: ", path)
		return nil, err
	}
	return &LocalDir{
		root: path,
	}, nil

}

// Close implements KV.
func (*LocalDir) Close() {
	//do nothing

}

// CreateBucket implements KV.
func (m *LocalDir) CreateBucket(_ context.Context, bucketName string) error {

	//创建文件目录
	return os.MkdirAll(filepath.Join(m.root, bucketName), 0755)
}

// DeleteBucket implements KV.
func (m *LocalDir) DeleteBucket(_ context.Context, bucketName string) error {
	//删除目录同时删除对应的文件路径中所有的内容
	return os.RemoveAll(filepath.Join(m.root, bucketName))

}

// ListBuckets implements KV.
func (m *LocalDir) ListBuckets(context context.Context) ([]string, error) {
	//遍历获取当前根目录下目录列表并返回
	buckets := make([]string, 0)
	files, err := os.ReadDir(m.root)
	if err != nil {
		return nil, err
	}
	for _, file := range files {
		if file.IsDir() {
			buckets = append(buckets, file.Name())
		}
	}
	return buckets, nil

}

// CreateBucket implements KV.
func (m *LocalDir) ExistsBucket(_ context.Context, bucketName string) bool {

	//判断文件目录是否存在
	_, err := os.Stat(filepath.Join(m.root, bucketName))
	return err == nil

}

// DeleteObject implements KV.
func (m *LocalDir) Delete(_ context.Context, bucketName string, objectName string) error {
	//删除对应目录下文件
	return os.Remove(filepath.Join(m.root, bucketName, objectName))
}

// Get implements KV.
func (m *LocalDir) Get(context context.Context, bucketName string, objectName string) ([]byte, error) {
	//读取对应bucketName 目录下 名为 objectName 的文件内容，并将其封装在Ojbect 里面

	file, err := os.Open(filepath.Join(m.root, bucketName, objectName))
	if err != nil {
		return nil, err
	}
	// defer file.Close()
	defer func() {
		file.Close()
		println(`close file`)
	}()

	//读取文件内容
	buf := bytes.NewBuffer(nil)
	_, err = io.Copy(buf, file)
	if err != nil {
		return nil, err
	}

	return buf.Bytes(), nil

}

// List implements KV.
func (*LocalDir) List(_ context.Context, bucketName string, prefix string, recursive bool) ([]Object, error) {
	panic("unimplemented")
}

// Upload implements KV.
func (m *LocalDir) Upload(_ context.Context, bucketName, objectName string, reader io.Reader) error {

	//创建文件如果已经存在则覆盖

	//在对应目录下创建文件,并将文件内容写入

	file, err := os.Create(filepath.Join(m.root, bucketName, objectName))

	if err != nil {
		log.E(err.Error())
		return err
	}
	defer file.Close()

	_, err = io.Copy(file, reader)

	if err != nil {
		log.E(err.Error())
		return err
	}

	return nil

}

// Put implements KV.
func (m *LocalDir) Put(_ context.Context, bucketName, key string, data []byte) error {

	if data == nil {
		data = []byte{}
	}

	//创建文件如果已经存在则覆盖

	//在对应目录下创建文件,并将文件内容写入

	file, err := os.Create(filepath.Join(m.root, bucketName, key))

	if err != nil {
		log.E(err.Error())
		return err
	}
	defer file.Close()

	_, err = file.Write(data)

	return err

}

// Batch implements KV.
func (m *LocalDir) Batch(context context.Context, bucketName string, objects []Object) (err error) {

	//创建文件如果已经存在则覆盖

	//在对应目录下创建文件,并将文件内容写入

	for _, object := range objects {
		if err = m.Put(context, bucketName, object.Key, object.Data); err != nil {
			return err
		}
	}
	return nil

}

func openFileAndRead(filename string) (*bufio.Reader, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close() // 使用 defer 来确保文件在函数退出时被关闭

	reader := bufio.NewReader(file)
	return reader, nil
}
