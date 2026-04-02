# Reader Chrome Redesign

> **Date:** 2026-04-02
> **Status:** Approved
> **Scope:** Extract reader chrome from reading_page.dart, restyle with Omnigram design language, bottom bar with progress bar + action buttons

---

## 1. Overview

Refactor the reader's UI chrome (top bar + bottom bar + show/hide logic) out of the monolithic `reading_page.dart` (916 lines) into focused, independent widgets. Restyle with Omnigram's visual language. Replace the bottom BottomSheet with a two-layer bar (progress indicator + action buttons).

**Not in scope:** The WebView engine, AI layers, TTS logic, and the 5 sub-panels (TOC, Notes, Progress details, Style, TTS) remain untouched.

---

## 2. Component Architecture

### 2.1 File Structure

| File | Responsibility | Status |
|------|---------------|--------|
| `widgets/reader/reader_app_bar.dart` | Top bar: back, centered title, action buttons | Replace stub |
| `widgets/reader/reader_bottom_bar.dart` | Bottom bar: progress indicator + 5 action buttons | Replace stub |
| `widgets/reader/reader_chrome.dart` | Orchestrator: combines top + bottom bars, manages show/hide animation | New |
| `page/reading_page.dart` | Slim down: remove inline chrome code, delegate to `ReaderChrome` | Modify |

### 2.2 Dependency Direction

```
reading_page.dart
    └─ ReaderChrome (reader_chrome.dart)
          ├─ ReaderAppBar (reader_app_bar.dart)
          └─ ReaderBottomBar (reader_bottom_bar.dart)
```

`ReaderChrome` receives callbacks from `reading_page.dart` for actions (toggle bookmark, show companion, show TOC, etc.). Chrome widgets are stateless display components; state lives in `reading_page.dart` and providers.

---

## 3. Top Bar (ReaderAppBar)

### 3.1 Layout

```
┌─────────────────────────────────────────┐
│  ←    Chapter 3: The Beginning    🔖 💬 ⋮  │
└─────────────────────────────────────────┘
```

- **Left:** Back button (`Icons.arrow_back`)
- **Center:** Chapter title, auto-ellipsis, `OmnigramTypography.titleMedium`
- **Right:** Bookmark toggle, Companion panel button, More menu (⋮)

### 3.2 Visual Style

- Background: `colorScheme.surface` with `alpha: 0.92` (semi-transparent, content visible behind)
- Bottom edge: no hard border, subtle shadow (`elevation: 0`, `boxShadow` with blur 8, alpha 0.08)
- Border radius: bottom corners rounded (`borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))`)
- Height: standard AppBar height (56) + SafeArea top padding
- Icons: `colorScheme.onSurface`, size 22

### 3.3 Parameters

```dart
class ReaderAppBar extends StatelessWidget {
  final String chapterTitle;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleBookmark;
  final VoidCallback onShowCompanion;
  final VoidCallback onShowMenu;
}
```

### 3.4 Existing Actions Preserved

Current top bar has: back, title, companion, AI chat, copy chapter, bookmark, more menu.

Mapping:
- **Back** → preserved as `onBack`
- **Bookmark toggle** → preserved as `onToggleBookmark`
- **Companion panel** → preserved as `onShowCompanion`
- **More menu (⋮)** → preserved as `onShowMenu`, opens existing `BookDetail` page
- **AI chat** → removed from top bar (accessible via companion panel or more menu)
- **Copy chapter** → moved to more menu

This reduces top bar clutter from 5 action buttons to 3.

---

## 4. Bottom Bar (ReaderBottomBar)

### 4.1 Layout

```
┌─────────────────────────────────────────┐
│  ████████████░░░░░░░  68%     p.142     │  ← Progress layer
│  📑   📝   📊   🎨   🎧                  │  ← Action layer
└─────────────────────────────────────────┘
```

### 4.2 Progress Layer

- **Linear progress indicator:** `LinearProgressIndicator` or custom `Container` with rounded corners
- **Color:** `colorScheme.primary` for filled, `colorScheme.surfaceVariant` for track
- **Corner radius:** 4px rounded
- **Text (right side):** `"68%"` percentage + `"p.142"` page indicator
- **Typography:** `OmnigramTypography.caption` for both
- **Draggable:** Progress bar responds to horizontal drag for position seeking (calls existing `goToPercentage` or `goToCfi`)
- **Data source:** `currentReadingProvider.percentage`, `currentReadingProvider.chapterCurrentPage`, `currentReadingProvider.chapterTotalPages`

### 4.3 Action Layer

Five icon buttons, evenly spaced:

| Icon | Action | Callback |
|------|--------|----------|
| `Icons.list_outlined` | Table of Contents | `onShowToc` |
| `Icons.edit_note_outlined` | Notes | `onShowNotes` |
| `Icons.data_usage_outlined` | Reading progress details | `onShowProgress` |
| `Icons.palette_outlined` | Reading style/theme | `onShowStyle` |
| `Icons.headphones_outlined` | TTS controls | `onShowTts` |

Icons use `colorScheme.onSurface`, size 22. Active states (e.g., TTS playing) can use `colorScheme.primary`.

### 4.4 Visual Style

- Background: `colorScheme.surface` with `alpha: 0.92` (matches top bar)
- Top edge: subtle shadow (same style as top bar but inverted)
- Border radius: top corners rounded (`Radius.circular(16)`)
- Padding: 12px horizontal, 8px vertical between layers
- Height: ~96px (progress layer ~32px + action layer ~48px + padding)
- SafeArea bottom padding included

### 4.5 Parameters

```dart
class ReaderBottomBar extends StatelessWidget {
  final double progress;         // 0.0 - 1.0
  final int currentPage;
  final int totalPages;
  final ValueChanged<double>? onSeek;  // drag-to-seek
  final VoidCallback onShowToc;
  final VoidCallback onShowNotes;
  final VoidCallback onShowProgress;
  final VoidCallback onShowStyle;
  final VoidCallback onShowTts;
}
```

---

## 5. Chrome Orchestrator (ReaderChrome)

### 5.1 Responsibility

Combines `ReaderAppBar` and `ReaderBottomBar` into a single overlay that sits on top of the reading content. Manages show/hide animation as a unit.

### 5.2 Show/Hide Animation

- **Trigger:** Same as current — tap on page toggles visibility
- **Animation:** `SlideTransition` — top bar slides in from top, bottom bar slides from bottom
- **Duration:** 200ms, `Curves.easeOut`
- **State:** `bool chromeVisible` managed by parent (`reading_page.dart`)
- **Status bar:** Hides when chrome is hidden (preserves current immersive behavior)

### 5.3 Structure

```dart
class ReaderChrome extends StatelessWidget {
  final bool visible;
  final Animation<Offset> topAnimation;
  final Animation<Offset> bottomAnimation;
  // ... all callbacks from app bar + bottom bar

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dim overlay when visible
        if (visible) GestureDetector(onTap: onToggleChrome, child: dimOverlay),
        // Top bar
        Positioned(top: 0, left: 0, right: 0,
          child: SlideTransition(position: topAnimation, child: ReaderAppBar(...))),
        // Bottom bar
        Positioned(bottom: 0, left: 0, right: 0,
          child: SlideTransition(position: bottomAnimation, child: ReaderBottomBar(...))),
      ],
    );
  }
}
```

### 5.4 Integration with reading_page.dart

`reading_page.dart` changes:
1. Remove inline AppBar build code (~60 lines)
2. Remove inline BottomSheet build code (~40 lines)
3. Remove `_buildBottomBarButton` helper
4. Replace with single `ReaderChrome(...)` widget in the Stack
5. Keep all state management, callbacks, and sub-panel logic in reading_page

Estimated line reduction: ~120 lines removed, ~20 lines added for ReaderChrome integration = net -100 lines.

---

## 6. Progress Bar Seeking

### 6.1 Interaction

User can drag horizontally on the progress bar to seek to a position:

1. `GestureDetector.onHorizontalDragUpdate` captures drag position
2. Convert pixel offset to 0.0-1.0 percentage
3. Call `onSeek(percentage)` callback
4. `reading_page.dart` converts percentage to CFI and calls `webViewController.evaluateJavascript(source: "goToPercentage($pct)")`

### 6.2 Visual Feedback

During drag:
- Progress bar thumb appears at drag position
- Percentage text updates in real-time
- No haptic feedback (keep it simple)

---

## 7. Migration Strategy

### 7.1 reading_page.dart Code Removal

Code blocks to extract/remove from `reading_page.dart`:

| Lines (approx) | Current Code | Destination |
|----------------|-------------|-------------|
| 675-730 | AppBar construction | `reader_app_bar.dart` |
| 732-769 | BottomSheet construction | `reader_bottom_bar.dart` |
| 770-810 | Bottom bar button builder | `reader_bottom_bar.dart` |
| 625-660 | Show/hide bar logic | `reader_chrome.dart` |

### 7.2 Callback Wiring

All existing callbacks in reading_page.dart are preserved and passed through:

| Callback | Current Location | Chrome Widget |
|----------|-----------------|---------------|
| `Navigator.pop(context)` | AppBar leading | `ReaderAppBar.onBack` |
| `showCompanionPanel()` | AppBar action | `ReaderAppBar.onShowCompanion` |
| `toggleBookmark()` | AppBar action | `ReaderAppBar.onToggleBookmark` |
| `tocHandler()` | BottomSheet | `ReaderBottomBar.onShowToc` |
| `noteHandler()` | BottomSheet | `ReaderBottomBar.onShowNotes` |
| `progressHandler()` | BottomSheet | `ReaderBottomBar.onShowProgress` |
| `styleHandler()` | BottomSheet | `ReaderBottomBar.onShowStyle` |
| `ttsHandler()` | BottomSheet | `ReaderBottomBar.onShowTts` |

---

## 8. What Does NOT Change

- WebView/foliate-js rendering engine
- AI layers 1-4 (context bar, glossary, margin notes, companion panel)
- TTS FAB (floating button when chrome is hidden)
- All 5 sub-panels (TOC, Notes, Progress details, Style, TTS)
- Reading state providers (`currentReadingProvider`)
- Page navigation gestures (swipe, tap zones)
- Chapter content bridge
- Book service / entry point

---

## 9. Testing Strategy

| Test | Scope | Priority |
|------|-------|----------|
| ReaderAppBar renders title and buttons | Widget test | P0 |
| ReaderBottomBar displays progress and buttons | Widget test | P0 |
| Progress bar percentage formatting | Unit test | P0 |
| Chrome show/hide animation | Widget test: verify visibility toggle | P1 |
| reading_page.dart still compiles and runs | Integration: flutter analyze | P0 |

---

## 10. Out of Scope

- Menu sheet redesign (separate spec — moves buttons into slide-up panel)
- Dark mode toggle button in top bar (future, when reader theme system is reworked)
- TTS button in top bar (stays in bottom bar for now)
- Progress bar chapter markers / book-level progress (future enhancement)
- Landscape layout differences
