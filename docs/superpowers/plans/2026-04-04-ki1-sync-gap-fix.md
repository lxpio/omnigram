# KI-1/KI-3/KI-4 Sync Gap Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add pull (server→client) sync for Companion Chat, Margin Notes, and Concept Tags/Edges; fix push-side book ID and tag ID mapping.

**Architecture:** Extend existing SyncManager with a new `_pullAiData()` step (step 7). Server GET endpoints get `since` + `server_time` for delta pull. Push side gets IdMappingDao conversion. Server Wins conflict strategy.

**Tech Stack:** Go (Gin/GORM), Dart (Flutter/sqflite), existing OmnigramApi + IdMappingDao

**Spec:** `docs/superpowers/specs/2026-04-04-ki1-sync-gap-design.md`

---

## File Map

| Action | File | Responsibility |
|--------|------|---------------|
| Modify | `server/service/reader/handler_companion.go` | Add `since` + `server_time` to chat & margin notes GET |
| Modify | `server/service/reader/handler_knowledge.go` | Add `since` + `server_time` to knowledge GET; return tag ID mappings from POST |
| Modify | `server/schema/concept.go` | `UpsertConceptTags` returns `[]TagMapping` |
| Modify | `app/lib/dao/companion_chat.dart` | Add `insertFromServer()`, `fromServerJson()` |
| Modify | `app/lib/dao/margin_note.dart` | Add `upsertFromServer()`, `fromServerJson()` |
| Modify | `app/lib/dao/concept_tag.dart` | Add `insertTagIfNotExists()`, `insertEdgeIfNotExists()`, `getUnsyncedEdges()`, `markEdgesSynced()`, `fromServerJson()` |
| Modify | `app/lib/service/sync/sync_manager.dart` | Add `_pullAiData()`; fix push-side book ID + tag ID mapping |
| Create | `server/service/reader/handler_companion_test.go` | Server handler tests |
| Create | `server/service/reader/handler_knowledge_test.go` | Server handler tests |
| Modify | `docs/superpowers/KNOWN_ISSUES.md` | Mark KI-1/KI-3/KI-4 resolved |
| Modify | `docs/superpowers/PROGRESS.md` | Update status |

---

## Task 1: Server — Add `since` + `server_time` to companion chat GET

**Files:**
- Modify: `server/service/reader/handler_companion.go` (lines 25-44, `listCompanionChatHandle`)

- [ ] **Step 1: Add `since` query param and `server_time` to response**

In `handler_companion.go`, replace `listCompanionChatHandle`:

```go
func listCompanionChatHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	var chats []schema.CompanionChat
	query := orm.Where("user_id = ? AND book_id = ?", userID, bookID)

	// Delta pull: only records after since
	if sinceStr := c.Query("since"); sinceStr != "" {
		if since, err := strconv.ParseInt(sinceStr, 10, 64); err == nil && since > 0 {
			query = query.Where("ctime > ?", since)
		}
	}

	query = query.Order("ctime ASC")

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))
	if limit < 1 || limit > 200 {
		limit = 50
	}
	query = query.Limit(limit).Offset(offset)

	if err := query.Find(&chats).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"data":        chats,
		"server_time": time.Now().UnixMilli(),
	})
}
```

Note: Add `"time"` to the import block at the top of the file.

- [ ] **Step 2: Verify server compiles**

Run: `cd server && go build ./...`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add server/service/reader/handler_companion.go
git commit -m "feat(server): add since + server_time to companion chat GET endpoint"
```

---

## Task 2: Server — Add `since` + `server_time` to margin notes GET

**Files:**
- Modify: `server/service/reader/handler_companion.go` (lines 92-110, `listMarginNotesHandle`)

- [ ] **Step 1: Add `since` query param and `server_time` to response**

Replace `listMarginNotesHandle`:

```go
func listMarginNotesHandle(c *gin.Context) {
	bookID := c.Param("book_id")
	userID := c.GetInt64(middleware.XUserIDTag)

	query := orm.Where("user_id = ? AND book_id = ?", userID, bookID)

	// Delta pull: only records updated after since
	if sinceStr := c.Query("since"); sinceStr != "" {
		if since, err := strconv.ParseInt(sinceStr, 10, 64); err == nil && since > 0 {
			query = query.Where("utime > ?", since)
		}
	}

	if chapter := c.Query("chapter"); chapter != "" {
		query = query.Where("chapter = ?", chapter)
	}

	query = query.Where("dismissed = false").Order("confidence DESC")

	var notes []schema.MarginNote
	if err := query.Find(&notes).Error; err != nil {
		schema.Error(c, http.StatusInternalServerError, "DB_ERROR", err.Error())
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"data":        notes,
		"server_time": time.Now().UnixMilli(),
	})
}
```

- [ ] **Step 2: Verify server compiles**

Run: `cd server && go build ./...`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add server/service/reader/handler_companion.go
git commit -m "feat(server): add since + server_time to margin notes GET endpoint"
```

---

## Task 3: Server — Add `since` + `server_time` to knowledge graph GET

**Files:**
- Modify: `server/service/reader/handler_knowledge.go` (lines 21-49, `GetKnowledgeGraph`)
- Modify: `server/schema/concept.go` — add `since` parameter to list functions

- [ ] **Step 1: Add since-aware list functions in concept.go**

Add these two functions to `server/schema/concept.go`:

```go
func ListConceptTagsSince(db *gorm.DB, userID int64, since int64) ([]ConceptTag, error) {
	var tags []ConceptTag
	err := db.Where("user_id = ? AND ctime > ?", userID, since).Order("ctime desc").Find(&tags).Error
	return tags, err
}

func ListConceptTagsByBookSince(db *gorm.DB, userID int64, bookID string, since int64) ([]ConceptTag, error) {
	var tags []ConceptTag
	err := db.Where("user_id = ? AND book_id = ? AND ctime > ?", userID, bookID, since).Order("ctime desc").Find(&tags).Error
	return tags, err
}

func ListConceptEdgesSince(db *gorm.DB, userID int64, since int64) ([]ConceptEdge, error) {
	var edges []ConceptEdge
	err := db.Where("user_id = ? AND ctime > ?", userID, since).Find(&edges).Error
	return edges, err
}
```

- [ ] **Step 2: Update GetKnowledgeGraph handler**

Replace `GetKnowledgeGraph` in `handler_knowledge.go`:

```go
func GetKnowledgeGraph(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)
	bookID := c.Query("book_id")

	db := store.FileStore()

	var since int64
	if sinceStr := c.Query("since"); sinceStr != "" {
		if s, err := strconv.ParseInt(sinceStr, 10, 64); err == nil && s > 0 {
			since = s
		}
	}

	var tags []schema.ConceptTag
	var err error
	if since > 0 {
		if bookID != "" {
			tags, err = schema.ListConceptTagsByBookSince(db, userID, bookID, since)
		} else {
			tags, err = schema.ListConceptTagsSince(db, userID, since)
		}
	} else {
		if bookID != "" {
			tags, err = schema.ListConceptTagsByBook(db, userID, bookID)
		} else {
			tags, err = schema.ListConceptTags(db, userID)
		}
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	var edges []schema.ConceptEdge
	if since > 0 {
		edges, err = schema.ListConceptEdgesSince(db, userID, since)
	} else {
		edges, err = schema.ListConceptEdges(db, userID)
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"nodes":       tags,
		"edges":       edges,
		"server_time": time.Now().UnixMilli(),
	})
}
```

Note: Add `"strconv"` and `"time"` to the import block if not present.

- [ ] **Step 3: Verify server compiles**

Run: `cd server && go build ./...`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add server/schema/concept.go server/service/reader/handler_knowledge.go
git commit -m "feat(server): add since + server_time to knowledge graph GET endpoint"
```

---

## Task 4: Server — POST `/reader/knowledge/tags` returns ID mappings

**Files:**
- Modify: `server/schema/concept.go` — change `UpsertConceptTags` signature
- Modify: `server/service/reader/handler_knowledge.go` — update `SyncConceptTags`

- [ ] **Step 1: Add TagMapping struct and update UpsertConceptTags**

In `server/schema/concept.go`, add the struct and replace `UpsertConceptTags`:

```go
// TagMapping maps client-provided local_id to server-assigned id.
type TagMapping struct {
	LocalID  int64 `json:"local_id"`
	ServerID int64 `json:"server_id"`
}

// ConceptTagWithLocalID extends ConceptTag with a client-side local_id for sync mapping.
type ConceptTagWithLocalID struct {
	ConceptTag
	LocalID int64 `json:"local_id" gorm:"-"`
}

func UpsertConceptTagsWithMapping(db *gorm.DB, tags []ConceptTagWithLocalID) ([]TagMapping, error) {
	mappings := make([]TagMapping, 0, len(tags))
	for _, tag := range tags {
		var existing ConceptTag
		err := db.Where("user_id = ? AND book_id = ? AND name = ? AND note_id = ?",
			tag.UserID, tag.BookID, tag.Name, tag.NoteID).
			Assign(tag.ConceptTag).FirstOrCreate(&existing).Error
		if err != nil {
			return nil, err
		}
		mappings = append(mappings, TagMapping{
			LocalID:  tag.LocalID,
			ServerID: existing.ID,
		})
	}
	return mappings, nil
}
```

Keep the old `UpsertConceptTags` function as-is (it may be used elsewhere).

- [ ] **Step 2: Update SyncConceptTags handler**

Replace `SyncConceptTags` in `handler_knowledge.go`:

```go
func SyncConceptTags(c *gin.Context) {
	userID := c.GetInt64(middleware.XUserIDTag)

	var tags []schema.ConceptTagWithLocalID
	if err := c.ShouldBindJSON(&tags); err != nil {
		c.JSON(http.StatusBadRequest, schema.ErrorResponse{Message: err.Error()})
		return
	}

	for i := range tags {
		tags[i].UserID = userID
	}

	mappings, err := schema.UpsertConceptTagsWithMapping(store.FileStore(), tags)
	if err != nil {
		c.JSON(http.StatusInternalServerError, schema.ErrorResponse{Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   "ok",
		"mappings": mappings,
	})
}
```

- [ ] **Step 3: Verify server compiles**

Run: `cd server && go build ./...`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add server/schema/concept.go server/service/reader/handler_knowledge.go
git commit -m "feat(server): return tag ID mappings from POST /reader/knowledge/tags"
```

---

## Task 5: Server — Update swagger annotations

**Files:**
- Modify: `server/service/reader/handler_companion.go`
- Modify: `server/service/reader/handler_knowledge.go`

- [ ] **Step 1: Update swagger annotations for modified endpoints**

Add/update `@Param since` annotations on the three GET handlers and update `@Success` to reflect the new response shapes. For `SyncConceptTags`, update `@Success` to show mappings in response.

Example for `listCompanionChatHandle`:
```go
// @Param since query int false "Delta sync: only return records with ctime > since (milliseconds)"
```

Example for `SyncConceptTags`:
```go
// @Success 200 {object} map[string]interface{} "status: ok, mappings: [{local_id, server_id}]"
```

- [ ] **Step 2: Regenerate swagger docs**

Run: `cd server && make swagger`
Expected: Docs regenerated successfully

- [ ] **Step 3: Verify server compiles**

Run: `cd server && go build ./...`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add server/service/reader/handler_companion.go server/service/reader/handler_knowledge.go server/docs/
git commit -m "docs(server): update swagger annotations for sync endpoints"
```

---

## Task 6: Client — Add pull methods to CompanionChatDao

**Files:**
- Modify: `app/lib/dao/companion_chat.dart`

- [ ] **Step 1: Add `insertFromServer()` method to CompanionChatDao**

After the existing `markSynced()` method (around line 74), add:

```dart
  /// Insert a message from server. Returns the local auto-increment ID.
  /// Dedup is handled by SyncManager via IdMappingDao (server ID check).
  Future<int> insertFromServer(CompanionMessage msg) async {
    final db = await DBHelper().database;
    final map = msg.toMap();
    map['synced'] = 1; // Already on server, no need to push back
    return await db.insert('tb_companion_chat', map);
  }
```

- [ ] **Step 2: Add `fromServerJson()` factory to CompanionMessage**

After the existing `isCompanion` getter (around line 128), add:

```dart
  /// Construct from server JSON response, mapping server book_id to local book_id.
  factory CompanionMessage.fromServerJson(Map<String, dynamic> json, int localBookId) {
    return CompanionMessage(
      bookId: localBookId,
      role: json['role'] as String,
      content: json['content'] as String,
      chapter: json['chapter'] as String?,
      cfi: json['cfi'] as String?,
      createdAt: json['ctime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] as int).toIso8601String()
          : DateTime.now().toIso8601String(),
      synced: true,
    );
  }
```

- [ ] **Step 3: Verify no analysis errors**

Run: `cd app && flutter analyze lib/dao/companion_chat.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add app/lib/dao/companion_chat.dart
git commit -m "feat(client): add insertFromServer and fromServerJson to CompanionChatDao"
```

---

## Task 7: Client — Add pull methods to MarginNoteDao

**Files:**
- Modify: `app/lib/dao/margin_note.dart`

- [ ] **Step 1: Add `upsertFromServer()` method to MarginNoteDao**

After the existing `markSynced()` method (around line 72), add:

```dart
  /// Upsert a margin note from server using Server Wins strategy.
  /// Dedup key: (book_id, chapter, cfi, content).
  /// If exists: update dismissed/helpful/confidence. If not: insert.
  Future<void> upsertFromServer(MarginNote note) async {
    final db = await DBHelper().database;
    final existing = await db.query(
      'tb_margin_notes',
      where: 'book_id = ? AND chapter = ? AND cfi = ? AND content = ?',
      whereArgs: [note.bookId, note.chapter, note.cfi ?? '', note.content],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      // Server Wins: update feedback fields
      await db.update(
        'tb_margin_notes',
        {
          'dismissed': note.dismissed ? 1 : 0,
          'helpful': note.helpful ? 1 : 0,
          'confidence': note.confidence,
          'synced': 1,
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      final map = note.toMap();
      map['synced'] = 1;
      await db.insert('tb_margin_notes', map);
    }
  }
```

- [ ] **Step 2: Add `fromServerJson()` factory to MarginNote**

After the existing `toMap()` method (around line 140), add:

```dart
  /// Construct from server JSON response, mapping server book_id to local book_id.
  factory MarginNote.fromServerJson(Map<String, dynamic> json, int localBookId) {
    return MarginNote(
      bookId: localBookId,
      chapter: json['chapter'] as String,
      cfi: json['cfi'] as String?,
      content: json['content'] as String,
      relatedBookId: null, // Server uses string book_id; local mapping not needed for display
      relatedBookTitle: json['related_book_title'] as String?,
      relatedHighlight: json['related_highlight'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      dismissed: json['dismissed'] as bool? ?? false,
      helpful: json['helpful'] as bool? ?? false,
      createdAt: json['ctime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] as int).toIso8601String()
          : DateTime.now().toIso8601String(),
      synced: true,
    );
  }
```

- [ ] **Step 3: Verify no analysis errors**

Run: `cd app && flutter analyze lib/dao/margin_note.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add app/lib/dao/margin_note.dart
git commit -m "feat(client): add upsertFromServer and fromServerJson to MarginNoteDao"
```

---

## Task 8: Client — Add pull methods to ConceptTagDao

**Files:**
- Modify: `app/lib/dao/concept_tag.dart`

- [ ] **Step 1: Add `fromServerJson()` factories to ConceptTag and ConceptEdge**

After `ConceptTag.fromMap()` (around line 38), add:

```dart
  /// Construct from server JSON, mapping server book_id to local book_id.
  factory ConceptTag.fromServerJson(Map<String, dynamic> json, int localBookId) {
    return ConceptTag(
      bookId: localBookId,
      name: json['name'] as String,
      source: json['source'] as String?,
      noteId: json['note_id'] as int?,
      createTime: json['ctime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] as int).toIso8601String()
          : null,
      synced: 1,
    );
  }
```

After `ConceptEdge.fromMap()` (around line 76), add:

```dart
  /// Construct from server JSON, using already-mapped local tag IDs.
  factory ConceptEdge.fromServerJson(
    Map<String, dynamic> json,
    int localSourceId,
    int localTargetId,
  ) {
    return ConceptEdge(
      sourceTagId: localSourceId,
      targetTagId: localTargetId,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      reason: json['reason'] as String?,
      createTime: json['ctime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ctime'] as int).toIso8601String()
          : null,
      synced: 1,
    );
  }
```

- [ ] **Step 2: Add `insertTagIfNotExists()` to ConceptTagDao**

After `markSynced()` (around line 146), add:

```dart
  /// Insert a tag if it doesn't exist (dedup by book_id + name + note_id).
  /// Returns the local ID (existing or newly inserted).
  Future<int> insertTagIfNotExists(ConceptTag tag) async {
    final db = await DBHelper().database;
    final existing = await db.query(
      'tb_concept_tags',
      columns: ['id'],
      where: 'book_id = ? AND name = ? AND note_id = ?',
      whereArgs: [tag.bookId, tag.name, tag.noteId ?? 0],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    final map = tag.toMap();
    map['synced'] = 1;
    return await db.insert('tb_concept_tags', map);
  }
```

- [ ] **Step 3: Add `insertEdgeIfNotExists()` to ConceptTagDao**

```dart
  /// Insert an edge if it doesn't exist (dedup by source_tag_id + target_tag_id).
  Future<void> insertEdgeIfNotExists(ConceptEdge edge) async {
    final db = await DBHelper().database;
    final existing = await db.query(
      'tb_concept_edges',
      columns: ['id'],
      where: 'source_tag_id = ? AND target_tag_id = ?',
      whereArgs: [edge.sourceTagId, edge.targetTagId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;
    final map = edge.toMap();
    map['synced'] = 1;
    await db.insert('tb_concept_edges', map);
  }
```

- [ ] **Step 4: Add `getUnsyncedEdges()` and `markEdgesSynced()` to ConceptTagDao**

```dart
  /// Get edges not yet synced to server.
  Future<List<ConceptEdge>> getUnsyncedEdges() async {
    final db = await DBHelper().database;
    final rows = await db.query('tb_concept_edges', where: 'synced = 0');
    return rows.map((r) => ConceptEdge.fromMap(r)).toList();
  }

  /// Mark edges as synced after successful push.
  Future<void> markEdgesSynced(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await DBHelper().database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE tb_concept_edges SET synced = 1 WHERE id IN ($placeholders)',
      ids,
    );
  }
```

- [ ] **Step 5: Verify no analysis errors**

Run: `cd app && flutter analyze lib/dao/concept_tag.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add app/lib/dao/concept_tag.dart
git commit -m "feat(client): add pull sync methods to ConceptTagDao"
```

---

## Task 9: Client — Fix push-side book ID mapping (KI-4)

**Files:**
- Modify: `app/lib/service/sync/sync_manager.dart` (lines 366-448, `_pushAiData`)

- [ ] **Step 1: Fix companion chat push to use server book ID**

In `_pushAiData()`, replace the companion chat push block (around lines 399-422) with:

```dart
    // Companion Chat — group by book, convert to server book ID
    final chatDao = CompanionChatDao();
    final unsyncedChats = await chatDao.getUnsynced();
    if (unsyncedChats.isNotEmpty) {
      final byBook = <int, List<CompanionMessage>>{};
      for (final msg in unsyncedChats) {
        byBook.putIfAbsent(msg.bookId, () => []).add(msg);
      }
      for (final entry in byBook.entries) {
        try {
          final serverId = await IdMappingDao.getServerId(
            entry.key.toString(), 'book',
          );
          if (serverId == null) continue; // Book not synced yet
          await api.postVoid(
            '/reader/books/$serverId/companion/chat',
            data: entry.value.map((m) => m.toMap()).toList(),
          );
          await chatDao.markSynced(
            entry.value.where((m) => m.id != null).map((m) => m.id!).toList(),
          );
        } catch (e) {
          debugPrint('[SyncManager] Push chat for book ${entry.key}: $e');
        }
      }
    }
```

- [ ] **Step 2: Fix margin notes push to use server book ID**

Replace the margin notes push block (around lines 424-447) with:

```dart
    // Margin Notes — group by book, convert to server book ID
    final marginDao = MarginNoteDao();
    final unsyncedNotes = await marginDao.getUnsynced();
    if (unsyncedNotes.isNotEmpty) {
      final byBook = <int, List<MarginNote>>{};
      for (final note in unsyncedNotes) {
        byBook.putIfAbsent(note.bookId, () => []).add(note);
      }
      for (final entry in byBook.entries) {
        try {
          final serverId = await IdMappingDao.getServerId(
            entry.key.toString(), 'book',
          );
          if (serverId == null) continue; // Book not synced yet
          await api.postVoid(
            '/reader/books/$serverId/margin-notes',
            data: entry.value.map((n) => n.toMap()).toList(),
          );
          await marginDao.markSynced(
            entry.value.where((n) => n.id != null).map((n) => n.id!).toList(),
          );
        } catch (e) {
          debugPrint('[SyncManager] Push margin notes for book ${entry.key}: $e');
        }
      }
    }
```

- [ ] **Step 3: Fix concept tags push to use server book ID and return mappings (KI-3)**

Replace the concept tags push block (around lines 373-384) with:

```dart
    // Concept Tags — convert book_id, get ID mappings back
    final conceptDao = ConceptTagDao();
    final unsyncedTags = await conceptDao.getUnsynced();
    if (unsyncedTags.isNotEmpty) {
      // Build server book ID lookup
      final bookMappings = await IdMappingDao.getAllMappings('book');
      // bookMappings: {localId: serverId}

      final tagMaps = <Map<String, dynamic>>[];
      final localTagIds = <int>[];
      for (final t in unsyncedTags) {
        final serverBookId = bookMappings[t.bookId.toString()];
        if (serverBookId == null) continue; // Book not synced
        final m = t.toMap();
        m['local_id'] = t.id;
        m['book_id'] = serverBookId;
        tagMaps.add(m);
        if (t.id != null) localTagIds.add(t.id!);
      }

      if (tagMaps.isNotEmpty) {
        try {
          final resp = await api.post<Map<String, dynamic>>(
            '/reader/knowledge/tags',
            data: tagMaps,
          );
          // Cache tag ID mappings for edges push
          final mappings = resp?['mappings'] as List? ?? [];
          for (final m in mappings) {
            await IdMappingDao.upsert(
              m['local_id'].toString(),
              m['server_id'].toString(),
              'concept_tag',
            );
          }
          await conceptDao.markSynced(localTagIds);
        } catch (e) {
          debugPrint('[SyncManager] Push concept tags: $e');
        }
      }
    }

    // Concept Edges — map local tag IDs to server tag IDs
    final unsyncedEdges = await conceptDao.getUnsyncedEdges();
    if (unsyncedEdges.isNotEmpty) {
      final edgeMaps = <Map<String, dynamic>>[];
      final syncedEdgeIds = <int>[];

      for (final e in unsyncedEdges) {
        final sourceServerId = await IdMappingDao.getServerId(
          e.sourceTagId.toString(), 'concept_tag',
        );
        final targetServerId = await IdMappingDao.getServerId(
          e.targetTagId.toString(), 'concept_tag',
        );
        if (sourceServerId == null || targetServerId == null) continue;

        edgeMaps.add({
          'source_id': int.parse(sourceServerId),
          'target_id': int.parse(targetServerId),
          'weight': e.weight,
          'reason': e.reason,
        });
        if (e.id != null) syncedEdgeIds.add(e.id!);
      }

      if (edgeMaps.isNotEmpty) {
        try {
          await api.postVoid('/reader/knowledge/edges', data: edgeMaps);
          await conceptDao.markEdgesSynced(syncedEdgeIds);
        } catch (e) {
          debugPrint('[SyncManager] Push concept edges: $e');
        }
      }
    }
```

- [ ] **Step 4: Verify no analysis errors**

Run: `cd app && flutter analyze lib/service/sync/sync_manager.dart`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add app/lib/service/sync/sync_manager.dart
git commit -m "fix(client): use server book ID in push + return tag ID mappings (KI-3, KI-4)"
```

---

## Task 10: Client — Add `_pullAiData()` to SyncManager

**Files:**
- Modify: `app/lib/service/sync/sync_manager.dart`

- [ ] **Step 1: Add SharedPreferences key for AI sync server time**

In the `_SyncKeys` class (around line 79), add:

```dart
  static const lastAiSyncServerTime = 'sync_last_ai_sync_server_time_ms';
```

- [ ] **Step 2: Add `_lastAiSyncServerTimeMs` field**

In the `SyncManager` class, near the existing `_lastSyncTimeMs` field, add:

```dart
  int _lastAiSyncServerTimeMs = 0;
```

And in the initialization (where `_lastSyncTimeMs` is loaded from prefs), add:

```dart
  _lastAiSyncServerTimeMs = _prefs.getInt(_SyncKeys.lastAiSyncServerTime) ?? 0;
```

- [ ] **Step 3: Add `_pullAiData()` method**

Add this method to the `SyncManager` class, after `_pullProgress()`:

```dart
  /// Pull AI data from server: companion chat, margin notes, concept tags/edges.
  /// Strategy: Server Wins — server data overwrites local on conflict.
  Future<void> _pullAiData() async {
    final conn = ref.read(serverConnectionProvider.notifier);
    if (!conn.state.isConnected) return;
    final api = conn.api;

    final since = _lastAiSyncServerTimeMs;
    final books = await IdMappingDao.getAllMappings('book');
    int latestServerTime = since;

    final chatDao = CompanionChatDao();
    final marginDao = MarginNoteDao();
    final conceptDao = ConceptTagDao();

    for (final entry in books.entries) {
      final localBookId = int.parse(entry.key);
      final serverId = entry.value;

      // 1. Pull companion chat (paginated)
      try {
        int offset = 0;
        const limit = 100;
        while (true) {
          final resp = await api.get<Map<String, dynamic>>(
            '/reader/books/$serverId/companion/chat',
            queryParameters: {'since': since, 'limit': limit, 'offset': offset},
          );
          if (resp == null) break;
          final chats = (resp['data'] as List?) ?? [];
          final serverTime = resp['server_time'] as int? ?? 0;
          latestServerTime = max(latestServerTime, serverTime);

          for (final chat in chats) {
            final serverChatId = chat['id'] as int;
            // Dedup by server ID
            final existing = await IdMappingDao.getLocalId(
              serverChatId.toString(), 'companion_chat',
            );
            if (existing != null) continue;

            final localId = await chatDao.insertFromServer(
              CompanionMessage.fromServerJson(
                chat as Map<String, dynamic>, localBookId,
              ),
            );
            await IdMappingDao.upsert(
              localId.toString(), serverChatId.toString(), 'companion_chat',
            );
          }

          if (chats.length < limit) break;
          offset += limit;
        }
      } catch (e) {
        debugPrint('[SyncManager] Pull companion chat for $serverId: $e');
      }

      // 2. Pull margin notes
      try {
        final resp = await api.get<Map<String, dynamic>>(
          '/reader/books/$serverId/margin-notes',
          queryParameters: {'since': since},
        );
        if (resp != null) {
          final notes = (resp['data'] as List?) ?? [];
          final serverTime = resp['server_time'] as int? ?? 0;
          latestServerTime = max(latestServerTime, serverTime);

          for (final note in notes) {
            await marginDao.upsertFromServer(
              MarginNote.fromServerJson(
                note as Map<String, dynamic>, localBookId,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('[SyncManager] Pull margin notes for $serverId: $e');
      }
    }

    // 3. Pull concept tags + edges (all books at once)
    try {
      final resp = await api.get<Map<String, dynamic>>(
        '/reader/knowledge',
        queryParameters: {'since': since},
      );
      if (resp != null) {
        final serverTime = resp['server_time'] as int? ?? 0;
        latestServerTime = max(latestServerTime, serverTime);

        final serverTagIdToLocalId = <int, int>{};

        final nodes = (resp['nodes'] as List?) ?? [];
        for (final tag in nodes) {
          final serverBookId = tag['book_id'] as String?;
          if (serverBookId == null) continue;
          final localBookId = await IdMappingDao.getLocalId(serverBookId, 'book');
          if (localBookId == null) continue;

          final localId = await conceptDao.insertTagIfNotExists(
            ConceptTag.fromServerJson(
              tag as Map<String, dynamic>, int.parse(localBookId),
            ),
          );
          serverTagIdToLocalId[tag['id'] as int] = localId;
        }

        final edges = (resp['edges'] as List?) ?? [];
        for (final edge in edges) {
          final localSourceId = serverTagIdToLocalId[edge['source_id']];
          final localTargetId = serverTagIdToLocalId[edge['target_id']];
          if (localSourceId == null || localTargetId == null) continue;

          await conceptDao.insertEdgeIfNotExists(
            ConceptEdge.fromServerJson(
              edge as Map<String, dynamic>, localSourceId, localTargetId,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[SyncManager] Pull knowledge graph: $e');
    }

    // Persist server time for next delta pull
    _lastAiSyncServerTimeMs = latestServerTime;
    await _prefs.setInt(_SyncKeys.lastAiSyncServerTime, latestServerTime);
  }
```

- [ ] **Step 4: Wire `_pullAiData()` into the sync() flow**

In the `sync()` method, after the step 6 block (around line 226, after `_processOfflineQueue()`), add:

```dart
      // Step 7: Pull AI data
      state = state.copyWith(progress: 0.97, message: '同步 AI 数据...');
      await _pullAiData();
```

- [ ] **Step 5: Verify no analysis errors**

Run: `cd app && flutter analyze lib/service/sync/sync_manager.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add app/lib/service/sync/sync_manager.dart
git commit -m "feat(client): add _pullAiData() for server→client AI data sync (KI-1)"
```

---

## Task 11: Server — Hurl integration tests

**Files:**
- Modify or create: Hurl test file for the modified endpoints

- [ ] **Step 1: Check existing Hurl test location**

Look for existing Hurl tests: `ls server/test/` or `find server -name "*.hurl"`

- [ ] **Step 2: Add sync endpoint smoke tests**

Add tests covering:
1. POST `/reader/knowledge/tags` with `local_id` field → verify response contains `mappings` array
2. GET `/reader/books/:id/companion/chat?since=0` → verify response contains `data` and `server_time`
3. GET `/reader/books/:id/margin-notes?since=0` → verify response contains `data` and `server_time`
4. GET `/reader/knowledge?since=0` → verify response contains `nodes`, `edges`, `server_time`

- [ ] **Step 3: Run Hurl tests**

Run: `cd server && hurl --test test/*.hurl` (adjust path based on step 1)
Expected: All tests pass

- [ ] **Step 4: Commit**

```bash
git add server/test/
git commit -m "test(server): add Hurl tests for sync endpoint changes"
```

---

## Task 12: Full verification + docs cleanup

**Files:**
- Modify: `docs/superpowers/KNOWN_ISSUES.md`
- Modify: `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Verify server builds and tests pass**

Run: `cd server && go build ./... && go test ./...`
Expected: All pass

- [ ] **Step 2: Verify client analyzes clean**

Run: `cd app && flutter analyze lib/`
Expected: No errors

- [ ] **Step 3: Update KNOWN_ISSUES.md**

Mark KI-1, KI-3, KI-4 as resolved. Change each section header prefix from `🟡` / `🟢` to `✅ 已修复`, and add resolution note with date and commit ref.

- [ ] **Step 4: Update PROGRESS.md**

In the "跨层级功能" section and the "已知问题" references, mark KI-1/KI-3/KI-4 as resolved. Add an entry to the "更新记录" section:

```markdown
| 2026-04-04 | **KI-1/KI-3/KI-4 同步缺口修复** ✅：Companion Chat、Margin Notes、Concept Tags/Edges 双向同步完成。Push 侧 book ID 映射修复（KI-4），concept tag ID 映射修复（KI-3）。Server GET 端点增加 delta pull（since + server_time） |
```

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/KNOWN_ISSUES.md docs/superpowers/PROGRESS.md
git commit -m "docs: mark KI-1/KI-3/KI-4 as resolved"
```
