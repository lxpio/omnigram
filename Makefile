#Makefile

PROJECT_PATH=$(shell cd "$(dirname "$0" )" &&pwd)
PROJECT_NAME=omnigram
VERSION=$(shell git describe --tags | sed 's/\(.*\)-.*/\1/')
BUILD_DATE=$(shell date -u '+%Y-%m-%d_%I:%M:%S%p')
BUILD_HASH=$(shell git rev-parse HEAD)

.PHONY: all


all : omnigram




objectbox:
	@echo "objectbox build"
	@flutter clean
	@dart run build_runner build
omnigram: objectbox
	# @flutter pub get
	@dart run flutter_native_splash:create
	@dart run flutter_launcher_icons:main


release:
	@echo "release build"
	@flutter build appbundle 