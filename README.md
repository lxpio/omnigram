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

Omnigram is an **AI-native, self-hosted book library and reading service**. Deploy it on your NAS or homeserver, and your ebook collection becomes an intelligent, personal reading experience — not just a pile of files.

### Origin

I'm a tech enthusiast with a NAS full of PDFs and EPUBs. Over time, files became messy, searching became painful, and the books I'd read faded from memory. No existing tool solves both "library management" and "AI-enhanced reading" — so Omnigram was born.

### The Gap

```
                    Server (NAS/Self-hosted)       No Server (Client only)
                 ┌──────────────────────┬──────────────────────┐
   AI-capable    │                      │  Anx Reader          │
                 │    ❌ EMPTY!         │  Readwise (SaaS)     │
                 │                      │                      │
                 ├──────────────────────┼──────────────────────┤
   No AI         │  Calibre-Web         │  KOReader            │
                 │  Kavita              │  Foliate             │
                 │  Audiobookshelf      │                      │
                 └──────────────────────┴──────────────────────┘
```

**"Self-hosted + AI + Reading" = zero competition. That's where Omnigram lives.**

---

## Design Philosophy

### AI is Air, Not a Button

This is the fundamental difference between Omnigram and every competitor.

Most "AI readers" slap a ChatGPT dialog next to the book viewer. That's not AI reading — that's reading + chatting.

Omnigram's AI is **invisible**:
- Turn to a new chapter, a context bar fades in with a recap — you didn't press anything
- Select a word, a tooltip appears with a definition — you didn't "open AI"
- Your bookshelf groups by topic automatically, imported books get tags and summaries
- Your notes aren't scattered highlights — they're a knowledge network organized by concept

**You're not "using AI." You're reading — and the experience itself has changed.**

### Companion, Not Tool

Reading has always been a solitary activity. AI can change that.

Omnigram's AI is a reading companion with configurable personality — like TARS from *Interstellar*, you can adjust its proactivity, style, depth, and warmth. It can be a silent assistant, a Socratic mentor, or a friend reading alongside you.

### Insight, Not Statistics

Traditional reading apps give you bar charts and heatmaps — "you read 300 pages this month." So what?

Omnigram's Insights page tells the story of your reading journey: what domains you've been exploring, which books connect to each other, where your reading is heading. Not data — **self-awareness**.

### Privacy as Freedom

Some books you'd rather keep private. Omnigram has a fully isolated "hidden library" — zero trace in the main interface, biometric entry, complete AI experience inside. Privacy protects against others' eyes, not your own reading experience.

---

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
- Full AI experience inside private space
- Encrypted local storage with platform keystore

### Data Portability
- Export notes/highlights as Markdown, JSON, or CSV
- Export knowledge network for Obsidian/Logseq
- Import highlights from Kindle, Apple Books, Readwise
- Full library export as portable archive
- OPDS catalog for interoperability

---

## An Analogy

If Calibre-Web is a library bookshelf — you come find a book, you read it yourself — then Omnigram gives you a personal librarian.

They remember what you've read, what you like, where you left off. Occasionally they'll say, "You might like this one — it connects to that book you read last month." They don't talk much, but when you need them, they know everything.

---

## Architecture

![base_struct](assets/img/struct.svg)

## Official Documentation

You can find the official documentation (including installation manuals) at <https://omnigram.lxpio.com/>.

## Examples

For the mobile app, you can use https://omnigram-demo.lxpio.com:9443 for the Server Endpoint URL

```
Credentials:
email: admin
password: 123456
```

## For Dev

### Build

#### Omnigram App (Flutter)

```bash
git clone https://github.com/lxpio/omnigram.git
cd omnigram/app
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter build apk  # or: flutter build ios / macos / windows
```

#### Omnigram Server (Go)

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
| **AI** | langchain_dart (OpenAI, Claude, Gemini, Ollama, DeepSeek) |
| **TTS** | Kokoro / Edge TTS (server sidecar) + sherpa-onnx (on-device) |
| **Database** | SQLite / PostgreSQL / MySQL |
| **Deployment** | Docker / Docker Compose |

## Acknowledgments

Omnigram's reading engine builds on [Anx Reader](https://github.com/Anxcye/anx-reader) (MIT License). We are deeply grateful for their excellent work.

Key libraries and dependencies:

- [Anx Reader](https://github.com/Anxcye/anx-reader) — Reading engine foundation
- [foliate-js](https://github.com/nickthecook/foliate-js) — Ebook rendering engine
- [Riverpod](https://riverpod.dev/) — State management
- [langchain_dart](https://github.com/davidmigloz/langchain_dart) — AI integration
- [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI) — TTS engine (Sidecar)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
