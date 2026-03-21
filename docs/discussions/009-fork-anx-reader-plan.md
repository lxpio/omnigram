# 009 - App 客户端策略：Fork Anx Reader

> 讨论日期：2026-03-21
> 状态：✅ 已决策
> 决策：放弃当前 Omnigram App，Fork Anx Reader 作为新客户端基础

---

## 决策背景

### 当前 Omnigram App 的问题（代码审计 008 结论）

- 综合评分 **⭐ 2.5/5**，处于「能跑的原型」阶段
- 🔴 嵌套 MaterialApp 架构问题
- 🔴 API 拦截器被静默丢弃
- 🔴 路由认证守卫被注释掉
- 🔴 Isar 4.0-dev 预发布依赖（项目半废弃）
- 🔴 多处安全问题（token 日志泄露、测试文件含凭证）
- 仅支持 EPUB + PDF，仅 iOS/Android
- 无翻译、无思维导图、笔记/TTS/统计功能基础

### Anx Reader 的现状（v1.14.0，7,928 ⭐）

- 综合质量远超当前 Omnigram App
- 4 平台（iOS/Android/macOS/Windows）
- 6 种格式（EPUB/MOBI/AZW3/FB2/TXT/PDF）
- 完整 AI 集成（langchain_dart，多模型支持）
- 完整 TTS（多音色、语速、定时）
- 完整笔记系统（多色、导出、分享卡片）
- 阅读统计热力图
- 全书翻译 + 双语对照
- AI 思维导图生成
- WebDAV 同步（已实现）
- OPDS 支持（开发中）
- MIT 许可证，可自由使用

### 成本对比

| 路线 | 预估工时 | 结果质量 |
|------|---------|---------|
| 修复当前 App + 补齐功能 | 6-12 个月 | 追平 Anx Reader |
| Fork Anx Reader + 接入 Server | 4-6 周 | 超越 Anx Reader（有服务端） |

**结论：Fork 是唯一合理选择。**

---

## Fork 架构设计

```
┌─────────────────────────────────────────┐
│          Omnigram App (Fork)             │
│  ┌─────────────┐  ┌──────────────────┐  │
│  │ Anx Reader   │  │ Omnigram 新增     │  │
│  │ 原有功能     │  │                  │  │
│  │              │  │ Server API 接入   │  │
│  │ 本地阅读     │  │ 服务端 AI 调用    │  │
│  │ 本地 AI      │  │ 服务端 TTS       │  │
│  │ WebDAV 同步  │  │ 多用户登录       │  │
│  │ TTS/笔记/统计│  │ 书库浏览/下载     │  │
│  │ 翻译/思维导图 │  │ OPDS 增强        │  │
│  └─────────────┘  └──────────────────┘  │
└────────────────┬────────────────────────┘
                 │ HTTP API
                 ▼
┌─────────────────────────────────────────┐
│          Omnigram Server (Go)            │
│                                         │
│  多用户权限 │ 书库扫描 │ 元数据管理       │
│  服务端 AI  │ 语义搜索 │ 服务端 TTS      │
│  OPDS 服务  │ WebDAV  │ Docker 部署      │
└─────────────────────────────────────────┘
```

### 工作模式

```
模式 A：连接 Omnigram Server（完整体验）
  App ←→ Server API ←→ 书库/AI/TTS

模式 B：独立使用（兼容 Anx Reader 原有能力）
  App ←→ 本地存储 + WebDAV + 本地 AI

模式 C：连接第三方 OPDS/WebDAV（兼容生态）
  App ←→ Calibre-Web / 其他 OPDS 服务
```

---

## 实施计划

### Phase 1：Fork + 品牌化（第 1 周）

| 步骤 | 工作 | 详情 |
|------|------|------|
| 1.1 | Fork 仓库 | Fork Anxcye/anx-reader main 分支 |
| 1.2 | 替换包名 | `com.anxcye.anx_reader` → `com.lxpio.omnigram` |
| 1.3 | 替换品牌 | App 名称、图标、启动页、关于页 |
| 1.4 | 删除 IAP | 移除 `in_app_purchase` 相关代码 |
| 1.5 | 编译验证 | 确保 iOS/Android/macOS/Windows 全平台可编译 |
| 1.6 | 致谢声明 | README + 关于页保留 Anx Reader 原始致谢 |

### Phase 2：接入 Omnigram Server（第 2-3 周）

| 步骤 | 工作 | 详情 |
|------|------|------|
| 2.1 | 添加服务端配置 | 设置页新增 Server URL 配置 |
| 2.2 | 登录/注册 | 接入 Server 用户认证 API |
| 2.3 | 书库浏览 | 从 Server 获取书库列表（替代/补充本地书库） |
| 2.4 | 书籍下载 | 从 Server 下载到本地阅读 |
| 2.5 | 同步增强 | 阅读进度/笔记/收藏与 Server 双向同步 |
| 2.6 | 保留 WebDAV | 作为可选同步方式，不删除 |

### Phase 3：服务端 AI 功能（第 4-5 周）

| 步骤 | 工作 | 详情 |
|------|------|------|
| 3.1 | 服务端 AI 选项 | AI 助手可选「本地 AI」或「服务端 AI」 |
| 3.2 | 服务端 TTS | 可选使用服务端 GPU TTS（更高质量） |
| 3.3 | 语义搜索 | 全书库语义搜索（服务端 embedding） |
| 3.4 | AI 摘要 | 书籍摘要自动生成（服务端计算） |

### Phase 4：差异化 + 发布（第 5-6 周）

| 步骤 | 工作 | 详情 |
|------|------|------|
| 4.1 | UI 主题调整 | Omnigram 品牌色 + 主题风格 |
| 4.2 | 文档更新 | 安装指南、Server 配置指南 |
| 4.3 | Docker 完善 | 一键 docker-compose（Server + 依赖） |
| 4.4 | 首版发布 | GitHub Release + 应用商店提交 |

---

## 需要注意的事项

### 许可证合规

```
Anx Reader 许可证：MIT
允许：✅ 商用 ✅ 修改 ✅ 分发 ✅ 私用
要求：保留版权声明
```

**必须做：**
- README 致谢 Anx Reader
- 关于页展示「Based on Anx Reader」
- 保留原始 LICENSE 文件中的版权声明

### 与上游同步策略

```
方案：定期 merge（推荐）
频率：每月或每个 Anx Reader 大版本
方法：
  git remote add upstream https://github.com/Anxcye/anx-reader.git
  git fetch upstream
  git merge upstream/main --no-edit
```

**冲突最小化原则：**
- 尽量通过「新增文件」而非「修改原有文件」来添加功能
- Server API 层做成独立的 service/provider
- 品牌相关改动集中在少数文件

### 社区关系

- 向 Anx Reader 贡献通用性改进（bug fix、性能优化）
- 不直接竞争客户端功能，差异化在服务端
- 在 Omnigram 社区推荐 Anx Reader 作为独立使用方案

---

## 对 Go 后端的影响

**后端不受影响，继续独立开发。** 后端是 Omnigram 的核心差异化资产。

需要后端配合的工作：

| 后端任务 | 优先级 | 说明 |
|---------|--------|------|
| 完善用户认证 API | P0 | 修复审计中的安全问题 |
| 书库列表/下载 API | P0 | App 需要的基础接口 |
| 阅读进度同步 API | P1 | 多设备同步 |
| AI 摘要/搜索 API | P1 | 服务端 AI 功能 |
| 服务端 TTS API | P2 | GPU 加速 TTS |
| WebDAV 协议实现 | P2 | 兼容其他客户端 |

---

## 要废弃的内容

| 内容 | 处理方式 |
|------|---------|
| `app/` 目录（当前 Flutter 代码） | 归档到 `app-legacy/` 分支，不再维护 |
| `app/pubspec.yaml` | 被 Anx Reader 的替代 |
| OpenAPI 代码生成 | 评估是否仍需要，可能改用手写 API 层 |
| `patch/` 目录 | 评估哪些 patch 仍需要 |
| `fishtts/` 目录 | 保留，服务端 TTS 仍使用 |
