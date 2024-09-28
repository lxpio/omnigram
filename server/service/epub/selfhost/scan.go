// scan 目录扫描搜刮工具
package selfhost

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/service/epub/schema"
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

func (m *Scanner) Stop() {
	if m.wg != nil {
		m.wg.Wait()
	}
	if m.cached != nil {
		m.cached.Close()
	}
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

func (m *Scanner) status(errs []string, done bool) ScanStatus {
	return ScanStatus{
		Running:   done,
		ScanCount: m.Count,
		EpubCount: m.Count, // 当前只是扫描了 epub 文件
		Errs:      errs,
	}
}

func (m *Scanner) scanEpub(manager *ScannerManager, books <-chan *schema.Book) {

	errs := []string{}
	statusChan := make(chan ScanStatus) // 新增一个状态通道

	m.wg.Add(1)
	go func() {

		ticker := time.NewTicker(1 * time.Second) // 定义一个1秒的定时器

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
						m.cacheEpubFilePath(book.Path)
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

		m.cached.Close()
		m.cached = nil
	}()

}

func (m *Scanner) Start(manager *ScannerManager, refresh bool) {

	books := m.Walk(refresh)

	m.scanEpub(manager, books)

}

// Walk 遍历扫描路径下epub文件
func (m *Scanner) Walk(refresh bool) <-chan *schema.Book {

	log.I(`开始扫描路径:`, m.root)
	books := make(chan *schema.Book)

	go func() {

		err := filepath.Walk(m.root, func(path string, info os.FileInfo, err error) error {

			if err != nil {
				log.E(`扫描路径失败：`, path)
				return err
			}

			//只扫描epub文件
			if !info.IsDir() && filepath.Ext(info.Name()) == `.epub` {

				if m.epubFilePathExists(path) && !refresh {
					log.I(`文件：`, path, `已经存在,放弃扫描`)
					return nil
				}

				log.I(`扫描的到文件：`, path)
				ctime := time.Now().Unix()
				book := &schema.Book{
					ID:            0,
					Size:          info.Size(),
					Path:          path,
					CTime:         ctime,
					UTime:         ctime,
					Rating:        0,
					PublishDate:   `1970-01-01`,
					CountVisit:    0,
					CountDownload: 0,
				}

				books <- book

			}
			return nil
		})

		if err != nil {
			log.E(`扫描路径失败：`, err.Error())
		}
		close(books)
	}()

	return books
}

func (m *Scanner) cacheEpubFilePath(path string) error {
	return m.cached.Update(
		func(tx *nutsdb.Tx) error {
			if err := tx.Put(`epub`, []byte(path), []byte{}, 0); err != nil {
				return err
			}
			return nil
		})

}

func (m *Scanner) epubFilePathExists(path string) bool {

	err := m.cached.View(func(tx *nutsdb.Tx) error {

		_, err := tx.Get(`epub`, []byte(path))
		return err

	})

	return err == nil

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
