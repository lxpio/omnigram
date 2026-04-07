# Layer 5：跨书连接设计

> **日期：** 2026-04-07
> **状态：** Approved
> **关联：** PROGRESS.md Layer 5, 设计文档 §6.1 Layer 3, 审核建议 #1

---

## 1. 概述

洞察页 Layer 3 补全：展示跨书主题关联 + "Record my thought" 思考日记。

**原则（审核建议 #1）：** 只展示主题关联，不做认知推断。AI 说"这两本书都讨论了X"，不说"你的想法变了"。

## 2. 功能 A：跨书发现列表

### 2.1 UI 位置

在 `KnowledgeGraphCard` 下方新增一个"跨书发现"section。每条发现是一张卡片：

```
┌─────────────────────────────────────┐
│ 📖 《量子力学导论》 ↔ 📖 《信息论》  │
│                                     │
│ "量子纠缠" ↔ "信息传递"             │
│ 两者都探讨了信息在物理系统中的角色    │
│                                     │
│ 权重: ●●●●○  [记录想法]             │
└─────────────────────────────────────┘
```

### 2.2 数据来源

- 从 `ConceptEdge` 表读取所有 edges
- 通过 `sourceTagId`/`targetTagId` 关联到 `ConceptTag`，获取概念名 + bookId
- 通过 bookId 关联到 `Book`，获取书名
- 只显示**跨书**的 edge（sourceTag.bookId ≠ targetTag.bookId）
- 按 weight 降序排列

### 2.3 实现

- 新建 `widgets/insights/cross_book_card.dart` — 单条跨书发现卡片
- 修改 `page/home/insights_page.dart` — 在知识网络卡片后加载并渲染跨书发现列表
- 无需新 AI 调用 — 复用已有的 `ConceptEdge` 数据

### 2.4 空状态

- 无跨书连接（只有 1 本书有标签，或无 edge）→ 不显示该 section
- 需要 2+ 本书有 AI 标签才能出现跨书发现

## 3. 功能 B：Record My Thought（思考日记）

### 3.1 概述

用户主动记录对某个主题/关联的想法。独立于 AI 数据，是用户自己的思考轨迹。形成时间线式的 intellectual journal。

### 3.2 数据模型

新建 `tb_thoughts` 表（sqflite DB version bump）：

```sql
CREATE TABLE tb_thoughts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  concept_name TEXT,          -- 关联的概念名（可选）
  book_id INTEGER,            -- 关联的书（可选）
  edge_id INTEGER,            -- 关联的跨书连接（可选）
  created_at TEXT NOT NULL,
  synced INTEGER DEFAULT 0
);
```

模型简单：一条 thought 可以独立存在，也可以关联到概念/书/连接。

### 3.3 入口

两个入口：
1. **跨书发现卡片上的"记录想法"按钮** — 预填关联的 concept_name 和 edge_id
2. **洞察页底部的 FAB "✏️"** — 独立记录，不关联任何概念

### 3.4 输入 UI

点击后弹出 bottom sheet，包含：
- 文本输入框（多行，placeholder: "记录你的想法..."）
- 如果有关联概念，显示一个小标签（如 "关于：量子纠缠 ↔ 信息传递"）
- "保存"按钮

### 3.5 展示

洞察页新增"我的思考"section（在跨书发现下方）：
- 按时间倒序展示
- 每条显示：内容 + 关联概念标签（如有）+ 日期
- 简洁卡片式，类似笔记列表

### 3.6 空状态

无思考记录 → 不显示该 section（依赖现有空状态系统引导）

## 4. 文件改动

| 文件 | 改动 |
|------|------|
| 新建 `widgets/insights/cross_book_card.dart` | 跨书发现卡片 widget |
| 新建 `dao/thought.dart` | Thought 模型 + ThoughtDao |
| 新建 `widgets/insights/thought_card.dart` | 思考日记卡片 |
| 新建 `widgets/insights/record_thought_sheet.dart` | 记录想法的 bottom sheet |
| 修改 `page/home/insights_page.dart` | 加载跨书发现 + 思考日记，FAB |
| 修改 `dao/database.dart` | DB version bump，创建 tb_thoughts 表 |
| 修改 `l10n/app_en.arb` + `app_zh-CN.arb` | 新增 L10n keys |

## 5. L10n Keys

```
insightsCrossBookDiscoveries — "Cross-book Discoveries"
insightsCrossBookReason — "{concept1} ↔ {concept2}"
insightsRecordThought — "Record a thought"
insightsMyThoughts — "My Thoughts"
insightsThoughtPlaceholder — "Record your thought..."
insightsThoughtAbout — "About: {topic}"
insightsSave — "Save"
```

## 6. 不改的部分

- KnowledgeGraphCard 本身不修改（图可视化保持原样）
- ConceptExtractor 不修改（已有 findConnections）
- MarginNote 不修改（阅读器内的跨书提示已有）
- 不做认知推断

## 7. 测试要点

- 2+ 本书有 AI 标签 + edges → 跨书发现列表出现
- 只有同书 edges → 不显示跨书 section
- 点击"记录想法" → bottom sheet 弹出，保存后出现在"我的思考"
- FAB 记录 → 无关联概念的独立想法
- DB upgrade 正确创建 tb_thoughts 表
