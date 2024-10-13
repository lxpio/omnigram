package schema

import (
	"crypto/sha1"
	"encoding/json"
	"fmt"
	"time"

	"github.com/lxpio/omnigram/server/log"
	"gorm.io/gorm"
)

type Session struct {
	Session     string        `json:"session" gorm:"type:char(40);primaryKey;comment:当前会话id"`
	UserID      int64         `json:"user_id" gorm:"comment:用户ID(UUID)"`
	RemoteIP    string        `json:"remote_ip" gorm:"column:remote_ip;type:cidr;comment:用户登录ip"`
	UserAgent   string        `json:"user_agent" gorm:"column:user_agent;default:null;type:varchar(255);comment:客户端平台标识"`
	DeviceID    string        `json:"device_id" gorm:"column:device_id;type:varchar(50);comment:客户端登录设备"`
	DeviceModel string        `json:"device_model" gorm:"column:device_model;type:varchar(50);comment:客户端登录设备"`
	DeviceType  string        `json:"device_type" gorm:"column:device_type;type:varchar(50);comment:客户端登录设备类型"`
	DistrictId  int32         `json:"district_id" gorm:"column:district_id;type:int8;comment:登录城市id"`
	FromUrl     string        `json:"from_url" gorm:"column:from_url;type:varchar(255);comment:登录上一跳服务"`
	Duration    time.Duration `json:"duration" gorm:"type:int8;comment:会话有效时间"`
	CTime       int64         `json:"ctime" form:"ctime" gorm:"column:ctime;autoCreateTime;comment:创建时间"`
	UTime       int64         `json:"utime" form:"utime" gorm:"column:utime;autoUpdateTime;comment:更新时间"`
	UserInfo    *User         `json:"user_info" gorm:"-"`
}

func (m *Session) Clean(store *gorm.DB) {
	//这里忽略错误，由系统其他goroutine 定时清理过期session
	if m.Session != `` {
		store.Delete(m)
		// key := cacheKeySession + m.Session
		// store.LRU.Remove(key)
	}

}

func DeleteSessionByID(store *gorm.DB, id string) error {

	return store.Exec(`DELETE FROM sessions WHERE session = ?`, id).Error

}

func (m *Session) Save(store *gorm.DB) error {
	//这里忽略错误，由系统其他goroutine 定时清理过期session
	if err := store.Create(m).Error; err != nil {
		log.E("CreateSession err", err)
		return err
	}

	// store.LRU.Set(cacheKeySession+m.Session, m)
	return nil
}

// parseSessionUser 获取session 关联的用户信息，
func FirstSessionByID(store *gorm.DB, id string) (*Session, error) {

	//get session from db
	ret := &Session{
		UserInfo: &User{},
	}

	if err := store.Table(`sessions`).Where(`session = ?`, id).First(&ret).Error; err != nil {
		log.E(`查询session：`, id, err.Error())
		return ret, err
	}

	//get session related user
	err := store.Table(`users`).Where(`id = ?`, ret.UserID).First(&ret.UserInfo).Error
	if err != nil {
		log.E(`查询session 关联的UserID失败`, ret.UserID)
	}

	return ret, err

}

// BeforeCreate BeforeCreate
func (m *Session) BeforeCreate(_ *gorm.DB) error {

	m.CTime = time.Now().Unix()

	h := sha1.New()

	b, _ := json.Marshal(m)

	h.Write([]byte(b))

	bs := h.Sum(nil)

	m.Session = fmt.Sprintf("%x", bs)

	return nil
}
