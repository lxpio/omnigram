#

<picture>
  <source
    srcset="./assets/img/logo_with_letter_dark.svg"
    media="(prefers-color-scheme: dark)"
  />
  <source
    srcset="./assets/img/logo_with_letter_white.svg"
    media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)"
  />
  <img src="./assets/img/logo_with_letter_white.svg" />
</picture>

<div style="font-size: 1.5rem;">
  <a href="./README.md">English</a> | <a href="./README.zh.md">中文</a>
</div>
</br>

![docker action](https://github.com/lxpio/omnigram/actions/workflows/docker.yaml/badge.svg)
![build app](https://github.com/lxpio/omnigram/actions/workflows/build_app.yaml/badge.svg)

## About Omnigram

> **Jellyfin for videos. Immich for photos. Omnigram for books.**

Omnigram is an **AI-native, self-hosted book library and reading service**. Deploy it on your NAS or homeserver with Docker, and your ebook collection becomes an intelligent, personal reading experience — not just a file manager.

**The core idea: AI is air, not a button.** There is no "AI tab" in Omnigram. Instead, AI is woven into every surface — your bookshelf organizes itself, your reader remembers where you left off and what you were thinking, and your notes connect across books into a knowledge network. You never "use AI." You just read, and the experience is transformed.

### Why Omnigram?

| Tool | What it does | What it doesn't |
|------|-------------|----------------|
| **Calibre-Web** | Manages books | No AI, no TTS, aging UI |
| **Audiobookshelf** | Plays audiobooks | Can't generate them from ebooks |
| **Anx Reader** | Great reader app | No server, single-device only |
| **Readwise Reader** | AI-powered reading | $8.99/mo, not self-hostable |

**Omnigram fills the gap: self-hosted + ambient AI + reading — all in one.**

## Design Philosophy

Omnigram is built on five principles:

1. **Ambient over explicit** — AI works silently in the background. No chat tabs, no AI buttons
2. **Companion over tool** — AI is a reading partner with configurable personality, not a Q&A bot
3. **Insight over statistics** — AI tells you what you learned, not how many pages you read
4. **Privacy as freedom** — A hidden private library lets you read anything without concern
5. **New experience, proven foundation** — Fresh design language on top of battle-tested reading engine

## Features

### Reading Experience
- Multi-format ebook reading (EPUB, MOBI, AZW3, FB2, TXT)
- iOS, Android, macOS, Windows native client
- Four-tab navigation: **Reading Desk** | **Library** | **Insights** | **Settings**
- Reading Desk — open the app, see what you're reading, continue in one tap
- Full-screen immersive reader with customizable typography
- Reading notes, highlights, and bookmarks
- TTS text-to-speech with customizable voices

### AI-Powered (Ambient)
- AI reading companion with configurable personality (TARS model — adjust proactivity, style, depth, warmth)
- Context bar — chapter recaps fade in automatically when you turn pages
- Inline glossary — select a word, see AI-generated definitions without leaving the page
- Margin notes — AI surfaces cross-book connections in the page margin
- Smart bookshelf — auto-tagging, summaries, and reading time estimates on import
- Semantic search — search your library by meaning, not just keywords
- Knowledge network — notes organized by concept across all your books
- Reading narrative — AI tells the story of your reading journey, not just charts

### Server
- Self-hosted book library with directory scanning
- Multi-format metadata extraction
- Multi-user management with session auth
- Book search, favorites, reading progress sync across devices
- Docker one-click deployment (SQLite / PostgreSQL / MySQL)
- Server-side TTS via sidecar (Kokoro / Edge TTS, OpenAI-compatible API)
- OPDS catalog protocol

### Privacy
- Hidden private library — completely isolated second space with biometric access
- Zero trace in main interface — private books never appear in bookshelf, search, or insights
- Full AI experience inside private space — privacy protects against others' eyes, not your reading experience
- Encrypted local storage with platform keystore

### Data Portability
- Export notes/highlights as Markdown, JSON, or CSV
- Export knowledge network for Obsidian/Logseq
- Import highlights from Kindle, Apple Books, Readwise
- Full library export as portable archive
- OPDS catalog for interoperability

## Omnigram Infrastructure

![base_struct](assets/img/struct.svg)

## Official Documentation

You can find the official documentation (including installation manuals) at <https://omnigram.lxpio.com/>.

## Examples

For the mobile app, you can use https://omnigram-demo.lxpio.com:9443 for the Server Endpoint URL

```
The credential
email: admin
password: 123456
```

## For Dev

### Build

#### For Omnigram App (Flutter)

```bash
git clone https://github.com/lxpio/omnigram.git
cd omnigram/app
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter build apk  # or: flutter build ios / macos / windows
```

#### For Omnigram Server (Go)

```bash
git clone https://github.com/lxpio/omnigram.git
cd omnigram/server
make

# Docker build
make docker
```

### TTS Service

Omnigram Server supports TTS via a sidecar Docker container with OpenAI-compatible API. The default choice is [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI):

```yaml
# docker-compose.yml — add TTS sidecar
services:
  tts:
    image: ghcr.io/remsky/kokoro-fastapi:latest
    # OpenAI-compatible API: POST /v1/audio/speech
    # CPU mode by default, add GPU resources for acceleration
```

Configure `TTS_PROVIDER=kokoro` and `TTS_SIDECAR_URL=http://tts:8880` in your Omnigram Server environment.

Edge TTS is also available as a zero-deployment fallback (no additional container needed).

## Tech Stack

| Component | Technology |
|-----------|-----------|
| **Server** | Go 1.23 + Gin + GORM + BadgerDB |
| **Client** | Flutter 3.41 + Riverpod v2 |
| **AI** | langchain_dart (multi-model: OpenAI, Claude, Gemini, Ollama, DeepSeek) |
| **TTS** | Kokoro / Edge TTS (OpenAI-compatible Sidecar) / sherpa-onnx (on-device) |
| **Database** | SQLite / PostgreSQL / MySQL |
| **Deployment** | Docker / Docker Compose |

## Acknowledgments

Omnigram's client reading engine builds on [Anx Reader](https://github.com/Anxcye/anx-reader) (MIT License). We are deeply grateful for their excellent work.

Key libraries and dependencies:

- [Anx Reader](https://github.com/Anxcye/anx-reader) — Reading engine foundation
- [foliate-js](https://github.com/nickthecook/foliate-js) — Ebook rendering engine
- [Riverpod](https://riverpod.dev/) — State management
- [langchain_dart](https://github.com/davidmigloz/langchain_dart) — AI integration
- [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI) — TTS engine (Sidecar)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
