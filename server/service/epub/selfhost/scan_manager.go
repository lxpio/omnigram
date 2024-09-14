package selfhost

import (
	"context"
	"encoding/json"
	"path/filepath"
	"sync"

	"github.com/lxpio/omnigram/server/service/epub/schema"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
	"github.com/nutsdb/nutsdb"
	"gorm.io/gorm"
)

// const statsCachePath = `config`

// ScanStatus 扫描状态
type ScanStatus struct {
	Total     int64    `json:"total"`
	Running   bool     `json:"running"`
	ScanCount int      `json:"scan_count"`
	Errs      []string `json:"errs"`
	DiskUsage int      `json:"disk_usage"`
	EpubCount int      `json:"epub_count"`
	PDFCount  int      `json:"pdf_count"`
	// Version   string   `json:"version"`
}

type ScannerManager struct {
	// cf *conf.Config
	dataPath string
	metaPath string
	kv       store.KV
	orm      *gorm.DB

	ctx context.Context

	//cancel scanner
	cancelFunc context.CancelFunc

	sync.RWMutex

	stats ScanStatus
}

func NewScannerManager(ctx context.Context, cf *conf.Config, kv store.KV, orm *gorm.DB) (*ScannerManager, error) {

	metapath := filepath.Join(cf.MetaDataPath, utils.ConfigBucket)

	stats, err := loadLastScanStatus(metapath, orm)

	if err != nil {
		return nil, err
	}

	scanner := &ScannerManager{
		dataPath: cf.EpubOptions.DataPath,
		metaPath: metapath,
		kv:       kv,
		orm:      orm,
		stats:    stats,
		ctx:      ctx,
	}

	//获取本地存储的状态

	return scanner, nil
}

func (m *ScannerManager) IsRunning() bool {
	m.RLock()
	defer m.RUnlock()
	return m.stats.Running
}

func (m *ScannerManager) Status() ScanStatus {
	m.RLock()
	defer m.RUnlock()

	return m.stats

}

func (m *ScannerManager) Start(maxThread int, refresh bool) {

	if m.IsRunning() {
		log.E(`扫描器已经在执行，放弃执行`)
		return
	}
	log.I(`启动文件目录扫描`)

	m.newScan(refresh)

}

func (m *ScannerManager) newScan(refresh bool) {
	m.Lock()

	var ctx context.Context
	ctx, m.cancelFunc = context.WithCancel(m.ctx)

	scan, err := NewScan(ctx, m.dataPath, m.metaPath) //new scanner

	if err != nil {
		m.Unlock()
		log.E(err.Error())
		return
	}
	m.stats.Running = true
	m.stats.Errs = nil
	m.Unlock()

	scan.Start(m, refresh)
}

func (m *ScannerManager) Stop() {
	m.Lock()
	defer m.Unlock()
	if m.cancelFunc != nil {
		log.D(`执行退出扫描命令...`)
		m.cancelFunc()
	} else {

		m.stats.Running = false
	}

}

func (m *ScannerManager) updateStatus(stats ScanStatus) {
	m.Lock()
	defer m.Unlock()
	stats.Errs = append(stats.Errs, m.stats.Errs...)
	stats.Total = m.stats.Total + int64(m.stats.ScanCount)
	m.stats = stats

}

func (m *ScannerManager) dumpStats(cached *nutsdb.DB) error {

	bytes, _ := json.Marshal(m.Status())

	return cached.Update(
		func(tx *nutsdb.Tx) error {
			if err := tx.Put(`sys`, []byte(scanStatsKey), bytes, 0); err != nil {
				return err
			}
			return nil
		})

}

func loadLastScanStatus(metapath string, orm *gorm.DB) (ScanStatus, error) {

	stats := ScanStatus{}

	db, err := nutsdb.Open(
		nutsdb.DefaultOptions,
		nutsdb.WithDir(metapath),
	)

	if err != nil {
		return stats, err
	}

	defer db.Close()

	db.View(
		func(tx *nutsdb.Tx) error {

			e, err := tx.Get(`sys`, []byte(scanStatsKey))
			if err != nil {
				return err
			}

			return json.Unmarshal(e.Value, &stats)

		})

	stats.Total, err = schema.CountBook(orm)

	return stats, err
}
