# Layer 3 补全：自动检测难词 + 智能分组

> **日期：** 2026-04-05
> **状态：** Approved
> **关联：** PROGRESS.md Layer 3 两个 ❌ 项

---

## 功能 1：自动检测难词

### 1.1 概述

阅读器 Inline Glossary 的自动模式。用户翻到新章节时，AI 后台扫描章节文本，识别难词，注入淡色虚线下划线高亮。用户点击高亮词即看到已缓存的释义。

受 `CompanionPersonality.annotateHardWords` 开关控制（已有字段，当前未接入逻辑）。

### 1.2 触发机制

- **触发时机：** 章节切换（与 context bar 相同的 `onRelocate` 事件）
- **优先级：** P2（后台），不阻塞阅读
- **去重：** 同一章节只扫描一次，结果缓存在 AI cache（L1 内存 + L2 sqflite）

### 1.3 AI Prompt

新增 `AmbientTaskType.autoGlossary` 和 `AmbientTasks.autoGlossary()` 方法：

```
Identify 5-8 difficult, uncommon, or domain-specific words/phrases in the following text.
For each word, provide a brief definition (1 sentence max).
Format: one per line, word|definition
Only include words that a general reader would likely not know.

Text:
{chapterText}

Reply in {language}.
```

返回格式：`word|definition`，每行一个。

### 1.4 高亮注入

1. AI 返回难词列表后，在 Flutter 侧匹配每个词在章节文本中的位置
2. 通过 JS bridge 调用 `addAnnotation()` 注入高亮，使用特殊类型 `'glossary'`
3. Overlayer 渲染为**淡色虚线下划线**（不是实心高亮），不与用户标注混淆
4. 需要在 `view.js` 的 `draw-annotation` 事件中处理 `type === 'glossary'` 的特殊绘制

### 1.5 点击交互

1. 用户点击虚线下划线词 → 触发 `onAnnotationClick` 事件
2. Flutter 侧根据 annotation type 判断：
   - `type === 'glossary'` → 直接从缓存读取释义，显示 `GlossaryTooltip`（无需二次 AI 调用）
   - 其他类型 → 现有标注行为
3. 释义已在扫描时生成并缓存，点击即显示，零延迟

### 1.6 降级

- AI 不可用 → 不注入任何高亮，阅读体验不受影响
- `annotateHardWords` 关闭 → 跳过扫描
- 网络慢 → 高亮可能在用户读了几秒后才出现（渐入动画）

### 1.7 文件改动

| 文件 | 改动 |
|------|------|
| `service/ai/ambient_tasks.dart` | 新增 `autoGlossary()` 方法 |
| `service/ai/ambient_ai_pipeline.dart` | 新增 `AmbientTaskType.autoGlossary` |
| `page/book_player/epub_player.dart` | `onRelocate` 中触发扫描；注入高亮；处理 glossary annotation click |
| `assets/foliate-js/src/view.js` | `draw-annotation` 处理 `type: 'glossary'` 渲染虚线下划线 |
| `widgets/reader/glossary_tooltip.dart` | 支持从缓存直接显示（不调 AI） |

---

## 功能 2：智能分组（主题聚合）

### 2.1 概述

书架页面的书籍按 AI 检测的主题分组显示，替代当前的纯时间排列。每个主题是一个水平滚动的 `TopicSection`。

### 2.2 分组逻辑

- **数据来源：** 书籍导入时 `post_import_ai.dart` 已通过 `autoTag()` 生成 AI 标签
- **分组方式：** 按最常见的 AI 标签聚合。取 top N 个标签（N = 有 3 本以上书的标签），每个标签一个 TopicSection
- **无需额外 AI 调用** — 复用已有的 autoTag 结果
- **Fallback：** 标签不足时（<3 本书有标签），保持现有"最近添加"+ 全部网格布局

### 2.3 UI 布局

```
[AI 推荐卡]                          ← 已有
[主题: 哲学] ────── 查看全部 →        ← 新增 TopicSection
  📕 📗 📘 📙 (水平滚动)
[主题: 科技] ────── 查看全部 →        ← 新增 TopicSection
  📕 📗 📘 (水平滚动)
[最近添加] ────── 查看全部 →          ← 已有
  📕 📗 📘 📙 📚 (水平滚动)
[全部 (42)] ──────                    ← 已有网格
  📕 📗 📘 📙 📚 📖 ...
```

### 2.4 数据流

1. `library_page.dart` 加载时，从本地 sqflite 查询所有书的 AI 标签
2. 按标签频率排序，取有 ≥3 本书的标签
3. 每个标签渲染一个 `TopicSection`（复用现有组件）
4. 标签查询来自 `concept_tag` 表或书籍的 tag 字段（取决于 autoTag 存储位置）

### 2.5 文件改动

| 文件 | 改动 |
|------|------|
| `page/home/library_page.dart` | 加载主题分组数据，渲染多个 TopicSection |
| `dao/book.dart` 或 `dao/concept_tag.dart` | 查询方法：按标签分组获取书籍 |
| `widgets/library/topic_section.dart` | 无改动（已够用） |

---

## 3. 不改的部分

- 手动 Inline Glossary（选词 → Explain）保持不变
- 现有标注系统不受影响
- 导入流程不变
- 其他 14 语言 ARB 不需要新增 key（本次无新增 UI 文本）

## 4. 测试要点

**自动检测难词：**
- `annotateHardWords` 开启：章节切换后高亮出现
- `annotateHardWords` 关闭：无高亮
- 点击虚线词：释义 tooltip 立即显示（从缓存）
- AI 不可用：无高亮，不报错
- 同一章节切回：使用缓存结果，不重复调 AI

**智能分组：**
- 有 AI 标签的书 ≥3 本：显示主题 TopicSection
- 无标签或标签不足：保持现有布局
- 新书导入后标签生成完成：刷新书架时出现分组
