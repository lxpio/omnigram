# 数据导出设计

> **日期：** 2026-04-05
> **状态：** Approved
> **关联：** PROGRESS.md 跨层级功能 — 数据导出/迁移 §10.9

---

## 1. 概述

两个导出功能：全库笔记 Markdown + 知识网络 JSON。入口在设置页新增"数据"分区。

## 2. 功能 1：全库笔记导出（Markdown）

### 输出格式

```markdown
# Omnigram Notes Export
> Exported on 2026-04-05

---

# 书名 — 作者

## 章节标题

> 高亮文本内容

用户笔记（如果有）

> 另一段高亮

---

# 另一本书 — 作者

## 章节一

> 高亮内���

...
```

### 实现

- 查询所有非删除书籍的笔记（`BookNoteDao.selectBookNotesByBookId` 循环所有书）
- 按书分组，每书按章节分组
- 复用现有 `export_notes.dart` 的 Markdown 格式化逻辑
- 写入 Downloads 文件夹：`omnigram_notes_YYYYMMDD.md`
- 导出后 toast 提示文件路径

### 跳过

- 无笔记的书不出现在导出中
- 空库提示"无笔记可导出"

## 3. 功能 2：知识网络导出（JSON）

### 输出格式

```json
{
  "exported_at": "2026-04-05T12:00:00Z",
  "nodes": [
    { "name": "量子纠缠", "book": "量子力学导论", "source": "原文片段" }
  ],
  "edges": [
    { "source": "量子纠缠", "target": "信息论", "weight": 0.8, "reason": "量子信息传递" }
  ]
}
```

### 实现

- 从 `ConceptTagDao.getAll()` 获取所有 tags
- 从 `ConceptTagDao.getAllEdges()` 获取所有 edges
- 通�� tag ID 解析 edge 的 source/target 为 name
- 通过 bookId 关联书名
- 写入 Downloads：`omnigram_knowledge_YYYYMMDD.json`

## 4. 设置页入��

在设置页添加"数据"分区（或加入现有分区）：

```
📦 数据
  ├─ 导出全部笔记    [Markdown]
  └─ 导出知识网络    [JSON]
```

## 5. 文件改动

| 文件 | 改动 |
|------|------|
| 新建 `service/export/data_export.dart` | 全库笔记 + 知识网络导出逻辑 |
| 修改 `page/home/settings_page.dart` | 新增"数据"分区 + 两个导出按钮 |
| 修改 `l10n/app_en.arb` + `app_zh-CN.arb` | 新增导出相关 L10n key |

## 6. 不改的部分

- 现有单书笔记导出（`export_notes.dart`）不修改
- 无需服务端改动
- 不做导入功能（Kindle/Readwise 留后续）

## 7. 测试要点

- 有笔记 → 导出 Markdown 文件包含所有书所有笔记
- 无笔记 → toast 提示"无笔记可导出"
- 有知识网络 → JSON 包含 nodes + edges，name 字段正确
- 无知识网络 → toast 提示"无知识数据"
- 文件成功写入 Downloads 目录
