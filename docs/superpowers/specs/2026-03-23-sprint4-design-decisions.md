# Sprint 4 设计决策讨论记录

> **日期：2026-03-23**
> **状态：讨论中**
> **参与者：创始人 + AI 助手**
> **前置：** Sprint 1-3 + Sprint 3.5（同步架构）已完成

---

## 背景

Sprint 4 目标是 Layer 4（深度 AI），包含 5 大功能。在开始实施前，发现 PROGRESS.md 中的计划和实际代码状态有 5 个不一致点，需要逐个确认设计方案。

---

## 不一致 1：知识网络（Knowledge Network）技术方案

### 问题

设计文档（§6.1 Layer 2）写的是"交互式知识图谱：节点是概念，边是关联"。审核报告建议"用 tag-based 聚合，不用图数据库"。但当前：
- Server 只有基础 `BookTagShip`（book ↔ tag 多对多），没有"概念节点"或"笔记-概念关联"
- Client 没有任何图可视化代码

### 讨论过程

1. 最初提出两个方案：A（分组列表）vs B（tag 关联图可视化）
2. 创始人指出：**AI 编码时代不考虑工作量，只考虑先做什么后做什么**
3. 进一步讨论后，以乔布斯视角重新审视用户痛点：
   - 用户真正的痛点："我读了 50 本书，做了 300 条笔记，但它们是一盘散沙。我想知道我的阅读之间有什么联系。"
   - 传统知识图谱让用户自己去解读节点和连线，把理解的工作推给了用户，违反"AI 是空气"哲学
   - 更好的方式：**AI 直接告诉你联系**，不需要用户去独立页面"浏览知识图谱"
4. 创始人认同"AI 直接告诉联系"的思路，但指出**图也要做，关键是图怎么体现 AI 叙事**

### ✅ 决策：AI 叙事驱动的动态图

**图不是让用户自己探索的知识图谱，而是 AI 叙事的可视化注脚：**
- AI 先生成叙事："你这个月在量子力学和认知科学之间建立了有趣的桥梁"
- 图作为叙事的可视化注脚——高亮显示 AI 提到的那几个节点和连线，其余节点灰化
- 用户点击叙事中的关键词，图自动聚焦到对应区域
- 图不是入口，是 AI 叙事的展示媒介

**依赖链：** concept tag 管道 → AI 叙事引擎升级 → 图组件作为叙事注脚

---

## 不一致 2：Margin Notes 跨书关联的搜索方案

### 问题

设计文档说 Margin Notes 需要"跨书向量搜索"才能找到关联。但 Server 没有 embedding/向量搜索能力。

### 讨论过程

1. 最初提出 FTS5 全文搜索 vs embedding 向量搜索
2. 创始人询问业界顶级方案
3. 介绍了三层方案：关键词匹配 → 语义搜索 → 混合搜索
4. 创始人提到 Immich 使用 `postgres:14-vectorchord0.4.3-pgvectors0.2.0`
5. 讨论了 pgvector/pgvecto.rs/VectorChord 的区别和适用场景
6. 分析了 Omnigram vs Immich 的数据量差异（笔记几千条 vs 照片几十万张）

### ✅ 决策：统一 PG + pgvector，放弃 Server SQLite 模式

**数据库架构重大变更：**
- **Server 端统一使用 PostgreSQL + pgvector**（不再支持 SQLite 作为 Server 数据库）
- Client 本地仍用 sqflite（不受影响）
- docker-compose 默认使用带 pgvector 扩展的 PG 镜像（类似 Immich）

**搜索分层自适应：**

| 用户配置 | 搜索方案 | 说明 |
|---|---|---|
| **无 embedding API** | PG tsvector 全文搜索 | PG 内置，零额外依赖（不是 SQLite FTS5） |
| **有 AI API（OpenAI/Ollama）** | pgvector 向量搜索 | embedding 由 AI API 生成，存入 pgvector |

**Embedding 来源说明：**
- embedding 提供方和 LLM 提供方往往是同一个（OpenAI 既提供 chat 也提供 embedding）
- 用户配了 AI 就自然有 embedding 能力，无需额外配置
- Server 启动时自动检测 AI 配置，选择最优搜索方案

**影响范围：**
1. Server 放弃 SQLite 模式 → 移除 SQLite 驱动和初始化代码
2. docker-compose 加 PG + pgvector 容器
3. GORM 配置切换为 PG only
4. Server schema 可用 PG 特有功能（JSONB、pgvector、tsvector 等）

---

## 不一致 3：两套同步并存的冲突风险

### 问题

当前 SyncManager（REST API）和 WebDAV syncProvider 同时运行，没有协调。两者都可能触发自动同步。

### 讨论过程

1. 提出三个方案：A（互斥）、B（并存+锁）、C（职责分离）
2. 创始人直接决定：**不要 WebDAV，完全丢弃这个功能**

### ✅ 决策：完全移除 WebDAV，统一用 REST API

**移除范围：**
- 删除 `app/lib/service/sync/webdav_client.dart` 及所有 WebDAV 相关代码
- 删除设置页面中的 WebDAV 配置入口
- 删除 `providers/sync.dart` 中 WebDAV 相关逻辑
- 删除 Server 端 WebDAV 服务（`server/service/webdav/`）
- 所有同步统一走 Omnigram Server REST API

**注意：** Server 端 WebDAV 和 OPDS 一起删除。第三方客户端（KOReader 等）如需访问书库，后续通过 OPDS 协议支持。

---

## 不一致 4：AI 缓存持久化

### 问题

当前 `AmbientAiPipeline._cache` 是内存 Map，重启 App 就丢失。Sprint 4 加入 Companion Panel 对话历史和 Margin Notes，缓存需求更大。

### 讨论过程

1. 最初提出方案 A（通用 ai_cache 表）vs 方案 B（每功能各自表）
2. 创始人问：核心作用是什么？存 App 端还是 Server 端？
3. 解释了 AI 缓存的 5 个使用场景（Context Bar、Memory Bridge、Margin Notes、Companion 对话、AI 叙事）
4. 既然统一用 PG，建议 AI 结果存 Server PG，App 做内存缓存
5. 创始人指出：内存缓存重启就没了，主流聊天都用 sqflite

### ✅ 决策：App sqflite 缓存 + Server PG 持久化

**双端存储方案：**
- **App 端**：sqflite `ai_cache` 表，存所有 AI 生成结果。重启 App 直接从本地读，秒出
- **Server 端**：PG `ai_results` 表，source of truth
- **流程**：App 先查本地 sqflite → 没有则请求 Server → 返回后写入 sqflite。有网时后台增量同步新结果
- **Companion Panel 对话历史**也存 sqflite，类似微信的本地消息存储

**表结构（App 端 sqflite）：**
```sql
CREATE TABLE ai_cache (
  id INTEGER PRIMARY KEY,
  type TEXT NOT NULL,       -- 'context_bar', 'margin_note', 'glossary', 'narrative', 'companion_chat'
  book_id INTEGER,
  key TEXT NOT NULL,         -- 去重 key（如 chapter CFI）
  content TEXT NOT NULL,     -- AI 生成结果（JSON）
  created_at INTEGER,
  expires_at INTEGER,        -- 可选过期时间
  UNIQUE(type, book_id, key)
);
```

---

## 不一致 5：TTS 集成路径

### 问题

设计文档说"TTS 是伴侣体验的一部分，用伴侣配置的声音"。但实际 Client 已有 7 个成熟 TTS provider，Server 也有 TTS manager，两者和伴侣系统完全没关联。

### ✅ 决策：轻度关联——伴侣提示 + 声音关联

- 伴侣人格设置中增加"声音"选项，让用户选择一个 TTS voice 关联到伴侣
- 伴侣可以在合适时机提示"要不要我给你读这一章？"（触发 TTS）
- TTS 引擎架构不动，只是声音选择和伴侣人格关联
- 低风险，不影响已有 TTS 功能

---

## 决策汇总

| # | 议题 | 决策 | 状态 |
|---|------|------|------|
| 1 | 知识网络方案 | AI 叙事驱动的动态图（图是叙事注脚，不是独立浏览工具） | ✅ 已确认 |
| 2 | 搜索/向量方案 | 统一 PG + pgvector，Server 放弃 SQLite 模式 | ✅ 已确认 |
| 3 | 同步方案 | 完全移除 WebDAV，统一 REST API | ✅ 已确认 |
| 4 | AI 缓存持久化 | App sqflite 缓存 + Server PG 持久化（双端存储） | ✅ 已确认 |
| 5 | TTS 集成路径 | 轻度关联（伴侣提示 + 声音选项关联，不重构 TTS 架构） | ✅ 已确认 |

---

## 对 Sprint 4 实施的影响

基于以上 5 个决策，Sprint 4 的实施需要调整：

### 前置任务（Sprint 4 开始前）
1. **Server 数据库迁移**：SQLite → PG only + pgvector 扩展
2. **移除 WebDAV**：Client + Server 双端清理
3. **AI 缓存表**：App 端 sqflite 新建 `ai_cache` 表，Server 端 PG 新建 `ai_results` 表

### Sprint 4 功能清单（调整后）
1. **Companion Panel** — 底部滑出双向对话面板，对话历史存 sqflite + PG
2. **Margin Notes** — 跨书关联（PG tsvector 兜底 + pgvector 向量搜索升级）
3. **知识网络** — AI 叙事驱动的动态图（concept tag 管道 → 叙事升级 → 图组件）
4. **语义搜索** — pgvector 向量搜索
5. **TTS 伴侣关联** — 声音选项关联 + 伴侣提示触发
