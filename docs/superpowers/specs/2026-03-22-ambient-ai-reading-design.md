# Omnigram Ambient AI Reading Experience Design

> Date: 2026-03-22
> Status: Draft
> Brainstorm Record: `docs/discussions/011-ambient-ai-reading-brainstorm.md`
> Review Report: `docs/superpowers/specs/2026-03-22-ambient-ai-reading-review.md`
> Related: `docs/discussions/005-ai-era-ebook-demand.md`

---

## 1. Design Philosophy

**AI is air, not a button.**

Omnigram's AI does not live in a chat tab. It is woven into every surface of the reading experience — the bookshelf, the reader, the insights page. Users never "open AI." They read books, and the experience is transformed.

**Core principles:**

1. **Ambient over explicit** — AI works silently in the background. No AI tab, no chat-first interfaces
2. **Companion over tool** — AI is a reading partner with configurable personality (TARS model), not a Q&A bot
3. **Insight over statistics** — Numbers serve narrative; AI tells you what you learned, not how many pages you read
4. **Privacy as freedom** — A hidden second library protects against others' eyes, not the user's own reading experience
5. **New experience, proven foundation** — Complete UI rewrite with new design language; reuse battle-tested logic from Anx Reader. No old wine in new bottles

---

## 2. Navigation Architecture

### 2.1 Tab Structure

Four tabs, "Reading" as default:

```
📖 阅读 (Reading)  |  📚 书架 (Bookshelf)  |  💡 洞察 (Insights)  |  ⚙ 设置 (Settings)
```

### 2.2 Full-Screen Reader

The book reader is NOT a sub-page of any tab. Tapping a book from the Reading tab or Bookshelf enters a full-screen immersive reader. Back returns to the originating tab.

### 2.3 AI Chat Interface

Demoted to Settings > Advanced > AI Chat (Debug). Serves as debug/backup only, not a primary interaction surface.

---

## 3. Reading Tab — "The Desk"

### 3.1 Concept

The user opens Omnigram and sits down at their reading desk. Their current books are laid out, ready to continue. AI provides memory bridging so the user never loses context.

### 3.2 Layout

| Element | Description |
|---------|-------------|
| Greeting | Personalized, tone set by companion personality settings |
| Hero card | Currently reading book — large cover, chapter progress, estimated time remaining |
| AI memory bridge | One-line context on the hero card: "Last time you read about X, this chapter covers Y" |
| Secondary shelf | "Also reading" — horizontal scroll of other in-progress books |
| Daily summary | Single line: "Today: 42 minutes of reading" — not a chart |
| Empty state | No kaomoji. AI recommends a starting book or guides to bookshelf |

### 3.3 AI Integration Points

- **Memory bridge** (automatic): AI generates a brief recap of where the user left off
- **Greeting tone** (automatic): Adapts to companion personality — warm vs. concise
- **Reading suggestion** (automatic): When no book is in progress, AI recommends based on library

---

## 4. Bookshelf Tab — "The Library"

### 4.1 Concept

Not a file manager. A personal library organized by meaning, not by filename.

### 4.2 Layout

| Element | Description |
|---------|-------------|
| AI recommendation card | Top card — companion-voiced suggestion: "You finished X, this book will make you rethink Y" |
| Recently added | New books with AI-generated tags |
| Topic sections | Books grouped by AI-detected themes, not manual folders |
| Search | Semantic search — "the book about procrastination" works |

### 4.3 AI Integration Points

- **Auto-tagging** (background): On import, AI generates tags, summary, difficulty level, estimated read time
- **Smart grouping** (background): Books organized by detected themes/topics
- **Semantic search** (on demand): Natural language queries across entire library
- **Recommendations** (automatic): Contextual suggestions based on reading history and library content

### 4.4 Book Import Flow

User adds a book → two-phase processing:

**Phase 1 — Immediate (no AI required):**
1. Parse metadata (title, author, language, page count)
2. Detect language
3. Estimate reading time (word count based)
4. Book is usable immediately

**Phase 2 — Background AI (async, queued):**
1. Generate 3-length summary (one-line ~20 words, paragraph ~100 words, full ~500 words)
2. Auto-tag by topic, difficulty, genre
3. Suggest translations if applicable
4. Results appear progressively as they complete

Batch import of 50 books: Phase 1 completes instantly for all; Phase 2 queued with priority (books the user opens jump the queue). See §10.6 for AI pipeline architecture.

---

## 5. Reader — Immersive Reading + AI Companion

### 5.1 Four-Layer AI Integration

| Layer | Name | Trigger | Presentation | Default |
|-------|------|---------|--------------|---------|
| 1 | Context Bar | Auto on chapter change | Thin bar at top, fades in/out — "Previously: X. This chapter: Y" | ON |
| 2 | Inline Glossary | Select text / auto-detect difficult terms | Floating tooltip, stays in reading flow | ON |
| 3 | Margin Notes | AI detects cross-book connections (max 3 per chapter, confidence-filtered) | Gray text in margin — "Related: your highlight in Book X" | ON |
| 4 | Companion Panel | Manual — reader menu icon, or configurable gesture (platform-aware: avoid iPadOS three-finger conflicts) | Bottom slide-up panel, bidirectional conversation | Manual |

**Design rules:**
- Layers 1-3 are unidirectional (AI speaks, user listens) — lightweight, no response needed
- Layer 4 is bidirectional (conversation) — user must actively summon it
- All layers individually toggleable in settings
- All layers adapt to companion personality settings
- All layers respect dark mode
- Margin notes: density capped at 3 per chapter; low-confidence connections filtered out; user can dismiss/mark "not relevant" to improve future filtering

### 5.2 Reader Chrome

```
Top bar (tap to show/hide):  ← Chapter Title    ⋮  🎧  ☾
Bottom bar:                  ████████░░░  68%    p.142
```

- 🎧 TTS playback — integrated into reader, not a separate feature. Companion's voice.
- ☾ Dark mode toggle
- ⋮ Menu: bookmarks, notes, chapter list, reading settings

### 5.3 TTS Integration

TTS is part of the companion experience, not a standalone tool:
- Uses the companion's configured voice
- Companion may offer: "Want me to read this chapter to you?"
- Controls appear as minimal overlay during playback

---

## 6. Insights Tab — "The Second Brain"

### 6.1 Three-Layer Structure

#### Layer 1: Reading Narrative (Surface)

**Not charts. Stories.**

AI generates a narrative summary of the user's reading journey over a time period:

> "This month you went deep into physics — from quantum mechanics basics in *God Does Play Dice* to cosmology in *A Brief History of Time*. Your reading is moving from popular science toward deeper theoretical understanding."

Below: lightweight stats as supporting data (3 books · 42 hours · 128 notes).

Time period is swipeable (horizontal swipe on time label): this month → last month → this year → all time.

#### Layer 2: Knowledge Network (Middle)

**Notes organized by concept, not by book.**

- Interactive knowledge graph: nodes are concepts, edges are connections
- Click a node → see all highlights/notes from all books related to that concept
- AI automatically clusters notes by detected themes
- Users can also browse by-book or by-topic toggle
- Example: "Cognitive Bias" node → 17 highlights from 3 different books

#### Layer 3: Cross-Book Connections (Deep)

**AI surfaces thematic relationships across your reading history.**

- Cross-book contradictions: "You highlighted Einstein's 'God does not play dice' but Hawking in *A Brief History of Time* disagrees"
- Thematic echoes: "Three books in your library discuss cognitive bias from different angles"
- AI presents **relationships**, not cognitive judgments — it does NOT claim "your thinking has changed" (LLMs cannot reliably infer intent behind a highlight)
- "Record my thought" button → user explicitly writes their position on a topic. Over time, the user's own recorded thoughts form a self-authored intellectual journal that AI can reference

### 6.2 Recent Notes Section

- Default view: grouped by AI-detected topic/theme
- Toggle: by topic / by book / by date
- Each topic shows book count and note count

### 6.3 Privacy

Content from the hidden library (stealth mode) NEVER appears in the main Insights tab. Stealth space has its own isolated Insights.

---

## 7. Settings

### 7.1 Structure

| Section | Contents |
|---------|----------|
| My Reading Identity | Reading goals, preferred languages, account |
| My Reading Companion | **Personality config (TARS panel)**, voice, behavior toggles |
| Reading Experience | Font, typography, page turning, themes |
| Sync & Storage | WebDAV, import/export, cache |
| Advanced | AI service config (API keys, providers, models), AI Chat (Debug), developer options |
| About Omnigram | Version, licenses, links |

### 7.2 Reading Companion Configuration (TARS Panel)

**Personality sliders (0-100%):**

| Dimension | Low end | High end |
|-----------|---------|----------|
| Proactivity | Silent assistant | Chatty scholar |
| Style | Direct answers | Socratic questioning |
| Depth | Plain language | Academic analysis |
| Warmth | Cool & objective | Emotionally engaged |

**Preset personalities (default entry point for most users):**

| Preset | Proactivity | Style | Depth | Warmth | Description |
|--------|------------|-------|-------|--------|-------------|
| Silent Helper | 20% | Direct | Medium | Low | Does the work, stays quiet |
| Reading Buddy | 50% | Mixed | Plain | High | Like reading with a friend |
| Academic Mentor | 80% | Socratic | Academic | Medium | Challenges you to think deeper |

Users pick a preset, then optionally fine-tune with sliders in advanced mode.

**Additional settings:**
- Companion name (customizable)
- TTS voice selection (tied to companion identity)
- Live preview: sample text updates in real-time as sliders change
- Behavior toggles:
  - ☑ Auto-generate chapter recap
  - ☑ Annotate difficult terms
  - ☑ Alert on cross-book connections
  - ☐ Ask questions after chapter completion
  - ☑ Auto-organize notes into knowledge graph

### 7.3 Hidden Library Access

Entry point hidden within "My Reading Identity" or "Advanced" — long-press on an inconspicuous element triggers biometric authentication. No visible text or icon hints at its existence.

---

## 8. Stealth Reading Mode — "The Hidden Library"

### 8.1 Concept

A completely isolated second space for private reading. Inspired by Samsung Secure Folder / iOS Hidden Photos.

### 8.2 Design Rules

1. **Zero trace in main space** — stealth books never appear in main bookshelf, desk, insights, or search
2. **Hidden entry** — no visible button/label; activated by gesture + biometric auth
3. **Full experience inside** — stealth space has its own desk, bookshelf, insights, and companion
4. **Complete AI isolation** — companion data, knowledge graph, reading history are separate; main-space AI never references stealth content
5. **Independent companion settings** — stealth space can have different companion personality if desired

---

## 9. UI Style Direction

Based on user-provided reference image:

| Attribute | Direction |
|-----------|-----------|
| Cards | Soft, large border-radius, generous padding |
| Colors | Pastel backgrounds — soft pink, light green, lavender |
| Typography | Bold hierarchy, large headings, warm tone |
| Illustrations | Friendly, warm illustration style (not cold/corporate) |
| Overall feel | Approachable, cozy, like a well-lit reading room |

This aligns with the "companion with warmth" philosophy — the app itself should feel like a comfortable place to spend time.

---

## 10. Implementation Strategy

### 10.1 Approach: UI Rewrite, Logic Reuse

**Reuse from Anx Reader:**
- EPUB rendering engine (WebView-based)
- Data models and DAO layer (sqflite)
- Riverpod provider architecture
- TTS engine integration
- AI backend connectivity (langchain_dart)
- WebDAV sync logic
- Book import/parsing logic

**Rewrite:**
- All page layouts and navigation framework
- AI interaction components (context bar, inline glossary, margin notes, companion panel)
- Theme and design system (new visual language)
- Insights page (entirely new concept)
- Reading desk (new concept replacing bookshelf-as-homepage)
- Companion personality system
- Stealth reading mode

### 10.2 Key Technical Considerations

- **Companion personality → prompt engineering**: Slider values map to system prompt modifiers for the LLM
- **Background AI processing**: Book import triggers async AI pipeline (summary, tags, difficulty)
- **Knowledge network storage**: Tag-based aggregation in sqflite. Data model: `concept` table + `concept_note` join table linking concepts to highlights/notes. The "graph" is a frontend visualization concern — the backend only needs tag-based queries and concept co-occurrence. No graph database needed. Embedding vectors stored alongside notes for similarity search
- **Cross-book analysis**: Embedding-based similarity search across all user notes, using the same vector storage
- **Stealth mode isolation**: Separate encrypted database for stealth space data, key managed by platform keystore
- **Context bar content**: Generated on chapter load, cached per chapter
- **Margin notes**: Require paragraph-level analysis against user's reading history
- **Summary lengths**: One-line (~20 words), paragraph (~100 words), full (~500 words). For large books, generation is chunked/progressive
- **PDF support**: Deferred from this design phase. Current scope covers EPUB only. PDF rendering can be added as a future phase.

### 10.3 Graceful Degradation

Since Omnigram is self-hosted (NAS/homeserver), AI services may be unreachable, slow, or unconfigured. Every AI-integrated surface must have a non-AI fallback:

| Feature | With AI | Without AI |
|---------|---------|------------|
| Context bar | "Previously: X. This chapter: Y" | Chapter title only |
| Inline glossary | AI-generated definitions | Built-in dictionary or hidden |
| Margin notes | Cross-book connections | Hidden |
| Companion panel | Full conversation | Unavailable (gesture does nothing) |
| Reading desk memory bridge | "Last time you read about..." | "Chapter 7 · 68%" (raw progress) |
| Bookshelf auto-tagging | AI-generated tags, summary | Manual tagging, no summary |
| Bookshelf recommendations | AI-voiced suggestion card | Hidden |
| Insights narrative | AI-generated reading story | Raw stats: books, hours, notes count |
| Knowledge graph | AI-clustered concept network | Notes listed by book (traditional view) |
| Cross-book connections | AI-detected thematic relationships | Hidden |

**Rules:**
- App must be fully functional with zero AI configuration — it degrades to a clean, well-designed traditional reader
- AI features appear progressively as the user configures AI providers
- Loading/processing states are subtle (skeleton screens, not spinners)
- Failed AI requests never show error dialogs — features silently fall back

### 10.4 Stealth Mode Data Lifecycle

- **Encryption at rest**: Stealth database encrypted with AES-256. Encryption key generated and stored in platform keystore (Android Keystore / iOS Keychain). Biometric authentication is the access gate to the key, not the key material itself
- **Backup behavior**: Stealth data excluded from normal WebDAV sync by default. Optional: user can enable encrypted stealth backup to a separate WebDAV path (backup itself is encrypted, filename is opaque)
- **Lockout policy**: After 5 failed biometric attempts, stealth entry is disabled for 30 minutes
- **App uninstall**: User-configurable — option to auto-wipe stealth data on uninstall (default: wipe). On iOS, keychain entry persists across reinstall unless explicitly deleted
- **Quick lock**: Pressing power button or switching apps immediately locks stealth space. Re-entry requires biometric auth

### 10.5 Empty States

Empty state copy adapts to companion personality (warm vs. concise). Examples shown as warm / concise:

| Screen | Warm | Concise |
|--------|------|---------|
| Reading desk | "Your desk is waiting! Let's find you something to read." | "No books in progress. Go to bookshelf to start." |
| Bookshelf | "Your library is empty — exciting, a blank slate! Import your first book to get started." | "No books. Import via file picker, WebDAV, or server sync." |
| Insights | "Nothing here yet, but every great library starts with one book. Your insights will grow as you read." | "Insights appear after you start reading." |
| Stealth library | "Your private space is ready. Anything you add here stays completely between us." | "Private space active. Add books to isolate from main library." |

### 10.6 AI Processing Pipeline

All AI features route through a unified pipeline with queue management:

**Priority levels:**
| Priority | Examples | Behavior |
|----------|---------|----------|
| P0 (Real-time) | Inline glossary, context bar | Blocks UI briefly, timeout 3s → fallback |
| P1 (Interactive) | Companion panel conversation, semantic search | Streaming response, no hard timeout |
| P2 (Background) | Book import processing, auto-tagging, margin note pre-computation | Queued, processed when idle |
| P3 (Batch) | Knowledge network rebuild, reading narrative generation | Scheduled, runs during low-usage periods |

**Resource controls:**
- User-configurable "AI processing budget" — limits concurrent background requests
- Queue persistence — survives app restart
- Priority promotion — when user opens a book, its P2 tasks promote to P0/P1

### 10.7 Data Architecture

Every data type has a defined source of truth and sync strategy:

| Data Type | Source of Truth | Sync via Server? | Notes |
|-----------|----------------|-------------------|-------|
| Books (files) | Server | Yes (WebDAV/API) | Binary files stored on server |
| Reading progress | Client → Server | Yes | Client writes, server stores, resolves conflicts by latest timestamp |
| Highlights & notes | Client → Server | Yes | Core user data, always synced |
| AI-generated tags | Server | Yes | Generated server-side or client-side, synced as metadata |
| AI summaries | Server | Yes | Cached on server, regenerated if model changes |
| Context bar cache | Client-local | No | Ephemeral, regenerated per chapter load |
| Margin notes cache | Client-local | No | Pre-computed locally, regenerated as needed |
| Knowledge network | Server | Yes | Concept-note associations stored as relational data |
| Companion personality | Account-level | Yes | Same companion across all devices |
| Stealth space data | Client-local only | Optional (encrypted, separate path) | Never in normal sync |
| Embedding vectors | Server | Yes | Generated server-side, distributed to clients for local similarity search |

**Multi-device behavior:**
- User reads on phone, switches to tablet → same progress, same companion, same knowledge network
- AI-generated content (tags, summaries) computed once on server, cached on clients
- Stealth space is device-local by default — explicit opt-in for encrypted cross-device sync

### 10.8 Onboarding Flow

Progressive onboarding that follows the "AI is air" principle — don't frontload AI configuration:

1. **Welcome** → Import first book or connect to Omnigram server
2. **Start reading** → Pure reading experience, zero AI, zero configuration
3. **First AI touch** → After first reading session, subtle prompt: "Want to see a recap next time you open this book? Set up AI to unlock smart features." Links to AI provider configuration
4. **Companion introduction** → After AI is configured, offer personality preset selection (not sliders). "Pick a reading style that suits you."
5. **Gradual discovery** → AI features appear naturally as user accumulates reading data. Knowledge network only surfaces after 3+ books with notes

AI is never required. A user who ignores all AI prompts gets a clean, beautiful, fully functional reader.

### 10.9 Data Portability

Self-hosted users demand data ownership:

- **Export notes/highlights**: Markdown, JSON, or CSV — user's choice
- **Export knowledge network**: JSON graph format (nodes + edges) for use in other tools (Obsidian, Logseq)
- **Import highlights from**: Kindle (My Clippings.txt), Apple Books (via export), Readwise CSV
- **Full library export**: All books + metadata + notes as a portable archive
- **OPDS catalog**: Server exposes library as OPDS feed for interoperability

---

## 11. Implementation Phasing

### 11.1 Dependency Layers

```
Layer 0 (Foundation)
├── New UI design system + theme
├── Four-tab navigation framework
└── EPUB rendering engine reuse verification

Layer 1 (Core Reading Loop) — depends on Layer 0
├── Full-screen reader (page turning, bookmarks, highlights, notes)
├── Bookshelf (import, browse, search)
├── Reading Tab "Desk" (current book, progress)
├── Insights Tab skeleton (raw stats + notes list, no AI)
└── Settings framework

Layer 2 (AI Pipeline) — depends on Layer 1
├── AI service abstraction (provider config, multi-model, degradation)
├── AI background processing pipeline (queue, priority, retry)
└── Companion personality config (TARS Panel) + prompt engineering framework

Layer 3 (Ambient AI) — depends on Layer 2
├── Context Bar (Layer 1 reader AI)
├── Inline Glossary (Layer 2 reader AI)
├── Memory Bridge (desk "last time you read...")
├── Bookshelf AI (auto-tagging, smart grouping, recommendations)
└── Insights Layer 1 upgrade (AI narrative)

Layer 4 (Deep AI) — depends on Layer 3
├── Companion Panel (Layer 4 bidirectional conversation)
├── Margin Notes (Layer 3 cross-book connections)
├── Semantic search
├── TTS integration (companion voice)
└── Knowledge Network (Insights Layer 2)

Layer 5 (Advanced) — depends on Layer 4
├── Cross-Book Connections (Insights Layer 3)
└── Stealth Reading Mode (requires complete main-space experience)
```

### 11.2 Sprint Targets

| Sprint | Delivers | User Value |
|--------|----------|------------|
| 1 | Layer 0 + Layer 1 | Beautiful new reader with no AI — fully functional |
| 2 | Layer 2 | AI pipeline operational, end-to-end Context Bar demo |
| 3 | Layer 3 | **Core differentiation moment** — ambient AI across all surfaces |
| 4 | Layer 4 | Deep AI features, full companion experience |
| 5 | Layer 5 | Stealth mode + advanced insights |

**First WOW moment (Sprint 3):** User opens Omnigram, sees the desk, taps a book, chapter changes and a context bar fades in, selects a word and a definition appears — **no AI button was pressed, but AI is everywhere.**

Each sprint delivers a shippable version, not a half-finished product.

---

## 12. What This Is NOT

- Not a ChatGPT wrapper with a book viewer
- Not a feature-list app where AI is one menu item among many
- Not a statistics dashboard with reading charts
- Not a file manager for EPUBs

**This is a reading experience where AI has changed everything, but you can't point to where AI "is."**
