# Omnigram 实施进度索引

> **最后更新：2026-03-24**
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
| Layer 5 | 高级体验 | ❌ 未开始 | Sprint 5 |

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
| └─ 自动检测难词 | §5.1 | ❌ | | |
| **书架 AI 功能** | §4.3 | ✅ | | |
| ├─ AI 推荐卡 | §4.2 | ✅ | `widgets/library/ai_recommendation_card.dart` | `e4bdf3f` |
| ├─ 智能分组（主题聚合） | §4.3 | ❌ | | |
| └─ 语义搜索 | §4.2 | ✅ | Sprint 4 完成 |
| **洞察 Layer 1 升级：AI 叙事** | §6.1 | ✅ | `widgets/insights/ai_narrative_card.dart` | `d6c2fc2` |
| └─ AI 生成阅读旅程叙述 | §6.1 | ✅ | `page/home/insights_page.dart` | `d6c2fc2` |

---

## Layer 3.5 — Server-Client 同步架构 ✅

> Sprint 3.5 · 全部完成

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
| ├─ SyncManager 双向增量同步 | ✅ | `service/sync/sync_manager.dart` | `037eeae` |
| └─ SyncStatusIndicator UI | ✅ | `widgets/common/sync_status_indicator.dart` | `037eeae` |
| **Phase 4: Server 新端点（Go）** | ✅ | | |
| ├─ GET/PUT /user/companion | ✅ | `server/service/user/handler_companion.go` | `368ff32` |
| ├─ GET /reader/books/:id/ai | ✅ | `server/service/reader/handler_ai.go` | `368ff32` |
| └─ CompanionProfile schema | ✅ | `server/schema/companion_profile.go` | `368ff32` |
| **Phase 5: Client 集成** | ✅ | | |
| ├─ 启动时自动同步 + 定时同步 | ✅ | `main.dart` | `0347391` |
| ├─ 伴侣人格双向同步 | ✅ | `providers/companion_provider.dart` | `0347391` |
| └─ PostImport AI 服务端优先 | ✅ | `service/ai/post_import_ai.dart` | `0347391` |

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
| **跨书连接（洞察 Layer 3）** | §6.1 Layer 3 | ❌ | | |
| ├─ 跨书主题关联（非认知推断） | 审核建议 #1 | ❌ | | |
| └─ "Record my thought" 按钮 | §6.1 | ❌ | | |
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
| Onboarding 流程 | §10.8 | ❌ | 渐进式引导，首次使用零 AI |
| 多设备同步 | §10.7 | ❌ | 数据架构已定义，实现待排期 |
| 数据导出/迁移 | §10.9 | ❌ | Markdown/JSON/CSV 导出 |
| 外部高亮导入（Kindle/Apple Books） | §10.9 | ❌ | |
| 阅读器 Chrome 重写 | §5.2 | ❌ | 当前用 stub，完整 chrome 待实现 |
| 空状态受伴侣性格影响 | §10.5 | ❌ | 审核建议 #5 |
| AI 处理预算（用户可配置） | §10.6 | ❌ | 审核建议 #5（NAS 资源控制） |
| PDF 支持 | §10.2 | ❌ | 设计文档明确 defer |
| 伴侣行为开关（5 个 toggle） | §7.2 | ❌ | 章节回顾/难词标注/跨书提醒等 |
| 伴侣名称自定义 | §7.2 | ❌ | |
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
| L2 自动爬虫 | Firebase Robo Test | P0 | ❌ 未搭建 | 需要 GCP 配置 + CI workflow |
| L3 视觉回归 | Golden Test | P1 | ❌ 未搭建 | 关键页面截图 diff，零 golden 文件 |
| L4 E2E 流程 | Maestro | P2 | ❌ 未搭建 | 备选方案 |

### Server 端测试

| 层级 | 工具 | 优先级 | 状态 | 备注 |
|------|------|--------|------|------|
| L1 静态分析 | `go vet` / `staticcheck` | P0 | ⚠️ 部分 | go build 通过，staticcheck 未接入 CI |
| L2 数据层 | `go test ./schema/...` | P0 | ❌ 未搭建 | 无 schema 测试 |
| L3 Swagger Fuzz | Schemathesis | P0 | ❌ 未搭建 | 需要先完善 swagger 文档 |
| L4 API 冒烟 | Hurl | P0 | ❌ 未搭建 | 声明式 API 测试 |

### AI 服务测试

| 层级 | 方式 | 状态 | 备注 |
|------|------|------|------|
| L1 契约测试 | Fixture + 结构断言 | ❌ 未搭建 | testdata/*.json 未创建 |
| L2 错误处理 | httptest 返回 429/500 | ❌ 未搭建 | |
| L3 真实调用 | 重新录制 fixtures | ❌ 未搭建 | 每周/手动 |

### App ↔ Server 集成测试

| 层级 | 工具 | 状态 | 备注 |
|------|------|------|------|
| L1 API Client 集成 | Dart `integration_test` | ❌ 未搭建 | 文档定义了覆盖范围，代码未写 |
| L2 全链路 E2E | Maestro + Docker | ❌ 未搭建 | P2 备选 |

### CI Workflows

| 文件 | 用途 | 状态 | 备注 |
|------|------|------|------|
| `.github/workflows/test-robo.yaml` | App Robo Test | ❌ 未创建 | |
| `.github/workflows/test-api.yaml` | Server + 集成测试 | ❌ 未创建 | |
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
| macOS 构建 | ⚠️ | 未验证 |
| Release APK | ⚠️ | 缺少 keystore 配置 |
| Debug APK | ✅ | 正常构建 |
| Flutter Analyze | ✅ | 0 errors, warnings 仅 unused elements |
| Codegen (build_runner) | ✅ | freezed + riverpod + json_serializable |
| L10n | ✅ | 16 语言，含新增 key |
| 数据库版本 | v11 | 新增 tb_ai_cache(v8), tb_companion_chat(v9), tb_margin_notes(v10), tb_concept_tags+edges(v11) |

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
| 2026-03-24 | 新增测试状态跟踪章节。更新 iOS 构建状态为已验证。修复导入卡住 bug（AnxToast null context） |
| 2026-03-23 | Sprint 4 Phase 1 完成。Companion Panel、Margin Notes、TTS 声音关联、知识网络（AI 叙事+图可视化）、语义搜索（pgvector embedding） |
| 2026-03-23 | Sprint 4 Phase 0 完成。Server PG+pgvector 迁移、WebDAV 完全移除（Client+Server）、AI 缓存持久化（sqflite+PG 双层） |
| 2026-03-23 | Sprint 3.5 完成。Server-Client 同步架构就绪：全量 API 客户端、双向增量同步、Server 新端点、伴侣同步、AI 去重 |
| 2026-03-23 | Sprint 3 完成。Layer 3 全部主要功能就绪（Inline Glossary, 书架 AI 推荐, 洞察 AI 叙事） |
| 2026-03-22 | 初始创建。Sprint 1 全部完成，Sprint 2 全部完成 |
