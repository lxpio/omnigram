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

Omnigram is an **AI-native, self-hosted book library management and reading service**. Deploy it on your NAS or homeserver with Docker, and turn your ebook collection into an intelligent, searchable, listenable personal library.

Built with a Go backend and Flutter multi-platform client, Omnigram combines book management, AI-powered reading assistance, and TTS audiobook generation into a single, self-hosted solution — something no existing tool provides.

### Why Omnigram?

- 📚 **Calibre-Web** manages books but has no AI, no TTS, and an aging UI
- 🎧 **Audiobookshelf** plays existing audiobooks but can't generate them from ebooks
- 📖 **Anx Reader** is a great reader app but has no server — single-device only
- 💸 **Readwise Reader** is powerful but costs $8.99/mo and isn't self-hostable

**Omnigram fills the gap: self-hosted + AI + reading — all in one.**

## Features

### Available Now (App — Anx Reader Fork)
- [x] Multi-format ebook reading (EPUB, MOBI, AZW3, FB2, TXT, PDF)
- [x] iOS, Android, macOS, Windows native client
- [x] AI conversational assistant (local LLM integration)
- [x] TTS text-to-speech with customizable voices
- [x] Reading notes, highlights, and bookmarks
- [x] AI-powered mind map generation
- [x] Full-book translation with bilingual side-by-side reading
- [x] Reading statistics heatmap
- [x] WebDAV sync (client-side)

### Available Now (Server)
- [x] Self-hosted book library with directory scanning
- [x] Multi-format metadata extraction (EPUB)
- [x] Multi-user management with session auth
- [x] Book search, favorites, reading progress sync
- [x] Docker one-click deployment (SQLite/PostgreSQL/MySQL)
- [x] Server-side TTS via Sidecar (Kokoro / Edge TTS, OpenAI-compatible API)

### Roadmap
- [ ] 🔒 Server security hardening (in progress)
- [ ] 📚 Book metadata editing & management API
- [ ] 🌐 **Web UI** — Beautiful book library browser with dark mode
- [ ] 📂 WebDAV server (sync with Anx Reader / KOReader)
- [ ] 📖 OPDS catalog protocol
- [ ] 🏷️ Tags, shelves, and library organization
- [ ] 📝 Notes & highlights cross-device sync
- [ ] 🤖 AI metadata auto-completion on import (LLM/Ollama)
- [ ] 🔍 Full-text semantic search across entire library
- [ ] 📊 AI book summarization & chapter insights
- [ ] 🧠 AI-powered cross-book knowledge linking
- [ ] 🎧 High-quality multi-voice TTS audiobook generation (server-side)
- [ ] 📖 Web reader (foliate-js, in-browser reading)
- [ ] 📥 Calibre database import tool
- [ ] 🐧 Linux desktop client

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
flutter pub run build_runner build
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
| **Client** | Flutter 3.41 + Riverpod (Anx Reader fork) |
| **TTS** | Kokoro / Edge TTS (OpenAI-compatible Sidecar) / langchain_dart (client) |
| **Database** | SQLite / PostgreSQL / MySQL |
| **Deployment** | Docker / Docker Compose |

## Acknowledgments

Omnigram's client app is based on [Anx Reader](https://github.com/Anxcye/anx-reader) (MIT License). We are deeply grateful for their excellent work on the reading experience.

Key libraries and dependencies:

- [Anx Reader](https://github.com/Anxcye/anx-reader) — Client app foundation
- [foliate-js](https://github.com/nickthecook/foliate-js) — Ebook rendering engine
- [riverpod](https://riverpod.dev/) — State management
- [langchain_dart](https://github.com/davidmigloz/langchain_dart) — AI integration
- [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI) — TTS engine (Sidecar)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details