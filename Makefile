# Makefile - Omnigram

.PHONY: app-deps app-codegen app-analyze app-test app-golden-update app-build-apk \
        server-build server-test server-swagger server-docker docker docker-cn \
        test lint

# === App (Flutter) ===

app-deps:
	cd app && flutter pub get

app-codegen:
	cd app && flutter gen-l10n
	cd app && dart run build_runner build --delete-conflicting-outputs

app-analyze:
	cd app && flutter analyze --no-fatal-infos --no-fatal-warnings lib/

app-test:
	cd app && flutter test

app-golden-update:
	cd app && flutter test --update-goldens

app-build-apk:
	cd app && flutter build apk --split-per-abi

# === Server (Go) ===

server-build:
	cd server && make

server-test:
	cd server && go test ./...

server-swagger:
	cd server && make swagger

server-docker:
	cd server && make docker

# === Docker ===

docker:
	cd server && make docker

docker-cn:
	cd server && make docker_cn

# === Combined ===

test: server-test app-test
	@echo "All tests passed."

lint: app-analyze
	cd server && go vet ./...
	@echo "All lint checks passed."
