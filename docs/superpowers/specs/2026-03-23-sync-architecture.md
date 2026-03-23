# Sprint 3.5: Server-Client 同步架构修正

> **日期：2026-03-23**
> **状态：Draft — 待创始人确认**
> **前置：** Sprint 1-3 完成（Layer 0-3），进入 Sprint 4 前的架构修正
> **参考：** Immich 同步模式、设计文档 §10.7

---

## 1. 问题诊断

### 1.1 当前状态

```
                    ┌────────────────────┐
                    │   Omnigram Server  │
                    │                    │
                    │  REST API (完整)    │  ← Client 完全没用
                    │  ├─ /reader/books  │
                    │  ├─ /sync/full     │
                    │  ├─ /sync/delta    │
                    │  ├─ /sync/annotations│
                    │  ├─ /reader/books/:id/annotations│
                    │  └─ /reader/books/:id/progress   │
                    │                    │
                    │  WebDAV (文件)      │  ← Client 只用这个
                    │  AI Enhancement    │  ← Client 重复做了
                    └────────┬───────────┘
                             │
                    WebDAV: 整个 SQLite 文件搬运
                             │
                    ┌────────┴───────────┐
                    │   Flutter Client   │
                    │                    │
                    │  本地 sqflite       │
                    │  AI Pipeline       │  ← 结果只存内存，重启消失
                    │  Companion 人格     │  ← 只存 SharedPrefs，换设备丢失
                    └────────────────────┘
```

### 1.2 五个核心问题

| # | 问题 | 严重程度 | 影响 |
|---|------|---------|------|
| 1 | Client 不用 Server REST API，只用 WebDAV 搬 SQLite 文件 | 🔴 架构级 | 无法增量同步，无法多设备并发 |
| 2 | Server 上传时已跑 AI（打标签+摘要+分类），Client 又跑一遍 | 🟡 浪费 | API 费用翻倍，结果不一致 |
| 3 | Client AI 产出（标签、摘要、推荐）只存内存，重启消失 | 🟡 体验差 | 每次重启都要重新生成 |
| 4 | 伴侣人格只存 SharedPrefs，换设备丢失 | 🟡 体验差 | 违背设计文档 §10.7 "account-level" |
| 5 | Server 有完整 CRUD API 但 Client 不知道 | 🔴 浪费 | Server 白建了 |

---

## 2. 目标架构（参考 Immich 模式）

### 2.1 Immich 同步模式核心理念

Immich 的架构：
- **Server 是 Source of Truth** — 所有照片、元数据、AI 识别结果存在 Server
- **Client 是缓存层** — 本地存缩略图和元数据缓存，按需下载原图
- **增量同步** — Client 记录 last sync timestamp，只拉新增/修改
- **离线容忍** — Client 可以离线浏览已缓存内容，上线后同步

### 2.2 Omnigram 目标架构

```
                    ┌──────────────────────────┐
                    │     Omnigram Server       │
                    │                           │
                    │  Source of Truth:          │
                    │  ├─ 书籍文件 + 元数据      │
                    │  ├─ 阅读进度               │
                    │  ├─ 注释/高亮              │
                    │  ├─ AI 标签 + 摘要         │
                    │  ├─ 伴侣人格配置           │
                    │  └─ 阅读统计               │
                    │                           │
                    │  REST API (增量同步)       │
                    │  WebDAV (兼容模式/文件拉取) │
                    └──────────┬────────────────┘
                               │
                    REST API: 增量同步 (delta)
                    WebDAV: 兼容模式（拉取远端文件）
                               │
                    ┌──────────┴────────────────┐
                    │     Flutter Client         │
                    │                            │
                    │  本地缓存层:                │
                    │  ├─ sqflite (元数据缓存)    │
                    │  ├─ 文件缓存 (封面+书籍)    │
                    │  ├─ AI 缓存 (context bar等) │
                    │  └─ SharedPrefs (UI 偏好)   │
                    │                            │
                    │  离线模式:                   │
                    │  ├─ 已缓存书籍可正常阅读     │
                    │  ├─ AI 功能降级             │
                    │  └─ 上线后自动同步           │
                    └────────────────────────────┘
```

---

## 3. 实施方案

### 3.1 新增 Client 端：API Client 层

创建 `app/lib/service/api/` — Omnigram Server REST API 客户端：

```
app/lib/service/api/
├── omnigram_api.dart          # API 基类（base URL, auth token, 错误处理）
├── book_api.dart              # 书籍 CRUD + 元数据
├── annotation_api.dart        # 注释/高亮 CRUD
├── sync_api.dart              # 增量同步（delta）
├── progress_api.dart          # 阅读进度同步
├── companion_api.dart         # 伴侣人格同步（需 Server 新增接口）
└── ai_api.dart                # AI 相关（获取 Server 生成的标签/摘要）
```

**核心类：**

```dart
class OmnigramApi {
  final String baseUrl;
  final String? authToken;
  
  // 所有请求走这里，统一错误处理
  Future<T> get<T>(String path, {Map<String, dynamic>? params});
  Future<T> post<T>(String path, {dynamic body});
  Future<T> put<T>(String path, {dynamic body});
  Future<void> delete(String path);
}
```

### 3.2 增量同步策略

```dart
class SyncManager {
  DateTime? _lastSyncTime;  // 持久化到 SharedPreferences
  
  /// 核心同步流程
  Future<void> sync() async {
    // 1. 上传本地变更（Client → Server）
    await _pushLocalChanges();
    
    // 2. 拉取远端变更（Server → Client）
    await _pullRemoteChanges();
    
    // 3. 更新同步时间戳
    _lastSyncTime = DateTime.now();
  }
  
  Future<void> _pushLocalChanges() async {
    // 阅读进度：PUT /reader/books/:id/progress
    // 注释/高亮：POST /sync/annotations (upsert)
    // 阅读时间：POST /reader/sessions
  }
  
  Future<void> _pullRemoteChanges() async {
    // 书籍元数据：POST /sync/delta (since lastSyncTime)
    // 包含 Server AI 生成的标签、摘要、分类
    // 注释：POST /sync/annotations (双向)
  }
}
```

**同步时机：**
- App 启动时
- 进入/离开阅读器时
- 手动下拉刷新
- 后台定时（可配置间隔）

### 3.3 Server 端需要新增

| 接口 | Method | Path | 用途 |
|------|--------|------|------|
| 获取/更新伴侣人格 | GET/PUT | `/user/companion` | 跨设备同步人格配置 |
| 获取 AI 增强结果 | GET | `/reader/books/:id/ai` | 返回 Server 生成的标签+摘要+分类 |
| 阅读会话记录 | POST | `/reader/sessions` | 上传阅读时长统计 |
| 用户偏好同步 | GET/PUT | `/user/preferences` | 通用偏好存储（预留扩展） |

### 3.4 WebDAV 角色调整

| 场景 | 当前 | 调整后 |
|------|------|--------|
| 书籍文件下载 | WebDAV 搬整个 DB | REST API 获取文件列表 → 按需下载文件 |
| 元数据同步 | WebDAV 搬整个 DB | REST API `/sync/delta` |
| 注释同步 | WebDAV 搬整个 DB | REST API `/sync/annotations` |
| 第三方 WebDAV 兼容 | 支持 | **保留**作为兼容模式（连接非 Omnigram Server） |

### 3.5 AI 处理职责划分

| AI 任务 | 执行者 | 理由 |
|---------|--------|------|
| 导入时打标签/摘要/分类 | **Server** | 一次生成，多设备复用 |
| Context Bar | **Client** | 实时性要求高，与当前章节相关 |
| Memory Bridge | **Client** | 依赖本地阅读状态 |
| Inline Glossary | **Client** | 实时交互，需要快速响应 |
| 阅读叙事 (Narrative) | **Server**（优先）→ Client 降级 | 需要全局阅读数据 |
| 推荐 | **Server**（优先）→ Client 降级 | 需要全局书库数据 |
| Margin Notes | **Server** | 需要跨书向量搜索 |

### 3.6 迁移策略

Client 需要同时支持两种模式：

| 模式 | 使用场景 | 同步方式 |
|------|---------|---------|
| **Omnigram Server 模式** | 连接自建 Omnigram Server | REST API 增量同步 |
| **WebDAV 兼容模式** | 连接第三方 WebDAV（坚果云等） | 文件级同步（简化版） |

首次连接时检测：如果 `GET /healthz` 返回 Omnigram 标识 → 切换到 Server 模式。

---

## 4. 任务拆分

### Phase 1: API Client 基础层
- [ ] 创建 `OmnigramApi` 基类（HTTP client, auth, error handling）
- [ ] 创建 Server 连接配置 UI（URL + 登录）
- [ ] 实现 `GET /healthz` 检测是否为 Omnigram Server
- [ ] 创建 `BookApi` — 对接 `/reader/books`, `/sync/delta`
- [ ] 创建 `AnnotationApi` — 对接 `/sync/annotations`
- [ ] 创建 `ProgressApi` — 对接 `/reader/books/:id/progress`

### Phase 2: 增量同步引擎
- [ ] 创建 `SyncManager` — 双向增量同步
- [ ] 本地变更追踪（dirty flag 或 changelog 表）
- [ ] 冲突解决策略（last-write-wins by timestamp）
- [ ] 同步状态 UI（同步中/已同步/离线）

### Phase 3: Server 新接口
- [ ] `GET/PUT /user/companion` — 伴侣人格同步
- [ ] `GET /reader/books/:id/ai` — AI 增强结果
- [ ] `POST /reader/sessions` — 阅读会话上传
- [ ] 更新 Swagger 文档

### Phase 4: Client 集成
- [ ] `postImportAi` 改为从 Server 拉取 AI 结果
- [ ] `companionProvider` 支持 Server 同步
- [ ] AI 缓存持久化（sqflite 表）
- [ ] WebDAV 降级为兼容模式

---

## 5. 设计决策（已确认）

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 同步模式 | **Immich 模式（在线优先）** | Server 是 source of truth，Client 是缓存层 |
| 纯本地模式 | **保留** | 不连 Server 也能用，AI 只用 Client 端 Provider |
| 冲突解决 | **Last-write-wins（timestamp）** | 简单可靠，与 Immich 一致 |
| 接口范围 | **全量对接** | 一次性对接 Server 所有 ~30 个 REST 接口 |
