# Reader Chrome Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract reader chrome from `reading_page.dart` into 3 independent widgets, restyle with Omnigram design language, and replace bottom bar with progress indicator + action buttons.

**Architecture:** Create `ReaderAppBar`, `ReaderBottomBar`, and `ReaderChrome` (orchestrator). `ReaderChrome` manages show/hide as a Stack overlay. `reading_page.dart` passes callbacks and state; chrome widgets are pure display. Progress data comes from `currentReadingProvider`.

**Tech Stack:** Flutter (Riverpod), Omnigram design system (`theme/`)

**Spec:** `docs/superpowers/specs/2026-04-02-reader-chrome-redesign.md`

---

### Task 1: Create ReaderAppBar widget

**Files:**
- Create: `app/lib/widgets/reader/reader_app_bar.dart`
- Create: `app/test/widgets/reader/reader_app_bar_test.dart`

- [ ] **Step 1: Write widget test**

```dart
// app/test/widgets/reader/reader_app_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/widgets/reader/reader_app_bar.dart';

void main() {
  group('ReaderAppBar', () {
    testWidgets('displays chapter title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReaderAppBar(
            chapterTitle: 'Chapter 3: The Beginning',
            isBookmarked: false,
            onBack: () {},
            onToggleBookmark: () {},
            onShowCompanion: () {},
            onShowMenu: () {},
          ),
        ),
      ));
      expect(find.text('Chapter 3: The Beginning'), findsOneWidget);
    });

    testWidgets('shows filled bookmark icon when bookmarked', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReaderAppBar(
            chapterTitle: 'Test',
            isBookmarked: true,
            onBack: () {},
            onToggleBookmark: () {},
            onShowCompanion: () {},
            onShowMenu: () {},
          ),
        ),
      ));
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('shows outline bookmark icon when not bookmarked', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReaderAppBar(
            chapterTitle: 'Test',
            isBookmarked: false,
            onBack: () {},
            onToggleBookmark: () {},
            onShowCompanion: () {},
            onShowMenu: () {},
          ),
        ),
      ));
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('calls onBack when back button pressed', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReaderAppBar(
            chapterTitle: 'Test',
            isBookmarked: false,
            onBack: () => called = true,
            onToggleBookmark: () {},
            onShowCompanion: () {},
            onShowMenu: () {},
          ),
        ),
      ));
      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(called, true);
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `cd app && flutter test test/widgets/reader/reader_app_bar_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 3: Implement ReaderAppBar**

```dart
// app/lib/widgets/reader/reader_app_bar.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';

/// Omnigram-styled reader top bar.
/// Semi-transparent with rounded bottom corners.
class ReaderAppBar extends StatelessWidget {
  final String chapterTitle;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleBookmark;
  final VoidCallback onShowCompanion;
  final VoidCallback onShowMenu;

  const ReaderAppBar({
    super.key,
    required this.chapterTitle,
    required this.isBookmarked,
    required this.onBack,
    required this.onToggleBookmark,
    required this.onShowCompanion,
    required this.onShowMenu,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
                iconSize: 22,
              ),
              Expanded(
                child: Text(
                  chapterTitle,
                  style: OmnigramTypography.titleMedium(context),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: onToggleBookmark,
                iconSize: 22,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: onShowCompanion,
                iconSize: 22,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onShowMenu,
                iconSize: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests — expect PASS**

Run: `cd app && flutter test test/widgets/reader/reader_app_bar_test.dart`
Expected: All 4 tests PASS

- [ ] **Step 5: Commit**

```bash
git add app/lib/widgets/reader/reader_app_bar.dart app/test/widgets/reader/reader_app_bar_test.dart
git commit -m "feat: implement ReaderAppBar with Omnigram styling"
```

---

### Task 2: Create ReaderBottomBar widget

**Files:**
- Create: `app/lib/widgets/reader/reader_bottom_bar.dart`
- Create: `app/test/widgets/reader/reader_bottom_bar_test.dart`

- [ ] **Step 1: Write widget tests**

```dart
// app/test/widgets/reader/reader_bottom_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/widgets/reader/reader_bottom_bar.dart';

void main() {
  Widget buildBar({
    double progress = 0.68,
    int currentPage = 142,
    int totalPages = 208,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ReaderBottomBar(
          progress: progress,
          currentPage: currentPage,
          totalPages: totalPages,
          onSeek: (_) {},
          onShowToc: () {},
          onShowNotes: () {},
          onShowProgress: () {},
          onShowStyle: () {},
          onShowTts: () {},
        ),
      ),
    );
  }

  group('ReaderBottomBar', () {
    testWidgets('displays percentage text', (tester) async {
      await tester.pumpWidget(buildBar(progress: 0.68));
      expect(find.text('68%'), findsOneWidget);
    });

    testWidgets('displays page indicator', (tester) async {
      await tester.pumpWidget(buildBar(currentPage: 142, totalPages: 208));
      expect(find.text('142 / 208'), findsOneWidget);
    });

    testWidgets('displays 0% for zero progress', (tester) async {
      await tester.pumpWidget(buildBar(progress: 0.0));
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('displays 100% for full progress', (tester) async {
      await tester.pumpWidget(buildBar(progress: 1.0));
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('renders 5 action buttons', (tester) async {
      await tester.pumpWidget(buildBar());
      // TOC, Notes, Progress, Style, TTS
      expect(find.byType(IconButton), findsNWidgets(5));
    });

    testWidgets('calls onShowToc when toc button pressed', (tester) async {
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReaderBottomBar(
            progress: 0.5,
            currentPage: 1,
            totalPages: 10,
            onSeek: (_) {},
            onShowToc: () => called = true,
            onShowNotes: () {},
            onShowProgress: () {},
            onShowStyle: () {},
            onShowTts: () {},
          ),
        ),
      ));
      await tester.tap(find.byIcon(Icons.list_outlined));
      expect(called, true);
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `cd app && flutter test test/widgets/reader/reader_bottom_bar_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 3: Implement ReaderBottomBar**

```dart
// app/lib/widgets/reader/reader_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';

/// Omnigram-styled reader bottom bar.
/// Two layers: progress indicator on top, action buttons below.
class ReaderBottomBar extends StatelessWidget {
  final double progress;
  final int currentPage;
  final int totalPages;
  final ValueChanged<double>? onSeek;
  final VoidCallback onShowToc;
  final VoidCallback onShowNotes;
  final VoidCallback onShowProgress;
  final VoidCallback onShowStyle;
  final VoidCallback onShowTts;

  const ReaderBottomBar({
    super.key,
    required this.progress,
    required this.currentPage,
    required this.totalPages,
    this.onSeek,
    required this.onShowToc,
    required this.onShowNotes,
    required this.onShowProgress,
    required this.onShowStyle,
    required this.onShowTts,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress layer
              _ProgressLayer(
                progress: progress,
                percentText: '$pct%',
                pageText: '$currentPage / $totalPages',
                onSeek: onSeek,
              ),
              const SizedBox(height: 8),
              // Action buttons layer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: const Icon(Icons.list_outlined, size: 22), onPressed: onShowToc),
                  IconButton(icon: const Icon(Icons.edit_note_outlined, size: 22), onPressed: onShowNotes),
                  IconButton(icon: const Icon(Icons.data_usage_outlined, size: 22), onPressed: onShowProgress),
                  IconButton(icon: const Icon(Icons.palette_outlined, size: 22), onPressed: onShowStyle),
                  IconButton(icon: const Icon(Icons.headphones_outlined, size: 22), onPressed: onShowTts),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLayer extends StatelessWidget {
  final double progress;
  final String percentText;
  final String pageText;
  final ValueChanged<double>? onSeek;

  const _ProgressLayer({
    required this.progress,
    required this.percentText,
    required this.pageText,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onHorizontalDragUpdate: onSeek != null
          ? (details) {
              final box = context.findRenderObject() as RenderBox;
              final localX = details.localPosition.dx;
              final pct = (localX / box.size.width).clamp(0.0, 1.0);
              onSeek!(pct);
            }
          : null,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(percentText, style: OmnigramTypography.caption(context)),
          const SizedBox(width: 8),
          Text(pageText, style: OmnigramTypography.caption(context).copyWith(
            color: colorScheme.onSurfaceVariant,
          )),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests — expect PASS**

Run: `cd app && flutter test test/widgets/reader/reader_bottom_bar_test.dart`
Expected: All 6 tests PASS

- [ ] **Step 5: Commit**

```bash
git add app/lib/widgets/reader/reader_bottom_bar.dart app/test/widgets/reader/reader_bottom_bar_test.dart
git commit -m "feat: implement ReaderBottomBar with progress indicator + action buttons"
```

---

### Task 3: Create ReaderChrome orchestrator

**Files:**
- Create: `app/lib/widgets/reader/reader_chrome.dart`

- [ ] **Step 1: Implement ReaderChrome**

```dart
// app/lib/widgets/reader/reader_chrome.dart
import 'package:flutter/material.dart';
import 'package:omnigram/widgets/reader/reader_app_bar.dart';
import 'package:omnigram/widgets/reader/reader_bottom_bar.dart';

/// Orchestrates reader chrome: top bar + bottom bar as a unified overlay.
/// Manages slide-in/slide-out animation.
class ReaderChrome extends StatelessWidget {
  final bool visible;
  final Animation<Offset> topSlide;
  final Animation<Offset> bottomSlide;
  final VoidCallback onDismiss;

  // AppBar props
  final String chapterTitle;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleBookmark;
  final VoidCallback onShowCompanion;
  final VoidCallback onShowMenu;

  // BottomBar props
  final double progress;
  final int currentPage;
  final int totalPages;
  final ValueChanged<double>? onSeek;
  final VoidCallback onShowToc;
  final VoidCallback onShowNotes;
  final VoidCallback onShowProgress;
  final VoidCallback onShowStyle;
  final VoidCallback onShowTts;

  // Sub-panel content (notes, style, TTS, etc.)
  final Widget? activePanel;

  const ReaderChrome({
    super.key,
    required this.visible,
    required this.topSlide,
    required this.bottomSlide,
    required this.onDismiss,
    required this.chapterTitle,
    required this.isBookmarked,
    required this.onBack,
    required this.onToggleBookmark,
    required this.onShowCompanion,
    required this.onShowMenu,
    required this.progress,
    required this.currentPage,
    required this.totalPages,
    this.onSeek,
    required this.onShowToc,
    required this.onShowNotes,
    required this.onShowProgress,
    required this.onShowStyle,
    required this.onShowTts,
    this.activePanel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dim overlay
        if (visible)
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withValues(alpha: 0.12)),
            ),
          ),
        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: topSlide,
            child: ReaderAppBar(
              chapterTitle: chapterTitle,
              isBookmarked: isBookmarked,
              onBack: onBack,
              onToggleBookmark: onToggleBookmark,
              onShowCompanion: onShowCompanion,
              onShowMenu: onShowMenu,
            ),
          ),
        ),
        // Bottom bar + active panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: bottomSlide,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (activePanel != null) activePanel!,
                  ReaderBottomBar(
                    progress: progress,
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onSeek: onSeek,
                    onShowToc: onShowToc,
                    onShowNotes: onShowNotes,
                    onShowProgress: onShowProgress,
                    onShowStyle: onShowStyle,
                    onShowTts: onShowTts,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify analyze**

Run: `cd app && flutter analyze lib/widgets/reader/reader_chrome.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add app/lib/widgets/reader/reader_chrome.dart
git commit -m "feat: add ReaderChrome orchestrator combining top + bottom bars"
```

---

### Task 4: Integrate ReaderChrome into reading_page.dart

**Files:**
- Modify: `app/lib/page/reading_page.dart`

This is the critical task. We replace the inline chrome code with `ReaderChrome`, add animation controllers, and wire up callbacks. The `_currentPage` (sub-panel content) pattern is preserved but passed as `activePanel` to `ReaderChrome`.

- [ ] **Step 1: Add animation controller in initState**

In `ReadingPageState`, add animation fields after `_readerFocusNode`:

```dart
  late final AnimationController _chromeAnimController;
  late final Animation<Offset> _topSlide;
  late final Animation<Offset> _bottomSlide;
```

In `initState()`, after `_readerFocusNode = FocusNode(...)`, add:

```dart
    _chromeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _topSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _chromeAnimController, curve: Curves.easeOut));
    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _chromeAnimController, curve: Curves.easeOut));
```

In `dispose()`, add `_chromeAnimController.dispose();` before `super.dispose()`.

- [ ] **Step 2: Update showBottomBar / hideBottomBar to drive animation**

Replace `showBottomBar()`:

```dart
  void showBottomBar() {
    setState(() {
      showStatusBarWithoutResize();
      bottomBarOffstage = false;
      _chromeAnimController.forward();
      _releaseReaderFocus();
    });
  }
```

Replace `hideBottomBar()`:

```dart
  void hideBottomBar() {
    _chromeAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentPage = empty;
          bottomBarOffstage = true;
        });
      }
    });
    if (Prefs().hideStatusBar) {
      hideStatusBar();
    }
    _requestReaderFocus();
  }
```

- [ ] **Step 3: Add reading state variables for progress**

Add to state variables (after `bookmarkExists`):

```dart
  String _chapterTitle = '';
  double _readingProgress = 0.0;
  int _currentChapterPage = 0;
  int _totalChapterPages = 0;
```

Find the `updateState` method (called by EpubPlayer's `updateParent` callback) and add code to update these. If `updateState` is just `setState(() {})`, change it to also read from `currentReadingProvider`:

```dart
  void updateState() {
    final reading = ref.read(currentReadingProvider);
    setState(() {
      bookmarkExists = epubPlayerKey.currentState?.bookmarkExists ?? false;
      _chapterTitle = reading.chapterTitle ?? _book.title;
      _readingProgress = reading.percentage ?? 0.0;
      _currentChapterPage = reading.chapterCurrentPage ?? 0;
      _totalChapterPages = reading.chapterTotalPages ?? 0;
    });
  }
```

NOTE: Read the existing `updateState` method first. If it already does some of this, merge rather than replace.

- [ ] **Step 4: Replace the `controller` Offstage block with ReaderChrome**

In the `build` method, find the `Offstage controller = Offstage(...)` block (lines 657-775). This entire block creates the inline AppBar + BottomSheet. Replace it with:

```dart
    final import 'package:omnigram/widgets/reader/reader_chrome.dart';
```

Wait — add the import at the top of the file:
```dart
import 'package:omnigram/widgets/reader/reader_chrome.dart';
```

Then replace the `Offstage controller = Offstage(...)` variable (lines 657-775) with:

```dart
    Widget chromeOverlay = Offstage(
      offstage: bottomBarOffstage && !_chromeAnimController.isAnimating,
      child: PointerInterceptor(
        child: ReaderChrome(
          visible: !bottomBarOffstage,
          topSlide: _topSlide,
          bottomSlide: _bottomSlide,
          onDismiss: () => showOrHideAppBarAndBottomBar(false),
          chapterTitle: _chapterTitle.isNotEmpty ? _chapterTitle : _book.title,
          isBookmarked: bookmarkExists,
          onBack: () => Navigator.pop(context),
          onToggleBookmark: () {
            if (bookmarkExists) {
              epubPlayerKey.currentState!.removeAnnotation(epubPlayerKey.currentState!.bookmarkCfi);
            } else {
              epubPlayerKey.currentState!.addBookmarkHere();
            }
          },
          onShowCompanion: showCompanionPanel,
          onShowMenu: () {
            Navigator.push(context, CupertinoPageRoute(builder: (context) => BookDetail(book: widget.book)));
          },
          progress: _readingProgress,
          currentPage: _currentChapterPage,
          totalPages: _totalChapterPages,
          onSeek: (pct) {
            epubPlayerKey.currentState?.webViewController?.evaluateJavascript(
              source: 'goToPercentage($pct)',
            );
          },
          onShowToc: tocHandler,
          onShowNotes: noteHandler,
          onShowProgress: progressHandler,
          onShowStyle: () async {
            // styleHandler needs a StateSetter — use setState directly
            List<ReadTheme> themes = await themeDao.selectThemes();
            setState(() {
              _currentPage = StyleWidget(
                themes: themes,
                epubPlayerKey: epubPlayerKey,
                setCurrentPage: (Widget page) {
                  setState(() => _currentPage = page);
                },
                hideAppBarAndBottomBar: showOrHideAppBarAndBottomBar,
              );
            });
          },
          onShowTts: ttsHandler,
          activePanel: identical(_currentPage, empty) ? null : _currentPage,
        ),
      ),
    );
```

Then in the Stack body (around line 803), replace `controller,` with `chromeOverlay,`.

- [ ] **Step 5: Remove unused imports**

Remove imports that were only used by the old inline chrome:
- `package:icons_plus/icons_plus.dart` (if `EvaIcons` is no longer used elsewhere in the file — check first)

Keep: `pointer_interceptor`, `cupertino`, `material`, etc.

- [ ] **Step 6: Remove the `aiButton` variable**

The old `aiButton` variable (lines 625-656) was an AI chat button in the top bar. Remove the entire variable declaration since it's no longer referenced (AI chat is accessible via companion panel or more menu).

- [ ] **Step 7: Verify analyze**

Run: `cd app && flutter analyze lib/page/reading_page.dart`
Expected: No errors (warnings about unused variables are OK to fix)

- [ ] **Step 8: Commit**

```bash
git add app/lib/page/reading_page.dart
git commit -m "refactor: replace inline chrome with ReaderChrome widget"
```

---

### Task 5: Final verification + PROGRESS.md

**Files:** verification only + `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Run all tests**

Run: `cd app && flutter test`
Expected: All tests PASS

- [ ] **Step 2: Run flutter analyze**

Run: `cd app && flutter analyze lib/`
Expected: No new errors in changed files

- [ ] **Step 3: Verify the reader chrome files have no issues**

Run: `cd app && flutter analyze lib/widgets/reader/reader_app_bar.dart lib/widgets/reader/reader_bottom_bar.dart lib/widgets/reader/reader_chrome.dart lib/page/reading_page.dart`
Expected: No errors

- [ ] **Step 4: Update PROGRESS.md**

Change the reader chrome line:
```markdown
| 阅读器 Chrome 重写 | §5.2 | ✅ | `widgets/reader/reader_chrome.dart`, `reader_app_bar.dart`, `reader_bottom_bar.dart` | <commit-hash> |
```

Add to 更新记录:
```markdown
| 2026-04-02 | **阅读器 Chrome 重构完成** ✅：从 reading_page.dart 抽取 chrome 到 3 个独立 widget（ReaderAppBar + ReaderBottomBar + ReaderChrome），Omnigram 视觉风格，进度条 + 按钮两层底栏，slide 动画。reading_page.dart 减少约 120 行 |
```

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs: mark reader chrome redesign as complete"
```
