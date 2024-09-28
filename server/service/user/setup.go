package user

import (
	"context"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/middleware"
	"github.com/lxpio/omnigram/server/service/user/schema"
	"github.com/lxpio/omnigram/server/store"
	"github.com/lxpio/omnigram/server/utils"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/hashicorp/golang-lru/v2/expirable"
)

var (
	orm *gorm.DB

	sessionCache  *expirable.LRU[string, *schema.Session]
	userInfoCache *expirable.LRU[string, *schema.User]
	// kv  schema.KV
)

func Initialize(ctx context.Context, cf *conf.Config) {

	if cf.DBOption.Driver == store.DRSQLite {
		dbPath := filepath.Join(cf.DBOption.Host, `omnigram.db`)
		log.I(`初始化用户库: ` + dbPath)

		var err error
		orm, err = store.OpenDB(&store.Opt{
			Driver:   store.DRSQLite,
			Host:     dbPath,
			LogLevel: cf.LogLevel,
		})

		if err != nil {
			log.E(`open user db failed`, err)
			os.Exit(1)
		}
	} else {
		orm = ctx.Value(utils.DBContextKey).(*gorm.DB)
	}

	log.I(`设置5分钟超时的LRU缓存...`)

	userInfoCache = expirable.NewLRU[string, *schema.User](15, nil, time.Second*300)
	sessionCache = expirable.NewLRU[string, *schema.Session](15, nil, time.Second*300)

	middleware.Register(middleware.OathMD, OauthMiddleware)
	middleware.Register(middleware.AdminMD, AdminMiddleware)
}

// Setup reg router
func Setup(router *gin.Engine) {

	oauthMD := middleware.Get(middleware.OathMD)
	adminMD := middleware.Get(middleware.AdminMD)

	router.POST("/auth/login", loginHandle)
	router.POST("/auth/token", getAccessTokenHandle)

	router.POST("/auth/logout", oauthMD, logoutHandle)

	router.DELETE("/auth/accounts/:user_id/apikeys/:key_id", oauthMD, deleteAPIKeyHandle)
	router.POST("/auth/accounts/:user_id/apikeys", oauthMD, createAPIKeyHandle)
	router.GET(`/auth/accounts/:user_id/apikeys`, oauthMD, getAPIKeysHandle)

	router.POST(`/auth/accounts/:user_id/reset`, oauthMD, resetPasswordHandle)

	router.GET("/user/userinfo", oauthMD, getUserInfoHandle) //获取用户信息

	router.POST(`/admin/accounts`, oauthMD, adminMD, createAccountHandle)            //创建用户
	router.GET(`/admin/accounts`, oauthMD, adminMD, listAccountHandle)               //获取用户列表
	router.GET(`/admin/accounts/:user_id`, oauthMD, adminMD, getAccountHandle)       //获取用户信息（这里是关联接口获取
	router.DELETE(`/admin/accounts/:user_id`, oauthMD, adminMD, deleteAccountHandle) //删除用户

}

func Close() {

}

func InitData(cf *conf.Config) error {

	var db *gorm.DB
	var err error

	if cf.DBOption.Driver == store.DRSQLite {

		dbPath := filepath.Join(cf.DBOption.Host, `omnigram.db`)
		log.I(`初始化数据库: ` + dbPath)

		db, err = store.OpenDB(&store.Opt{
			Driver:   store.DRSQLite,
			Host:     dbPath,
			LogLevel: cf.LogLevel,
		})

	} else {
		log.I(`初始化数据库...`)
		db, err = store.OpenDB(cf.DBOption)
	}

	if err != nil {
		log.E(err)
		os.Exit(1)
	}

	return db.Transaction(func(tx *gorm.DB) error {

		if err := tx.AutoMigrate(&schema.User{}, &schema.APIToken{}, &schema.Session{}); err != nil {
			return err
		}

		u := &schema.User{
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

		if err := tx.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "name"}},
			DoNothing: true,
		}).Create(u).Error; err != nil {
			return err
		}

		if u.ID == 1 {
			apiKey := schema.NewAPIToken(u.ID)
			if err := tx.Create(&apiKey).Error; err != nil {
				log.E(`初始化用户APIKey失败`, err)
				return err
			}
			log.I(`初始化数据成功, 用户信息: `, u.Name, `, 初始 APIKey: `, apiKey.APIKey)
		}

		return nil

	})

}
