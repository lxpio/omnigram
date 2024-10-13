// scan 目录扫描搜刮工具
package sys

import (
	"context"
	"encoding/json"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/nutsdb/nutsdb"
)

const scanStatsKey = `last_scan_status_v2`

// Scanner  文件扫描器
type Scanner struct {
	Running bool     `json:"running"`
	Count   int      `json:"count"` //扫描文件计数
	Errs    []string `json:"errors"`
	root    string   `json:"-"` //扫描错误详情信息
	ctx     context.Context
	cached  *nutsdb.DB
	wg      *sync.WaitGroup `json:"-"`
}

func NewScan(ctx context.Context, root, meta string) (*Scanner, error) {

	db, err := nutsdb.Open(
		nutsdb.DefaultOptions,
		nutsdb.WithDir(meta),
	)

	if err != nil {
		log.E("打开metadata失败：", err.Error())
		return nil, err
	}

	return &Scanner{
		Count:  0,
		root:   root,
		cached: db,
		ctx:    ctx,
		wg:     new(sync.WaitGroup),
		Errs:   []string{},
	}, nil

}

func (m *Scanner) Start(manager *ScannerManager, refresh bool) {
	//默认最多扫描5层目录
	m.scanFiles(manager, m.Walk(refresh, 5))

}

func (m *Scanner) Stop() {

	if m.wg != nil {
		m.wg.Wait()
	}
	if m.cached != nil {
		log.I(`关闭缓存数据库`)
		m.cached.Close()
	}
}

func (m *Scanner) KVFn() *nutsdb.DB {

	select {
	case <-m.ctx.Done():
		return nil
	default:
		return m.cached
	}
	// return m.cached
}

// Walk 遍历扫描路径下文件
func (m *Scanner) Walk(refresh bool, maxDepth int) <-chan *schema.Book {

	log.I(`开始扫描路径:`, m.root)
	books := make(chan *schema.Book)
	m.wg.Add(1)
	go func() {
		defer m.wg.Done()
		err := filepath.WalkDir(m.root, newWalkDirFunc(books, m.KVFn, maxDepth, refresh))

		if err != nil {
			log.E(`扫描路径失败：`, err.Error())
		}

		close(books)
	}()

	return books
}

func (m *Scanner) scanFiles(manager *ScannerManager, books <-chan *schema.Book) {

	errs := []string{}
	statusChan := make(chan ScanStatus) // 新增一个状态通道

	m.wg.Add(1)
	go func() {

		ticker := time.NewTicker(1 * time.Second) // 定义一个1秒的定时器,没秒钟将当前扫描状态传出去

		defer func() {

			m.wg.Done()
			// close(errChan)

			close(statusChan)
			ticker.Stop()
			log.I(`退出扫描程序`)
		}()

		for {

			select {

			case <-m.ctx.Done():
				statusChan <- m.status(errs, false)
				log.W(`接收到退出命令，退出扫描`)
				return
			case <-ticker.C: // 定时器触发时发送当前状态
				statusChan <- m.status(errs, true)
				errs = []string{}
			case book, ok := <-books:
				if !ok {
					//books is closed
					statusChan <- m.status(errs, false)
					log.I(`扫描完成，退出解析文件。`)
					return
				}
				m.Count++
				log.D(`开始解析: `, book.Path, ` 到数据库`)

				if err := book.GetMetadataFromFile(); err != nil {
					log.E(`获取图书基本元素失败 `, err.Error())
					errs = append(errs, `文件：`+book.Path+` 解析失败：`+err.Error())
				} else {
					if err := book.Save(m.ctx, manager.orm, manager.kv); err != nil {
						errs = append(errs, err.Error())
					} else {
						m.cacheFilePath(book.Path)
					}
					//

				}

			}
		}

	}()

	m.wg.Add(1)
	// 新增一个 goroutine，用于监听状态通道，并更新状态
	go func() {
		defer m.wg.Done()
		for status := range statusChan {
			manager.updateStatus(status)
		}
		//关闭扫描器
		manager.dumpStats(m.cached)
		log.D(`exit m.cached.Close()`)
		m.cached.Close()
		m.cached = nil
	}()

}

func (m *Scanner) cacheFilePath(path string) error {
	return m.cached.Update(
		func(tx *nutsdb.Tx) error {
			if err := tx.Put(`files/`, []byte(path), []byte{}, 0); err != nil {
				return err
			}
			return nil
		})

}

func (m *Scanner) filePathExists(path string) bool {

	err := m.cached.View(func(tx *nutsdb.Tx) error {

		_, err := tx.Get(`files/`, []byte(path))
		return err

	})

	return err == nil

}

func filePathExists(cached *nutsdb.DB, path string) bool {

	if cached == nil {
		return false
	}

	return cached.View(func(tx *nutsdb.Tx) error {

		_, err := tx.Get(`files/`, []byte(path))
		return err

	}) == nil
}

func (m *Scanner) status(errs []string, done bool) ScanStatus {
	return ScanStatus{
		Running:   done,
		ScanCount: m.Count,
		Errs:      errs,
	}
}

func (m *Scanner) dumpStats(status ScanStatus) error {

	bytes, _ := json.Marshal(status)

	return m.cached.Update(
		func(tx *nutsdb.Tx) error {
			if err := tx.Put(`sys`, []byte(scanStatsKey), bytes, 0); err != nil {
				return err
			}
			return nil
		})

}

type getDBFn func() *nutsdb.DB

func newWalkDirFunc(bookChan chan<- *schema.Book, dbfn getDBFn, maxDepth int, refresh bool) fs.WalkDirFunc {

	return func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			log.E(`扫描路径失败：`, path)
			return err
		}

		if d.IsDir() && strings.Count(path, string(os.PathSeparator)) > maxDepth {
			log.W("skip", path)
			return fs.SkipDir
			// return nil
		}

		//只扫描epub文件
		if !d.IsDir() {

			fileType := schema.ParseFileType(filepath.Ext(d.Name()))

			if fileType == schema.UnkownFile || (filePathExists(dbfn(), path) && !refresh) {
				return nil
			}

			info, err := d.Info()
			if err != nil {
				log.E(`获取文件信息失败：`, path)
				return err
			}

			log.I(`扫描的到文件：`, path)
			now := time.Now()

			book := &schema.Book{
				ID:            schema.GenBookID(now),
				BookType:      fileType,
				Size:          info.Size(),
				Path:          path,
				CTime:         info.ModTime().UnixMilli(),
				UTime:         now.UnixMilli(),
				Rating:        0,
				PublishDate:   `1970-01-01`,
				CountVisit:    0,
				CountDownload: 0,
			}

			bookChan <- book

		}

		time.Sleep(time.Millisecond * 200) //测试用，防止cpu占用过高
		return nil
	}
}
