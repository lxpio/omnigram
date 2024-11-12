// scan 目录扫描搜刮工具
package sys

import (
	"context"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
)

const scanStatsKey = `last_scan_status_v2`

// Scanner  文件扫描器
type Scanner struct {
	Running bool     `json:"running"`
	Count   int      `json:"count"` //扫描文件计数
	Errs    []string `json:"errors"`
	root    string   `json:"-"` //扫描文件根目录
	ctx     context.Context

	wg *sync.WaitGroup `json:"-"`
}

func NewScan(ctx context.Context, dataPath string) (*Scanner, error) {

	return &Scanner{
		Count: 0,
		root:  dataPath,

		ctx:  ctx,
		wg:   new(sync.WaitGroup),
		Errs: []string{},
	}, nil

}

func (m *Scanner) Start(refresh bool) {
	//默认最多扫描5层目录
	m.scanFiles(m.Walk(refresh, 5))

}

func (m *Scanner) Stop() {

	if m.wg != nil {
		m.wg.Wait()
	}

}

// Walk 遍历扫描路径下文件
func (m *Scanner) Walk(refresh bool, maxDepth int) <-chan *schema.Book {

	log.I(`开始扫描路径:`, m.root)
	books := make(chan *schema.Book)
	m.wg.Add(1)
	go func() {
		defer m.wg.Done()
		err := filepath.WalkDir(m.root, newWalkDirFunc(m.ctx, books, maxDepth, refresh))

		if err != nil {
			log.E(`扫描路径失败：`, err.Error())
		}

		close(books)
	}()

	return books
}

func (m *Scanner) scanFiles(books <-chan *schema.Book) {

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
				// log.D(`开始解析: `, book.Path, ` 到数据库`)

				if err := book.GetMetadataFromFile(); err != nil {
					log.E(`获取图书基本元素失败 `, err.Error())
					errs = append(errs, `文件：`+book.Path+` 解析失败：`+err.Error())
				} else {
					if err := book.Save(m.ctx); err != nil {
						errs = append(errs, err.Error())
					} else {
						m.cacheFilePath(m.ctx, book.Path, book.Identifier)
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
			updateStatus(status)
		}
		//关闭扫描器
		dumpStatus()

	}()

}

func (m *Scanner) cacheFilePath(ctx context.Context, path, identifier string) error {

	return store.GetKV().Put(ctx, `files`, path, []byte(identifier))

}

func filePathExists(ctx context.Context, path string) bool {

	_, err := store.GetKV().Get(ctx, `files`, path)

	return err == nil
}

func (m *Scanner) status(errs []string, done bool) ScanStatus {
	return ScanStatus{
		Running:   done,
		ScanCount: m.Count,
		Errs:      errs,
	}
}

func newWalkDirFunc(ctx context.Context, bookChan chan<- *schema.Book, maxDepth int, refresh bool) fs.WalkDirFunc {

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

			if fileType == schema.UnkownFile {
				log.W(`未知文件类型：`, path)
				return nil
			}
			//文件已经扫描过，并且不刷新
			if filePathExists(ctx, path) && !refresh {
				log.W(`文件已经扫描过，并且不刷新：`, path)
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
				FileType:      fileType,
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
