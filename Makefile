# Makefile - Omnigram

.PHONY: app-deps app-codegen app-analyze app-build-apk server-build server-docker

# === App (Flutter) ===

app-deps:
	cd app && flutter pub get

app-codegen:
	cd app && flutter gen-l10n
	cd app && dart run build_runner build --delete-conflicting-outputs

app-analyze:
	cd app && flutter analyze lib/

app-build-apk:
	cd app && flutter build apk --split-per-abi

# === Server (Go) ===

server-build:
	cd server && make

server-docker:
	cd server && make docker