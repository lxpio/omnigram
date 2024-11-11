#Makefile

PROJECT_PATH=$(shell cd "$(dirname "$0" )" &&pwd)
PROJECT_NAME=omnigram
VERSION=$(shell git describe --tags | sed 's/\(.*\)-.*/\1/')
BUILD_DATE=$(shell date -u '+%Y-%m-%d_%I:%M:%S%p')
BUILD_HASH=$(shell git rev-parse HEAD)

.PHONY: all


all : omnigram

l10n:
	@echo "l10n build"
	@flutter gen-l10n




build_runner:
	@echo "build_runner build"
	@flutter clean
	@dart run --enable-experiment=macros  build_runner build

launcher_icons: build_runner
	@dart run flutter_launcher_icons:main


release: l10n
	@echo "release build"
	@flutter build appbundle 


apk: l10n
	@flutter build apk --split-per-abi