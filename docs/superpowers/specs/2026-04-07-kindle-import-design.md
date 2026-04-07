# 外部高亮导入：Kindle My Clippings.txt

> **日期：** 2026-04-07
> **状态：** Approved
> **关联：** PROGRESS.md 跨层级功能 — 外部高亮导入 §10.9

---

## 1. 概述

导入 Kindle `My Clippings.txt` 文件中的高亮和笔记，关联到 Omnigram 书库已有书籍。

## 2. My Clippings.txt 格式

```
书名 (作者)
- 您在位置 #123-125 的标注 | 添加于 2024年1月15日 星期一 下午3:42:18

高亮文本内容

==========
```

- 分隔符：`==========`
- 第一行：书名 + 作者（括号内）
- 第二行：类型（标注/笔记/书签）+ 位置 + 时间
- 第三行起：内容（可多行）
- 类型关键词（多语言）：Highlight/标注/ハイライト、Note/笔记/メモ、Bookmark/书签/ブックマーク

## 3. 解析逻辑

1. 按 `==========` 分割为条目
2. 每条提取：书名、作者、类型、位置、时间、内容
3. 跳过 Bookmark 类型，只保留 Highlight 和 Note
4. 按书名分组

## 4. 书籍匹配

- 按书名与 Omnigram 书库做模糊匹配（`title.toLowerCase().contains()` 或 Levenshtein 距离）
- 匹配成功 → 导入高亮为 `BookNote`（type='highlight'，无 CFI）
- 未匹配 → 跳过（toast 提示有 N 条未匹配）

简化处理：不做手动关联 UI，第一版只做自动匹配。

## 5. 导入为 BookNote

```dart
BookNote(
  bookId: matchedBook.id,
  content: clipContent,        // 高亮文本
  readerNote: noteContent,     // 如果紧跟着一条 Note，合并为 readerNote
  type: 'highlight',
  chapter: '',                 // Kindle 无章节信息
  cfi: '',                     // 无法映射
  color: 'FFF9A825',          // 默认黄色（Kindle 风格）
  createTime: parsedTime,
  updateTime: parsedTime,
)
```

去重：按 (bookId, content) 检查是否已存在，避免重复导入。

## 6. 入口

设置页"数据"区块的导出 bottom sheet 中新增一个"导入 Kindle 高亮"选项。

## 7. 文件改动

| 文件 | 改动 |
|------|------|
| 新建 `service/import/kindle_import.dart` | 解析 + 匹配 + 导入 |
| 修改 `page/home/settings_page.dart` | sheet 加导入选项 |
| 修改 L10n ARB | 新增 key |

## 8. L10n Keys

- `importKindleHighlights` — "Import Kindle highlights"
- `importKindleDesc` — "From My Clippings.txt"
- `importKindleSuccess` — "Imported {count} highlights from {books} books"
- `importKindleNoMatch` — "{count} highlights skipped (no matching book)"
- `importKindleEmpty` — "No highlights found in file"

## 9. 不做的

- 不导入书签
- 不做 CFI 精确定位（Kindle 位置号无法映射到 EPUB CFI）
- 不创建新书（只关联已有书）
- 不做手动关联 UI（第一版自动匹配）
- 不做 Readwise / Apple Books（后续扩展）

## 10. 测试要点

- 标准 My Clippings.txt 解析正确（中文、英文、日文书名）
- 高亮+笔记合并（相邻的 Highlight+Note 合并为一条带 readerNote 的 BookNote）
- 书名匹配：完全匹配 + 部分匹配
- 重复导入不产生重复记录
- 空文件 / 无高亮 → 提示"无高亮"
- 无匹配书 → 提示跳过数量
