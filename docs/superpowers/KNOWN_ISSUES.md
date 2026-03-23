# Omnigram Known Issues

> **最后更新：2026-03-23**
> **来源：Sprint 4 代码审查**

---

## 🟡 数据同步缺口

### KI-1: Sprint 4 新数据无 Server 同步逻辑

**影响范围：** Companion Chat、Margin Notes、Concept Tags

**现状：**
- 三个 DAO 都有 `synced` 标记字段（sqflite），Server 也有对应的 CRUD endpoints
- 但没有实际的同步调用代码——`SyncManager` 未扩展来处理这些新表
- 数据目前仅存在于本地 sqflite，多设备用户会丢失这些数据

**客户端 DAO：**
- `dao/companion_chat.dart` — `synced` 字段存在，`getUnsynced()` 未实现
- `dao/margin_note.dart` — `synced` 字段存在
- `dao/concept_tag.dart` — `synced` 字段存在，`getUnsynced()` + `markSynced()` 已实现

**Server endpoints（已就绪）：**
- `POST /reader/books/:id/companion/chat` — 批量上传聊天
- `POST /reader/books/:id/margin-notes` — 批量上传边注
- `POST /reader/knowledge/tags` — 批量上传概念标签
- `POST /reader/knowledge/edges` — 批量上传概念关联

**修复方案：** 扩展 `service/sync/sync_manager.dart`，参照现有 annotation 同步模式，增加三类数据的双向增量同步。

**优先级：** Sprint 5

---

## 🟡 国际化缺口

### KI-2: AI Prompt 和 UI 文本硬编码中文

**影响范围：** 知识网络、概念提取、伴侣面板

**现状：**
- `widgets/insights/knowledge_graph_card.dart` — 卡片标题"知识网络"、AI prompt 硬编码中文
- `service/ai/concept_extractor.dart` — 概念提取和关联发现的 prompt 硬编码中文
- `widgets/reader/companion_panel.dart` — Quick prompts（"总结这一章"等）硬编码中文

**修复方案：**
1. UI 文本移入 L10n ARB 文件
2. AI prompt 根据用户语言偏好动态选择（或始终用英文 prompt + 指定输出语言）

**优先级：** Sprint 5（随 L10n 统一处理）

---

## 🟢 性能优化

### KI-3: 概念提取使用本地 SQLite ID 作为 AI 交互标识

**影响范围：** `service/ai/concept_extractor.dart`

**现状：**
- `findConnections()` 方法将本地 sqflite autoincrement ID 放入 AI prompt（`[ID:${t.id}]`）
- AI 返回的 `sourceID|targetID` 是本地 ID，如果数据同步到 server，ID 不匹配

**修复方案：** 同步时使用 name+bookId 作为匹配键，而非依赖本地 ID；或在 prompt 中使用 UUID/name 替代 autoincrement ID。

**优先级：** 与 KI-1 同步修复时一并处理

---

## 🟢 客户端 Book ID 类型差异

### KI-4: Client Book ID (int) vs Server Book ID (string char(24))

**影响范围：** 所有 Sprint 4 新 DAO

**现状：**
- Client sqflite 中 `book_id` 为 `INTEGER`
- Server PG 中 `book_id` 为 `char(24)` string
- 现有 `SyncManager` 用 `book.id.toString()` 做转换，但新增的 DAO 没有接入这套转换逻辑

**修复方案：** 在 KI-1 同步逻辑实现时统一处理 ID 映射。

**优先级：** 与 KI-1 一并处理

---

## 更新记录

| 日期 | 更新 |
|------|------|
| 2026-03-23 | 初始创建，记录 Sprint 4 代码审查遗留问题 |
