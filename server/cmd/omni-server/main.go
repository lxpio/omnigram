package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/lxpio/omnigram/server"
	"github.com/lxpio/omnigram/server/conf"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/store"
)

var (
	BUILDSTAMP = ""
	GITHASH    = ""

	confFile    string
	showVersion bool

	//override config logLevel
	initFlag bool
)

// @title Omnigram API
// @version 0.1.0
// @description Omnigram - AI-native self-hosted book library management service
// @host localhost:9527
// @BasePath /
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @securityDefinitions.apikey CookieAuth
// @in cookie
// @name _omnigram_session
// @tag.name Auth
// @tag.description Authentication and session management
// @tag.name User
// @tag.description User information
// @tag.name Admin
// @tag.description Admin account management
// @tag.name Reader
// @tag.description Book library management
// @tag.name Sync
// @tag.description Data synchronization
// @tag.name System
// @tag.description System configuration and scanning
// @tag.name TTS
// @tag.description Text-to-speech services
// @tag.name AI
// @tag.description AI configuration and status
// @tag.name OPDS
// @tag.description OPDS catalog feed
func main() {

	flag.BoolVar(&showVersion, "version", false, "show build version.")
	flag.StringVar(&confFile, "conf", "./conf.yml", "The configure file")
	flag.BoolVar(&initFlag, "init", false, "init server first user and token")

	importCalibreFlag := flag.String("import-calibre", "", "path to Calibre library directory to import")

	flag.Parse()

	if showVersion {
		println(`omnigram-server version: `, conf.Version)
		println(`git commit hash: `, GITHASH)
		println(`utc build time: `, BUILDSTAMP)
		os.Exit(0)
	}

	err := conf.InitConfig(confFile)

	if err != nil {
		fmt.Println(`open config file with err:`, err.Error())
		os.Exit(1)
	}

	cf := conf.GetConfig()

	log.Init(cf.LogDir, cf.LogLevel)

	log.I(`omnigram-server version: `, conf.Version)
	log.I(`git commit hash: `, GITHASH)
	log.I(`utc build time: `, BUILDSTAMP)
	log.D(`log level: `, cf.LogLevel)

	defer log.Flush()

	ch := make(chan os.Signal, 2)
	signal.Notify(ch, os.Interrupt, syscall.SIGTERM)
	ctx, cancel := context.WithCancel(context.Background())

	var app *server.App

	if *importCalibreFlag != "" {
		server.InitServerData(ctx)
		importCalibre(*importCalibreFlag, cf.EpubOptions.DataPath, store.FileStore())
		os.Exit(0)
	} else if initFlag {
		server.InitServerData(ctx)
		os.Exit(0)
	} else {
		//open api server
		app = server.NewAPP()
		app.StartContext(ctx)
	}

	<-ch

	fmt.Println(`receive ctrl+c command, now quit...`)
	defer cancel()

	if app != nil {
		app.GracefulStop()
	}
}
