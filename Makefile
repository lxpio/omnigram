#Makefile

PROJECT_PATH=$(shell cd "$(dirname "$0" )" &&pwd)
PROJECT_NAME=omnigram
VERSION=$(shell git describe --tags | sed 's/\(.*\)-.*/\1/')
BUILD_DATE=$(shell date -u '+%Y-%m-%d_%I:%M:%S%p')
BUILD_HASH=$(shell git rev-parse HEAD)

.PHONY: all


all : omnigram

i18n:
	@echo "gen i18n locales"
	@get generate locales assets/locales

objectbox:
	@echo "gen i18n locales"
	@dart run build_runner build
omnigram: i18n objectbox
	# @flutter pub get
	@dart run flutter_native_splash:create
	@dart run flutter_launcher_icons:main