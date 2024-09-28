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

type CacheEntryIdxMode int

const (
	//索引和值都存储在内存中
	CacheHintKeyValAndRAMIdxMode = iota

	//索引存储内存，值不存储内存
	CacheHintKeyAndRAMIdxMode

	//多级索引存储内存，值不存储内存
	CacheHintBPTSparseIdxMode
)

type KV interface {
	CreateBucket(context context.Context, bucketName string) error
	DeleteBucket(context context.Context, bucketName string) error
	ListBuckets(context context.Context) ([]string, error)

	ListObjects(context context.Context, bucketName string, prefix string, recursive bool) ([]*Object, error)
	GetObject(context context.Context, bucketName, objectName string) (*Object, error)

	PutObject(context context.Context, bucketName string, object *Object) error
	PutObjects(context context.Context, bucketName string, objects []*Object) error

	UploadObject(context context.Context, bucketName, objectName string, reader io.Reader) error

	DeleteObject(context context.Context, bucketName, objectName string) error

	Close()
}

type Object struct {
	Key          string
	Size         int64
	LastModified int64
	Data         []byte
}

var _ KV = &LocalDir{}

type LocalDir struct {
	root string
	// client *nutsdb.DB
	// bucket string
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

// DeleteObject implements KV.
func (m *LocalDir) DeleteObject(_ context.Context, bucketName string, objectName string) error {
	//删除对应目录下文件
	return os.Remove(filepath.Join(m.root, bucketName, objectName))
}

// GetObject implements KV.
func (m *LocalDir) GetObject(context context.Context, bucketName string, objectName string) (*Object, error) {
	//读取对应bucketName 目录下 名为 objectName 的文件内容，并将其封装在Ojbect 里面
	//type Object struct {
	// 	Key          string
	// 	Size         int64
	// 	LastModified time.Time
	// 	Data         io.Reader
	// }

	file, err := os.Open(filepath.Join(m.root, bucketName, objectName))
	if err != nil {
		return nil, err
	}
	// defer file.Close()
	defer func() {
		file.Close()
		println(`close file`)
	}()
	//读取文件大小
	stat, err := file.Stat()
	if err != nil {
		return nil, err
	}

	//读取文件内容
	buf := bytes.NewBuffer(nil)
	_, err = io.Copy(buf, file)
	if err != nil {
		return nil, err
	}

	// return reader, nil
	//封装Object
	object := &Object{
		Key:          objectName,
		Size:         stat.Size(),
		LastModified: stat.ModTime().Unix(), //读取文件最后修改时间
		Data:         buf.Bytes(),
	}

	return object, nil

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

// ListObjects implements KV.
func (*LocalDir) ListObjects(_ context.Context, bucketName string, prefix string, recursive bool) ([]*Object, error) {
	panic("unimplemented")
}

// PutObject implements KV.
func (m *LocalDir) UploadObject(_ context.Context, bucketName, objectName string, reader io.Reader) error {

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

// PutObject implements KV.
func (m *LocalDir) PutObject(_ context.Context, bucketName string, object *Object) error {

	if object == nil {
		return nil
	}

	//创建文件如果已经存在则覆盖

	//在对应目录下创建文件,并将文件内容写入

	file, err := os.Create(filepath.Join(m.root, bucketName, object.Key))

	if err != nil {
		log.E(err.Error())
		return err
	}
	defer file.Close()

	// write object.data to file
	_, err = file.Write(object.Data)

	return err

}

// PutObject implements KV.
func (m *LocalDir) PutObjects(context context.Context, bucketName string, objects []*Object) (err error) {

	//创建文件如果已经存在则覆盖

	//在对应目录下创建文件,并将文件内容写入

	for _, object := range objects {
		if err = m.PutObject(context, bucketName, object); err != nil {
			return err
		}
	}
	return nil

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

func openFileAndRead(filename string) (*bufio.Reader, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close() // 使用 defer 来确保文件在函数退出时被关闭

	reader := bufio.NewReader(file)
	return reader, nil
}
