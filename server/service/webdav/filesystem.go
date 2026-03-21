package webdav

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/lxpio/omnigram/server/log"
	davlib "golang.org/x/net/webdav"
)

// OmnigramFS 实现 webdav.FileSystem 接口
// 双区设计：/books/ 只读，/sync/ 可写
type OmnigramFS struct {
	booksRoot string
	syncRoot  string
}

func NewOmnigramFS(booksRoot, syncRoot string) *OmnigramFS {
	if err := os.MkdirAll(syncRoot, 0755); err != nil {
		log.E("create sync root failed: ", err)
	}
	return &OmnigramFS{booksRoot: booksRoot, syncRoot: syncRoot}
}

func (fs *OmnigramFS) resolvePath(name string) (realPath string, writable bool) {
	if name == "/sync" || strings.HasPrefix(name, "/sync/") {
		rel := strings.TrimPrefix(name, "/sync")
		rel = strings.TrimPrefix(rel, "/")
		cleaned := filepath.Clean(filepath.Join(fs.syncRoot, rel))
		root := filepath.Clean(fs.syncRoot)
		if cleaned != root && !strings.HasPrefix(cleaned, root+string(os.PathSeparator)) {
			return "", false // path traversal blocked
		}
		return cleaned, true
	}
	if name == "/books" || strings.HasPrefix(name, "/books/") {
		rel := strings.TrimPrefix(name, "/books")
		rel = strings.TrimPrefix(rel, "/")
		cleaned := filepath.Clean(filepath.Join(fs.booksRoot, rel))
		root := filepath.Clean(fs.booksRoot)
		if cleaned != root && !strings.HasPrefix(cleaned, root+string(os.PathSeparator)) {
			return "", false // path traversal blocked
		}
		return cleaned, false
	}
	return filepath.Join(fs.booksRoot, filepath.Clean(name)), false
}

func (fs *OmnigramFS) Mkdir(ctx context.Context, name string, perm os.FileMode) error {
	realPath, writable := fs.resolvePath(name)
	if !writable {
		return os.ErrPermission
	}
	return os.MkdirAll(realPath, perm)
}

func (fs *OmnigramFS) OpenFile(ctx context.Context, name string, flag int, perm os.FileMode) (davlib.File, error) {
	realPath, writable := fs.resolvePath(name)

	isWrite := flag&(os.O_WRONLY|os.O_RDWR|os.O_CREATE|os.O_TRUNC) != 0
	if isWrite && !writable {
		return nil, os.ErrPermission
	}

	if isWrite {
		dir := filepath.Dir(realPath)
		if err := os.MkdirAll(dir, 0755); err != nil {
			return nil, err
		}
	}

	return os.OpenFile(realPath, flag, perm)
}

func (fs *OmnigramFS) RemoveAll(ctx context.Context, name string) error {
	realPath, writable := fs.resolvePath(name)
	if !writable {
		return os.ErrPermission
	}
	return os.RemoveAll(realPath)
}

func (fs *OmnigramFS) Rename(ctx context.Context, oldName, newName string) error {
	oldPath, oldWritable := fs.resolvePath(oldName)
	newPath, newWritable := fs.resolvePath(newName)
	if !oldWritable || !newWritable {
		return os.ErrPermission
	}
	return os.Rename(oldPath, newPath)
}

func (fs *OmnigramFS) Stat(ctx context.Context, name string) (os.FileInfo, error) {
	if name == "/" || name == "" {
		return &virtualDirInfo{name: "/"}, nil
	}
	realPath, _ := fs.resolvePath(name)
	return os.Stat(realPath)
}

type virtualDirInfo struct {
	name string
}

func (d *virtualDirInfo) Name() string       { return d.name }
func (d *virtualDirInfo) Size() int64        { return 0 }
func (d *virtualDirInfo) Mode() os.FileMode  { return os.ModeDir | 0755 }
func (d *virtualDirInfo) ModTime() time.Time { return time.Now() }
func (d *virtualDirInfo) IsDir() bool        { return true }
func (d *virtualDirInfo) Sys() interface{}   { return nil }
