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
)

var (
	BUILDSTAMP = ""
	GITHASH    = ""

	confFile    string
	showVersion bool

	//override config logLevel
	initFlag bool
)

func main() {

	flag.BoolVar(&showVersion, "version", false, "show build version.")
	flag.StringVar(&confFile, "conf", "./conf.yml", "The configure file")
	flag.BoolVar(&initFlag, "init", false, "init server first user and token")

	flag.Parse()

	if showVersion {
		println(`omnigram-server version: `, conf.Version)
		println(`git commit hash: `, GITHASH)
		println(`utc build time: `, BUILDSTAMP)
		os.Exit(0)
	}

	cf, err := conf.InitConfig(confFile)

	if err != nil {
		fmt.Println(`open config file with err:`, err.Error())
		os.Exit(1)
	}

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

	if initFlag {
		server.InitServerData(cf)
		os.Exit(0)
	} else {
		//open api server
		app := server.NewAPPWithConfig(cf)
		app.StartContext(ctx)
	}

	<-ch

	fmt.Println(`receive ctrl+c command, now quit...`)
	defer cancel()

	if app != nil {
		app.GracefulStop()
	}
}
