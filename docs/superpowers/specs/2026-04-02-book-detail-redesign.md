# Book Detail Page Redesign

> **Date:** 2026-04-02
> **Status:** Approved
> **Scope:** Redesign BookDetail page from "information display" to "book soul page"

---

## 1. Overview

Redesign the BookDetail page (760 lines, inherited from Anx Reader) with Omnigram's design philosophy: action-oriented, AI-enhanced, no vanity metrics. The page answers three user questions: "What is this book about?", "Where did I leave off?", "What did this book leave me?"

**Core principle from brainstorm doc:** "Insights, not statistics" — users don't need to know they read for "0 hours 0 minutes". They need to continue reading or understand what they've read.

---

## 2. Information Architecture

### 2.1 Layer Priority

| Layer | Content | Rationale |
|-------|---------|-----------|
| **1st — Action** | Cover + title + author + progress bar + "Continue Reading" button | The reason 80% of users open this page |
| **2nd — Understanding** | AI one-line summary or book description | "What is this book about?" |
| **3rd — Reflection** | Recent 3 highlights/notes | "What did this book leave me?" |
| **4th — Management** | Tags + import date | Rarely needed, tucked away |

### 2.2 Removed Elements

| Old Feature | Reason |
|-------------|--------|
| "Nth book read" statistic | Vanity metric — no actionable value |
| 5-star rating bar | Rating should be asked naturally by AI after finishing, not displayed on detail page |
| Reading history table (date + seconds) | Debug data, not user data |
| HintBanner edit instructions (x2) | Removed "edit mode" concept; editing is inline |
| Circular progress indicator (100x100) | Replaced by linear progress bar next to title |
| "0.0/5" rating display | Removed with rating bar |
| "0 hours 0 minutes" reading time | Vanity metric when zero; not useful even when nonzero |

### 2.3 New Elements

| Feature | Data Source | Fallback |
|---------|------------|----------|
| "Continue Reading" prominent button | `pushToReadingPage()` | Shows "Start Reading" if progress is 0% |
| AI one-line summary | `AmbientTasks.summary()` / ai_cache | Book's `description` field; hide section if both empty |
| Cover-derived gradient background | `ColorScheme.fromImageProvider()` or palette_generator | `colorScheme.surface` solid color |
| Recent notes preview (3 max) | `noteDao` by bookId, ordered by time desc | Hide section if no notes |

---

## 3. Visual Design

### 3.1 Cover Area

- **Background:** Gradient derived from cover's dominant color (top: dominant color at 0.6 alpha → bottom: surface color). Similar to Apple Music album detail.
- **Layout:** Cover image on left (Hero animation preserved), title + author + progress on right
- **Progress:** Linear bar below author name, with percentage text (e.g., "48%")
- **Height:** Adaptive to content, not fixed 280px
- **Safe area:** Respects top safe area for notch

### 3.2 Continue Reading Button

- Full-width `FilledButton` below cover area
- Text: "Continue Reading" when progress > 0%, "Start Reading" when 0%
- Omnigram primary color, rounded corners (12px)
- L10n keys: `bookDetailContinueReading`, `bookDetailStartReading`

### 3.3 AI Summary Section

- Section title: "About this book" with book icon
- One-line AI summary in `bodyLarge` style, italic
- If no AI summary, show book `description` (plain text, non-italic)
- If neither exists, hide entire section
- No loading spinner — show cached result or nothing

### 3.4 Notes Preview Section

- Section title: "My Notes" + count badge + "View All >" link
- Up to 3 note cards, each showing highlight text + optional annotation
- Cards use `OmnigramCard` with `cardLavender` background
- Tap card → navigate to note in context (future: jump to reading position)
- Hide entire section if no notes for this book

### 3.5 Tags Section

- Horizontal `Wrap` of tag chips (existing `TagChip` widget)
- In edit mode: add button appears, chips become deletable
- Non-edit mode: read-only display, compact

### 3.6 Meta Info

- Single line of text: "Imported on 2026-03-15"
- `caption` style, `onSurfaceVariant` color
- No card wrapper, just text at the bottom

---

## 4. Edit Mode

### 4.1 Trigger

- Right side of AppBar: edit icon button (pencil)
- Tap toggles between edit/view mode
- No page navigation — inline transformation

### 4.2 Edit State Changes

| Element | View Mode | Edit Mode |
|---------|-----------|-----------|
| Title | Text | TextField (auto-focus) |
| Author | Text | TextField |
| Cover | Static image | Tap to pick new image |
| Tags | Read-only chips | Chips with delete (x), + add button |
| Progress / Summary / Notes | Normal | Unchanged (not editable here) |

### 4.3 Save Behavior

- Auto-save on exiting edit mode (tap edit button again)
- Or auto-save on navigating away (pop)
- Uses existing `bookDao.updateBook()` and `bookTagEditorProvider`

---

## 5. Cover Color Extraction

### 5.1 Approach

Use Flutter's `ColorScheme.fromImageProvider()` (available since Flutter 3.x) to extract dominant color from book cover. This is lightweight and built-in — no extra package needed.

### 5.2 Caching

Cache the extracted color in memory (provider) per book ID. Re-extract only when cover changes. The extraction is fast (~50ms) so no loading state needed.

### 5.3 Gradient Construction

```
Top: dominant color at alpha 0.6
  ↓ linear gradient
Bottom: colorScheme.surface
```

Entire gradient is the background of the SliverAppBar expanded area.

---

## 6. Page Structure (Widget Tree)

```
Scaffold
  └─ CustomScrollView
      ├─ SliverAppBar (expandable)
      │   ├─ Background: cover color gradient
      │   ├─ Leading: back button
      │   ├─ Actions: edit button
      │   └─ FlexibleSpaceBar
      │       └─ Row: [Cover image, Column: [Title, Author, ProgressBar]]
      ├─ SliverToBoxAdapter: Continue Reading button
      ├─ SliverToBoxAdapter: AI Summary section (conditional)
      ├─ SliverToBoxAdapter: Notes preview section (conditional)
      ├─ SliverToBoxAdapter: Tags section
      └─ SliverToBoxAdapter: Meta info line
```

---

## 7. File Plan

| File | Action | Responsibility |
|------|--------|---------------|
| `page/book_detail.dart` | Rewrite | Main page — slimmed from 760 to ~300 lines |
| `widgets/book_detail/cover_header.dart` | Create | Cover + title + author + progress area |
| `widgets/book_detail/notes_preview.dart` | Create | Recent 3 notes cards |
| `widgets/book_detail/ai_summary_section.dart` | Create | AI summary or description display |

Existing widgets reused: `BookCover`, `TagChip`, `OmnigramCard`, `FilledContainer`

---

## 8. L10n Keys

| Key | EN | CN |
|-----|----|----|
| `bookDetailContinueReading` | Continue Reading | 继续阅读 |
| `bookDetailStartReading` | Start Reading | 开始阅读 |
| `bookDetailAbout` | About this book | 关于这本书 |
| `bookDetailMyNotes` | My Notes | 我的笔记 |
| `bookDetailViewAll` | View All | 查看全部 |
| `bookDetailImportedOn` | Imported on {date} | 导入于 {date} |
| `bookDetailEditTitle` | Edit title | 编辑标题 |

7 keys x 16 languages = 112 translations.

---

## 9. Degradation

| Scenario | Behavior |
|----------|----------|
| No AI configured | Summary section shows `description` or hides |
| No notes | Notes section hides entirely |
| No tags | Tags section shows "Add tags" chip in edit mode, hidden in view mode |
| No cover image | Default gradient cover (existing `BookCover` fallback) + surface color gradient |
| Book not yet read (0%) | Button says "Start Reading", progress bar empty |

---

## 10. Testing

| Test | Scope | Priority |
|------|-------|----------|
| CoverHeader renders title, author, progress | Widget test | P0 |
| Continue Reading button shows correct text based on progress | Widget test | P0 |
| AI summary section hides when no data | Widget test | P1 |
| Notes preview shows max 3 notes | Widget test | P1 |
| Edit mode toggles inline fields | Widget test | P1 |
| Color extraction fallback when cover missing | Unit test | P1 |

---

## 11. Out of Scope

- Rating system redesign (future: AI asks after book completion)
- Reading history visualization (future: integrate into insights page)
- Book description editing (no UI for it currently, not adding)
- Note tap → jump to reading position (future enhancement)
- AI-curated note selection (future: replace "recent 3" with "AI picks")
