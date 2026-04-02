# Book Detail Page Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign BookDetail from 760-line "information display" into a focused "book soul page" with action-oriented layout, AI summary, and notes preview.

**Architecture:** Split the monolithic `book_detail.dart` into 3 focused widgets (`CoverHeader`, `AiSummarySection`, `NotesPreview`) + a slimmed main page. Use `ColorScheme.fromImageProvider()` for cover-derived gradient. Reuse existing `AiCacheDao` for summary, `BookNoteDao` for notes preview.

**Tech Stack:** Flutter (Riverpod), Omnigram design system (`theme/`), L10n (16 ARB files)

**Spec:** `docs/superpowers/specs/2026-04-02-book-detail-redesign.md`

---

### Task 1: L10n — add 7 keys to all 16 ARB files

**Files:**
- Modify: all 16 `app/lib/l10n/app_*.arb` files

- [ ] **Step 1: Add keys to app_en.arb**

```json
  "bookDetailContinueReading": "Continue Reading",
  "bookDetailStartReading": "Start Reading",
  "bookDetailAbout": "About this book",
  "bookDetailMyNotes": "My Notes",
  "bookDetailViewAll": "View All",
  "bookDetailImportedOn": "Imported on {date}",
  "@bookDetailImportedOn": { "placeholders": { "date": { "type": "String" } } },
  "bookDetailEditTitle": "Edit title"
```

- [ ] **Step 2: Add keys to app_zh-CN.arb**

```json
  "bookDetailContinueReading": "继续阅读",
  "bookDetailStartReading": "开始阅读",
  "bookDetailAbout": "关于这本书",
  "bookDetailMyNotes": "我的笔记",
  "bookDetailViewAll": "查看全部",
  "bookDetailImportedOn": "导入于 {date}",
  "@bookDetailImportedOn": { "placeholders": { "date": { "type": "String" } } },
  "bookDetailEditTitle": "编辑标题"
```

- [ ] **Step 3: Add keys to remaining 14 ARB files**

Translate each to the appropriate language. Note: `bookDetailImportedOn` uses `{date}` placeholder — include the `@bookDetailImportedOn` metadata in every ARB file.

- [ ] **Step 4: Regenerate L10n**

Run: `cd app && flutter gen-l10n`
Expected: exit code 0

- [ ] **Step 5: Commit**

```bash
git add app/lib/l10n/
git commit -m "l10n: add book detail page strings for 16 languages"
```

---

### Task 2: Create CoverHeader widget

**Files:**
- Create: `app/lib/widgets/book_detail/cover_header.dart`
- Create: `app/test/widgets/book_detail/cover_header_test.dart`

- [ ] **Step 1: Write widget tests**

```dart
// app/test/widgets/book_detail/cover_header_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/widgets/book_detail/cover_header.dart';

void main() {
  group('CoverHeader', () {
    testWidgets('displays book title and author', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CoverHeader(
            title: 'Test Book',
            author: 'Test Author',
            progress: 0.48,
            coverPath: '',
            dominantColor: Colors.blue,
          ),
        ),
      ));
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('displays progress percentage', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CoverHeader(
            title: 'Test',
            author: 'Author',
            progress: 0.48,
            coverPath: '',
            dominantColor: Colors.blue,
          ),
        ),
      ));
      expect(find.text('48%'), findsOneWidget);
    });

    testWidgets('displays 0% for zero progress', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CoverHeader(
            title: 'Test',
            author: 'Author',
            progress: 0.0,
            coverPath: '',
            dominantColor: Colors.blue,
          ),
        ),
      ));
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `cd app && flutter test test/widgets/book_detail/cover_header_test.dart`
Expected: FAIL — file doesn't exist

- [ ] **Step 3: Implement CoverHeader**

```dart
// app/lib/widgets/book_detail/cover_header.dart
import 'package:flutter/material.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/bookshelf/book_cover.dart';
import 'package:omnigram/models/book.dart';

/// Cover area with gradient background, book cover, title, author, and progress bar.
class CoverHeader extends StatelessWidget {
  final String title;
  final String author;
  final double progress; // 0.0 - 1.0
  final String coverPath;
  final Color dominantColor;

  const CoverHeader({
    super.key,
    required this.title,
    required this.author,
    required this.progress,
    required this.coverPath,
    required this.dominantColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pct = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            dominantColor.withValues(alpha: 0.6),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              SizedBox(
                width: 120,
                height: 170,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: coverPath.isNotEmpty
                      ? BookCover(book: Book.mock().copyWith(coverPath: coverPath))
                      : Container(
                          color: dominantColor.withValues(alpha: 0.3),
                          child: Icon(Icons.book, size: 48, color: colorScheme.onSurfaceVariant),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Title, author, progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: OmnigramTypography.titleLarge(context),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      author,
                      style: OmnigramTypography.bodyMedium(context).copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pct%',
                      style: OmnigramTypography.caption(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

NOTE: The `BookCover` widget takes a `Book` object. In the actual integration (Task 5), we pass `widget.book` directly instead of mock. For the standalone widget, we accept primitive params to keep it testable. The real integration will use `Hero` + actual `BookCover`.

- [ ] **Step 4: Run tests — expect PASS**

Run: `cd app && flutter test test/widgets/book_detail/cover_header_test.dart`
Expected: All 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add app/lib/widgets/book_detail/cover_header.dart app/test/widgets/book_detail/cover_header_test.dart
git commit -m "feat: add CoverHeader widget with gradient background"
```

---

### Task 3: Create AiSummarySection widget

**Files:**
- Create: `app/lib/widgets/book_detail/ai_summary_section.dart`

- [ ] **Step 1: Implement AiSummarySection**

```dart
// app/lib/widgets/book_detail/ai_summary_section.dart
import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/theme/typography.dart';

/// Shows AI-generated one-line summary or book description.
/// Hides entirely if no content available.
class AiSummarySection extends StatelessWidget {
  final String? aiSummary;
  final String? description;

  const AiSummarySection({
    super.key,
    this.aiSummary,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final text = aiSummary ?? description;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final isAi = aiSummary != null && aiSummary!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_outlined, size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(L10n.of(context).bookDetailAbout,
                  style: OmnigramTypography.titleMedium(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: OmnigramTypography.bodyLarge(context).copyWith(
              fontStyle: isAi ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analyze**

Run: `cd app && flutter analyze lib/widgets/book_detail/ai_summary_section.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add app/lib/widgets/book_detail/ai_summary_section.dart
git commit -m "feat: add AiSummarySection widget for book detail"
```

---

### Task 4: Create NotesPreview widget

**Files:**
- Create: `app/lib/widgets/book_detail/notes_preview.dart`

- [ ] **Step 1: Implement NotesPreview**

```dart
// app/lib/widgets/book_detail/notes_preview.dart
import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

/// Shows up to 3 recent notes/highlights for a book.
/// Hides entirely if no notes.
class NotesPreview extends StatelessWidget {
  final List<BookNote> notes;
  final VoidCallback? onViewAll;

  const NotesPreview({
    super.key,
    required this.notes,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final l10n = L10n.of(context);
    final displayNotes = notes.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_outlined, size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('${l10n.bookDetailMyNotes} (${notes.length})',
                  style: OmnigramTypography.titleMedium(context)),
              const Spacer(),
              if (notes.length > 3)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(l10n.bookDetailViewAll),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...displayNotes.map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OmnigramCard(
                  backgroundColor: OmnigramColors.cardLavender.withValues(alpha: 0.3),
                  child: Text(
                    note.content.isNotEmpty ? note.content : note.chapter,
                    style: OmnigramTypography.bodyMedium(context),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify analyze**

Run: `cd app && flutter analyze lib/widgets/book_detail/notes_preview.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add app/lib/widgets/book_detail/notes_preview.dart
git commit -m "feat: add NotesPreview widget for book detail"
```

---

### Task 5: Rewrite book_detail.dart

**Files:**
- Modify: `app/lib/page/book_detail.dart`

This is the critical task. We rewrite the entire page using the new widgets.

- [ ] **Step 1: Read the current file thoroughly**

Read `app/lib/page/book_detail.dart` (760 lines) to understand:
- How `_book` state is managed
- How tag editing works (via `bookTagEditorProvider`)
- How `pushToReadingPage` is called
- The hero animation tag pattern
- The AppBar scroll collapse behavior

- [ ] **Step 2: Rewrite the file**

Replace the ENTIRE content of `app/lib/page/book_detail.dart` with a new implementation that:

**Structure:**
```dart
class BookDetail extends ConsumerStatefulWidget {
  final Book book;
  // ...
}

class _BookDetailState extends ConsumerState<BookDetail> {
  late Book _book;
  bool isEditing = false;
  Color _dominantColor = Colors.grey;
  List<BookNote> _recentNotes = [];
  String? _aiSummary;

  @override
  void initState() {
    _book = widget.book;
    _extractColor();
    _loadNotes();
    _loadAiSummary();
  }

  Future<void> _extractColor() async {
    // Use ColorScheme.fromImageProvider if cover exists
    // Set _dominantColor, call setState
  }

  Future<void> _loadNotes() async {
    final notes = await BookNoteDao().selectBookNotesByBookId(_book.id);
    setState(() => _recentNotes = notes);
  }

  Future<void> _loadAiSummary() async {
    final entry = await AiCacheDao().get('summary', 'bookId:${_book.id}');
    if (entry != null) setState(() => _aiSummary = entry.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with back + edit button, transparent
          SliverAppBar(
            expandedHeight: 0, // no expanded area, cover is in the list
            floating: true,
            leading: BackButton(),
            actions: [
              IconButton(icon: Icon(isEditing ? Icons.check : Icons.edit), onPressed: _toggleEdit),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          // Cover header
          SliverToBoxAdapter(child: CoverHeader(
            title: _book.title, author: _book.author ?? '',
            progress: _book.readingPercentage,
            coverPath: _book.coverPath, dominantColor: _dominantColor,
          )),
          // Continue Reading button
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: FilledButton(
              onPressed: () => pushToReadingPage(ref, context, _book),
              child: Text(_book.readingPercentage > 0
                ? L10n.of(context).bookDetailContinueReading
                : L10n.of(context).bookDetailStartReading),
            ),
          )),
          // AI Summary
          SliverToBoxAdapter(child: AiSummarySection(
            aiSummary: _aiSummary,
            description: _book.description,
          )),
          // Notes preview
          SliverToBoxAdapter(child: NotesPreview(
            notes: _recentNotes,
            onViewAll: () { /* navigate to full notes */ },
          )),
          // Tags
          SliverToBoxAdapter(child: _buildTags(context)),
          // Meta info
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              L10n.of(context).bookDetailImportedOn(date: _book.createTime.split(' ').first),
              style: OmnigramTypography.caption(context),
            ),
          )),
        ],
      ),
    );
  }
}
```

**Key details:**
- Keep the `bookTagEditorProvider` integration for tag editing
- Keep `bookDao.updateBook()` for saving edits
- Keep hero animation on cover (use `Hero(tag: _book.coverFullPath)`)
- Use `ColorScheme.fromImageProvider(provider: FileImage(File(_book.coverFullPath)))` for dominant color extraction. Wrap in try/catch — fallback to `Colors.grey`.
- `_loadAiSummary`: query `AiCacheDao().get('summary', ...)`. The cache key format is `'{bookId:${bookId}}'` — check how `AmbientTasks.summary()` stores it by reading `ambient_ai_pipeline.dart`'s key generation.
- Edit mode: when `isEditing`, title and author become `TextField` widgets. Tags section shows add/delete. Cover becomes tappable (image picker).
- The full tag editing logic (create tag, toggle attachment, color picker) should be preserved from the old file.

- [ ] **Step 3: Verify analyze**

Run: `cd app && flutter analyze lib/page/book_detail.dart`
Expected: No errors

- [ ] **Step 4: Verify the page works**

Run: `cd app && flutter test`
Expected: All existing tests still PASS

- [ ] **Step 5: Commit**

```bash
git add app/lib/page/book_detail.dart
git commit -m "refactor: rewrite BookDetail page with action-oriented layout"
```

---

### Task 6: Final verification + PROGRESS.md

**Files:** verification only + `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Run all tests**

Run: `cd app && flutter test`
Expected: All tests PASS

- [ ] **Step 2: Run flutter analyze**

Run: `cd app && flutter analyze lib/`
Expected: No new errors in changed files

- [ ] **Step 3: Update PROGRESS.md**

Add to 跨层级功能 table:
```markdown
| 书籍详情页重设计 | — | ✅ | `page/book_detail.dart`, `widgets/book_detail/` | <commit-hash> |
```

Add to 更新记录:
```markdown
| 2026-04-02 | **书籍详情页重设计完成** ✅：从 760 行信息陈列柜重写为行动导向的"书的灵魂页"。封面主色渐变、继续阅读按钮、AI 一句话总结、最近笔记预览。砍掉虚荣指标（评分/阅读时长/第N本书） |
```

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs: mark book detail page redesign as complete"
```
