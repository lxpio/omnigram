# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.

## Project Overview

Omnigram is a multi-platform file reading and audiobook client with a Go backend and Flutter frontend. It supports EPUB/PDF reading, TTS audiobook functionality via AI models, and local book management (NAS).

## Repository Structure

```
omnigram/
├── server/          # Go backend (Gin + GORM)
├── app/             # Flutter cross-platform client
│   ├── lib/         # Dart source code
│   └── openapi/     # Generated API client (dart-dio)
├── docs/            # Docusaurus 3.x documentation site
├── fishtts/         # Fish Audio TTS Docker service
├── patch/           # Post-generation patches for OpenAPI client
├── omnigram.openapi.spec.yaml  # API contract (OpenAPI 3.0.1)
└── Makefile         # Root-level build orchestration
```

## Tech Stack

| Layer       | Technology                  |
|-------------|-----------------------------|
| Backend     | Go 1.23, Gin, GORM, BadgerDB |
| Frontend    | Flutter 3.24.3, Dart 3.5.3+ |
| State Mgmt  | Riverpod (with code generation) |
| Local DB    | Isar 4.0, Hive              |
| Server DB   | SQLite / MySQL / PostgreSQL  |
| API Spec    | OpenAPI 3.0.1 (dart-dio generator) |
| Docs        | Docusaurus 3.x (pnpm)       |
| TTS         | Fish Audio (Docker)          |
| CI/CD       | GitHub Actions               |

## Build Commands

### Server (Go)

```bash
cd server
make          # Build server binary
make docker   # Build Docker image
```

### App (Flutter)

```bash
cd app
make                    # Full build
flutter build apk --split-per-abi   # Build Android APK
```

### OpenAPI Client Regeneration

```bash
# From project root
make openapi    # Regenerate dart-dio client + apply patch
```

This runs: `openapi-generator-cli generate` → `build_runner build` → `patch -p1 < patch/api.patch`

### Code Generation (Flutter)

```bash
cd app
dart run build_runner build   # Riverpod, Isar, json_serializable
```

### Docs

```bash
cd docs
pnpm install
pnpm start      # Dev server
pnpm build      # Production build
```

## Architecture Notes

### Server (`server/`)

- **Entry point:** `server/cmd/omni-server/`
- **Core init:** `server/app.go`
- **Data models:** `server/schema/` (book, user, read_process, tag, favorite_book, api_key)
- **Business logic:** `server/service/` (reader, user, sys, m4t)
- **Persistence:** `server/store/` (BadgerDB key-value store)
- **Config:** YAML-based (`server/conf/`)
- **Middleware:** `server/middleware/`
- **gRPC:** Used for M4T TTS service integration

### App (`app/lib/`)

- **State:** `providers/` — Riverpod providers (API, auth, books, TTS, settings, etc.)
- **UI:** `screens/` — login, home, reader, discover, profile, notes
- **Models:** `models/` — generated data models
- **Entities:** `entities/` — Isar local DB entities (book, user, notes, settings)
- **Services:** `services/` — business logic layer
- **Routing:** `routes/` — GoRouter navigation
- **Widgets:** `components/` — reusable UI components
- **Localization:** `easy_localization` for i18n

### API Contract

The OpenAPI spec (`omnigram.openapi.spec.yaml`) defines 6 endpoint categories:
- 登录认证 (Auth)
- 用户管理 (User Management)
- 阅读管理 (Reader Management)
- 系统管理 (System)
- 同步接口 (Sync)
- 语音服务 (TTS)

## Coding Conventions

- **Language:** Code in English; comments and docs may use Chinese
- **Build orchestration:** Makefiles at project root, `server/`, `app/`, `docs/`
- **Code generation:** Heavy use — OpenAPI client, Riverpod providers, Isar schemas, json_serializable
- **Versioning:** Git tags (`v*.*.*`) trigger CI release pipelines
- **Config format:** YAML (server config, API spec, Flutter pubspec)

## CI/CD Pipelines

| Workflow          | Trigger                    | Purpose                              |
|-------------------|----------------------------|--------------------------------------|
| `docker.yaml`     | Push tag `v*.*.*` / release | Build server Docker images (arm64/amd64) |
| `build_app.yaml`  | Push/PR on main            | Build & sign Flutter APK             |
| `docs.yaml`       | Push to main               | Deploy Docusaurus to GitHub Pages    |
