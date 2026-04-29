# Omnigram Known Issues

> **最后更新：2026-04-04**
> **来源：Sprint 4 代码审查**

---

## ✅ 已修复 — 数据同步缺口

### KI-1: Sprint 4 新数据无 Server 同步逻辑

**影响范围：** Companion Chat、Margin Notes、Concept Tags

**修复（2026-04-04）：**
- SyncManager 新增 `_pullAiData()` 步骤，实现 Server→Client 增量拉取
- Push 侧修复 book ID 映射（使用 IdMappingDao 转换本地 int → 服务端 char(24)）
- 服务端 GET 端点增加 `since` 参数 + `server_time` 响应字段
- 冲突策略：Server Wins
- **设计文档：** `docs/superpowers/specs/2026-04-04-ki1-sync-gap-design.md`

---

## ✅ 已修复 — 国际化缺口

### KI-2: AI Prompt 和 UI 文本硬编码中文

**修复（2026-04-05）：**

**批次 A — AI Prompt 国际化：**
- 3 处 AI prompt 改为英文 + `Reply in {language}` 动态语言后缀
- 新增 `service/ai/ai_language.dart` — 共享语言检测 helper

**批次 B — UI 文本 L10n：**
- ~50 个硬编码中文字符串移入 L10n ARB 文件（16 语言）
- 覆盖 16 个源文件：desk widgets、insights widgets、library widgets、pages、companion settings/panel
- 新增英文和中文 ARB key，其他 14 语言 fallback 到英文

---

## ✅ 已修复 — 概念提取 ID 问题

### KI-3: 概念提取使用本地 SQLite ID 作为 AI 交互标识

**影响范围：** `service/ai/concept_extractor.dart`

**修复（2026-04-04）：** 同步时通过 IdMappingDao 维护 local tag ID → server tag ID 映射。Push tags 后服务端返回 `[{local_id, server_id}]` 映射，edges push 使用映射后的 server tag ID。随 KI-1 一并修复。

---

## ✅ 已修复 — Book ID 类型差异

### KI-4: Client Book ID (int) vs Server Book ID (string char(24))

**影响范围：** 所有 Sprint 4 新 DAO

**修复（2026-04-04）：** Push 侧所有 URL 和 payload 中的 book_id 均通过 `IdMappingDao.getServerId()` 转换。无 server mapping 的书跳过同步。随 KI-1 一并修复。

---

---

## 🟡 待办 — Now-Playing UX

### ✅ KI-5: Now-Playing 章节按钮接 AudiobookPage（已修复 2026-04-29）

**修复：** 改用 `DraggableScrollableSheet` 内嵌章节列表 — 直接复用 `audiobookProvider(bookId)` 的数据，不需要 Book 引用。当前章高亮 + ChapterStatusDot 显示就绪/生成中/未生成状态，tap 章节调 `jumpToChapter`（新增到 controller）。`app/lib/widgets/tts/now_playing_utility_row.dart`。

### KI-6: 阅读器"跟读模式"入口缺失

**影响范围：** Sprint 8 Plan 2

**现状：** Plan 2 把阅读器底部耳机图标、书详情"听书"、AudiobookPage 章节 ▶ 三处都重定向到 Now-Playing 之后，`SyncListeningPage`（Sprint 7 的 EPUB+音频同步页）已无可达入口。

**待做：** 阅读器顶栏菜单或 Now-Playing 页面里加"跟读模式"按钮 → `SyncListeningPage`。

**优先级：** 低。是次要使用模式。

---

## 更新记录

| 日期 | 更新 |
|------|------|
| 2026-04-28 | 新增 KI-5（Now-Playing 章节按钮 → AudiobookPage）+ KI-6（跟读模式入口） |
| 2026-04-04 | KI-1/KI-3/KI-4 已修复：AI 数据双向同步完成 |
| 2026-03-23 | 初始创建，记录 Sprint 4 代码审查遗留问题 |
