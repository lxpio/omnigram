# KI-1/KI-3/KI-4 修复：Sprint 4 AI 数据双向同步

> **日期：** 2026-04-04
> **状态：** Draft
> **关联：** `docs/superpowers/KNOWN_ISSUES.md` KI-1, KI-3, KI-4

---

## 1. 问题概述

Sprint 4 新增的三类 AI 数据（Companion Chat、Margin Notes、Concept Tags/Edges）仅有 push（客户端→服务端）逻辑，缺少 pull（服务端→客户端）方向。多设备用户在新设备上看不到这些数据。

附带问题：
- **KI-4：** Push 时用本地 int book_id 拼 URL，服务端期望 char(24) server ID
- **KI-3：** Concept edges 的 source_id/target_id 引用本地 autoincrement ID，push 到服务端后无法关联

## 2. 设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 冲突策略 | **Server Wins** | 与 Immich 一致，服务端为单一事实源，简单可靠 |
| Pull 方式 | **Delta Pull**（`since` 参数） | 增量拉取，与现有 book delta sync 模式一致 |
| Edge ID 解析 | **服务端返回 tag ID 映射** | push tags 后拿到 local→server ID 映射，用于 edges push |

## 3. 服务端改动

### 3.1 GET 端点加 `since` 参数

**GET `/reader/books/:id/companion/chat`**
- 新增可选查询参数 `since`（int64 毫秒时间戳）
- 过滤条件：`ctime > since`（聊天不可编辑，只有 ctime）
- 其余行为不变（limit/offset 分页）

**GET `/reader/books/:id/margin-notes`**
- 新增可选查询参数 `since`（int64 毫秒时间戳）
- 过滤条件：`utime > since`
- 其余行为不变（chapter 过滤、dismissed 过滤）

**GET `/reader/knowledge`**
- 新增可选查询参数 `since`（int64 毫秒时间戳）
- Tags 过滤：`ctime > since`
- Edges 过滤：`ctime > since`
- 其余行为不变（book_id 过滤）

### 3.2 POST `/reader/knowledge/tags` 返回 ID 映射

当前返回：
```json
{"status": "ok"}
```

改为返回：
```json
{
  "status": "ok",
  "mappings": [
    {"local_id": 1, "server_id": 42},
    {"local_id": 2, "server_id": 43}
  ]
}
```

实现方式：
- 客户端 payload 每个 tag 带 `local_id` 字段（即本地 autoincrement ID）
- 服务端 upsert 后，将 local_id 和实际 server ID 配对返回
- 客户端缓存映射用于后续 edges push

## 4. 客户端改动

### 4.1 SyncManager 新增 `_pullAiData()`

插入同步流程第 7 步（pullProgress 之后、processOfflineQueue 之前）：

```
sync flow:
  1. pushBooks
  2. pushAnnotations
  3. pushAiData
  4. pullBooks
  5. pullAnnotations
  6. pullProgress
  7. pullAiData        ← 新增
  8. processOfflineQueue
```

伪代码：

```dart
Future<void> _pullAiData() async {
  final since = _lastSyncTimeMs;
  final books = await IdMappingDao.getAllMappings('book');
  // books: {localId: serverId}

  for (final entry in books.entries) {
    final localBookId = int.parse(entry.key);
    final serverId = entry.value;

    // 1. Pull companion chat
    try {
      final chats = await api.get(
        '/reader/books/$serverId/companion/chat',
        queryParams: {'since': since},
      );
      for (final chat in chats) {
        await companionChatDao.insertIfNotExists(
          CompanionMessage.fromServerJson(chat, localBookId),
        );
      }
    } catch (e) {
      debugPrint('[SyncManager] Pull companion chat for $serverId: $e');
    }

    // 2. Pull margin notes
    try {
      final notes = await api.get(
        '/reader/books/$serverId/margin-notes',
        queryParams: {'since': since},
      );
      for (final note in notes) {
        await marginNoteDao.upsertFromServer(
          MarginNote.fromServerJson(note, localBookId),
        );
      }
    } catch (e) {
      debugPrint('[SyncManager] Pull margin notes for $serverId: $e');
    }
  }

  // 3. Pull concept tags + edges (all books at once)
  try {
    final graph = await api.get(
      '/reader/knowledge',
      queryParams: {'since': since},
    );
    final serverTagIdToLocalId = <int, int>{};

    for (final tag in graph['nodes']) {
      final serverBookId = tag['book_id'] as String;
      final localBookId = await IdMappingDao.getLocalId(serverBookId, 'book');
      if (localBookId == null) continue;

      final localId = await conceptTagDao.insertTagIfNotExists(
        ConceptTag.fromServerJson(tag, int.parse(localBookId)),
      );
      serverTagIdToLocalId[tag['id'] as int] = localId;
    }

    for (final edge in graph['edges']) {
      final localSourceId = serverTagIdToLocalId[edge['source_id']];
      final localTargetId = serverTagIdToLocalId[edge['target_id']];
      if (localSourceId == null || localTargetId == null) continue;

      await conceptTagDao.insertEdgeIfNotExists(
        ConceptEdge.fromServerJson(edge, localSourceId, localTargetId),
      );
    }
  } catch (e) {
    debugPrint('[SyncManager] Pull knowledge graph: $e');
  }
}
```

### 4.2 Push 侧 Book ID 修复（KI-4）

修改 `_pushAiData()` 中所有用本地 book_id 拼 URL 的地方：

```dart
// Before:
await api.postVoid('/reader/books/${entry.key}/companion/chat', ...);

// After:
final serverId = await IdMappingDao.getServerId(entry.key.toString(), 'book');
if (serverId == null) continue; // 书还没同步
await api.postVoid('/reader/books/$serverId/companion/chat', ...);
```

同理修改 margin notes push 和 concept tags payload 中的 book_id 字段。

### 4.3 Push 侧 Tag ID 修复（KI-3）

Concept edges push 流程改为：

```dart
// 1. Push tags，拿到 ID 映射
final tags = await conceptDao.getUnsynced();
if (tags.isNotEmpty) {
  // payload 每个 tag 带 local_id
  final tagMaps = tags.map((t) {
    final m = t.toMap();
    m['local_id'] = t.id;
    m['book_id'] = serverBookIdMap[t.bookId]; // 转换 book_id
    return m;
  }).toList();

  final resp = await api.post('/reader/knowledge/tags', data: tagMaps);
  final mappings = resp['mappings'] as List;

  // 缓存 tag ID 映射
  for (final m in mappings) {
    await IdMappingDao.upsert(
      m['local_id'].toString(),
      m['server_id'].toString(),
      'concept_tag',
    );
  }

  await conceptDao.markSynced(...);
}

// 2. Push edges，用映射后的 server tag ID
final edges = await conceptDao.getUnsyncedEdges();
if (edges.isNotEmpty) {
  final edgeMaps = edges.map((e) {
    final sourceServerId = IdMappingDao.getServerId(e.sourceTagId.toString(), 'concept_tag');
    final targetServerId = IdMappingDao.getServerId(e.targetTagId.toString(), 'concept_tag');
    if (sourceServerId == null || targetServerId == null) return null;
    return {
      'source_id': int.parse(sourceServerId),
      'target_id': int.parse(targetServerId),
      'weight': e.weight,
      'reason': e.reason,
    };
  }).whereType<Map>().toList();

  if (edgeMaps.isNotEmpty) {
    await api.postVoid('/reader/knowledge/edges', data: edgeMaps);
    await conceptDao.markEdgesSynced(...);
  }
}
```

### 4.4 DAO 新增方法

**CompanionChatDao:**
```dart
/// 按 (book_id, role, content, created_at) 去重 insert，synced=1
Future<void> insertIfNotExists(CompanionMessage msg);

/// 从服务端 JSON 构造（book_id 用本地 ID）
static CompanionMessage fromServerJson(Map<String, dynamic> json, int localBookId);
```

**MarginNoteDao:**
```dart
/// 按 (book_id, chapter, content) 匹配
/// 不存在则 insert（synced=1），存在则更新 dismissed/helpful/confidence（Server Wins）
Future<void> upsertFromServer(MarginNote note);

/// 从服务端 JSON 构造（book_id 用本地 ID）
static MarginNote fromServerJson(Map<String, dynamic> json, int localBookId);
```

**ConceptTagDao:**
```dart
/// 按 (book_id, name, note_id) 去重 insert（synced=1），返回 local ID
Future<int> insertTagIfNotExists(ConceptTag tag);

/// 按 (source_tag_id, target_tag_id) 去重 insert（synced=1）
Future<void> insertEdgeIfNotExists(ConceptEdge edge);

/// 获取未同步的 edges
Future<List<ConceptEdge>> getUnsyncedEdges();

/// 标记 edges 已同步
Future<void> markEdgesSynced(List<int> ids);

/// 从服务端 JSON 构造
static ConceptTag fromServerJson(Map<String, dynamic> json, int localBookId);
static ConceptEdge fromServerJson(Map<String, dynamic> json, int localSourceId, int localTargetId);
```

## 5. 不改动的部分

- **无新 DB 版本** — 不新增表或字段，现有 `synced` 字段已够用
- **无新依赖** — 复用 OmnigramApi、IdMappingDao
- **服务端 schema 不变** — ConceptTag/Edge 不加 `utime`（append-only，`ctime` 足够）
- **CompanionChat 服务端 schema 不变** — 不可编辑，`ctime` 即可

## 6. 测试要点

- Push 时跳过无 server mapping 的书（不报错）
- Pull 去重：同一条数据拉两次不产生重复
- Margin Notes Server Wins：服务端 dismissed=true 覆盖本地 dismissed=false
- Concept edges 的 tag ID 映射正确性
- 单类数据 push/pull 失败不影响其他类
- 无服务端连接时整个 pullAiData 被跳过
