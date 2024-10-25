package store

import (
	"context"
	"io"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/utils"
)

type KV interface {
	CreateBucket(context context.Context, bucketName string) error
	ExistsBucket(context context.Context, bucketName string) bool
	DeleteBucket(context context.Context, bucketName string) error
	ListBuckets(context context.Context) ([]string, error)

	List(context context.Context, bucketName string, prefix string, recursive bool) ([]Object, error)
	Get(context context.Context, bucketName, key string) ([]byte, error)

	Put(context context.Context, bucketName, key string, data []byte) error
	Batch(context context.Context, bucketName string, objects []Object) error

	Upload(context context.Context, bucketName, key string, reader io.Reader) error

	Delete(context context.Context, bucketName, key string) error

	Close()
}

type Object struct {
	Key  string
	Data []byte
}

func NewKV(kvType conf.KVType, root string) (KV, error) {
	switch kvType {
	case conf.KVTypeLocalDisk:
		return OpenLocalDir(root)
	case conf.KVTypeBadgerDB:
		return OpenBadgerDB(root)
	default:
		return nil, utils.ErrInvalidKVType
	}
}
