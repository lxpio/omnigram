# KI-2 批次 A：AI Prompt 国际化

> **日期：** 2026-04-05
> **状态：** Approved
> **关联：** `docs/superpowers/KNOWN_ISSUES.md` KI-2

---

## 1. 问题概述

3 个文件中的 AI prompt 硬编码中文，导致非中文用户收到中文 AI 输出。

## 2. 设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| Prompt 语言 | **英文** | LLM 对英文理解最准确 |
| 输出语言 | **跟随用户设置** | 末尾加 `Reply in {language}.` |
| 语言来源 | **CompanionPersonality.languageCode** | 已有基础设施，fallback 为设备 locale |

## 3. 改动清单

### 3.1 `widgets/insights/knowledge_graph_card.dart`（L58-64）

知识网络叙事 prompt，当前中文：
```
基于以下知识概念和它们的关联，用2-3句话描述阅读者的知识网络特征。
语气像一个聪明的朋友在总结你的阅读收获。突出跨书的有趣连接。
...请用自然的中文叙述
```

改为英文 + 动态语言：
```
Based on the following concepts and their connections, describe the reader's knowledge network in 2-3 sentences.
Use the tone of a smart friend summarizing reading insights. Highlight interesting cross-book connections.
...Reply in {language}.
```

### 3.2 `service/ai/concept_extractor.dart`（L30-38）

概念提取 prompt，当前中文：
```
从以下书籍"$bookTitle"的高亮和笔记中，提取关键概念标签。
每个概念用一行表示，格式为: 概念名称|来源文本片段
...请直接输出概念列表，每行一个，格式: 概念|来源
```

改为英文 + 动态语言：
```
From the following highlights and notes of the book "$bookTitle", extract key concept tags.
One concept per line, format: concept name|source text snippet
Only extract meaningful concepts (people, theories, methods, core ideas), not common words.
Extract at most 10 of the most important concepts.
...Output the concept list directly, one per line, format: concept|source
Reply in {language}.
```

### 3.3 `service/ai/concept_extractor.dart`（L74-81）

关联发现 prompt，当前中文：
```
以下是从多本书中提取的概念标签。请找出跨书的概念关联。
每个关联用一行表示，格式: 源ID|目标ID|权重(0.1-1.0)|关联原因
只找出真正有意义的跨书关联，最多5个。
...请直接输出关联列表
```

改为英文 + 动态语言：
```
The following are concept tags extracted from multiple books. Find cross-book concept connections.
One connection per line, format: sourceID|targetID|weight(0.1-1.0)|reason
Only find truly meaningful cross-book connections, at most 5.
...Output the connection list directly.
Reply in {language}.
```

### 3.4 附带清理

- `concept_extractor.dart` L24 中的 `' (笔记: ${n.readerNote})'` 改为 `' (note: ${n.readerNote})'`

## 4. 语言获取

从 `CompanionPersonality` 读取 `languageCode`，转为语言名称。已有 `companion_prompt.dart` 的 `languageMap` 可复用。

```dart
String getReplyLanguage() {
  final langCode = companionPersonality.languageCode;
  if (langCode != null && langCode.isNotEmpty) {
    return languageMap[langCode] ?? 'English';
  }
  final locale = Platform.localeName.split('_').first;
  return languageMap[locale] ?? 'English';
}
```

`knowledge_graph_card.dart` 和 `concept_extractor.dart` 需要能访问到这个语言信息。两个文件都已经是 Riverpod widget/service，可通过 provider 获取 companion personality。

## 5. 不改的部分

- `companion_prompt.dart` L24-30 的 preview 示例文案 — 留给批次 B（UI 文本 L10n）
- `companion_panel.dart` L301 的 quick prompts — 留给批次 B
- UI 文本（页面标题、按钮等） — 留给批次 B

## 6. 测试要点

- 默认语言（中文设备）：AI 输出为中文
- 切换 companion 语言为英文：AI 输出为英文
- 无 companion 配置时：fallback 到设备 locale
- 概念提取的结构化输出格式不被语言指令破坏（`concept|source` 格式保持）
