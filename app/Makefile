#Makefile

PROJECT_PATH=$(shell cd "$(dirname "$0" )" &&pwd)
PROJECT_NAME=omnigram
VERSION=$(shell git describe --tags | sed 's/\(.*\)-.*/\1/')
BUILD_DATE=$(shell date -u '+%Y-%m-%d_%I:%M:%S%p')
BUILD_HASH=$(shell git rev-parse HEAD)

.PHONY: all


all : apk


build_runner:
	@echo "build_runner build"
	@flutter clean
	@dart run --enable-experiment=macros  build_runner build

launcher_icons: build_runner
	@dart run flutter_launcher_icons:main


release: build_runner
	@echo "release build"
	@flutter build appbundle --no-tree-shake-icons


apk:
	@flutter build apk --split-per-abi