package schema

import (
	"os"
	"path/filepath"

	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/store"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

func InitData() error {

	if err := initReaderData(); err != nil {
		log.E(err)
		os.Exit(1)
	}

	if err := initUserData(); err != nil {
		log.E(err)
		os.Exit(1)
	}

	return nil
}

func initUserData() error {

	db := store.Store()

	log.D(`初始化用户数据`)

	var err error

	return db.Transaction(func(tx *gorm.DB) error {

		if err = tx.AutoMigrate(&User{}, &APIToken{}, &Session{}); err != nil {
			return err
		}

		u := &User{
			Name:       os.Getenv(`OMNI_USER`),
			Credential: os.Getenv(`OMNI_PASSWORD`),
			RoleID:     1,
		}

		if u.Name == `` {
			u.Name = `admin`
		}

		if u.Credential == `` {
			u.Credential = `123456`
		}

		log.I(`初始化数据, 用户信息: `, u.Name, u.Credential)

		if err = tx.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "name"}},
			DoNothing: true,
		}).Create(u).Error; err != nil {
			return err
		}

		if u.ID == 1 {
			apiKey := NewAPIToken(u.ID)
			if err := tx.Create(&apiKey).Error; err != nil {
				log.E(`初始化用户APIKey失败`, err)
				return err
			}
			log.I(`初始化数据成功, 用户信息: `, u.Name, `, 初始 APIKey: `, apiKey.APIKey)
		}

		return nil

	})

}

func initReaderData() error {
	log.D(`初始化文档相关数据库`)
	cf := conf.GetConfig()

	metapath := cf.MetaPath()

	//metapath 路径不存在则创建
	if _, err := os.Stat(metapath); os.IsNotExist(err) {
		if err := os.Mkdir(metapath, 0755); err != nil {
			panic(err)
		}
	}

	//初始化上传文件目录
	os.MkdirAll(filepath.Join(cf.EpubOptions.DataPath, `upload`), 0755)
	os.MkdirAll(cf.MetaPath(), 0755)

	db := store.FileStore()

	return db.Transaction(func(tx *gorm.DB) error {

		//auotoMigrate
		if err := tx.AutoMigrate(&Book{}, &BookTagShip{}, &FavBook{}, &ReadProgress{}); err != nil {

			return err
		}

		log.I(`初始化书籍表成功。`)

		return nil

	})

}
