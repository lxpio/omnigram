# Omnigram 实施进度索引

> **最后更新：2026-04-07**
> **参考设计：** `docs/superpowers/specs/2026-03-22-ambient-ai-reading-design.md`
> **审核报告：** `docs/superpowers/specs/2026-03-22-ambient-ai-reading-review.md`
> **已知问题：** `docs/superpowers/KNOWN_ISSUES.md`
> **测试策略：** `docs/testing-strategy.md`

---

## 总览

| 层级 | 名称 | 状态 | Sprint |
|------|------|------|--------|
| Layer 0 | 地基（设计系统 + 导航） | ✅ 完成 | Sprint 1 |
| Layer 1 | 核心阅读闭环 | ✅ 完成 | Sprint 1 |
| Layer 2 | AI 管道 | ✅ 完成 | Sprint 2 |
| Layer 3 | 隐形 AI（Ambient AI） | ✅ 完成 | Sprint 2/3 |
| Layer 3.5 | Server-Client 同步架构 | ✅ 完成 | Sprint 3.5 |
| Layer 4.0 | 架构迁移（PG + 去 WebDAV + AI 缓存） | ✅ 完成 | Sprint 4 Phase 0 |
| Layer 4.1 | 深度 AI（伴侣面板 + 边注 + 知识网络 + 语义搜索） | ✅ 完成 | Sprint 4 Phase 1 |
| Layer 5 | 高级体验 | 🔶 部分完成 | Sprint 5 |

---

## Layer 0 — 地基 ✅

> Sprint 1 · 全部完成

| 功能 | 设计文档章节 | 状态 | 关键文件 | 提交 |
|------|-------------|------|----------|------|
| 新 UI 设计系统（色彩、字体、主题） | §9 | ✅ | `theme/colors.dart`, `typography.dart`, `omnigram_theme.dart` | `ef62fe9` |
| 基础组件（OmnigramCard, EmptyState） | §9 | ✅ | `widgets/common/omnigram_card.dart`, `empty_state.dart` | `ef62fe9` |
| 四 Tab 导航框架 | §2.1 | ✅ | `page/omnigram_home.dart` | `37fd90f` |
| 响应式布局（手机 BottomBar / 桌面 NavigationRail） | §2.1 | ✅ | `page/omnigram_home.dart` | `37fd90f` |

---

## Layer 1 — 核心阅读闭环 ✅

> Sprint 1 · 全部完成

| 功能 | 设计文档章节 | 状态 | 关键文件 | 提交 |
|------|-------------|------|----------|------|
| 阅读 Tab "书桌" | §3 | ✅ | `page/home/desk_page.dart` | `53a116c` |
| ├─ 问候语 | §3.2 | ✅ | `widgets/desk/greeting_header.dart` | `53a116c` |
| ├─ Hero 当前在读卡片 | §3.2 | ✅ | `widgets/desk/hero_book_card.dart` | `53a116c` |
| ├─ 同时在读书架 | §3.2 | ✅ | `widgets/desk/also_reading_shelf.dart` | `53a116c` |
| └─ 每日阅读摘要 | §3.2 | ✅ | （集成在 desk_page） | `53a116c` |
| 书架 Tab | §4 | ✅ | `page/home/library_page.dart` | `696afa2` |
| ├─ 书籍网格 | §4.2 | ✅ | `widgets/library/book_grid_item.dart` | `696afa2` |
| ├─ 主题分区 | §4.2 | ✅ | `widgets/library/topic_section.dart` | `696afa2` |
| └─ 导入 FAB | §4.4 | ✅ | `widgets/library/import_button.dart` | `696afa2` |
| 洞察 Tab 骨架（纯数据，无 AI） | §6 | ✅ | `page/home/insights_page.dart` | `fcc46dc` |
| ├─ 阅读统计卡片 | §6.1 | ✅ | `widgets/insights/reading_summary_card.dart` | `fcc46dc` |
| ├─ 按书分组的笔记 | §6.2 | ✅ | `widgets/insights/notes_list.dart` | `fcc46dc` |
| └─ 时间段选择器 | §6.1 | ✅ | `widgets/insights/time_period_selector.dart` | `fcc46dc` |
| 设置页面框架 | §7.1 | ✅ | `page/home/settings_page.dart` | `b75733d` |
| 全屏沉浸式阅读器入口 | §5, §2.2 | ✅ | `page/reader/immersive_reader.dart` | `d4fde8c` |
| 阅读器 Chrome（Stub） | §5.2 | ✅ | `widgets/reader/reader_app_bar.dart` 等 | `d4fde8c` |

---

## Layer 2 — AI 管道 ✅

> Sprint 2 · 全部完成

| 功能 | 设计文档章节 | 状态 | 关键文件 | 提交 |
|------|-------------|------|----------|------|
| AI 服务抽象层（多 Provider 支持） | §10.6 | ✅ ¹ | `service/ai/index.dart`, `providers/ai_providers.dart` | (已有) |
| AI 降级机制 | §10.3 | ✅ | `service/ai/ai_availability.dart`, `providers/ai_availability_provider.dart` | `7e89ff2` |
| AI 后台处理管道（队列、缓存） | §10.6 | ✅ | `service/ai/ambient_ai_pipeline.dart` | `7e89ff2` |
| 任务类型定义 | §10.6 | ✅ | `service/ai/ambient_tasks.dart` | `7e89ff2` |
| TARS 伴侣人格配置 | §7.2 | ✅ | `models/companion_personality.dart` | `57635a0` |
| ├─ 四维滑条（主动性、风格、深度、温度） | §7.2 | ✅ | `page/settings_page/companion_settings_page.dart` | `57635a0` |
| ├─ 三个预设模板 | §7.2 | ✅ | `models/companion_personality.dart` (CompanionPresets) | `57635a0` |
| ├─ 实时预览 | §7.2 | ✅ | `page/settings_page/companion_settings_page.dart` | `57635a0` |
| └─ Prompt 工程框架 | §10.2 | ✅ | `service/ai/companion_prompt.dart` | `57635a0` |
| 伴侣人格持久化 | §7.2 | ✅ | `providers/companion_provider.dart` | `57635a0` |

¹ AI 服务抽象层为 Anx Reader 原有基础设施（LangChain + 多模型 + 流式 + 工具 + 缓存 + RPM 限流），非本次新建。

---

## Layer 3 — 隐形 AI（Ambient AI） 🔶

> Sprint 2 部分完成 + Sprint 3 待完成

| 功能 | 设计文档章节 | 状态 | 关键文件 | 提交 |
|------|-------------|------|----------|------|
| **阅读器 AI Layer 1：Context Bar** | §5.1 | ✅ | `widgets/reader/context_bar.dart` | `f8cfaf4` |
| ├─ 章节切换自动触发 | §5.1 | ✅ | 监听 `currentReadingProvider` | `f8cfaf4` |
| ├─ AI 生成上下文 + 淡入/淡出动画 | §5.1 | ✅ | 8 秒自动隐藏 | `f8cfaf4` |
| └─ 无 AI 时降级为章节标题 | §10.3 | ✅ | | `f8cfaf4` |
| **书桌 Memory Bridge** | §3.3 | ✅ | `widgets/desk/hero_book_card.dart` (memoryText) | `f8cfaf4` |
| **书籍导入 AI 处理** | §4.4 Phase 2 | ✅ | `service/ai/post_import_ai.dart` | `d4f355e` |
| ├─ 自动标签 | §4.3 | ✅ | AmbientTasks.autoTag() | `d4f355e` |
| └─ 一句话摘要 | §4.3 | ✅ | AmbientTasks.summary() | `d4f355e` |
| **阅读器 AI Layer 2：Inline Glossary** | §5.1 | ✅ | `widgets/reader/glossary_tooltip.dart` | `12e449f` |
| ├─ 选词自动浮现释义 | §5.1 | ✅ | `widgets/context_menu/excerpt_menu.dart` (Explain 按钮) | `12e449f` |
| └─ 自动检测难词 | §5.1 | ✅ | `page/book_player/epub_player.dart` | `97ac9ba` |
| **书架 AI 功能** | §4.3 | ✅ | | |
| ├─ AI 推荐卡 | §4.2 | ✅ | `widgets/library/ai_recommendation_card.dart` | `e4bdf3f` |
| ├─ 智能分组（主题聚合） | §4.3 | ✅ | `page/home/library_page.dart` | `9ac37e4` |
| └─ 语义搜索 | §4.2 | ✅ | Sprint 4 完成 |
| **洞察 Layer 1 升级：AI 叙事** | §6.1 | ✅ | `widgets/insights/ai_narrative_card.dart` | `d6c2fc2` |
| └─ AI 生成阅读旅程叙述 | §6.1 | ✅ | `page/home/insights_page.dart` | `d6c2fc2` |

---

## Layer 3.5 — Server-Client 同步架构 ✅

> Sprint 3.5 · 同步架构全部完成（7 内部 + 22 外部审核缺口已修复）

| 功能 | 状态 | 关键文件 | 提交 |
|------|------|----------|------|
| **Phase 1: API Client 基础** | ✅ | | |
| ├─ Server 数据模型（freezed） | ✅ | `models/server/server_*.dart` (8 files) | `b6b2098` |
| ├─ OmnigramApi HTTP 客户端（Dio） | ✅ | `service/api/omnigram_api.dart` | `b6b2098` |
| ├─ Auth API | ✅ | `service/api/auth_api.dart` | `b6b2098` |
| ├─ Server 连接 Provider | ✅ | `providers/server_connection_provider.dart` | `b6b2098` |
| └─ Server 连接设置 UI | ✅ | `page/settings_page/server_connection_page.dart` | `b6b2098` |
| **Phase 2: 全部 Service APIs** | ✅ | | |
| ├─ Book API（CRUD/搜索/上传/下载） | ✅ | `service/api/book_api.dart` | `b6b2098` |
| ├─ Annotation API（CRUD/批量同步） | ✅ | `service/api/annotation_api.dart` | `b6b2098` |
| ├─ Progress API（进度/会话） | ✅ | `service/api/progress_api.dart` | `b6b2098` |
| ├─ Shelf/Tag API | ✅ | `service/api/shelf_api.dart` | `b6b2098` |
| ├─ Sync API + Stats API | ✅ | `service/api/sync_api.dart` | `b6b2098` |
| ├─ System/Admin API | ✅ | `service/api/system_api.dart` | `b6b2098` |
| └─ TTS API | ✅ | `service/api/tts_api.dart` | `b6b2098` |
| **Phase 3: 同步引擎** | ✅ | | |
| ├─ SyncManager 双向增量同步 | ✅ | `service/sync/sync_manager.dart` | `e25d317` |
| ├─ SyncStatusIndicator UI | ✅ | `widgets/common/sync_status_indicator.dart` | `037eeae` |
| ├─ 客户端调用 /sync/delta 增量同步 | ✅ | `service/sync/sync_manager.dart` | `e25d317` |
| ├─ lastSyncTime 持久化 | ✅ | `service/sync/sync_manager.dart` | `e25d317` |
| ├─ 登录后立即触发同步 | ✅ | `server_connection_page.dart` | `e25d317` |
| ├─ 离线操作队列 | ✅ | `service/sync/sync_manager.dart` | batch2 |
| ├─ 同步重试（指数退避） | ✅ | `service/sync/sync_manager.dart` | batch2 |
| ├─ 书籍文件按需下载 | ✅ | `service/sync/sync_manager.dart` | batch2 |
| ├─ 冲突日志 / 用户通知 | ✅ | `service/sync/sync_manager.dart` | batch2 |
| └─ 同步分页拉取（大库防 OOM） | ✅ | `service/sync/sync_manager.dart` | batch2 |
| **Phase 4: Server 新端点（Go）** | ✅ | | |
| ├─ GET/PUT /user/companion | ✅ | `server/service/user/handler_companion.go` | `368ff32` |
| ├─ GET /reader/books/:id/ai | ✅ | `server/service/reader/handler_ai.go` | `368ff32` |
| └─ CompanionProfile schema | ✅ | `server/schema/companion_profile.go` | `368ff32` |
| **Phase 5: Client 集成** | ✅ | | |
| ├─ 启动时自动同步 + 定时同步 | ✅ | `main.dart` | `0347391` |
| ├─ 伴侣人格双向同步 | ✅ | `providers/companion_provider.dart` | `0347391` |
| └─ PostImport AI 服务端优先 | ✅ | `service/ai/post_import_ai.dart` | `0347391` |

### 同步质量缺口说明

> ⚠️ 2026-03-24 审计发现：Phase 3 标注为"双向增量同步"，实际客户端为**双向全量同步**。
> 服务端 `/sync/delta` 端点已实现（基于 `utime` 时间戳），但客户端 `SyncManager._pullBooks()` 调用
> 的是 `bookApi.listBooks()` 全量拉取，未使用增量 API。
>
> 另发现 `healthCheck()` 校验值不匹配（客户端检查 `"ok"`，服务端返回 `"healthy"`），已修复。
>
> **外部审核报告：** `docs/superpowers/specs/2026-03-24-sync-architecture-audit.md`

#### 内部自查缺口（7 项）

| 优先级 | 缺口 | 影响 | 修复复杂度 |
|--------|------|------|-----------|
| ✅ 已修复 | 客户端未用 delta API | 书库 1000+ 每次同步流量大、耗时长 | 低 |
| ✅ 已修复 | lastSyncTime 不持久化 | 每次重启全量同步，无法真正增量 | 低 |
| ✅ 已修复 | 无离线操作队列 | 离线编辑笔记/标注恢复网络后不补推 | 中（需新建 pending_ops 表） |
| ✅ 已修复 | 书籍文件不同步 | 新设备只有元数据无法阅读 | 中（按需下载 + 缓存管理） |
| ✅ 已修复 | 无同步重试 | 网络抖动时同步直接失败 | 低（指数退避包装） |
| ✅ 已修复 | 冲突静默覆盖 | 用户不知道数据被服务端覆盖 | 低（日志 + toast） |
| ✅ 已修复 | 大库拉取无分页 | 万本级别可能 OOM | 中（服务端已支持分页） |

#### 外部审核发现（22 项，详见审核报告）

**数据一致性（5 项）**

| 编号 | 优先级 | 问题 | 复杂度 |
|------|--------|------|--------|
| C-1 | ✅ 已修复 | 时间戳秒级截断丢数据（服务端秒 vs 客户端毫秒） | 低 |
| C-2 | ✅ 已修复 | Push 无 dirty 标记，全量逐本推送，崩溃后级联刷新 uTime | 中 |
| C-3 | ✅ 已修复 | 标注同步部分失败不可追踪（仅返回 synced 总数） | 低 |
| C-4 | ✅ 已修复 | Book.Create 使用 DoNothing，优质元数据被静默丢弃 | 低 |
| C-5 | ✅ 已修复 | 阅读进度同步单向有损（回退重读无法同步） | 低 |

**安全性（3 项）**

| 编号 | 优先级 | 问题 | 复杂度 |
|------|--------|------|--------|
| S-1 | ✅ 已修复 | Token 明文存储在 SharedPreferences（应用 KeyStore/Keychain） | 低 |
| S-2 | ✅ 已修复 | Refresh token 无轮换机制（旧 token 不吊销） | 中 |
| S-3 | ✅ 已修复 | SSE 全量同步端点无速率限制 | 低 |

**性能与可扩展性（3 项）**

| 编号 | 优先级 | 问题 | 复杂度 |
|------|--------|------|--------|
| P-1 | ✅ 已修复 | Push 阶段 N+1 请求风暴（万本 = 万次 HTTP） | 中 |
| P-2 | ✅ 已修复 | SSE 流无反压控制（低端设备致连接池耗尽） | 中 |
| P-3 | ✅ 已修复 | Pull 标注比对 O(N) 逐条查询（5000 条标注 ≈ 60 秒） | 中 |

**多设备场景（2 项）**

| 编号 | 优先级 | 问题 | 复杂度 |
|------|--------|------|--------|
| M-1 | ✅ 已修复 | 客户端时钟偏移致 LWW 覆盖错误（NAS 场景常见） | 中 |
| M-2 | ✅ 已修复 | AI 数据类型（companion_chat/margin_notes/concept 等）synced 标志未接入 SyncManager | 中 |

**错误恢复（2 项）**

| 编号 | 优先级 | 问题 | 复杂度 |
|------|--------|------|--------|
| R-1 | ✅ 已修复 | 同步非原子，中途崩溃导致状态分裂（Push 成功 Pull 失败 → 旧数据覆盖新数据） | 中 |
| R-2 | ✅ 已修复 | SSE 流中断后无断点续传 | 中 |

**数据模型（2 项）**

| 编号 | 优先级 | 问题 | 复杂度 |
|------|--------|------|--------|
| D-1 | ✅ 已修复 | 本地 ID 与服务端 ID 映射脆弱（标注可能挂到错误的书上） | 中 |
| D-2 | ✅ 已修复 | Schema 版本无前向兼容（服务端升级后旧客户端字段丢失） | 中 |

**用户体验（3 项）**

| 编号 | 优先级 | 问题 | 复杂度 |
|------|--------|------|--------|
| U-1 | ✅ 已修复 | 首次同步无进度反馈（progress 字段未更新） | 低 |
| U-2 | ✅ 已修复 | 同步失败无可操作的错误分类 | 低 |
| U-3 | ✅ 已修复 | 无手动冲突解决界面 | 高 |

**业界对标缺失（4 项）**

| 编号 | 优先级 | 问题 | 复杂度 |
|------|--------|------|--------|
| B-1 | ✅ 已修复 | 无 Tombstone 删除同步（服务端已返回 deleted 列表，客户端未处理） | 低 |
| B-2 | ✅ 已修复 | 无同步审计日志 | 低 |
| B-3 | ✅ 已修复 | 无选择性同步（按书架/标签过滤） | 高 |
| B-4 | ✅ 已修复 | 无端到端加密同步选项 | 高 |

#### 修复路线（审核建议）

| 批次 | 范围 | 预计工作量 |
|------|------|-----------|
| **第一批** | C-1, C-3, S-1（低复杂度 🔴 项） | 1-2 天 |
| **第二批** | C-2+R-1（dirty 标记+checkpoint）, M-1（服务端时间戳）, P-1（batch push） | 3-5 天 |
| **第三批** | Sprint 5 P1 项按模块分批 | 见审核报告 |

### 延期到 Sprint 4 的任务

| 功能 | 原因 |
|------|------|
| ~~AI 缓存持久化（sqflite）~~ | ✅ Sprint 4 Phase 0 完成 |
| ~~WebDAV 降级为兼容模式 UI~~ | ✅ Sprint 4 Phase 0：完全移除 WebDAV |

---

## Layer 4 Phase 0 — 架构迁移 ✅

> Sprint 4 Phase 0 · 全部完成
> **设计决策文档：** `docs/superpowers/specs/2026-03-23-sprint4-design-decisions.md`

| 功能 | 状态 | 关键文件 | 提交 |
|------|------|----------|------|
| **Server: PG + pgvector 统一** | ✅ | | `b0561db` |
| ├─ 移除 SQLite driver（保留 Calibre 导入） | ✅ | `store/store.go`, `store/orm.go`, `conf/db_opts.go` | |
| ├─ FTS5 → PG tsvector + GIN 索引 | ✅ | `schema/init_data.go` | |
| ├─ FTS5 搜索 → tsvector 搜索 | ✅ | `service/reader/handler_search.go` | |
| ├─ pgvector 扩展初始化 | ✅ | `schema/init_data.go` | |
| └─ docker-compose PG 容器 | ✅ | `docker-compose.yml` | |
| **Server: 完全移除 WebDAV** | ✅ | | `b0561db` |
| ├─ 删除 webdav 包 | ✅ | ~~`service/webdav/`~~ | |
| └─ BasicAuth 迁移到 middleware | ✅ | `middleware/basic_auth.go` | |
| **Client: 完全移除 WebDAV** | ✅ | | `0a62e53` |
| ├─ 删除 9 个 WebDAV 相关文件 | ✅ | | |
| ├─ 清理 14 个文件中的 WebDAV 引用 | ✅ | | |
| └─ 移除 webdav_client 依赖 | ✅ | `pubspec.yaml` | |
| **AI 缓存持久化** | ✅ | | `d7ab94c` |
| ├─ Client: sqflite ai_cache 表（DB v8） | ✅ | `dao/ai_cache.dart`, `dao/database.dart` | |
| ├─ Client: AmbientAiPipeline 双层缓存 | ✅ | `service/ai/ambient_ai_pipeline.dart` | |
| ├─ Server: AiResult schema + AutoMigrate | ✅ | `schema/ai_result.go`, `schema/init_data.go` | |
| └─ Server: AI cache CRUD endpoints | ✅ | `service/reader/handler_ai.go`, `setup.go` | |

---

## Layer 4 Phase 1 — 深度 AI ✅

> Sprint 4 Phase 1 · 全部完成

| 功能 | 设计文档章节 | 状态 | 关键文件 | 提交 |
|------|-------------|------|----------|------|
| **阅读器 AI Layer 4：Companion Panel** | §5.1 | ✅ | | `d151bbb` |
| ├─ 底部滑出双向对话面板 | §5.1 | ✅ | `widgets/reader/companion_panel.dart` | |
| ├─ CompanionChatDao 聊天持久化 | §5.1 | ✅ | `dao/companion_chat.dart` | |
| ├─ DB v9: tb_companion_chat | §5.1 | ✅ | `dao/database.dart` | |
| ├─ Server companion chat endpoints | §5.1 | ✅ | `server/service/reader/handler_companion.go` | |
| └─ 集成到 reading_page 工具栏 | §5.1 | ✅ | `page/reading_page.dart` | |
| **阅读器 AI Layer 3：Margin Notes** | §5.1 | ✅ | | `d151bbb` |
| ├─ 跨书关联页边批注 | §5.1 | ✅ | `widgets/reader/margin_notes_overlay.dart` | |
| ├─ 每章最多 3 条 | §5.1 | ✅ | | |
| ├─ 置信度过滤 + 用户反馈 | 审核建议 #3 | ✅ | `dao/margin_note.dart` | |
| ├─ DB v10: tb_margin_notes | §5.1 | ✅ | `dao/database.dart` | |
| └─ Server margin notes endpoints | §5.1 | ✅ | `server/service/reader/handler_companion.go` | |
| **TTS 伴侣声音关联** | §5.3 | ✅ | | `161034c` |
| ├─ CompanionPersonality 添加 voice 字段 | §5.3 | ✅ | `models/companion_personality.dart` | |
| ├─ 伴侣设置页声音选择器 | §5.3 | ✅ | `page/settings_page/companion_settings_page.dart` | |
| └─ Server CompanionProfile Voice 字段 | §5.3 | ✅ | `server/schema/companion_profile.go` | |
| **知识网络（洞察 Layer 2）** | §6.1 Layer 2 | ✅ | | `22d299d` |
| ├─ ConceptTag + ConceptEdge 数据模型 | §6.1 | ✅ | `dao/concept_tag.dart`, `server/schema/concept.go` | |
| ├─ AI 概念提取管道 | §6.1 | ✅ | `service/ai/concept_extractor.dart` | |
| ├─ AI 叙事驱动的动态图可视化 | §6.1 | ✅ | `widgets/insights/knowledge_graph_card.dart` | |
| ├─ DB v11: tb_concept_tags + tb_concept_edges | §6.1 | ✅ | `dao/database.dart` | |
| ├─ Server knowledge graph endpoints | §6.1 | ✅ | `server/service/reader/handler_knowledge.go` | |
| └─ 集成到洞察页 | §6.1 | ✅ | `page/home/insights_page.dart` | |
| **语义搜索（pgvector）** | §4.2 | ✅ | | `5c21095` |
| ├─ Server embedding 生成服务 | §10.2 | ✅ | `server/service/ai/embedding.go` | |
| ├─ embedding vector(1536) + HNSW 索引 | §10.2 | ✅ | `server/schema/init_data.go` | |
| ├─ 搜索处理器 mode 参数（text/semantic） | §4.2 | ✅ | `server/service/reader/handler_search.go` | |
| ├─ 导入时自动生成 embedding | §4.4 | ✅ | `server/service/reader/hander_book.go` | |
| ├─ Client 搜索模式切换 UI | §4.2 | ✅ | `page/search/search_page.dart` | |
| └─ EmbeddingModel 配置 | §10.6 | ✅ | `server/conf/config.go` | |

---

## Layer 5 — 高级体验 ❌

> Sprint 5 · 未开始

| 功能 | 设计文档章节 | 状态 | 关键文件 | 提交 |
|------|-------------|------|----------|------|
| **跨书连接（洞察 Layer 3）** | §6.1 Layer 3 | ✅ | `widgets/insights/cross_book_card.dart` | `708aba7` |
| ├─ 跨书主题关联（非认知推断） | 审核建议 #1 | ✅ | `page/home/insights_page.dart` | `2c30448` |
| └─ "Record my thought" 按钮 | §6.1 | ✅ | `widgets/insights/record_thought_sheet.dart` | `2c30448` |
| **隐身书房** | §8 | ❌ | | |
| ├─ 独立加密空间 | §8.2 | ❌ | | |
| ├─ Platform Keystore 密钥管理 | §10.4 | ❌ | | |
| ├─ 隐藏入口 + 生物识别 | §7.3, §8.2 | ❌ | | |
| ├─ AI 数据完全隔离 | §8.2 | ❌ | | |
| └─ 快速锁定 + 卸载策略 | §10.4 | ❌ | | |

---

## 跨层级功能（设计文档中已定义但尚未排期）

| 功能 | 设计文档章节 | 状态 | 备注 |
|------|-------------|------|------|
| ~~**🔴 Server-Client REST API 同步**~~ | §10.7 | ✅ | Sprint 3.5 完成：全量 API 客户端 + 双向增量同步 |
| ~~**🔴 AI 处理去重**~~ | §4.4 | ✅ | Server 连接时跳过 Client AI，改用 Server 结果 |
| ~~**🟡 AI 缓存持久化**~~ | §10.6 | ✅ | Sprint 4 Phase 0 完成：Client sqflite + Server PG 双层缓存 |
| ~~**🟡 伴侣人格同步**~~ | §10.7 | ✅ | Sprint 3.5：双向同步（SharedPrefs + Server） |
| Onboarding 流程 | §10.8 | ✅ | `page/onboarding_flow.dart` — 渐进式 2 步引导（语言+导入） |
| 多设备同步 | §10.7 | ⚠️ 部分 | 数据架构已定义。M-1(时钟偏移) M-2(AI 数据同步) 已修复。KI-1 AI 数据双向同步已修复（2026-04-04）。完整多设备测试待验证 |
| 🔴 同步质量加固 | 审核报告 | ✅ | 22 项全部关闭，详见 `specs/2026-03-24-sync-architecture-audit.md` |
| 数据导出/迁移 | §10.9 | ✅ | 全库笔记 Markdown 导出 + 知识网络 JSON 导出 · `service/export/data_export.dart` |
| 外部高亮导入（Kindle） | §10.9 | ✅ | `service/import/kindle_import.dart` — My Clippings.txt 解析+导入 |
| 阅读器 Chrome 重写 | §5.2 | ✅ | `widgets/reader/reader_chrome.dart`, `reader_app_bar.dart`, `reader_bottom_bar.dart` · `b2cd962` |
| 空状态受伴侣性格影响 | §10.5 | ✅ | `widgets/common/empty_state_config.dart`, `models/warmth_tier.dart` · `188ed53` |
| AI 处理预算（用户可配置） | §10.6 | ✅ | 后台 AI 总开关 + 并发限制信号量 · `ambient_ai_pipeline.dart` |
| PDF 支持 | §10.2 | ❌ | 设计文档明确 defer |
| 伴侣行为开关（5 个 toggle） | §7.2 | ✅ | `companion_personality.dart`, `companion_settings_page.dart` · `e8f9757` |
| 伴侣名称自定义 | §7.2 | ✅ ¹ | 已在 `companion_settings_page.dart` 中实现（TextField） |
| 书籍详情页重设计 | — | ✅ | `page/book_detail.dart`, `widgets/book_detail/` · `a58922e` |
| OPDS 目录 | §10.9 | ✅ ¹ | 服务端已有 |

> **架构修正文档：** `docs/superpowers/specs/2026-03-23-sync-architecture.md`

¹ 服务端 OPDS 已实现（`server/service/opds/`），客户端集成未完成。

---

## 测试状态

> **测试策略文档：** `docs/testing-strategy.md`

### App 端测试

| 层级 | 工具 | 优先级 | 状态 | 备注 |
|------|------|--------|------|------|
| L1 静态分析 | `flutter analyze` | P0 | ✅ 已用 | 0 errors，每次提交前运行 |
| L2 自动爬虫 | Firebase Robo Test | P0 | ⚠️ CI 已配置 | `test-robo.yaml` 已创建，需 GCP secrets |
| L3 视觉回归 | Golden Test | P1 | ❌ 未搭建 | 关键页面截图 diff，零 golden 文件 |
| L4 E2E 流程 | Maestro | P2 | ❌ 未搭建 | 备选方案 |

### Server 端测试

| 层级 | 工具 | 优先级 | 状态 | 备注 |
|------|------|--------|------|------|
| L1 静态分析 | `go vet` / `staticcheck` | P0 | ⚠️ 部分 | go build 通过，staticcheck 未接入 CI |
| L2 数据层 | `go test ./schema/...` | P0 | ⚠️ 跳过 | DB 集成测试加 `integration` build tag，由 Hurl 覆盖 |
| L3 Swagger Fuzz | Schemathesis | P0 | ⚠️ CI 已配置 | `test-api.yaml` 中 continue-on-error |
| L4 API 冒烟 | Hurl | P0 | ✅ 已搭建 | 34 requests，覆盖 health/auth/books/tags/sync/system |

### AI 服务测试

| 层级 | 方式 | 状态 | 备注 |
|------|------|------|------|
| L1 契约测试 | Fixture + 结构断言 | ✅ 已搭建 | 12 tests, 4 fixtures (`testdata/ai/`) |
| L2 错误处理 | httptest 返回 429/500 | ✅ 已覆盖 | ai_test.go 含错误场景 |
| L3 真实调用 | 重新录制 fixtures | ❌ 未搭建 | 每周/手动 |

### App ↔ Server 集成测试

| 层级 | 工具 | 状态 | 备注 |
|------|------|------|------|
| L1 API Client 集成 | Dart `integration_test` | ✅ 已搭建 | 17 tests，覆盖 auth/books/sync/tags/shelves |
| L2 全链路 E2E | Maestro + Docker | ❌ 未搭建 | P2 备选 |

### CI Workflows

| 文件 | 用途 | 状态 | 备注 |
|------|------|------|------|
| `.github/workflows/test-robo.yaml` | App Robo Test | ✅ 已创建 | 需 GCP secrets |
| `.github/workflows/test-api.yaml` | Server + 集成测试 | ✅ 已创建 | Hurl + Schemathesis + Dart 集成 |
| `.github/workflows/docker.yaml` | Docker 镜像构建 | ✅ 已有 | tag push 触发 |
| `.github/workflows/build_app.yaml` | Flutter APK 构建 | ✅ 已有 | push/PR 触发 |

---

## 基础设施状态

| 组件 | 状态 | 备注 |
|------|------|------|
| Server (Go) | ✅ | PG + pgvector 统一，WebDAV 已移除 |
| Server Docker | ✅ | docker-compose: pgvector/pgvector:pg17 |
| Android 构建 | ✅ | AGP 8.9.1, Gradle 8.11.1, compileSdk 36 |
| iOS 构建 | ✅ | Debug 真机运行正常（2026-03-23 验证） |
| macOS 构建 | ⚠️ | 需要 Mac Development 签名证书（Team ID 28W956D5K8） |
| Release APK | ⚠️ | 缺少 keystore 配置 |
| Debug APK | ✅ | 正常构建 |
| Flutter Analyze | ✅ | 0 errors, warnings 仅 unused elements |
| Codegen (build_runner) | ✅ | freezed + riverpod + json_serializable |
| L10n | ✅ | 16 语言，含新增 key |
| 数据库版本 | v13 | 新增 tb_ai_cache(v8), tb_companion_chat(v9), tb_margin_notes(v10), tb_concept_tags+edges(v11), is_dirty(v12), tb_id_mapping(v13) |

---

## 审核报告关键问题追踪

| # | 问题 | 严重程度 | 状态 | 处理方式 |
|---|------|---------|------|---------|
| 1 | "认知变化追踪"是伪功能 | 🔴 Critical | ✅ 已采纳 | 设计文档已修改：降级为"跨书主题关联"，不做认知推断 |
| 2 | 知识图谱方案未决 | 🔴 Critical | ✅ 已采纳 | 设计文档已修改：采用 tag-based 聚合方案 |
| 3 | 缺少多设备同步设计 | 🔴 Critical | ✅ 已采纳 | 设计文档已新增 §10.7 数据架构 |
| 4 | 隐身书房加密方案有误 | 🟡 Major | ✅ 已采纳 | 设计文档已修正 §10.4 |
| 5 | NAS AI 处理负担 | 🟡 Major | 🔶 部分 | 管道优先级已实现，AI 预算配置未实现 |

---

## 更新记录

| 日期 | 更新内容 |
|------|---------|
| 2026-04-07 | **Kindle 高亮导入** ✅：My Clippings.txt 解析（多语言类型检测），按书名模糊匹配，Highlight+Note 合并，去重导入 |
| 2026-04-07 | **Layer 5 跨书连接** ✅：跨书发现列表（ConceptEdge 跨书过滤 + 卡片展示）+ "Record my thought" 思考日记（tb_thoughts DB v14 + bottom sheet + 时间线展示）+ InsightsPage FAB |
| 2026-04-05 | **AI 处理预算** ✅：后台 AI 总开关（backgroundAiEnabled）+ 并发限制信号量（maxConcurrentAiTasks），设置页 AI 预算卡片 |
| 2026-04-05 | **数据导出** ✅：全库笔记 Markdown 导出 + 知识网络 JSON 导出。设置页新增"数据"分区 |
| 2026-04-05 | **Onboarding 流程** ✅：渐进式 2 步引导（语言选择 + 导入书籍/连接服务端），接入 OmnigramHome 首次启动检测 |
| 2026-04-05 | **Layer 3 补全** ✅：自动检测难词（章节切换触发 AI 扫描，虚线下划线高亮，点击显示释义）+ 智能分组（书架按 AI 标签主题聚合为 TopicSection） |
| 2026-04-05 | **KI-2 国际化缺口修复** ✅：批次 A — 3 处 AI prompt 改为英文 + `Reply in {language}`。批次 B — ~50 个硬编码中文字符串移入 L10n ARB（16 文件），新增 ~50 个 ARB key |
| 2026-04-04 | **KI-1/KI-3/KI-4 同步缺口修复** ✅：Companion Chat、Margin Notes、Concept Tags/Edges 双向同步完成。Server GET 端点增加 delta pull（since + server_time）。Push 侧 book ID 映射修复（KI-4），concept tag ID 映射修复（KI-3）。Server Wins 冲突策略 |
| 2026-04-02 | **书籍详情页重设计完成** ✅：从 760 行信息陈列柜重写为行动导向的"书的灵魂页"（~500行）。封面主色渐变、继续阅读按钮、AI 一句话总结、最近笔记预览。砍掉虚荣指标。54 tests 全绿 |
| 2026-04-02 | **阅读器 Chrome 重构完成** ✅：从 reading_page.dart（916行→848行）抽取 chrome 到 3 个独立 widget（ReaderAppBar + ReaderBottomBar + ReaderChrome），Omnigram 视觉风格，进度条 + 按钮两层底栏，slide 动画。51 tests 全绿 |
| 2026-04-02 | **伴侣行为开关完成** ✅：5 toggle（2 enabled + 3 Coming Soon），CompanionPersonality 扩展 5 bool 字段，Server 同步改用 toJson/fromJson，AI guard 接入 margin notes + concept extractor。41 tests 全绿 |
| 2026-04-02 | **空状态性格化完成** ✅：4 页面空状态根据伴侣 warmth 三档适配（Lottie/SVG/Icon + 16 语言文案）。新增 WarmthTier、EmptyStateData、EmptyStateConfig、warmthTierProvider。EmptyState 组件升级支持 Widget visual。23 tests 全绿 |
| 2026-03-25 | **巩固：测试全绿 + 文档校正。** Go 测试：修复 conf/store 路径问题，schema/sys 加 `integration` build tag（`go test ./...` 全绿）。Dart 测试：补 main 方法（`flutter test test/` 全绿）。CI：修复 Hurl 变量名 username→account。PROGRESS.md：同步质量加固 ✅、测试状态表全面更新、DB 版本 v11→v13 |
| 2026-03-24 | **Layer 3.5 同步架构全部完成** ✅：第二批修复 22 项外部审核缺口全部关闭。服务端：C-4 DoUpdates 元数据保留、S-2 Refresh token 轮换、S-3 速率限制、P-1 批量推送端点、M-1 server_time LWW、P-2 SSE 反压、R-2 SSE 断点续传、B-2 审计日志、D-2 版本协商。客户端：同步重试指数退避、U-2 错误分类、冲突日志通知、R-1 原子 checkpoint、M-2 AI 数据类型同步、P-3 标注 O(1) 批量比对、离线操作队列、书籍文件按需下载、分页拉取、D-1 ID 映射表(DB v13)、U-3 冲突解决页面、B-3 选择性同步设置、B-4 E2E 加密基础 |
| 2026-03-24 | Layer 3.5 同步质量审计：补充外部审核发现 22 项（C-1~B-4），含 6 项 🔴 P0 + 13 项 🟡 P1 + 3 项 🟢 P2，关联审核报告 `specs/2026-03-24-sync-architecture-audit.md` |
| 2026-03-24 | Layer 3.5 同步质量审计：标注实际为全量同步（非增量），补充 7 项同步缺口（P0~P2），修复 healthCheck 校验值不匹配、登录后未触发同步 |
| 2026-03-24 | 新增测试状态跟踪章节。更新 iOS 构建状态为已验证。修复导入卡住 bug（AnxToast null context） |
| 2026-03-23 | Sprint 4 Phase 1 完成。Companion Panel、Margin Notes、TTS 声音关联、知识网络（AI 叙事+图可视化）、语义搜索（pgvector embedding） |
| 2026-03-23 | Sprint 4 Phase 0 完成。Server PG+pgvector 迁移、WebDAV 完全移除（Client+Server）、AI 缓存持久化（sqflite+PG 双层） |
| 2026-03-23 | Sprint 3.5 完成。Server-Client 同步架构就绪：全量 API 客户端、双向增量同步、Server 新端点、伴侣同步、AI 去重 |
| 2026-03-23 | Sprint 3 完成。Layer 3 全部主要功能就绪（Inline Glossary, 书架 AI 推荐, 洞察 AI 叙事） |
| 2026-03-22 | 初始创建。Sprint 1 全部完成，Sprint 2 全部完成 |
