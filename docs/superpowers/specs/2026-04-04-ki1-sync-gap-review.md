# KI-1/KI-3/KI-4 同步修复设计 — 审阅意见

> **日期：** 2026-04-04
> **审阅对象：** `docs/superpowers/specs/2026-04-04-ki1-sync-gap-design.md`

---

## ✅ 做得好的方面

1. **问题定义准确** — 三个 KI 问题的定位和根因分析都正确
2. **Server Wins 冲突策略** — 与现有 book delta sync 一致，简单可靠
3. **Push 顺序正确** — tags 先于 edges push，保证 ID 映射可用
4. **错误隔离设计合理** — 每类数据独立 try-catch，单类失败不影响其他
5. **Tag ID 映射方案** — 通过服务端返回 `local_id → server_id` 映射解决 KI-3，复用 IdMappingDao，设计合理

---

## 🔴 需要修正的问题

### R-1: 同步流程步骤编号错误

文档 §4.1 写了 8 步（pullAiData 是第 7 步，processOfflineQueue 是第 8 步），但当前 `sync_manager.dart` 实际只有 **6 步**：

```
1. pushBooks → 2. pushAnnotations → 3. pushAiData
4. pullBooks → 5. pullAnnotations → 6. pullProgress + offlineQueue
```

`processOfflineQueue` 并不是独立步骤，它包含在 pullProgress 内部。pullAiData 应该是第 **7** 步，总共 7 步。

**建议：** 更新步骤编号，或在代码中确认 offlineQueue 是否需要拆分为独立步骤。

### R-2: `_lastSyncTimeMs` 是本地时间，存在时钟偏差风险

代码中 `_lastSyncTimeMs` 基于 `DateTime.now()`（设备本地时钟），而非服务端时间。用它作为 `since` 参数发给服务端做 `ctime > since` 过滤：

- 设备时钟**快于**服务端 → 漏拉数据（`since` 值大于服务端记录的 `ctime`）
- 设备时钟**慢于**服务端 → 重复拉数据（有去重兜底，但浪费流量）

**建议：** 服务端在 pull 响应中返回 `server_time`（类似现有 `pushBooks` 批量端点的 `server_time` 字段），客户端存储并使用服务端时间作为下次 `since` 值。

### R-3: 伪代码中 `IdMappingDao.getServerId` 缺少 `await`

§4.3 的 edges push 代码中：

```dart
final sourceServerId = IdMappingDao.getServerId(e.sourceTagId.toString(), 'concept_tag');
```

`getServerId` 是 `async` 方法（返回 `Future<String?>`），在 `.map()` 闭包内未 `await`，实际运行时 `sourceServerId` 会是 `Future` 对象而非 `String?`，导致后续 `== null` 检查永远为 false。

**建议：** 改为 `for` 循环 + `await`，或在 map 前预先批量查询所有映射。

---

## 🟡 建议改进

### S-1: Pull 缺少分页处理

pullAiData 的 companion chat 未使用分页。一本书如果有上千条聊天记录，一次全量拉取可能超时或 OOM。现有 GET 端点已支持 `limit/offset`，建议 pull 也循环分页拉取。

### S-2: CompanionChat 去重键偏弱

文档 §4.4 提出按 `(book_id, role, content, created_at)` 去重。相同内容 + 时间的消息理论上可能存在（用户快速重复发送相同文本）。

**建议：** 优先使用服务端返回的 `id` 字段作为去重键（本地增加 `server_id` 列或通过 IdMappingDao 追踪），content hash 作为兜底。

### S-3: MarginNote 去重应包含 `cfi`

文档写按 `(book_id, chapter, content)` 匹配，但同一章可能有相同内容的笔记在不同位置（不同 `cfi`）。

**建议：** 去重键改为 `(book_id, chapter, cfi, content)`。

### S-4: KNOWN_ISSUES.md 信息过时

KNOWN_ISSUES.md §KI-1 记录 `companion_chat.dart` 的 `getUnsynced()` 未实现，但实际代码中已有实现（第 64-66 行）。实施此设计后应同步更新 KNOWN_ISSUES.md。

---

## 📋 小问题

- §3.1 中 Tags/Edges 都只过滤 `ctime > since` — 经确认服务端 schema 中两者均为 append-only（只有 `ctime`，无 `utime`），过滤条件正确
- §4.1 伪代码中 `IdMappingDao.getAllMappings('book')` 返回 `Map<String, String>`，注释写 `{localId: serverId}`，后面 `int.parse(entry.key)` 把 key 当 localId — 逻辑一致，但类型注释可以更明确
- §4.4 提出新增 `getUnsyncedEdges()` / `markEdgesSynced()`，当前 `concept_tag.dart` 确实缺这两个方法，但 edge 表已有 `synced` 字段，实现可行。§5 的"无新 DB 版本"结论正确

---

## 总结

| 类别 | 数量 | 阻塞实施？ |
|------|------|------------|
| 🔴 需要修正 | 3 | R-2（时钟偏差）和 R-3（async bug）会导致运行时错误 |
| 🟡 建议改进 | 4 | 不阻塞，但 S-1（分页）建议在实施时一并处理 |
| 📋 小问题 | 3 | 不阻塞 |

设计方向正确，可以作为实施依据。建议优先修正 **R-2（时钟偏差）** 和 **R-3（async bug）**，修正后可进入实施阶段。
