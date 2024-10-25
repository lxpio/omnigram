package store

import (
	"bytes"
	"context"
	"io"

	badger "github.com/dgraph-io/badger/v4"
)

type BadgerDB struct {
	db *badger.DB
}

var _ KV = (*BadgerDB)(nil)

func OpenBadgerDB(path string) (KV, error) {

	//如果path目标不存在则返回error，否则返回 LocalDir
	db, err := badger.Open(badger.DefaultOptions(path))
	if err != nil {
		return nil, err
	}

	return &BadgerDB{db: db}, nil

}

// Close implements KV.
func (b *BadgerDB) Close() {

	if b.db != nil {
		b.db.Close()
	}

}

// CreateBucket implements KV.
func (b *BadgerDB) CreateBucket(context context.Context, bucketName string) error {
	//do nothing
	return nil
}

// DeleteBucket implements KV.
func (b *BadgerDB) DeleteBucket(context context.Context, bucketName string) error {
	//do nothing
	return nil
}

// DeleteObject implements KV.
func (b *BadgerDB) DeleteObject(context context.Context, bucketName string, objectName string) error {
	return b.db.Update(func(txn *badger.Txn) error {
		return txn.Delete([]byte(bucketName + "/" + objectName))
	})
}

// ExistsBucket implements KV.
func (b *BadgerDB) ExistsBucket(context context.Context, bucketName string) bool {
	//BadgerDB not support bucket so always true
	return true
}

// ListBuckets implements KV.
func (b *BadgerDB) ListBuckets(context context.Context) ([]string, error) {
	panic("unimplemented")
}

// GetObject implements KV.
func (b *BadgerDB) Get(context context.Context, bucketName string, objectName string) ([]byte, error) {

	var data []byte

	err := b.db.View(func(txn *badger.Txn) error {
		item, err := txn.Get([]byte(bucketName + "/" + objectName))

		if err != nil {
			return err
		}
		item.Value(func(val []byte) error {
			// do something with val
			data = val
			return nil
		})

		return nil
	})

	return data, err
}

// List implements KV.
func (b *BadgerDB) List(context context.Context, bucketName string, prefix string, recursive bool) ([]Object, error) {
	panic("unimplemented")
}

// Put implements KV.
func (b *BadgerDB) Put(context context.Context, bucketName, key string, data []byte) error {
	return b.db.Update(func(txn *badger.Txn) error {
		return txn.Set([]byte(bucketName+"/"+key), data)
	})
}

// Batch implements KV.
func (b *BadgerDB) Batch(context context.Context, bucketName string, objects []Object) error {
	return b.db.Update(func(txn *badger.Txn) error {
		for _, object := range objects {
			if err := txn.Set([]byte(bucketName+"/"+object.Key), object.Data); err != nil {
				return err
			}
		}
		return nil
	})

}

// Upload implements KV.
func (b *BadgerDB) Upload(context context.Context, bucketName string, objectName string, reader io.Reader) error {

	buf := new(bytes.Buffer)
	buf.ReadFrom(reader)

	return b.db.Update(func(txn *badger.Txn) error {

		return txn.Set([]byte(bucketName+"/"+objectName), buf.Bytes())
	})
}

// Delete implements KV.
func (b *BadgerDB) Delete(context context.Context, bucketName string, key string) error {
	return b.db.Update(func(txn *badger.Txn) error {
		return txn.Delete([]byte(bucketName + "/" + key))

	})
}
