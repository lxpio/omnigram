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


objectbox:
	@echo "objectbox build"
	@flutter clean
	@dart run build_runner build
omnigram: objectbox
	# @flutter pub get
	@dart run flutter_native_splash:create
	@dart run flutter_launcher_icons:main


release: l10n
	@echo "release build"
	@flutter build appbundle 


apk: l10n
	@flutter build apk --split-per-abi