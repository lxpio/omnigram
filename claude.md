# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.


## Project Overview

Omnigram is an **AI-native, self-hosted book library management and reading service**. Deploy on NAS/homeserver via Docker. Go backend + Flutter client (forked from Anx Reader).

**Positioning:** Jellyfin for videos, Immich for photos, **Omnigram for books**.

## Repository Structure

```
omnigram/
├── server/          # Go backend (Gin + GORM)
├── app/             # Flutter client (forked from Anx Reader, MIT)
│   ├── lib/         # Dart source code
│   ├── android/     # Android platform (com.lxpio.omnigram)
│   ├── ios/         # iOS platform
│   ├── macos/       # macOS platform
│   └── windows/     # Windows platform
├── assets/img/      # Project logos, icons, favicons
├── docs/            # Documentation
│   ├── discussions/ # Strategic analysis documents (10 docs)
│   └── omnigram.openapi.spec.yaml  # Server API spec (reference)
├── fishtts/         # Fish Audio TTS Docker service
└── Makefile         # Root-level build orchestration
```

## Tech Stack

| Layer       | Technology                    |
|-------------|-------------------------------|
| Backend     | Go 1.23, Gin, GORM, BadgerDB |
| Frontend    | Flutter 3.41, Dart 3.11       |
| State Mgmt  | Riverpod v2 (with code gen)  |
| Local DB    | sqflite                       |
| Server DB   | SQLite / PostgreSQL           |
| TTS         | Fish Audio (Docker/gRPC)      |
| AI          | langchain_dart (multi-model)  |
| Deployment  | Docker / Docker Compose       |
| CI/CD       | GitHub Actions                |

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
flutter pub get                          # Install dependencies
flutter gen-l10n                         # Generate localizations
dart run build_runner build --delete-conflicting-outputs  # Codegen
flutter analyze lib/                     # Static analysis
flutter build apk --split-per-abi       # Build Android APK
```

Or from project root:

```bash
make app-deps       # flutter pub get
make app-codegen    # l10n + build_runner
make app-analyze    # flutter analyze
make app-build-apk  # Build APK
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
- **gRPC:** Used for TTS service integration

### App (`app/lib/`)

- **Forked from:** [Anx Reader](https://github.com/Anxcye/anx-reader) (MIT license)
- **State:** `providers/` — Riverpod providers
- **UI:** `page/` — screens and pages
- **Models:** `models/` — data models (with freezed)
- **Services:** `service/` — business logic
- **Widgets:** `widgets/` — reusable UI components
- **DAO:** `dao/` — sqflite database access
- **Config:** `config/` — shared preferences, settings
- **Localization:** Flutter gen-l10n (ARB files in `l10n/`)

### Server API

The OpenAPI spec (`docs/omnigram.openapi.spec.yaml`) defines 6 endpoint categories:
- Auth, User Management, Reader, System, Sync, TTS

## Coding Conventions

- **Language:** Code in English; comments and docs may use Chinese
- **Build orchestration:** Makefiles at project root and `server/`
- **Code generation:** Riverpod providers, freezed models, json_serializable, l10n
- **Versioning:** Git tags (`v*.*.*`) trigger CI release pipelines
- **License:** App is MIT (Anx Reader fork); Server is MIT

## CI/CD Pipelines

| Workflow          | Trigger                    | Purpose                              |
|-------------------|----------------------------|--------------------------------------|
| `docker.yaml`     | Push tag `v*.*.*` / release | Build server Docker images (arm64/amd64) |
| `build_app.yaml`  | Push/PR on main            | Build & sign Flutter APK             |

## Known Issues (from code audit)

See `docs/discussions/008-code-quality-audit.md` for the full audit report.
Top priorities: server security fixes (P0), app-server integration (Phase 2).
