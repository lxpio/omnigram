# 011 - Omnigram Server 产品差距分析

> 分析日期：2026-03-21
> 修订日期：2026-03-21（整合审计意见 011-review.md）
> 状态：✅ 已决策
> 目标：Server 独立达到产品级水准后，再与 App 对接

---

## 一、当前 Server 实际能力（扫描代码得出）

### ✅ 已实现（39 个 API 端点）

| 能力域 | 具体功能 | 实现质量 |
|--------|---------|---------|
| **用户认证** | 登录/登出/Token 刷新/API Key | ⚠️ 有 5 个 P0 安全漏洞 |
| **用户管理** | 创建/列表/删除账户（Admin） | ⚠️ 无角色系统，仅 admin 标志 |
| **书库扫描** | 递归扫描目录（5 层），提取 EPUB 元数据 | ⚠️ 仅 EPUB 能提取完整元数据 |
| **书籍列表** | 搜索/最近/随机/个人书架 | ⚠️ 仅子串搜索，无分页参数化 |
| **书籍下载** | 下载原始文件 | ✅ 正常 |
| **封面图片** | 从 BadgerDB 读取封面 | ✅ 正常 |
| **阅读进度** | 获取/更新进度（章节+百分比） | ✅ 基本可用 |
| **收藏夹** | 收藏/取消收藏 | ⚠️ SQL 参数绑定 bug |
| **TTS 语音** | gRPC 连接 M4T 服务器，流式合成 | ⚠️ 无 TLS，连接泄漏 |
| **同步** | 全量+增量同步（SSE） | ⚠️ >10 万条触发全量 |
| **系统管理** | 系统信息/扫描控制 | ✅ 基本可用 |
| **Docker 部署** | 多阶段构建，SQLite/PG/MySQL | ⚠️ root 运行，默认凭证 |

### ❌ 完全不存在的

| 能力 | 状态 |
|------|------|
| OPDS 协议服务 | 有 struct 定义，**零路由注册** |
| WebDAV 协议 | 完全不存在 |
| Web 阅读器 | 完全不存在 |
| AI/LLM 集成 | 完全不存在（model_options 配置项是空壳） |
| 语义搜索/Embedding | 完全不存在 |
| 书籍元数据编辑 | 无任何 PUT/PATCH API |
| 标签管理 API | 数据表存在，**无 API** |
| 阅读统计/报告 | 无统计聚合 API |
| 书架/分组管理 | 完全不存在 |
| 格式转换 | 完全不存在 |
| 邮件服务 | 完全不存在 |
| 通知系统 | 完全不存在 |
| 审计日志 | 完全不存在 |
| 批量操作 | 完全不存在 |
| 评分/评论 | Rating 字段存在，**无 API** |

---

## 二、产品定位要求 vs 现实

### 定位：「AI-Native Calibre-Web + TTS」

我们声称要做 **Jellyfin/Immich 级别的自托管书库服务**。对标 Calibre-Web（7,000+ ⭐），Omnigram Server 至少需要达到 Calibre-Web 的基础能力，然后在此之上叠加 AI 差异化。

```
               Calibre-Web          Kavita              Omnigram Server 现状      差距
              ───────────          ──────              ──────────────────       ────
书库管理        ✅ 完整              ✅ 完整              ⚠️ 仅扫描+列表          🔴 大
元数据编辑      ✅ 完整              ✅ 完整              ❌ 无                   🔴 大
OPDS 协议       ✅ 完整              ✅ 完整              ❌ 空壳                 🔴 大
WebDAV          ❌ 无               ❌ 无               ❌ 无                   🔴 大（差异化机会）
Web 阅读        ✅ 内置              ✅ 内置              ❌ 无                   🔴 大
用户管理        ✅ 完整              ✅ 完整              ⚠️ 基础+安全漏洞        🟡 中
搜索            ✅ 多维度             ✅ 全文搜索           ⚠️ 仅标题/作者子串      🟡 中
标签/分类       ✅ 完整              ✅ 完整              ❌ 仅存表无API           🔴 大
阅读统计        ❌ 无               ✅ 完整              ❌ 无                   🟡 中
笔记/高亮同步   ❌ 无               ❌ 无               ❌ 无                   🟡 中（差异化机会）
格式转换        ✅ Calibre 集成       ❌ 无               ❌ 无                   🟡 中（可后做）
邮件推送        ✅ Send-to-Kindle     ❌ 无               ❌ 无                   🟡 中（可后做）
书架/Collection ✅ 完整              ✅ 完整              ❌ 无                   🟡 中
AI 集成         ❌ 无               ❌ 无               ❌ 无                   核心差异化
下载管理        ✅ 完整              ✅ 完整              ✅ 基本可用              ✅ 可
多数据库        ✅ SQLite only        ❌ SQLite only       ✅ SQLite/PG/MySQL      ✅ 超越
Docker 部署     ✅ 成熟              ✅ 成熟              ⚠️ 可用但有问题          🟡 中
```

> **注：Kavita（8,800+ ⭐）是 Calibre-Web 最强竞品，Phase 2.0 完成后应达到 Kavita 基准线。**
> **OPDS 实现应参考 Komga（3,800+ ⭐）——业界公认最规范的 OPDS 实现。**

### 严酷现实

> **当前 Omnigram Server 的功能完整度大约是 Calibre-Web 的 30%，且有严重安全漏洞。**
>
> 我们连基础的「书库管理服务器」都还没做好，就想叠加 AI 功能——这不现实。
> 用户安装后发现连书的元数据都改不了、OPDS 不能用、没有 Web 界面，会直接卸载。

---

## 三、补全策略：先打地基，再盖楼

### 分层架构

```
Layer 4: AI 增值 ────── 语义搜索 │ AI 摘要 │ AI 问答 │ 知识图谱      （Phase 3 - Pro）
Layer 3: 高级体验 ────── Web 阅读器 │ TTS 有声书 │ 阅读报告          （Phase 2.5）
Layer 2: 书库管理 ────── OPDS │ WebDAV │ 元数据 │ 标签 │ Web UI │ AI  （Phase 2 - 核心）
Layer 1: 基础设施 ────── 安全修复 │ 错误处理 │ 测试 │ 文档 │ API       （Phase 1.5 - 必须）
         ──────────────────────────────────────────────────────────
         当前状态：Layer 1 有严重缺陷，Layer 2 约 30%
```

---

## 四、Server 补全路线图（滚动发布）

> **原则：每个版本可独立发布，不等所有功能做完。**

### Phase 1.5 → v0.1.0-alpha（安全修复 + 基础加固）

> **目标：让 Server 代码达到「可以放心部署」的最低标准**

| # | 任务 | 优先级 | 详情 |
|---|------|--------|------|
| 1 | 修复明文密码日志 | P0 | `init_data.go:57` — 删除 Credential 打印 |
| 2 | 改用 crypto/rand 生成 token | P0 | `session.go:117`, `utils.go:3` |
| 3 | 修复 double write | P0 | `handler.go:60-64,377-382` — 加 return |
| 4 | 修复 OpenDB 错误吞没 | P0 | `orm.go:35` — 返回 error |
| 5 | 修复密码重置验证 | P0 | `handler.go:345-347` — 校验 code |
| 6 | 修复 Title 解析 panic | P0 | `book.go:479-481` — 检查 Title 长度 |
| 7 | 启用 API Key 认证 | P0 | `middleware.go:43-55` — 取消注释+修复 |
| 8 | 修复 SQL 参数绑定 | P1 | `favorite_book.go:34` |
| 9 | 修复 gRPC 连接泄漏 | P1 | `m4t/handler.go` — 添加 Close |
| 10 | Docker 非 root 运行 | P1 | Dockerfile — 添加 appuser |
| 11 | 移除默认凭证 | P1 | Dockerfile — 强制首次设置密码 |
| 12 | 添加 CORS 中间件 | P1 | App/Web 跨域请求需要 |
| 13 | 统一错误响应格式 | P1 | 定义 `ErrorResponse` 结构体 |
| 14 | **分页参数化** | P1 | 当前硬编码 10，改为 `page` + `page_size` 参数 |
| 15 | 请求日志中间件 | P2 | 记录请求方法/路径/耗时/状态码 |
| 16 | 清理死代码 | P2 | `conf/models.go`, `upstream/`, println |
| 17 | **基础备份/导出** | P2 | DB dump + 配置导出 CLI 命令 |

### Phase 2.0 → v0.1.0 ~ v0.3.0（书库管理核心 — 滚动发布）

> **目标：达到 Kavita 基准线 + WebDAV/OPDS 生态兼容 + 精美 Web UI + 最小 AI 体验**

#### v0.1.0 — MVP（安全 + 元数据 + WebDAV + Web 落地页）

> **用户安装后即可：Docker 部署 → 扫描书库 → 打开浏览器看到书库 → WebDAV 连接阅读器**

##### 2.0.1 — 书籍元数据管理

| API | 方法 | 说明 |
|-----|------|------|
| `/reader/books/:id` | PUT | 编辑书籍元数据（标题/作者/描述/封面） |
| `/reader/books/:id` | DELETE | 删除书籍（可选删除文件） |
| `/reader/books/:id/cover` | PUT | 上传自定义封面 |
| `/reader/books/upload` | POST | 修复：改为 POST 方法（当前错误地用 GET） |

##### 2.0.2 — WebDAV Server

> **审计意见：WebDAV 比 OPDS 更紧迫——OPDS 是只读浏览，WebDAV 是读写同步。Anx Reader / KOReader / Moon+ Reader 原生支持 WebDAV。**

| 功能 | 说明 |
|------|------|
| WebDAV 端点 | `/dav/` 挂载，映射到书库目录 |
| 认证 | 复用 OAuth / HTTP Basic Auth |
| 读写权限 | 用户只能访问自己的书和公共书库 |
| 实现方式 | `golang.org/x/net/webdav` 标准库 |

##### 2.0.3 — 精美 Web UI（书库浏览）

> **决策：做精美的 Web UI，不做简陋的模板页面。AI 时代不用担心工作量。**

| 功能 | 说明 |
|------|------|
| 书库浏览 | 网格/列表视图，封面展示，响应式设计 |
| 搜索 + 过滤 | 按标题/作者/标签/格式搜索和筛选 |
| 书籍详情 | 元数据展示、封面、描述、阅读进度 |
| 元数据编辑 | 内联编辑标题/作者/描述/标签 |
| 用户管理 | Admin 面板：用户列表/创建/删除 |
| 系统设置 | 书库路径、扫描控制、TTS/AI 配置 |
| 暗色模式 | 支持亮/暗主题切换 |
| 移动端适配 | 响应式设计，手机/平板也好看 |

**技术选型建议：**
- 前端：React/Vue/Svelte SPA，嵌入 Go 二进制（`embed.FS`）
- 设计参考：Kavita（现代感）+ Immich（简洁大气）+ Audiobookshelf（功能性）

##### 2.0.4 — 非 EPUB 元数据提取增强

> **审计意见：Server 扫描支持 6 种格式，但仅 EPUB 能提取完整元数据。其他格式的书是「瞎子」。**

| 格式 | 当前 | 需要增强 |
|------|------|---------|
| EPUB | ✅ 完整 | — |
| PDF | ❌ 仅文件名 | 提取 Title/Author/CreationDate（PDF metadata） |
| MOBI/AZW3 | ❌ 仅文件名 | 解析 MOBI header（PalmDOC/EXTH） |
| FB2 | ❌ 仅文件名 | 解析 XML description 节点 |
| TXT/MD | ❌ 仅文件名 | 从文件名推断标题（无元数据可提取） |

#### v0.2.0 — 标签书架 + 笔记同步 + OPDS + Calibre 导入

##### 2.0.5 — 标签 & 书架系统

| API | 方法 | 说明 |
|-----|------|------|
| `/reader/tags` | GET | 获取所有标签（含书籍计数） |
| `/reader/tags` | POST | 创建标签 |
| `/reader/tags/:id` | DELETE | 删除标签 |
| `/reader/books/:id/tags` | PUT | 设置书籍标签 |
| `/reader/shelves` | GET/POST | 书架（用户自定义分组） |
| `/reader/shelves/:id` | GET/PUT/DELETE | 书架 CRUD |
| `/reader/shelves/:id/books` | POST/DELETE | 书架中添加/移除书籍 |

**新增数据模型：**
```go
type Shelf struct {
    ID          int64  `gorm:"primaryKey"`
    UserID      int64  `gorm:"index"`
    Name        string `gorm:"varchar(200)"`
    Description string `gorm:"text"`
    CoverURL    string `gorm:"varchar(255)"`
    SortOrder   int    `gorm:"default:0"`
    CTime       int64  `gorm:"autoCreateTime:milli"`
    UTime       int64  `gorm:"autoUpdateTime:milli"`
}

type ShelfBook struct {
    ID      int64  `gorm:"primaryKey"`
    ShelfID int64  `gorm:"uniqueIndex:idx_shelf_book"`
    BookID  string `gorm:"uniqueIndex:idx_shelf_book"`
    SortOrder int  `gorm:"default:0"`
    CTime   int64  `gorm:"autoCreateTime:milli"`
}
```

##### 2.0.6 — 笔记 & 高亮 & 评分同步

> **审计意见：笔记是 Anx Reader 的核心功能，用户 Fork 后第一件事就是期望笔记能跨设备同步。优先级应与阅读进度同级。**

| API | 说明 |
|-----|------|
| `/reader/books/:id/rating` | PUT — 设置评分（1-5） |
| `/reader/books/:id/annotations` | GET/POST — 获取/新增笔记和高亮 |
| `/reader/books/:id/annotations/:aid` | PUT/DELETE — 编辑/删除 |
| `/sync/annotations` | POST — 批量同步（Anx Reader 格式兼容） |

**新增数据模型：**
```go
type Annotation struct {
    ID         int64  `gorm:"primaryKey"`
    UserID     int64  `gorm:"index"`
    BookID     string `gorm:"index"`
    DeviceID   string `gorm:"varchar(50)"`           // 多设备区分
    Chapter    string `gorm:"varchar(200)"`
    Content    string `gorm:"text"`
    CFI        string `gorm:"varchar(500)"`           // EPUB CFI 定位
    PageNumber int    `gorm:"default:0"`              // PDF 页码定位
    Position   string `gorm:"varchar(500)"`           // 通用定位（格式无关）
    Color      string `gorm:"varchar(20)"`
    Type       string `gorm:"varchar(20)"`            // note/highlight/bookmark
    CTime      int64  `gorm:"autoCreateTime:milli"`
    UTime      int64  `gorm:"autoUpdateTime:milli"`
}
```

> **模型改进（审计意见采纳）：**
> - 增加 `PageNumber` — PDF 等非 EPUB 格式的定位
> - 增加 `Position` — 格式无关的通用定位字段，CFI 仅作为 EPUB 的 Position 值
> - 增加 `DeviceID` — 多设备场景下区分和合并
> - 模型名从 `Note` 改为 `Annotation` — 统一高亮/笔记/书签

##### 2.0.7 — OPDS 目录服务

> **实现参考 Komga 的 OPDS 端点设计（业界最规范）。**

当前状态：`service/reader/opds/opds.go` 已定义 Atom Feed 结构体，但**零路由注册**。

| API | 说明 |
|-----|------|
| `/opds/v1.2/catalog` | OPDS 根目录 |
| `/opds/v1.2/search?q=` | OPDS 搜索 |
| `/opds/v1.2/new` | 最新入库 |
| `/opds/v1.2/popular` | 最受欢迎 |
| `/opds/v1.2/authors` | 按作者浏览 |
| `/opds/v1.2/authors/:name` | 某作者的书 |
| `/opds/v1.2/tags/:tag` | 某标签的书 |
| `/opds/v1.2/shelves` | 用户书架 |
| `/opds/v1.2/books/:id/download` | 下载链接 |

**认证方式：HTTP Basic Auth**（OPDS 标准，Komga/Calibre-Web 均如此）

##### 2.0.8 — Calibre 数据库导入

> **审计意见：目标用户很可能从 Calibre-Web 迁移，提供导入工具大幅降低迁移门槛。**

| 功能 | 说明 |
|------|------|
| 导入 Calibre `metadata.db` | 解析 SQLite，映射 books/authors/tags/series |
| 导入 Calibre 书库目录结构 | `Author Name/Book Title (ID)/` 格式 |
| 保留 Calibre 封面 | `cover.jpg` 导入到 BadgerDB |
| 冲突处理 | 按 ISBN/书名+作者 去重 |
| CLI 命令 | `omni-server import --calibre /path/to/calibre` |

#### v0.3.0 — 搜索增强 + 统计 + 最小 AI + 批量操作

##### 2.0.9 — 搜索增强

| 功能 | 实现方式 |
|------|---------|
| 全文搜索 | SQLite FTS5（simple tokenizer 按字分词，中文友好） |
| 多字段搜索 | title + author + tags + description |
| 过滤器 | 按格式、语言、评分、标签、出版日期 |
| 排序选项 | 按标题/作者/添加时间/最近阅读/评分 |

> **中文分词策略（审计意见采纳）：** MVP 阶段使用 SQLite FTS5 + simple tokenizer（按字分词），后续再考虑 jieba 分词或 PostgreSQL zhparser 扩展。

##### 2.0.10 — 阅读统计 API

| API | 说明 |
|-----|------|
| `/reader/stats/overview` | 总阅读数/完成数/进行中 |
| `/reader/stats/daily` | 每日阅读量（热力图数据） |
| `/reader/stats/monthly` | 月度阅读统计 |
| `/reader/stats/books` | 各书阅读时长排名 |

**新增数据模型：**
```go
type ReadingSession struct {
    ID        int64  `gorm:"primaryKey"`
    UserID    int64  `gorm:"index"`
    BookID    string `gorm:"index"`
    DeviceID  string `gorm:"varchar(50)"`  // 多设备区分
    StartTime int64
    EndTime   int64
    Duration  int64  // 秒
    PagesRead int
}
```

##### 2.0.11 — 最小 AI 集成（导入时元数据补全）

> **审计意见：在 Phase 2 嵌入最小 AI 功能，让用户从第一个版本就能感受到「AI-Native」差异化。**

| 功能 | 说明 |
|------|------|
| LLM Provider 框架 | 统一接口：OpenAI / Ollama / 自定义 API |
| 导入时自动补全 | 书籍导入后调 LLM 补全缺失的元数据（描述、标签、语言） |
| 导入时自动摘要 | 生成 1-2 句简短摘要，展示在书库卡片上 |
| 配置页面 | Web UI 中配置 LLM API Key / Ollama 地址 |
| 可选开关 | 用户可关闭 AI 功能（不依赖外部服务） |

**这不是完整的 AI 功能（Phase 3），而是「AI 尝鲜」——让用户导入书后就能看到 AI 自动补全的描述和摘要。**

##### 2.0.12 — 批量操作

| API | 方法 | 说明 |
|-----|------|------|
| `/reader/books/batch/delete` | POST | 批量删除 |
| `/reader/books/batch/tag` | POST | 批量打标签 |
| `/reader/books/batch/shelf` | POST | 批量加入书架 |

> **审计意见采纳：拆分为独立端点，而非万能 batch POST。**

### Phase 2.5 → v0.4.0（高级体验）

#### Web 阅读器（嵌入式）

- 集成 foliate-js（与 Anx Reader App 同一引擎）
- 提供 `/web/reader/:book_id` 路由
- 支持 EPUB/PDF 在线阅读
- 阅读进度与 App 同步
- 阅读中高亮/笔记 → 同步到 Server

#### TTS 有声书生成（服务端）

当前 TTS 是实时流式合成，适合 App 端播放。Server 端应支持：
- 后台任务：整本书/按章节生成 MP3
- 任务队列 + 进度查询
- 生成的音频文件存储 + 下载
- 多 TTS 引擎支持（Fish Audio / Edge TTS / Coqui）

### Phase 3.0 → v0.5.0（AI 增值层）

| 功能 | 依赖 | 说明 |
|------|------|------|
| AI 书籍摘要 | LLM API（OpenAI/Ollama） | 导入即自动生成 3 种长度摘要（短/中/长） |
| 阅读问答 | LLM + 书籍内容 RAG | 基于全书内容回答问题 |
| 语义搜索 | Embedding + 向量数据库 | 「找讨论领导力的章节」 |
| 自动标签 | LLM 分类 | 导入时自动分类打标（增强 2.0.11） |
| 跨书知识关联 | Embedding 相似度 | 「这本书与 XX 观点相似」 |

---

## 五、版本发布计划

```
v0.1.0-alpha  Phase 1.5 完成 → 安全修复，可信赖的 API 基础
v0.1.0        Phase 2.0 前半 → MVP：元数据编辑 + WebDAV + 精美 Web UI + 非 EPUB 增强
v0.2.0        Phase 2.0 中段 → 标签书架 + 笔记同步 + OPDS + Calibre 导入
v0.3.0        Phase 2.0 后半 → 搜索增强 + 统计 + 最小 AI + 批量操作
v0.4.0        Phase 2.5     → Web 阅读器 + TTS 后台生成
v0.5.0        Phase 3.0     → 完整 AI 功能（Pro 层）
v1.0.0        Phase 4.0     → App ↔ Server 完整对接 + 公开发布
```

**每个版本都可独立发布到 GitHub Release，尽早获取社区反馈。**

v0.1.0 发布后的用户体验流程：
```
1. docker-compose up → Server 启动
2. 打开浏览器 → 看到精美的书库界面（Aha moment!）
3. 设置书库路径 → 自动扫描 → 封面/元数据展示
4. 配置 Anx Reader / KOReader → WebDAV 连接 → 开始阅读
5. 在 Web UI 编辑元数据、管理标签
```

---

## 六、已决策事项

| 决策 | 结论 | 依据 |
|------|------|------|
| Web UI | ✅ 做，且要做精美 | 自托管用户第一反应是打开浏览器；AI 辅助开发不用担心工作量 |
| Server 独立可用 | ✅ 不强绑定 App | OPDS + WebDAV + Web UI 让任何客户端都能用 |
| AI 功能阶段 | Phase 2 嵌入最小 AI，Phase 3 做完整 | 避免叙事断裂——用户应从 v0.1.0 就能感受到 AI-Native |
| 滚动发布 | ✅ 每个版本独立可用 | 独立开发者不能等全做完再发布 |
| Calibre 导入 | v0.2.0 | MVP 先不管迁移，v0.2 再做 |
| WebDAV 优先级 | 与 OPDS 并列，甚至更前 | 读写 > 只读；Anx Reader/KOReader 原生支持 |

---

## 七、与 App 对接时间线（修订后）

```
Phase 1   ✅ → Fork Anx Reader + 品牌化

Phase 1.5    → Server 安全修复 + 基础加固
               发布 v0.1.0-alpha

Phase 2.0    → Server 书库管理补全（滚动发布 v0.1.0 ~ v0.3.0）
               v0.1.0: 元数据 + WebDAV + Web UI
               v0.2.0: 标签 + 笔记 + OPDS + Calibre 导入
               v0.3.0: 搜索 + 统计 + 最小 AI + 批量操作

Phase 2.5    → App ↔ Server 对接 + Web 阅读器 + TTS 后台
               发布 v0.4.0

Phase 3.0    → Server 完整 AI 功能
               发布 v0.5.0

Phase 4.0    → 公开发布 v1.0.0
               GitHub Release + 应用商店 + awesome-selfhosted + CasaOS
```

---

## 八、风险清单

| 风险 | 级别 | 应对 |
|------|------|------|
| README 对外宣传与实际能力不符 | 🔴 高 | **立即修正**，未实现功能移到 Roadmap |
| Anx Reader 上游自己做服务端 | 🟡 中 | 保持差异化在 Server 端；定期观察上游动态 |
| 独立开发者精力有限 | 🟡 中 | 滚动发布；Phase 1.5 后开始接受社区 PR |
| 非 EPUB 格式元数据提取困难 | 🟡 中 | PDF 有成熟库；MOBI/AZW3 较复杂可后做 |
| BadgerDB + 关系型 DB 双存储备份复杂 | 🟡 中 | Phase 1.5 提供基础 DB dump |
