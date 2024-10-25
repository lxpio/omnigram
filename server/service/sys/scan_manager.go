package sys

import (
	"context"
	"encoding/json"
	"sync"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/schema"
	"github.com/lxpio/omnigram/server/store"
)

// const statsCachePath = `config`

// ScanStatus 扫描状态
type ScanStatus struct {
	Total     int64    `json:"total"`
	Running   bool     `json:"running"`
	ScanCount int      `json:"scan_count"`
	Errs      []string `json:"errs"`
	DiskUsage int      `json:"disk_usage"`
	// Version   string   `json:"version"`
}

type ScannerManager struct {
	// cf *conf.Config
	dataPath string

	ctx context.Context

	//cancel scanner
	cancelFunc context.CancelFunc

	sync.RWMutex

	stats ScanStatus
}

func NewScannerManager(ctx context.Context) (*ScannerManager, error) {

	mng := &ScannerManager{
		ctx: ctx,
	}

	//获取本地存储的状态
	log.I(`扫描器初始化完成`)
	return mng.load()
}

func (m *ScannerManager) IsRunning() bool {
	m.RLock()
	defer m.RUnlock()
	return m.stats.Running
}

func (m *ScannerManager) Status() ScanStatus {

	var total int64
	err := store.FileStore().Model(&schema.Book{}).Count(&total).Error

	if err != nil {
		log.W(`获取数据库中文件数量失败： `, err.Error())
	}

	m.RLock()
	defer m.RUnlock()

	m.stats.Total = total

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

	scan, err := NewScan(ctx, m.dataPath) //new scanner

	if err != nil {
		m.Unlock()
		log.E(err.Error())
		return
	}
	m.stats.Running = true
	m.stats.Errs = nil
	m.Unlock()

	scan.Start(refresh)
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

	m.stats = stats

}

func (m *ScannerManager) dumpStatus(cached store.KV) error {

	bytes, _ := json.Marshal(m.Status())

	return cached.Put(m.ctx, `sys`, scanStatsKey, bytes)

}

func updateStatus(stats ScanStatus) {

	if manager != nil {
		manager.updateStatus(stats)
	}
}

func dumpStatus() error {

	if manager != nil {

		return manager.dumpStatus(store.GetKV())
	}
	return nil
}

func (m *ScannerManager) load() (*ScannerManager, error) {
	cf := conf.GetConfig()

	m.dataPath = cf.EpubOptions.DataPath

	m.stats = ScanStatus{}

	e, err := store.GetKV().Get(m.ctx, `sys`, scanStatsKey)
	if err != nil {
		return m, err
	}

	if err = json.Unmarshal(e, &m.stats); err != nil {
		return m, err
	}

	m.stats.Total, err = schema.CountBook(store.FileStore())

	return m, err
}
