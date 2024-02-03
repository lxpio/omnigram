package schema

import (
	"strconv"

	"github.com/lxpio/omnigram/server/api/log"
	"github.com/lxpio/omnigram/server/api/utils"
	"gorm.io/gorm"
)

type APIToken struct {
	ID     int64  `json:"id" form:"id" gorm:"primaryKey;autoIncrement;comment:id:API ID"`
	APIKey string `json:"api_key" form:"api_key" gorm:"type:char(40);uniqueIndex;comment:API Key"`
	UserID int64  `json:"user_id" form:"user_id" gorm:"column:user_id;type:int8;comment:用户ID"`
}

// gen random string Key with length 32
func NewAPIToken(userID int64) *APIToken {

	return &APIToken{
		UserID: userID,
		APIKey: utils.RandomString(40),
	}
}

func FirstTokenByAPIKey(store *gorm.DB, apiKey string) (*APIToken, error) {
	token := &APIToken{}
	err := store.Model(token).Where("api_key = ?", apiKey).First(&token).Error
	return token, err
}

func (m *APIToken) Save(db *gorm.DB) error {
	return db.Save(m).Error
}

func DeleteAPIKey(db *gorm.DB, id string) error {
	//change id to int64
	idInt64, _ := strconv.ParseInt(id, 10, 64)
	return db.Where("id = ?", idInt64).Delete(&APIToken{}).Error
}

func GetAPIKeysByUserID(db *gorm.DB, userID int64) ([]*APIToken, error) {
	res := make([]*APIToken, 0)
	err := db.Where("user_id = ?", userID).Find(&res).Error
	return res, err

}

func GetAPIKeyByUserID(db *gorm.DB, userID int64) (*APIToken, error) {
	res := &APIToken{}
	err := db.Where("user_id = ?", userID).First(res).Error

	if err != nil {
		log.W("用户没有apikey 将创建一个新的")
		res = NewAPIToken(userID)
		err = res.Save(db)
	}

	return res, err
}
