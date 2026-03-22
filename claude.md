# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.


## Project Overview

Omnigram is an **AI-native, self-hosted book library and reading service**. Deploy on NAS/homeserver via Docker. Go backend + Flutter client.

**Positioning:** Jellyfin for videos, Immich for photos, **Omnigram for books**.

**Core philosophy:** "AI is air, not a button" — AI is ambient, woven into every surface (bookshelf, reader, insights). There is no AI tab or chat-first interface. The reading experience is transformed without the user ever "opening AI."

## Key Design Documents

| Document | Purpose |
|----------|---------|
| `docs/superpowers/PROGRESS.md` | **📊 实施进度索引** — 开工前必读，完工后必更新 |
| `docs/superpowers/specs/2026-03-22-ambient-ai-reading-design.md` | **Active design spec** — the definitive reference for all UI/UX decisions |
| `docs/discussions/011-ambient-ai-reading-brainstorm.md` | Brainstorm record with decision rationale |
| `docs/superpowers/specs/2026-03-22-ambient-ai-reading-review.md` | External review of the design spec |
| `docs/superpowers/plans/2026-03-22-sprint1-foundation-and-core-reading.md` | Sprint 1 implementation plan |
| `docs/superpowers/plans/2026-03-22-sprint2-ai-pipeline.md` | Sprint 2 implementation plan |
| `docs/discussions/005-ai-era-ebook-demand.md` | Strategic analysis: AI era ebook demand |

## Progress Tracking (IMPORTANT)

**Before starting any feature work**, read `docs/superpowers/PROGRESS.md` to check:
1. Whether the feature is already implemented (avoid duplicate work)
2. What layer/sprint it belongs to
3. Whether its dependencies are complete

**After completing any feature**, update `docs/superpowers/PROGRESS.md`:
1. Change status from ❌ to ✅
2. Fill in the key file path and commit hash
3. Update the "更新记录" section at the bottom
4. If Layer status changed (e.g., all items complete), update the 总览 table

## Repository Structure

```
omnigram/
├── server/          # Go backend (Gin + GORM)
├── app/             # Flutter client
│   ├── lib/         # Dart source code
│   │   ├── theme/       # NEW: Omnigram design system (colors, typography, theme)
│   │   ├── page/        # Screen pages
│   │   │   ├── home/        # Tab pages (desk, library, insights, settings)
│   │   │   ├── reader/      # Immersive reader
│   │   │   └── omnigram_home.dart  # 4-tab navigation shell
│   │   ├── widgets/     # Reusable UI components
│   │   │   ├── desk/        # Reading desk widgets
│   │   │   ├── library/     # Bookshelf widgets
│   │   │   ├── insights/    # Insights widgets
│   │   │   ├── reader/      # Reader chrome widgets
│   │   │   └── common/      # Base design components
│   │   ├── models/      # Data models (with freezed)
│   │   ├── providers/   # Riverpod state management
│   │   ├── dao/         # sqflite database access
│   │   ├── service/     # Business logic
│   │   ├── config/      # Shared preferences, settings
│   │   └── l10n/        # Localization (16 languages)
│   ├── android/     # Android platform (com.lxpio.omnigram)
│   ├── ios/         # iOS platform
│   ├── macos/       # macOS platform
│   └── windows/     # Windows platform
├── assets/img/      # Project logos, icons, favicons
├── docs/            # Documentation
│   ├── discussions/     # Strategic analysis documents
│   └── superpowers/     # Design specs and implementation plans
├── fishtts/         # Fish Audio TTS Docker service (legacy)
└── Makefile         # Root-level build orchestration
```

## App Navigation Architecture

**Four tabs** (Reading Desk is default):

```
📖 阅读 (Reading Desk)  |  📚 书架 (Library)  |  💡 洞察 (Insights)  |  ⚙ 设置 (Settings)
```

- **Reading Desk** — "The Desk": current book hero card, also-reading shelf, daily summary
- **Library** — "The Library": books grouped by topic, semantic search, import
- **Insights** — "The Second Brain": reading narrative, knowledge network, cross-book connections
- **Settings** — Reading identity, companion config (TARS panel), reading experience, sync, advanced

**Full-screen reader** is NOT a sub-page of any tab — it's an independent immersive experience.

**AI Chat** is demoted to Settings > Advanced > AI Chat (Debug). Not a primary interface.

## Tech Stack

| Layer       | Technology                    |
|-------------|-------------------------------|
| Backend     | Go 1.23, Gin, GORM, BadgerDB |
| Frontend    | Flutter 3.41, Dart 3.11       |
| State Mgmt  | Riverpod v2 (with code gen)  |
| Local DB    | sqflite                       |
| Server DB   | SQLite / PostgreSQL           |
| TTS         | Kokoro / Edge TTS (sidecar) + sherpa-onnx (on-device) |
| AI          | langchain_dart (OpenAI, Claude, Gemini, Ollama, DeepSeek) |
| Deployment  | Docker / Docker Compose       |
| CI/CD       | GitHub Actions                |

## Build Commands

### Server (Go)

```bash
cd server
make          # Build server binary
make swagger  # Regenerate API docs from annotations
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
- **Business logic:** `server/service/` (reader, user, sys, m4t, ai, opds, webdav)
- **Persistence:** `server/store/` (BadgerDB key-value store)
- **Config:** YAML-based (`server/conf/`)
- **Middleware:** `server/middleware/`
- **API docs:** `server/docs/` (auto-generated by swaggo, DO NOT edit manually)
- **gRPC:** Used for TTS service integration

### App (`app/lib/`)

- **Reading engine** builds on [Anx Reader](https://github.com/Anxcye/anx-reader) (MIT license) — EPUB rendering, data models, providers, DAO layer are reused
- **UI layer** is being rewritten with Omnigram's own design language (see design spec)
- **Package name:** `omnigram` (not `anx_reader`)
- **State:** `providers/` — Riverpod providers (code-generated with `@riverpod`)
- **UI:** `page/` — screens and pages
- **Models:** `models/` — data models (with freezed)
- **Services:** `service/` — business logic
- **Widgets:** `widgets/` — reusable UI components
- **DAO:** `dao/` — sqflite database access
- **Config:** `config/` — shared preferences, settings
- **Localization:** Flutter gen-l10n (ARB files in `l10n/`)
- **EPUB engine:** InAppWebView + foliate-js (`assets/foliate-js/`)
- **Design system:** `theme/` — colors, typography, theme tokens

### Server API

API documentation is auto-generated from code annotations using [swaggo/swag](https://github.com/swaggo/swag).
- **Swagger UI:** Available at `/swagger/index.html` when server is running
- **Generated files:** `server/docs/` (docs.go, swagger.json, swagger.yaml)
- **Regenerate:** Run `make swagger` in `server/` after modifying API annotations
- **Legacy spec:** `docs/omnigram.openapi.spec.yaml` (archived, no longer maintained)

API covers 9 tag categories: Auth, User, Admin, Reader, Sync, System, TTS, AI, OPDS

## Coding Conventions

- **Language:** Code in English; comments and docs may use Chinese
- **Build orchestration:** Makefiles at project root and `server/`
- **Code generation:** Riverpod providers, freezed models, json_serializable, l10n
- **Versioning:** Git tags (`v*.*.*`) trigger CI release pipelines
- **License:** MIT
- **Flutter API notes:**
  - Use `.withValues(alpha: 0.5)` not `.withOpacity()` (deprecated in Flutter 3.10+)
  - Package imports: `package:omnigram/...`
  - L10n import: `package:omnigram/l10n/generated/L10n.dart`

### App Design Principles

When building or modifying app UI, follow these principles from the design spec:

1. **AI features have no dedicated entry point** — they are embedded in existing surfaces
2. **Every AI feature must have a non-AI fallback** — app works fully without AI configured (see spec §10.3)
3. **UI style:** soft rounded cards, pastel backgrounds (pink/green/lavender), warm typography, generous padding (see spec §9)
4. **Empty states** adapt to companion personality (warm vs. concise variants)
5. **Reader AI has 4 layers:** context bar (auto), inline glossary (auto), margin notes (auto, max 3/chapter), companion panel (manual)

### Server API Documentation (Required)

All new or modified HTTP handler functions in `server/service/` **MUST** include swaggo annotations. This ensures API documentation stays in sync with the code.

**Annotation template:**
```go
// @Summary Short description of the endpoint
// @Description Longer description of what it does
// @Tags TagName
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param param_name path/query/body type required "Description"
// @Success 200 {object} ResponseType
// @Failure 400 {object} schema.ErrorResponse
// @Router /path/to/endpoint [method]
func handlerName(c *gin.Context) {
```

**Rules:**
1. Every handler function must have `@Summary`, `@Tags`, `@Router`, and at least one `@Success`
2. Use `@Security BearerAuth` for endpoints requiring OAuth middleware
3. Use appropriate tags: `Auth`, `User`, `Admin`, `Reader`, `Sync`, `System`, `TTS`, `AI`, `OPDS`
4. After adding/modifying annotations, run `cd server && make swagger` to regenerate docs
5. Commit the regenerated `server/docs/` files together with handler changes

## CI/CD Pipelines

| Workflow          | Trigger                    | Purpose                              |
|-------------------|----------------------------|--------------------------------------|
| `docker.yaml`     | Push tag `v*.*.*` / release | Build server Docker images (arm64/amd64) |
| `build_app.yaml`  | Push/PR on main            | Build & sign Flutter APK             |

## Implementation Status

> **Full progress tracking: `docs/superpowers/PROGRESS.md`**

### Completed
- **Sprint 1:** Foundation + Core Reading (Layer 0 + 1) — new 4-tab UI, design system, all pages
- **Sprint 2:** AI Pipeline (Layer 2) — TARS personality, ambient pipeline, context bar, memory bridge, post-import AI, degradation

### In Progress
- **Sprint 3:** Ambient AI (Layer 3) — inline glossary, bookshelf AI, insights AI narrative

### Planned
- **Sprint 4:** Deep AI (Layer 4) — companion panel, margin notes, semantic search, TTS, knowledge network
- **Sprint 5:** Advanced (Layer 5) — cross-book connections, stealth reading mode
