# Cross-Book Connections Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add cross-book discovery list and "Record my thought" journal to the Insights page, completing Layer 5.

**Architecture:** Cross-book discoveries read existing ConceptEdge data, filter for cross-book edges, and render as cards. Thoughts are stored in a new `tb_thoughts` sqflite table with optional concept/book associations. Both sections integrate into the existing InsightsPage ListView.

**Tech Stack:** Flutter (sqflite, Riverpod), existing ConceptTag/ConceptEdge DAOs

**Spec:** `docs/superpowers/specs/2026-04-07-cross-book-connections-design.md`

---

## File Map

| Action | File | Responsibility |
|--------|------|---------------|
| Modify | `app/lib/l10n/app_en.arb` + `app_zh-CN.arb` | L10n keys |
| Modify | `app/lib/dao/database.dart` | DB v14: create tb_thoughts |
| Create | `app/lib/dao/thought.dart` | Thought model + ThoughtDao |
| Create | `app/lib/widgets/insights/cross_book_card.dart` | Single cross-book discovery card |
| Create | `app/lib/widgets/insights/thought_card.dart` | Single thought card |
| Create | `app/lib/widgets/insights/record_thought_sheet.dart` | Bottom sheet for recording thoughts |
| Modify | `app/lib/page/home/insights_page.dart` | Integrate cross-book list + thoughts + FAB |
| Modify | `docs/superpowers/PROGRESS.md` | Mark Layer 5 cross-book as complete |

---

### Task 1: L10n keys + DB migration

**Files:**
- Modify: `app/lib/l10n/app_en.arb`
- Modify: `app/lib/l10n/app_zh-CN.arb`
- Modify: `app/lib/dao/database.dart`

- [ ] **Step 1: Add L10n keys to app_en.arb**

Before closing `}`, add:

```json
  "insightsCrossBookDiscoveries": "Cross-book Discoveries",
  "insightsRecordThought": "Record a thought",
  "insightsMyThoughts": "My Thoughts",
  "insightsThoughtPlaceholder": "Record your thought...",
  "insightsThoughtAbout": "About: {topic}",
  "@insightsThoughtAbout": { "placeholders": { "topic": { "type": "String" } } },
  "insightsSave": "Save"
```

- [ ] **Step 2: Add Chinese keys to app_zh-CN.arb**

```json
  "insightsCrossBookDiscoveries": "跨书发现",
  "insightsRecordThought": "记录想法",
  "insightsMyThoughts": "我的思考",
  "insightsThoughtPlaceholder": "记录你的想法...",
  "insightsThoughtAbout": "关于: {topic}",
  "@insightsThoughtAbout": { "placeholders": { "topic": { "type": "String" } } },
  "insightsSave": "保存"
```

- [ ] **Step 3: Add DB version 14 migration**

In `database.dart`, change `currentDbVersion` from 13 to 14.

In `onUpgradeDatabase`, after the `case 12:` block (before the closing `}`), add:

```dart
      case 13:
        // Layer 5: Thoughts journal for cross-book connections
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tb_thoughts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            concept_name TEXT,
            book_id INTEGER,
            edge_id INTEGER,
            created_at TEXT NOT NULL,
            synced INTEGER DEFAULT 0
          )
        ''');
```

Make sure the `case 12:` block falls through to `case 13:` by NOT having a `break` (the existing code uses continue/fallthrough pattern).

- [ ] **Step 4: Run gen-l10n and verify**

Run: `cd app && flutter gen-l10n && flutter analyze lib/dao/database.dart`
Expected: No issues

- [ ] **Step 5: Commit**

```bash
git add app/lib/l10n/ app/lib/dao/database.dart
git commit -m "feat: add L10n keys and DB v14 migration for cross-book connections"
```

---

### Task 2: Thought model + DAO

**Files:**
- Create: `app/lib/dao/thought.dart`

- [ ] **Step 1: Create Thought model and ThoughtDao**

```dart
import 'package:omnigram/dao/database.dart';

class Thought {
  final int? id;
  final String content;
  final String? conceptName;
  final int? bookId;
  final int? edgeId;
  final String createdAt;
  final bool synced;

  const Thought({
    this.id,
    required this.content,
    this.conceptName,
    this.bookId,
    this.edgeId,
    required this.createdAt,
    this.synced = false,
  });

  factory Thought.fromMap(Map<String, dynamic> map) {
    return Thought(
      id: map['id'] as int?,
      content: map['content'] as String,
      conceptName: map['concept_name'] as String?,
      bookId: map['book_id'] as int?,
      edgeId: map['edge_id'] as int?,
      createdAt: map['created_at'] as String,
      synced: (map['synced'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'concept_name': conceptName,
      'book_id': bookId,
      'edge_id': edgeId,
      'created_at': createdAt,
      'synced': synced ? 1 : 0,
    };
  }
}

class ThoughtDao {
  /// Get all thoughts, newest first.
  Future<List<Thought>> getAll() async {
    final db = await DBHelper().database;
    final rows = await db.query('tb_thoughts', orderBy: 'created_at DESC');
    return rows.map((r) => Thought.fromMap(r)).toList();
  }

  /// Insert a new thought. Returns the local ID.
  Future<int> insert(Thought thought) async {
    final db = await DBHelper().database;
    return await db.insert('tb_thoughts', thought.toMap());
  }

  /// Delete a thought by ID.
  Future<void> delete(int id) async {
    final db = await DBHelper().database;
    await db.delete('tb_thoughts', where: 'id = ?', whereArgs: [id]);
  }
}
```

- [ ] **Step 2: Verify**

Run: `cd app && flutter analyze lib/dao/thought.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add app/lib/dao/thought.dart
git commit -m "feat: add Thought model and ThoughtDao"
```

---

### Task 3: Cross-book discovery card widget

**Files:**
- Create: `app/lib/widgets/insights/cross_book_card.dart`

- [ ] **Step 1: Create CrossBookCard widget**

This widget displays a single cross-book connection. It receives pre-resolved data (book names, concept names, reason, weight).

```dart
import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/theme/colors.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class CrossBookDiscovery {
  final int edgeId;
  final String sourceBookTitle;
  final String targetBookTitle;
  final String sourceConcept;
  final String targetConcept;
  final String reason;
  final double weight;

  const CrossBookDiscovery({
    required this.edgeId,
    required this.sourceBookTitle,
    required this.targetBookTitle,
    required this.sourceConcept,
    required this.targetConcept,
    required this.reason,
    required this.weight,
  });
}

class CrossBookCard extends StatelessWidget {
  final CrossBookDiscovery discovery;
  final VoidCallback onRecordThought;

  const CrossBookCard({
    super.key,
    required this.discovery,
    required this.onRecordThought,
  });

  @override
  Widget build(BuildContext context) {
    final d = discovery;
    return OmnigramCard(
      backgroundColor: OmnigramColors.cardLavender.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book titles
          Row(
            children: [
              Icon(Icons.menu_book, size: 14, color: OmnigramColors.accentLavender),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${d.sourceBookTitle}  ↔  ${d.targetBookTitle}',
                  style: OmnigramTypography.caption(context).copyWith(
                    color: OmnigramColors.accentLavender,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Concept names
          Text(
            '"${d.sourceConcept}" ↔ "${d.targetConcept}"',
            style: OmnigramTypography.titleSmall(context),
          ),
          const SizedBox(height: 4),
          // Reason
          Text(
            d.reason,
            style: OmnigramTypography.bodyMedium(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          // Weight indicator + record thought button
          Row(
            children: [
              // Weight dots
              ...List.generate(5, (i) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.circle,
                  size: 6,
                  color: i < (d.weight * 5).round()
                      ? OmnigramColors.accentLavender
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              )),
              const Spacer(),
              TextButton.icon(
                onPressed: onRecordThought,
                icon: const Icon(Icons.edit_note, size: 16),
                label: Text(L10n.of(context).insightsRecordThought, style: const TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

Run: `cd app && flutter analyze lib/widgets/insights/cross_book_card.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add app/lib/widgets/insights/cross_book_card.dart
git commit -m "feat: add CrossBookCard widget for cross-book discoveries"
```

---

### Task 4: Thought card + record thought sheet

**Files:**
- Create: `app/lib/widgets/insights/thought_card.dart`
- Create: `app/lib/widgets/insights/record_thought_sheet.dart`

- [ ] **Step 1: Create ThoughtCard widget**

```dart
import 'package:flutter/material.dart';
import 'package:omnigram/dao/thought.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';

class ThoughtCard extends StatelessWidget {
  final Thought thought;

  const ThoughtCard({super.key, required this.thought});

  @override
  Widget build(BuildContext context) {
    return OmnigramCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thought.conceptName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                thought.conceptName!,
                style: OmnigramTypography.caption(context).copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            thought.content,
            style: OmnigramTypography.bodyMedium(context),
          ),
          const SizedBox(height: 6),
          Text(
            _formatDate(thought.createdAt),
            style: OmnigramTypography.caption(context).copyWith(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}
```

- [ ] **Step 2: Create RecordThoughtSheet**

```dart
import 'package:flutter/material.dart';
import 'package:omnigram/dao/thought.dart';
import 'package:omnigram/l10n/generated/L10n.dart';

/// Shows a bottom sheet for recording a thought.
/// [topic] is optional — if provided, shows "About: {topic}" label.
/// [edgeId] links the thought to a cross-book connection.
Future<Thought?> showRecordThoughtSheet(
  BuildContext context, {
  String? topic,
  int? edgeId,
  int? bookId,
}) async {
  return showModalBottomSheet<Thought>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _RecordThoughtContent(
      topic: topic,
      edgeId: edgeId,
      bookId: bookId,
    ),
  );
}

class _RecordThoughtContent extends StatefulWidget {
  final String? topic;
  final int? edgeId;
  final int? bookId;

  const _RecordThoughtContent({this.topic, this.edgeId, this.bookId});

  @override
  State<_RecordThoughtContent> createState() => _RecordThoughtContentState();
}

class _RecordThoughtContentState extends State<_RecordThoughtContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final thought = Thought(
      content: text,
      conceptName: widget.topic,
      bookId: widget.bookId,
      edgeId: widget.edgeId,
      createdAt: DateTime.now().toIso8601String(),
    );

    final dao = ThoughtDao();
    await dao.insert(thought);

    if (mounted) Navigator.pop(context, thought);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.topic != null) ...[
            Text(
              l10n.insightsThoughtAbout(widget.topic!),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _controller,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.insightsThoughtPlaceholder,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _save,
            child: Text(l10n.insightsSave),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Verify**

Run: `cd app && flutter analyze lib/widgets/insights/thought_card.dart lib/widgets/insights/record_thought_sheet.dart`
Expected: No issues

- [ ] **Step 4: Commit**

```bash
git add app/lib/widgets/insights/thought_card.dart app/lib/widgets/insights/record_thought_sheet.dart
git commit -m "feat: add ThoughtCard and RecordThoughtSheet for intellectual journal"
```

---

### Task 5: Integrate into InsightsPage

**Files:**
- Modify: `app/lib/page/home/insights_page.dart`

- [ ] **Step 1: Add imports**

```dart
import 'package:omnigram/dao/concept_tag.dart';
import 'package:omnigram/dao/thought.dart';
import 'package:omnigram/widgets/insights/cross_book_card.dart';
import 'package:omnigram/widgets/insights/thought_card.dart';
import 'package:omnigram/widgets/insights/record_thought_sheet.dart';
```

- [ ] **Step 2: Add data loading methods**

Add to `_InsightsPageState`:

```dart
  Future<List<CrossBookDiscovery>> _loadCrossBookDiscoveries() async {
    final dao = ConceptTagDao();
    final tags = await dao.getAll();
    final edges = await dao.getAllEdges();
    final bookDao = BookDao();
    final books = await bookDao.selectBooks();

    final tagById = <int, ConceptTag>{};
    for (final t in tags) {
      if (t.id != null) tagById[t.id!] = t;
    }
    final bookById = <int, Book>{};
    for (final b in books) {
      bookById[b.id] = b;
    }

    final discoveries = <CrossBookDiscovery>[];
    for (final edge in edges) {
      final source = tagById[edge.sourceTagId];
      final target = tagById[edge.targetTagId];
      if (source == null || target == null) continue;
      if (source.bookId == target.bookId) continue; // Same book — skip

      discoveries.add(CrossBookDiscovery(
        edgeId: edge.id ?? 0,
        sourceBookTitle: bookById[source.bookId]?.title ?? '',
        targetBookTitle: bookById[target.bookId]?.title ?? '',
        sourceConcept: source.name,
        targetConcept: target.name,
        reason: edge.reason ?? '',
        weight: edge.weight,
      ));
    }

    discoveries.sort((a, b) => b.weight.compareTo(a.weight));
    return discoveries.take(10).toList();
  }

  Future<List<Thought>> _loadThoughts() async {
    return ThoughtDao().getAll();
  }
```

- [ ] **Step 3: Add cross-book and thoughts sections to build()**

In the `build()` method's ListView children, after `const KnowledgeGraphCard()` (line 58) and before `ReadingSummaryCard`, insert:

```dart
          // Cross-book discoveries
          FutureBuilder<List<CrossBookDiscovery>>(
            future: _loadCrossBookDiscoveries(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(L10n.of(context).insightsCrossBookDiscoveries,
                      style: OmnigramTypography.titleLarge(context)),
                  const SizedBox(height: 8),
                  ...snapshot.data!.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CrossBookCard(
                      discovery: d,
                      onRecordThought: () => _recordThought(
                        topic: '${d.sourceConcept} ↔ ${d.targetConcept}',
                        edgeId: d.edgeId,
                      ),
                    ),
                  )),
                ],
              );
            },
          ),
          // My Thoughts
          FutureBuilder<List<Thought>>(
            future: _loadThoughts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(L10n.of(context).insightsMyThoughts,
                      style: OmnigramTypography.titleLarge(context)),
                  const SizedBox(height: 8),
                  ...snapshot.data!.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ThoughtCard(thought: t),
                  )),
                ],
              );
            },
          ),
```

- [ ] **Step 4: Add FAB and helper method**

Change the `Scaffold` wrapping: the current build returns `SafeArea` → `ListView`. Wrap with a `Scaffold` with a FAB:

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _recordThought(),
        child: const Icon(Icons.edit_note),
      ),
      body: SafeArea(
        child: ListView(
          // ... existing children ...
        ),
      ),
    );
  }

  Future<void> _recordThought({String? topic, int? edgeId}) async {
    final result = await showRecordThoughtSheet(
      context,
      topic: topic,
      edgeId: edgeId,
    );
    if (result != null) {
      setState(() {}); // Refresh to show new thought
    }
  }
```

- [ ] **Step 5: Verify**

Run: `cd app && flutter analyze lib/page/home/insights_page.dart`
Expected: No issues

- [ ] **Step 6: Commit**

```bash
git add app/lib/page/home/insights_page.dart
git commit -m "feat: integrate cross-book discoveries and thought journal into insights page"
```

---

### Task 6: Update PROGRESS.md

**Files:**
- Modify: `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Mark Layer 5 cross-book items as complete**

In the Layer 5 table:
```markdown
| **跨书连接（洞察 Layer 3）** | §6.1 Layer 3 | ✅ | `widgets/insights/cross_book_card.dart` | commit |
| ├─ 跨书主题关联（非认知推断） | 审核建议 #1 | ✅ | `page/home/insights_page.dart` | commit |
| └─ "Record my thought" 按钮 | §6.1 | ✅ | `widgets/insights/record_thought_sheet.dart` | commit |
```

Add to 更新记录:
```markdown
| 2026-04-07 | **Layer 5 跨书连接** ✅：跨书发现列表（ConceptEdge 跨书过滤 + 卡片展示）+ "Record my thought" 思考日记（tb_thoughts 新表 + bottom sheet + 时间线展示） |
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs: mark Layer 5 cross-book connections as complete"
```
