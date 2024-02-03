package schema

import (
	"errors"
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// User 用户表
type User struct {
	ID         int64     `json:"id" form:"id" gorm:"primaryKey;comment:用户ID(UUID)"`
	Email      string    `json:"email" form:"email"  gorm:"type:varchar(100);comment:用户邮箱"`
	Mobile     string    `json:"mobile" form:"mobile"   gorm:"type:varchar(50);comment:用户手机"`
	UserName   string    `json:"user_name" form:"user_name" gorm:"uniqueIndex:idx_users_user_name;type:varchar(100);comment:用户名"`
	RoleID     int64     `json:"role_id" gorm:"role_id;comment:用户角色"` //
	NickName   string    `json:"nick_name" form:"nick_name" gorm:"type:varchar(100); comment:用户昵称"`
	AvatarUrl  string    `json:"avatar_url" form:"avatar_url" gorm:"type:varchar(255); comment:用户头像图片地址"`
	WxUnionID  string    `json:"wx_unionid" form:"wx_unionid" gorm:"type:varchar(50); comment:微信unionID"`
	Credential string    `json:"credential" form:"credential" gorm:"type:varchar(100); comment:加密密码"`
	Locked     bool      `json:"locked" form:"locked" gorm:"comment:用户是否被锁定"`
	MFASwitch  bool      `json:"mfa_switch" form:"mfa_switch" gorm:"comment:mfa虚拟认证"`
	CTime      time.Time `json:"ctime" form:"ctime" gorm:"column:ctime;autoCreateTime;comment:创建时间"`
	UTime      time.Time `json:"utime" form:"utime" gorm:"column:utime;autoUpdateTime;comment:更新时间"`
	ATime      time.Time `json:"atime" form:"uatime" gorm:"column:atime;autoCreateTime;comment:访问时间"`
}

func (m *User) Masking() *User {
	m.Credential = ``
	return m
}

// BeforeCreate BeforeCreate
func (m *User) BeforeCreate(_ *gorm.DB) error {
	m.Credential = encryptPassword(m.Credential)

	return nil
}

// FirstUserByAccount 根据 邮箱，手机号，用户名 获取用户
func FirstUserByID(store *gorm.DB, id int64) (*User, error) {

	if id < 0 {
		return nil, errors.New(`账号信息为空`)
	}
	user := &User{ID: id}
	err := store.Model(user).First(&user).Error

	if err != nil {
		return user.Masking(), err
	}

	return user, err
}

// FirstUserByAccount 根据 邮箱，手机号，用户名 获取用户
func FirstUserByAccount(store *gorm.DB, account string) (*User, error) {

	if account == "" {
		return nil, errors.New(`账号信息为空`)
	}
	user := &User{}
	err := store.Model(user).Where("email = ? or mobile = ? or user_name = ?", account, account, account).First(&user).Error

	return user, err
}

// VerifyPassword VerifyPassword
func (m *User) VerifyPassword(str string) bool {

	return bcrypt.CompareHashAndPassword([]byte(m.Credential), []byte(str)) == nil

}

// encryptPassword 加密密码
func encryptPassword(raw string) (credential string) {
	bytes, _ := bcrypt.GenerateFromPassword([]byte(raw), 8)
	return string(bytes)
}

func (m *User) CreateSession(store *gorm.DB, UA, From, IP string) (*Session, error) {
	//zlog.D("VerifyPassword : ", m.Credential)
	session := &Session{
		UserID:    m.ID,
		UserInfo:  m,
		UserAgent: UA,
		FromUrl:   From,
		RemoteIP:  IP,
		Duration:  1800,
		UTime:     time.Now(),
	}

	err := session.Save(store)

	return session, err
}
