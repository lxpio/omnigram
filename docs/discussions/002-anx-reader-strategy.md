# 002 - Anx Reader 协同策略分析

> 日期：2026-03-20
> 状态：🔄 讨论中
> 核心问题：Anx Reader 是 MIT 开源的 Flutter 阅读器，我们应该如何利用它？

## Anx Reader 概况

- **技术栈：** Flutter/Dart + Riverpod（与 Omnigram 一致）
- **许可证：** MIT（可商用、可修改、可闭源）
- **核心能力：** 多格式阅读、AI 助手（langchain_dart）、TTS、笔记、阅读统计
- **同步方式：** WebDAV（无自有服务端）
- **平台：** iOS / macOS / Windows / Android（无 Web、无 Linux）
- **社区：** 活跃，增长快

## 技术栈对比

| 维度 | Anx Reader | Omnigram | 兼容性 |
|------|-----------|----------|--------|
| 语言 | Flutter/Dart | Flutter/Dart | ✅ 完全一致 |
| 状态管理 | Riverpod | Riverpod (hooks) | ✅ 一致 |
| 许可证 | **MIT** | - | ✅ 可商用 |
| 阅读引擎 | foliate-js (MIT) | epubx | ✅ foliate-js 更成熟 |
| AI 框架 | langchain_dart | 无 | ✅ 可直接用 |
| 网络 | dio | dio | ✅ 一致 |
| 数据库 | sqflite | isar | ⚠️ 需选择 |
| 同步 | WebDAV | 自有 API (openapi) | ⚠️ 需整合 |

## Omnigram vs Anx Reader 能力对比

| 能力维度 | Anx Reader | Omnigram（可做到） | 谁赢 |
|----------|-----------|-------------------|------|
| 客户端阅读体验 | ✅ 非常成熟 | 🔨 需要打磨 | Anx |
| 格式支持 | EPUB/MOBI/AZW3/FB2/TXT/PDF | EPUB/PDF | Anx |
| AI 问答/摘要/翻译 | ✅ 客户端直连 AI API | ✅ 服务端 AI 处理 | 平手 |
| TTS 听书 | ✅ 客户端实时生成 | ✅ 服务端后台生成 | **Omnigram** |
| 数据同步 | WebDAV | 自有服务端 | **Omnigram** |
| 多用户/家庭 | ❌ 单用户 | ✅ 多用户+权限 | **Omnigram** |
| 书库管理 | ❌ 无（靠社区插件） | ✅ NAS 扫描+元数据 | **Omnigram** |
| 跨书搜索 | ❌ 只能搜当前书 | ✅ 全库语义搜索 | **Omnigram** |
| Web 端 | ❌ 无 | ✅ 浏览器直接用 | **Omnigram** |
| Linux | ❌ 不支持 | ✅ Web 端覆盖 | **Omnigram** |

## Omnigram 的 5 个结构性优势（纯客户端做不到的）

### 1. 服务端 AI —— 「跨书知识大脑」

Anx Reader 的 AI 是单书实时的（选中文字 → 调 API → 返回）。

Omnigram 可以做到：
- 书导入时后台预处理：提取章节、生成 embedding、建立向量索引
- 跨整个书库的语义搜索：「我记得有本书讲过量子纠缠和信息论的关系」
- 知识关联：「这本书的观点和你之前读过的《XX》第3章有冲突」
- 批量处理：导入 100 本书 → 后台自动生成摘要/标签/分类

### 2. 服务端 TTS —— 「有声书工厂」

Anx Reader 的 TTS 是客户端实时合成（依赖设备性能，每次重新生成）。

Omnigram 可以做到：
- 服务端后台批量生成完整有声书
- 生成结果缓存复用：生成一次，全家人都能听
- 高质量模型：服务端可以跑本地大模型（GPU 版）
- 多角色 TTS：分析对话，不同角色用不同音色
- 与 Audiobookshelf 兼容：导出有声书给 Audiobookshelf

### 3. 多用户 + 家庭共享

Anx Reader 是单人工具。Omnigram 可以做到：
- 一个书库全家共享，权限分级
- 同一本书每人进度独立
- 共享 AI/TTS 额度

### 4. NAS 书库管理

Anx Reader 没有书库管理（社区做了 anx-calibre-manager 补这个缺）。
Omnigram 可以做到：NAS 目录自动扫描、元数据补全、OPDS、Web 管理后台。

### 5. Web 端阅读

Anx Reader 没有 Web 端。浏览器打开就能读，覆盖 Linux，降低推广门槛。

## 三个可行策略

### 策略 1：「服务端优先，让 Anx Reader 当客户端」 ⭐⭐⭐⭐⭐ 推荐

不做客户端竞争，专注做最强服务端。通过标准协议让 Anx Reader 成为 Omnigram 的客户端。

```
┌─────────────┐         ┌──────────────────────┐
│  Anx Reader  │◄──────►│   Omnigram Server     │
│  (客户端)     │ WebDAV  │                      │
│  AI阅读/TTS  │ + OPDS  │  · NAS 书库扫描管理    │
│  笔记/统计    │         │  · 多用户/权限         │
└─────────────┘         │  · 服务端 AI 处理      │
                        │  · 服务端 TTS 生成     │
       同时也有           │  · 语义搜索 (embedding)│
┌─────────────┐         │  · Web 管理后台        │
│ Omnigram App │◄──────►│  · Web 阅读器          │
│ (自有客户端)  │  API    │                      │
└─────────────┘         └──────────────────────┘
```

**优点：**
- 零成本获得成熟的多平台阅读客户端
- Anx Reader 的用户 = 潜在用户（他们正好需要一个好的服务端）
- 100% 精力做服务端差异化
- 不是竞争关系，是共生关系
- 社区已经有需求信号：anx-calibre-manager、anx-reader-calibre-plugin

**需要做的：**
1. Omnigram Server 实现标准 WebDAV 协议（书籍/笔记同步）
2. 完善 OPDS feed（已有基础）
3. 可选：提供 AI 服务 API 供客户端调用
4. 做好 Web 管理后台 + Web 阅读器

### 策略 2：Fork Anx Reader，替换同步层

直接 fork 整个项目，把 WebDAV 同步替换为 Omnigram Server API。

**优点：** 完全控制客户端，可深度定制
**缺点：**
- 维护 fork 的持续 rebase 工作量巨大
- 现有 Omnigram App 代码基本废弃
- 要理解并维护 100+ 依赖的别人代码

### 策略 3：Cherry-pick 关键组件

不 fork 整个项目，把关键独立组件拿过来用在自己的 App 里：

| 可直接用的组件 | 来源 | 许可证 |
|--------------|------|--------|
| `foliate-js` | EPUB/PDF 渲染引擎 | MIT |
| `langchain_dart` | AI 集成框架 | MIT |
| `flutter_heatmap_calendar` | 阅读热力图 | MIT |
| WebDAV 客户端 fork | 同步逻辑参考 | MIT |

**优点：** 保持自己的架构，按需取用
**缺点：** 要自己拼装，工作量中等

## 推荐方案：策略 1 + 策略 3 组合

### 短期

- Omnigram Server 实现 WebDAV + OPDS
- 立刻可以被 Anx Reader 当后端用
- 在 Anx Reader 社区推广

### 中期

- 用 foliate-js + langchain_dart 重构 Omnigram App
- 做出与 Anx Reader 差异化的「服务端深度集成体验」
  - 跨书搜索
  - 服务端 TTS 离线缓存
  - 家庭管理面板

### 长期

- 两个客户端并存：
  - 轻度用户 → Anx Reader 连 Omnigram Server
  - 重度用户 → Omnigram App 获得完整体验
- 在 r/selfhosted 发帖推广
- Docker Hub / Awesome-Selfhosted 收录

## 核心原则

> **不要把 Anx Reader 当竞品，把它当「免费的分发渠道」。做好服务端，它的用户自然会来。**

## 不要做的事（避免正面硬拼）

| 不要拼 | 原因 |
|--------|------|
| 客户端阅读 UI 细节 | Anx Reader 打磨了很久，追不上也不需要追 |
| 更多电子书格式 | EPUB + PDF 覆盖 95% 需求 |
| 思维导图/分享卡片 | 锦上添花，不是核心差异化 |
| 离线优先 | C/S 架构不是主场 |
