# Layer 3 Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete Layer 3 by implementing auto-detect difficult words (reader) and smart topic grouping (bookshelf).

**Architecture:** Feature 1 hooks into `onRelocated` chapter change → AI scans chapter → injects glossary annotations via JS bridge. Feature 2 queries AI cache for autoTag results → groups books by most frequent tags → renders TopicSections.

**Tech Stack:** Flutter (Riverpod, sqflite, InAppWebView), JavaScript (foliate-js Overlayer)

**Spec:** `docs/superpowers/specs/2026-04-05-layer3-completion-design.md`

---

## File Map

| Action | File | Responsibility |
|--------|------|---------------|
| Modify | `app/lib/service/ai/ambient_ai_pipeline.dart` | Add `autoGlossary` to AmbientTaskType |
| Modify | `app/lib/service/ai/ambient_tasks.dart` | Add `autoGlossary()` method |
| Modify | `app/lib/page/book_player/epub_player.dart` | Trigger auto-glossary on chapter change; inject highlights; handle glossary annotation clicks |
| Modify | `app/assets/foliate-js/src/view.js` | Render glossary annotations as dashed underlines |
| Modify | `app/lib/widgets/reader/glossary_tooltip.dart` | Support showing pre-cached definitions |
| Modify | `app/lib/page/home/library_page.dart` | Load topic groups and render TopicSections |
| Modify | `app/lib/dao/ai_cache.dart` | Add method to query autoTag results for all books |

---

## Feature 1: Auto-Detect Difficult Words

### Task 1: Add autoGlossary task type and AI method

**Files:**
- Modify: `app/lib/service/ai/ambient_ai_pipeline.dart` (line 10)
- Modify: `app/lib/service/ai/ambient_tasks.dart`

- [ ] **Step 1: Add `autoGlossary` to AmbientTaskType enum**

In `ambient_ai_pipeline.dart` line 10, add `autoGlossary` to the enum:

```dart
enum AmbientTaskType { contextBar, memoryBridge, autoTag, summary, glossary, autoGlossary, recommendation, narrative, conceptExtract, conceptConnect, knowledgeNarrative }
```

- [ ] **Step 2: Add `autoGlossary()` method to AmbientTasks**

In `ambient_tasks.dart`, add after the existing `glossary()` method (after line 101):

```dart
  /// Auto-detect difficult words in chapter text.
  /// Returns lines of "word|definition", one per line.
  static Future<String?> autoGlossary({
    required WidgetRef ref,
    required int bookId,
    required String chapterTitle,
    required String chapterText,
  }) {
    final lang = getAiReplyLanguage();
    final truncated = chapterText.length > 3000
        ? chapterText.substring(0, 3000)
        : chapterText;
    final prompt =
        'Identify 5-8 difficult, uncommon, or domain-specific words/phrases in the following text.\n'
        'For each word, provide a brief definition (1 sentence max).\n'
        'Format: one per line, word|definition\n'
        'Only include words that a general reader would likely not know.\n\n'
        'Text:\n$truncated\n\n'
        'Reply in $lang.';

    return AmbientAiPipeline.execute(
      type: AmbientTaskType.autoGlossary,
      prompt: prompt,
      ref: ref,
      cacheParams: {'bookId': bookId, 'chapter': chapterTitle},
      bookId: bookId,
    );
  }
```

Add import at the top of `ambient_tasks.dart`:
```dart
import 'package:omnigram/service/ai/ai_language.dart';
```

- [ ] **Step 3: Verify no analysis errors**

Run: `cd app && flutter analyze lib/service/ai/ambient_tasks.dart lib/service/ai/ambient_ai_pipeline.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add app/lib/service/ai/ambient_tasks.dart app/lib/service/ai/ambient_ai_pipeline.dart
git commit -m "feat: add autoGlossary AI task for difficult word detection"
```

---

### Task 2: Add dashed underline rendering in foliate-js

**Files:**
- Modify: `app/assets/foliate-js/src/view.js` (around line 360)

- [ ] **Step 1: Add glossary draw handler in the draw-annotation event**

The current `addAnnotation` method at line 360 emits:
```javascript
this.#emit('draw-annotation', { draw, annotation, doc, range })
```

The consumer of this event is in `epub_player.dart` where it calls `draw()` based on annotation type. But the actual drawing function is passed from Flutter side. We need a JS-side drawing function for glossary type.

In `view.js`, find where annotations are drawn. The `Overlayer` class in `overlayer.js` has static methods like `Overlayer.highlight` and `Overlayer.outline`. Add a new static method for dashed underline.

Read `app/assets/foliate-js/src/overlayer.js` to find the existing draw functions, then add a `Overlayer.underlineDashed` method:

```javascript
static underlineDashed(range, doc) {
    const rects = getOverlayRects(range, doc)
    return rects.map(({ x, y, width, height }) => {
        const el = doc.createElementNS('http://www.w3.org/2000/svg', 'line')
        el.setAttribute('x1', x)
        el.setAttribute('y1', y + height - 1)
        el.setAttribute('x2', x + width)
        el.setAttribute('y2', y + height - 1)
        el.setAttribute('stroke-dasharray', '3,2')
        el.setAttribute('stroke-width', '1.5')
        return el
    })
}
```

Then in `view.js`, modify the `addAnnotation` method to handle glossary type before emitting `draw-annotation`. Insert after line 355 (`const range = doc ? anchor(doc) : anchor`) and before the `draw-annotation` emit:

```javascript
if (annotation.type === 'glossary') {
    const draw = (func, opts) => overlayer.add(value, range, func, opts)
    draw(Overlayer.underlineDashed, { color: '#39c5bb88' })
    return { index }
}
```

This way glossary annotations bypass the Flutter-side `draw-annotation` event and are drawn directly with a dashed underline in a muted teal color.

- [ ] **Step 2: Verify the JS files have no syntax errors**

Run: `cd app && node -c assets/foliate-js/src/view.js && node -c assets/foliate-js/src/overlayer.js`
Expected: No syntax errors (note: may not have node installed — if so, visual inspection is fine)

- [ ] **Step 3: Commit**

```bash
git add app/assets/foliate-js/src/view.js app/assets/foliate-js/src/overlayer.js
git commit -m "feat: add dashed underline rendering for glossary annotations in foliate-js"
```

---

### Task 3: Trigger auto-glossary on chapter change in epub_player

**Files:**
- Modify: `app/lib/page/book_player/epub_player.dart`

- [ ] **Step 1: Add state variables for auto-glossary tracking**

In the `EpubPlayerState` class (around line 105, after the existing state variables), add:

```dart
  String? _lastAutoGlossaryChapter;
  List<Map<String, String>> _glossaryWords = [];
```

- [ ] **Step 2: Add method to trigger auto-glossary scan**

Add this method to `EpubPlayerState`:

```dart
  /// Auto-detect difficult words when chapter changes.
  /// Controlled by companion personality annotateHardWords toggle.
  Future<void> _triggerAutoGlossary() async {
    // Check if feature is enabled
    final personality = ref.read(companionProvider);
    if (!personality.annotateHardWords) return;

    // Skip if same chapter
    if (chapterTitle == _lastAutoGlossaryChapter) return;
    _lastAutoGlossaryChapter = chapterTitle;

    // Get chapter text via content bridge
    final handlers = ref.read(chapterContentBridgeProvider);
    if (handlers == null) return;

    String chapterText;
    try {
      chapterText = await handlers.fetchCurrentChapter(maxCharacters: 3000);
    } catch (e) {
      debugPrint('[AutoGlossary] Failed to fetch chapter text: $e');
      return;
    }

    if (chapterText.trim().isEmpty) return;

    // Call AI (P2 background, cached)
    final result = await AmbientTasks.autoGlossary(
      ref: ref,
      bookId: widget.book.id,
      chapterTitle: chapterTitle,
      chapterText: chapterText,
    );

    if (result == null || result.isEmpty || !mounted) return;

    // Parse word|definition pairs
    final words = <Map<String, String>>[];
    for (final line in result.split('\n')) {
      final parts = line.trim().split('|');
      if (parts.length >= 2 && parts[0].trim().isNotEmpty) {
        words.add({'word': parts[0].trim(), 'definition': parts[1].trim()});
      }
    }

    if (words.isEmpty) return;
    _glossaryWords = words;

    // Inject annotations into WebView
    for (var i = 0; i < words.length; i++) {
      final word = words[i]['word']!;
      // Use JS to find the word in current chapter and create annotation
      webViewController.evaluateJavascript(source: '''
        (function() {
          const word = ${_jsString(word)};
          const body = document.body || document.querySelector('[epub\\\\:type="bodymatter"]') || document.documentElement;
          if (!body) return;
          const walker = document.createTreeWalker(body, NodeFilter.SHOW_TEXT);
          while (walker.nextNode()) {
            const node = walker.currentNode;
            const idx = node.textContent.toLowerCase().indexOf(word.toLowerCase());
            if (idx >= 0) {
              const range = document.createRange();
              range.setStart(node, idx);
              range.setEnd(node, idx + word.length);
              const cfi = reader.getCFIFromRange(range);
              if (cfi) {
                reader.addAnnotation({
                  id: ${10000 + i},
                  type: 'glossary',
                  value: cfi,
                  color: '#39c5bb88',
                  note: '',
                });
              }
              break;
            }
          }
        })();
      ''');
    }
  }

  static String _jsString(String s) {
    return "'${s.replaceAll("\\", "\\\\").replaceAll("'", "\\'")}'";
  }
```

Add these imports at the top of the file if not present:
```dart
import 'package:omnigram/providers/companion_provider.dart';
import 'package:omnigram/service/ai/ambient_tasks.dart';
```

- [ ] **Step 3: Call _triggerAutoGlossary in the onRelocated handler**

In the `onRelocated` handler (around line 665, after `readingPageKey.currentState?.resetAwakeTimer();`), add:

```dart
        // Auto-detect difficult words (P2 background)
        _triggerAutoGlossary();
```

- [ ] **Step 4: Handle glossary annotation clicks**

In the `onAnnotationClick` handler (around line 725-767), add an early check for glossary type. After the `int id = annotation['annotation']['id'];` line (around line 749), add:

```dart
      // Glossary annotation — show cached definition directly
      if (id >= 10000 && id < 20000) {
        final wordIndex = id - 10000;
        if (wordIndex < _glossaryWords.length) {
          final word = _glossaryWords[wordIndex]['word']!;
          final definition = _glossaryWords[wordIndex]['definition']!;
          _showGlossaryPopup(context, word, definition, left, top, right, bottom);
          return;
        }
      }
```

Add the `_showGlossaryPopup` helper method:

```dart
  void _showGlossaryPopup(
    BuildContext context,
    String word,
    String definition,
    double left,
    double top,
    double right,
    double bottom,
  ) {
    contextMenuEntry?.remove();
    _animationController?.dispose();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController!, curve: Curves.easeOut);

    contextMenuEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: left,
        top: bottom + 4,
        child: FadeTransition(
          opacity: _animation!,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(word, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    definition,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(contextMenuEntry!);
    _animationController!.forward();

    // Auto-dismiss after 5 seconds or on next tap
    Future.delayed(const Duration(seconds: 5), () {
      if (contextMenuEntry?.mounted ?? false) {
        contextMenuEntry?.remove();
        contextMenuEntry = null;
      }
    });
  }
```

- [ ] **Step 5: Verify no analysis errors**

Run: `cd app && flutter analyze lib/page/book_player/epub_player.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add app/lib/page/book_player/epub_player.dart
git commit -m "feat: auto-detect difficult words on chapter change with glossary highlights"
```

---

## Feature 2: Smart Topic Grouping

### Task 4: Add AI cache query method for autoTag results

**Files:**
- Modify: `app/lib/dao/ai_cache.dart`

- [ ] **Step 1: Read the current ai_cache.dart file**

Read the file to understand the table structure and existing methods.

- [ ] **Step 2: Add method to query all autoTag results**

The AI cache table stores results keyed by `task_type` and `cache_key`. The `autoTag` task stores results with `task_type = 'autoTag'` and `cache_key` containing `bookId`. Add a method to retrieve all autoTag results:

```dart
  /// Get all cached autoTag results, returning a map of bookId → tags string.
  Future<Map<int, String>> getAllAutoTags() async {
    final db = await DBHelper().database;
    final rows = await db.query(
      'tb_ai_cache',
      columns: ['cache_key', 'result'],
      where: 'task_type = ?',
      whereArgs: ['autoTag'],
    );
    final result = <int, String>{};
    for (final row in rows) {
      final key = row['cache_key'] as String?;
      final tags = row['result'] as String?;
      if (key == null || tags == null) continue;
      // cache_key format: "autoTag_{bookId:123}" or similar — extract bookId
      final bookIdMatch = RegExp(r'bookId["\s:]+(\d+)').firstMatch(key);
      if (bookIdMatch != null) {
        final bookId = int.tryParse(bookIdMatch.group(1)!);
        if (bookId != null) {
          result[bookId] = tags;
        }
      }
    }
    return result;
  }
```

Note: The exact `cache_key` format depends on how `AmbientAiPipeline` serializes `cacheParams`. Read the `_cacheKey` method in `ambient_ai_pipeline.dart` to confirm the format, and adjust the regex accordingly.

- [ ] **Step 3: Verify**

Run: `cd app && flutter analyze lib/dao/ai_cache.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add app/lib/dao/ai_cache.dart
git commit -m "feat: add getAllAutoTags query to AiCacheDao"
```

---

### Task 5: Add topic grouping to library page

**Files:**
- Modify: `app/lib/page/home/library_page.dart`

- [ ] **Step 1: Read the current library_page.dart**

Read the full file to understand the current layout structure.

- [ ] **Step 2: Add topic grouping logic**

Add import:
```dart
import 'package:omnigram/dao/ai_cache.dart';
```

Convert `LibraryPage` from `ConsumerWidget` to `ConsumerStatefulWidget` to manage topic loading state, or use a `FutureBuilder`. The simpler approach is `FutureBuilder` inside the existing build:

In the `build()` method, after loading `allBooks`, add topic group computation:

```dart
    // Compute topic groups from AI cache
    final topicGroupsFuture = useMemoized(() async {
      final aiCache = AiCacheDao();
      final tagMap = await aiCache.getAllAutoTags();
      // tagMap: {bookId: "tag1, tag2, tag3"}

      // Count tag frequency and group books
      final tagToBooks = <String, List<Book>>{};
      for (final book in allBooks) {
        final tagsStr = tagMap[book.id];
        if (tagsStr == null) continue;
        for (final tag in tagsStr.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty)) {
          tagToBooks.putIfAbsent(tag, () => []).add(book);
        }
      }

      // Filter: only tags with 3+ books, sorted by frequency
      final groups = tagToBooks.entries
          .where((e) => e.value.length >= 3)
          .toList()
        ..sort((a, b) => b.value.length.compareTo(a.value.length));

      return groups.take(5).toList(); // Max 5 topic sections
    });
```

Since `ConsumerWidget` doesn't support hooks, the approach should be: make it `ConsumerStatefulWidget`, load topic groups in `initState`, and store in state.

Alternatively, add a simple provider or compute inline. The cleanest approach for this widget:

```dart
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  List<MapEntry<String, List<Book>>>? _topicGroups;

  @override
  void initState() {
    super.initState();
    _loadTopicGroups();
  }

  Future<void> _loadTopicGroups() async {
    final allBooks = ref.read(bookListProvider);
    final activeBooks = allBooks.where((b) => !b.isDeleted).toList();

    final aiCache = AiCacheDao();
    final tagMap = await aiCache.getAllAutoTags();

    final tagToBooks = <String, List<Book>>{};
    for (final book in activeBooks) {
      final tagsStr = tagMap[book.id];
      if (tagsStr == null) continue;
      for (final tag in tagsStr.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty)) {
        tagToBooks.putIfAbsent(tag, () => []).add(book);
      }
    }

    final groups = tagToBooks.entries
        .where((e) => e.value.length >= 3)
        .toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    if (mounted) {
      setState(() {
        _topicGroups = groups.take(5).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... existing build logic but now uses _topicGroups
  }
}
```

- [ ] **Step 3: Insert TopicSections for each group in the build method**

In the `build()` method's `SliverList` children, after the `AiRecommendationCard` and before the "Recently Added" section, insert:

```dart
          // AI topic groups
          if (_topicGroups != null)
            for (final group in _topicGroups!)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TopicSection(
                  title: group.key,
                  count: group.value.length,
                  books: group.value,
                ),
              ),
```

- [ ] **Step 4: Verify no analysis errors**

Run: `cd app && flutter analyze lib/page/home/library_page.dart`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add app/lib/page/home/library_page.dart app/lib/dao/ai_cache.dart
git commit -m "feat: add smart topic grouping to library page using AI-generated tags"
```

---

### Task 6: Update progress docs

**Files:**
- Modify: `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Mark Layer 3 items as complete**

In the Layer 3 table:
- Change `自动检测难词` from `❌` to `✅`, add file path `page/book_player/epub_player.dart` and commit hash
- Change `智能分组（主题聚合）` from `❌` to `✅`, add file path `page/home/library_page.dart` and commit hash

If all Layer 3 items are now ✅, update the 总览 table: Layer 3 status from `✅ 完成` to fully include these items (or they may already be marked as part of the layer).

- [ ] **Step 2: Add update record**

Add to the 更新记录 table:
```markdown
| 2026-04-05 | **Layer 3 补全** ✅：自动检测难词（章节切换触发 AI 扫描，虚线下划线高亮，点击显示释义）+ 智能分组（书架按 AI 标签主题聚合为 TopicSection） |
```

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs: mark Layer 3 as fully complete"
```
