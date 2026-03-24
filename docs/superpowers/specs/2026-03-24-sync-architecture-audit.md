# Omnigram 数据同步架构审核报告

> **审核日期**: 2026-03-24
> **审核范围**: Go 服务端同步端点 + Flutter 客户端 SyncManager + 数据模型
> **审核依据**: `server/service/reader/handler_sync.go`, `app/lib/service/sync/sync_manager.dart` 等核心文件完整审读
> **状态**: 待修复

---

## 背景

Omnigram 是自托管电子书阅读服务（Go 后端 + Flutter 多端客户端），当前同步架构为 REST + SSE 双向同步。本报告列出**已识别 7 项缺口之外**的遗漏问题，供开发团队排期修复。

### 已识别缺口（不在本报告范围内）

| # | 严重度 | 问题 |
|---|--------|------|
| 1 | 🔴 | 客户端未调用 /sync/delta（全量拉取） |
| 2 | 🔴 | lastSyncTime 仅内存变量，不持久化 |
| 3 | 🟡 | 无离线操作队列（pending_ops） |
| 4 | 🟡 | 书籍文件不同步（只同步元数据） |
| 5 | 🟡 | 无同步重试（指数退避） |
| 6 | 🟢 | 冲突静默覆盖，无用户通知 |
| 7 | 🟢 | 大库拉取无分页 |

---

## 审核发现

### 一、数据一致性

#### 🔴 C-1: 时间戳精度不一致导致静默丢数据

**现状**: 服务端 `uTime` 为 Unix 秒级精度，客户端 `updateTime` 为 ISO8601 毫秒精度。转换代码 `DateTime.fromMillisecondsSinceEpoch(serverBook.uTime * 1000)` 截断毫秒。

**失败场景**: 设备 A 在 12:00:00.300 改标注，设备 B 在 12:00:00.800 改同一标注。两次同步后 uTime 均为 `1711273200`（秒级相等），第二次变更被丢弃。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — `DateTime.fromMillisecondsSinceEpoch(serverBook.uTime * 1000)`
- `server/schema/` — GORM tag `autoUpdateTime:milli` 已配置但端点转换时截断

**修复方案**: 服务端 API 响应统一返回毫秒时间戳，客户端去掉 `* 1000` 转换。

**复杂度**: 低

---

#### 🔴 C-2: Push 阶段无变更追踪，全量逐本推送

**现状**: `_pushBooks()` 遍历所有本地书籍逐一调用 `BookApi.updateBook()`，无论是否有变更。

**失败场景**: 推送到第 500 本时 app 被杀 → 前 500 本的 uTime 已被服务端刷新，但客户端 lastSyncTime 未持久化 → 重启后再次全量推送 → 服务端 uTime 全部再次刷新 → 其他设备误以为所有书都有变更，触发无意义全量拉取。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — `_pushBooks()`
- `app/lib/dao/book.dart` — 无 dirty 标记字段

**修复方案**: sqflite `tb_books` 增加 `is_dirty` 字段，仅推送 `is_dirty=1` 的记录；推送成功后清除标记。

**复杂度**: 中

---

#### 🔴 C-3: Annotation sync 部分失败不可追踪

**现状**: 服务端 `handler_annotation.go` 逐条 UPSERT，单条失败时 `continue` 跳过，仅返回 `synced` 总数。客户端无法得知哪些标注失败。

**失败场景**: 批量同步 50 条标注，第 23 条因 CFI 格式异常失败 → 客户端收到 `synced: 49`，不知道哪条失败，也无法定向重试。

**涉及文件**:
- `server/service/reader/handler_annotation.go` — 同步处理逻辑
- `app/lib/service/sync/sync_manager.dart` — `_pushAnnotations()`

**修复方案**: 服务端返回 `failed_ids: []string` 列表；客户端对失败条目标记为 pending retry。

**复杂度**: 低

---

#### 🟡 C-4: Book.Create 使用 DoNothing 策略，元数据更新丢失

**现状**: `schema/book.go` 的 `Create()` 使用 `clause.OnConflict{DoNothing: true}`，按 `identifier` 去重。

**失败场景**: 设备 A 导入 Calibre 修正过的 EPUB（完整作者/描述），设备 B 导入原始 EPUB（元数据不全）。若 B 先同步 → A 的优质元数据被静默丢弃。

**涉及文件**:
- `server/schema/book.go` — `Create()` 方法

**修复方案**: 改为 `DoUpdates`，在 identifier 冲突时合并非空字段。

**复杂度**: 低

---

#### 🟡 C-5: 阅读进度同步是单向有损的

**现状**: `_pullProgress()` 仅当 `serverProgress > localProgress` 时更新本地。

**失败场景**: 用户在 iPad 回退重读前几章（进度 80% → 30%）→ 手机仍显示 80%，下次同步将 80% 推回服务端覆盖 iPad 的 30%。回退操作永远无法同步。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — `_pullProgress()`

**修复方案**: 用 `uTime` / `last_read_at` 时间戳比较代替进度值比较。

**复杂度**: 低

---

### 二、安全性

#### 🔴 S-1: Token 明文存储在 SharedPreferences

**现状**: `server_connection_provider.dart` 将 `access_token` 和 `refresh_token` 直接写入 SharedPreferences（Android = 明文 XML，iOS = plist）。

**失败场景**: Android 设备被盗或安装恶意 app 获取 root → token 泄露 → 可冒充用户访问 NAS 上所有书籍和笔记。

**涉及文件**:
- `app/lib/providers/server_connection_provider.dart` — token 存储逻辑

**修复方案**: Android 改用 `flutter_secure_storage`（KeyStore 加密），iOS 使用 Keychain。

**复杂度**: 低

---

#### 🟡 S-2: Refresh token 无轮换机制

**现状**: `_tryRefreshToken()` 刷新后获得新 token pair，但服务端未吊销旧 refresh token。

**失败场景**: 中间人截获一次 refresh 请求 → 旧 token 仍有效 → 攻击者可持续刷新，永久持有有效凭证。

**涉及文件**:
- `app/lib/service/api/omnigram_api.dart` — `_tryRefreshToken()`
- `server/service/user/` — token 刷新端点

**修复方案**: 服务端实现 refresh token rotation — 每次刷新时吊销旧 token、签发新 token。

**复杂度**: 中

---

#### 🟡 S-3: SSE 全量同步端点无速率限制

**现状**: `/sync/full` 可被反复调用，触发 FindInBatches 全表扫描。当前 rate limiter 未应用于 sync 路由组。

**失败场景**: 恶意脚本循环调用 `/sync/full` → PostgreSQL CPU 打满 → NAS 上其他服务受影响。

**涉及文件**:
- `server/service/reader/setup.go` — sync 路由注册
- `server/middleware/rate_limit.go` — 限流中间件

**修复方案**: 对 sync 路由组加 rate limiter，限制每用户每分钟同步次数（建议 ≤ 3 次/分钟）。

**复杂度**: 低

---

### 三、性能与可扩展性

#### 🔴 P-1: Push 阶段 N+1 请求风暴

**现状**: 逐本调用 `updateBook()`，万本书库 = 10000 次 HTTP 请求。

**失败场景**: 万本书库，按每请求 50ms RTT（局域网）计算，一次 push ≈ 8 分钟。用户以为挂了杀 app → 触发 C-2 的级联问题。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — `_pushBooks()`

**修复方案**: 实现 batch push API（一次传 100-500 本变更）；配合 dirty 标记只推增量。

**复杂度**: 中

---

#### 🟡 P-2: SSE 流无反压控制

**现状**: `SyncFullBooks()` goroutine 通过 unbuffered channel 发送批次。客户端消费慢时 goroutine 阻塞在 channel send 上，占着 DB 连接和内存。

**失败场景**: 低端 Android 手机全量同步 5 万本 → 服务端 goroutine 长时间挂起 → GORM 连接池耗尽 → 其他用户请求超时。

**涉及文件**:
- `server/service/reader/handler_sync.go` — `SyncFullBooks()` 和 SSE handler

**修复方案**: 使用 buffered channel + context timeout；客户端未消费超时后主动关闭连接释放资源。

**复杂度**: 中

---

#### 🟡 P-3: Pull 阶段标注比对为 O(N) 逐条查询

**现状**: `_pullAnnotations()` 拉取全量标注后，逐条在 sqflite 按 `(book_id, cfi)` 查询是否已存在。

**失败场景**: 重度标注用户（5000+ 条）每次同步花 30-60 秒在标注比对上。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — `_pullAnnotations()`
- `app/lib/dao/book_note.dart`

**修复方案**: 使用服务端标注 delta API 只返回变更集；或客户端维护 `(book_id, cfi) → uTime` 内存索引批量比对。

**复杂度**: 中

---

### 四、多设备场景

#### 🔴 M-1: 无设备级冲突感知 —— "幽灵覆盖"问题

**现状**: LWW 策略完全忽略设备来源，且使用客户端本地时间戳。

**失败场景**: 手机时钟快 5 分钟（飞行模式后未同步 NTP，NAS 场景常见）→ 飞行模式中做的标注时间戳比服务端上 iPad 的实际更新更"新" → 覆盖 iPad 的编辑，iPad 用户无任何感知。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — 所有 LWW 比较逻辑

**修复方案**:
- **短期**: 同步请求上传客户端时间，服务端用自身时间戳替代（`received_at`），消除时钟偏移影响。
- **中期**: 引入 vector clock 或 Lamport timestamp。

**复杂度**: 中（服务端时间戳）/ 高（vector clock）

---

#### 🟡 M-2: AI 数据类型的 synced 标志未接入 SyncManager

**现状**: `tb_companion_chat`、`tb_ai_cache`、`tb_margin_notes`、`tb_concept_tags`、`tb_concept_edges` 均有 `synced` 字段和 DAO 方法（如 `getUnsynced()`、`markSynced()`），但 SyncManager 完全未调用。

**失败场景**: 用户在设备 A 生成的 AI 洞察、知识图谱、伴侣对话 → 换设备后全部丢失。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — 缺失 AI 数据同步逻辑
- `app/lib/dao/companion_chat.dart`, `ai_cache.dart`, `margin_note.dart`, `concept_tag.dart`

**修复方案**: 在 SyncManager 的 push/pull 循环中加入这些数据类型的同步逻辑，利用已有的 `synced` 标记和 DAO 方法。

**复杂度**: 中

---

### 五、错误恢复

#### 🔴 R-1: 同步非原子 —— 中途崩溃导致状态分裂

**现状**: Push 和 Pull 是独立步骤，无事务语义，无断点记录。

**失败场景**: Push 500 本书成功 → Pull 阶段网络断开 → 服务端已有最新数据，客户端仍是旧数据 → 下次同步客户端又 Push 旧数据（uTime 已被上次 Push 刷新，可能覆盖服务端更新的数据）。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — `sync()` 主流程

**修复方案**: 记录 sync checkpoint（`push_completed` / `pull_books_completed` / `pull_annotations_completed`），恢复时从断点继续而非从头开始。

**复杂度**: 中

---

#### 🟡 R-2: SSE 流中断后无断点续传

**现状**: `/sync/full` 的 SSE 流中断后，客户端需从头重新请求全量同步。

**失败场景**: 全量同步 5 万本书，已收到 1.5 万本时 Wi-Fi 闪断 → 重连后从头开始 → 在不稳定网络下可能永远完不成。

**涉及文件**:
- `server/service/reader/handler_sync.go` — SSE handler
- `app/lib/service/api/sync_api.dart` — `fullSync()`

**修复方案**: SSE 事件带 batch offset / cursor；客户端断线重连时传 `last_received_cursor` 续传。

**复杂度**: 中

---

### 六、数据模型

#### 🟡 D-1: 本地 ID 与服务端 ID 映射脆弱

**现状**: 本地 sqflite `tb_books.id` 是自增整数，服务端 `books.id` 也是整数但由服务端生成。标注同步通过 `book_id` 关联。

**失败场景**: 本地 book_id=5（服务端 id=12），推送标注时传 book_id=5 → 服务端关联到 id=5 的另一本书 → 标注挂到错误的书上。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — `_pushAnnotations()`
- `server/service/reader/handler_annotation.go`

**修复方案**: 标注同步时用 book `identifier`（UUID/ISBN）而非 numeric ID 关联。

**复杂度**: 中

---

#### 🟡 D-2: Schema 版本无前向兼容

**现状**: 客户端 `currentDbVersion = 11`，服务端无 schema version 协商。

**失败场景**: 服务端升级加了 `book.reading_difficulty` 字段 → 旧客户端同步时忽略该字段 → 用户升级客户端后该字段全为 null → 需再次全量同步。

**涉及文件**:
- `app/lib/dao/database.dart` — `currentDbVersion`
- 服务端同步响应 — 无版本信息

**修复方案**: 同步响应 header 中包含 `X-Sync-Schema-Version`；客户端检测到版本差异时提示升级或存储原始 JSON 备用。

**复杂度**: 中

---

### 七、用户体验

#### 🟡 U-1: 首次同步无进度反馈

**现状**: `SyncState.progress` 字段存在但 `_pullBooks()` 中未更新（始终 0.0）。

**失败场景**: 5000 本书首次同步预计 2 分钟 → 用户只看到转圈无进度 → 以为卡死 → 杀 app。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — `_pullBooks()`, `SyncState.progress`

**修复方案**: Pull 过程中按 `已处理数 / 总数` 更新 `state.progress`。

**复杂度**: 低

---

#### 🟡 U-2: 同步失败无可操作的错误信息

**现状**: 异常 catch 后统一设置 `SyncStatus.error` + 泛化 message，不区分错误类型。

**失败场景**: Token 过期且 refresh 也失败 → 显示 "Sync failed" → 用户反复重试 → 其实应提示重新登录。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — 错误处理逻辑

**修复方案**: 按错误类型分类（网络不可达 / 认证失败 / 服务端错误），给出对应操作指引。

**复杂度**: 低

---

#### 🟢 U-3: 无手动冲突解决界面

**现状**: 标注冲突时 LWW 静默覆盖，无法恢复。

**失败场景**: 用户在 iPad 花 10 分钟写段落级长笔记 → 手机上旧版短笔记因时钟偏差覆盖 → 长笔记永久丢失。

**涉及文件**:
- `app/lib/service/sync/sync_manager.dart` — 标注冲突处理

**修复方案**: 对标注（尤其 note 类型）检测冲突时保留双版本，让用户选择保留哪个。

**复杂度**: 高

---

### 八、业界对标缺失特性

#### 🟡 B-1: 无 Tombstone / 软删除同步（对标 CouchDB）

**现状**: 删除操作（`is_deleted` 字段）不同步到其他设备。

**失败场景**: 用户在手机删除垃圾书 → iPad 同步后该书又"复活" → 反复删不掉。

**涉及文件**:
- `server/schema/book.go` — delta sync 已返回 `Deleted: []string`
- `app/lib/service/sync/sync_manager.dart` — 未处理 deleted 列表

**修复方案**: 客户端 Pull 时处理服务端返回的 `deleted` ID 列表（服务端基础设施已就绪）。

**复杂度**: 低

---

#### 🟡 B-2: 无同步日志/审计追踪（对标 Syncthing）

**现状**: 无记录"何时、哪个设备、同步了什么"。

**失败场景**: 用户发现笔记被覆盖 → 想排查是哪个设备什么时候覆盖的 → 无从追查。

**修复方案**: 客户端/服务端各维护最近 N 次同步日志（时间、设备 ID、推送/拉取条数、冲突数）。

**复杂度**: 低

---

#### 🟡 B-3: 无选择性同步（对标 Jellyfin / Immich）

**现状**: 无法让用户选择只同步某个书架或排除某类书籍。

**失败场景**: 500 本技术书 + 2000 本漫画，手机只想同步技术书 → 只能全量。

**修复方案**: 同步配置支持按 group/tag 过滤。

**复杂度**: 高

---

#### 🟢 B-4: 无端到端加密同步选项（对标 Syncthing）

**现状**: 数据以明文 JSON 传输。

**失败场景**: 用户通过 Tailscale 远程访问 NAS → 中继节点可见所有同步数据（书籍元数据、笔记内容）。

**修复方案**: 短期确保部署文档强调 HTTPS；长期可加 E2E 加密层。

**复杂度**: 低（HTTPS）/ 高（E2E）

---

## 修复优先级矩阵

| 优先级 | 编号 | 问题摘要 | 复杂度 | 建议排期 |
|--------|------|----------|--------|----------|
| **🔴 P0** | C-1 | 时间戳秒级截断丢数据 | 低 | Sprint 4 |
| **🔴 P0** | C-3 | 标注同步失败不可追踪 | 低 | Sprint 4 |
| **🔴 P0** | S-1 | Token 明文存储 | 低 | Sprint 4 |
| **🔴 P0** | C-2 + R-1 | Push 无 dirty 标记 + 崩溃状态分裂（建议一起做） | 中 | Sprint 4 |
| **🔴 P0** | M-1 | 客户端时钟偏移致 LWW 覆盖错误 | 中 | Sprint 4 |
| **🔴 P0** | P-1 | 万本书库 N+1 请求风暴 | 中 | Sprint 4 |
| **🟡 P1** | C-5 | 阅读进度回退不同步 | 低 | Sprint 5 |
| **🟡 P1** | C-4 | Book.Create DoNothing 丢元数据 | 低 | Sprint 5 |
| **🟡 P1** | B-1 | 删除不同步（服务端已就绪） | 低 | Sprint 5 |
| **🟡 P1** | U-1 | 首次同步无进度反馈 | 低 | Sprint 5 |
| **🟡 P1** | U-2 | 同步错误无分类 | 低 | Sprint 5 |
| **🟡 P1** | B-2 | 无同步审计日志 | 低 | Sprint 5 |
| **🟡 P1** | M-2 | AI 数据 synced 标志未接入 | 中 | Sprint 5 |
| **🟡 P1** | S-2 | Refresh token 无轮换 | 中 | Sprint 5 |
| **🟡 P1** | S-3 | SSE 端点无限流 | 低 | Sprint 5 |
| **🟡 P1** | P-2 | SSE 流无反压控制 | 中 | Sprint 5 |
| **🟡 P1** | P-3 | 标注比对 O(N) 逐条查询 | 中 | Sprint 5 |
| **🟡 P1** | D-1 | 本地/服务端 ID 映射脆弱 | 中 | Sprint 5 |
| **🟡 P1** | D-2 | Schema 版本无前向兼容 | 中 | Sprint 5 |
| **🟡 P1** | R-2 | SSE 断点续传 | 中 | Sprint 5 |
| **🟢 P2** | U-3 | 无手动冲突解决界面 | 高 | Backlog |
| **🟢 P2** | B-3 | 无选择性同步 | 高 | Backlog |
| **🟢 P2** | B-4 | 无 E2E 加密同步 | 高 | Backlog |

---

## 建议修复路线

### 第一批（1-2 天，6 个低复杂度 🔴 项）

1. **C-1**: 服务端 API 统一毫秒时间戳，客户端去掉 `* 1000`
2. **C-3**: 服务端标注同步返回 `failed_ids`
3. **S-1**: 引入 `flutter_secure_storage` 替换 SharedPreferences 存 token

### 第二批（3-5 天，架构调整）

4. **C-2 + R-1**: sqflite 增 `is_dirty` 字段 + sync checkpoint 持久化（一起做，共享基础设施）
5. **M-1**: 同步接口改用服务端时间戳（`received_at`）替代客户端时间戳
6. **P-1**: 实现 batch push API + dirty 标记联动

### 第三批（Sprint 5，P1 项按模块分批）

- 数据模型修复: C-4, C-5, D-1, B-1
- 安全加固: S-2, S-3
- 性能优化: P-2, P-3, R-2
- 体验提升: U-1, U-2, M-2, B-2, D-2
