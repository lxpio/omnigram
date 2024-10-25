package schema

import (
	"errors"
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// User 用户表
type User struct {
	ID         int64  `json:"id" form:"id" gorm:"primaryKey;comment:用户ID(UUID)"`
	Name       string `json:"name" form:"name" gorm:"uniqueIndex:idx_users_user_name;type:varchar(100);comment:用户名"`
	Email      string `json:"email" form:"email"  gorm:"type:varchar(100);comment:用户邮箱"`
	Mobile     string `json:"mobile" form:"mobile"   gorm:"type:varchar(50);comment:用户手机"`
	RoleID     int64  `json:"role_id" gorm:"role_id;comment:用户角色"` //
	NickName   string `json:"nick_name" form:"nick_name" gorm:"column:nick_name;type:varchar(100); comment:用户昵称"`
	AvatarUrl  string `json:"avatar_url" form:"avatar_url" gorm:"column:avatar_url;type:varchar(255); comment:用户头像图片地址"`
	WxUnionID  string `json:"wx_unionid" form:"wx_unionid" gorm:"column:wx_unionid;type:varchar(50); comment:微信unionID"`
	Credential string `json:"credential" form:"credential" gorm:"type:varchar(100); comment:加密密码"`
	Locked     bool   `json:"locked" form:"locked" gorm:"comment:用户是否被锁定"`
	MFASwitch  int    `json:"mfa_switch" form:"mfa_switch" gorm:"column:mfa_switch;default:1;comment:mfa虚拟认证"`
	CTime      int64  `json:"ctime" form:"ctime" gorm:"column:ctime;autoCreateTime:milli;comment:创建时间"`
	UTime      int64  `json:"utime" form:"utime" gorm:"column:utime;autoUpdateTime:milli;comment:更新时间"`
	ATime      int64  `json:"atime" form:"uatime" gorm:"column:atime;autoCreateTime:milli;comment:访问时间"`
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

	return user.Masking(), err
}

func AllUsers(store *gorm.DB) ([]User, error) {
	var users []User
	//获取用户基本信息

	err := store.Select("id", "name", "mobile", "email", "role_id", "nick_name", "AvatarUrl", "locked", "mfa_switch", "ctime", "atime").Limit(10).Find(&users).Error

	return users, err

}

// FirstUserByAccount 根据 邮箱，手机号，用户名 获取用户
func FirstUserByAccount(store *gorm.DB, account string) (*User, error) {

	if account == "" {
		return nil, errors.New(`账号信息为空`)
	}
	user := &User{}
	err := store.Model(user).Where("email = ? or mobile = ? or name = ?", account, account, account).First(&user).Error

	return user, err
}

// VerifyPassword VerifyPassword
func (m *User) VerifyPassword(str string) bool {

	return bcrypt.CompareHashAndPassword([]byte(m.Credential), []byte(str)) == nil

}

func (m *User) ResetPassword(store *gorm.DB, password string) error {
	m.Credential = encryptPassword(password)

	return store.Model(m).Update("credential", m.Credential).Error

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
		UTime:     time.Now().UnixMilli(),
	}

	err := session.Save(store)

	return session, err
}
