# 011-server-gap-analysis 审计意见

> 审计日期：2026-03-21
> 审计角色：开源自托管产品架构师 + 技术产品经理

## 总评

综合评分：4/5
一句话评价：**这是一份高质量的产品差距分析，「先打地基再盖楼」的策略完全正确，但在 MVP 边界定义、WebDAV 优先级、以及首次用户体验（Web UI）上存在需要调整的地方。AI 辅助开发下整体路线图 5-8 周可完成，关键瓶颈在设计决策和用户体验打磨而非编码速度。**

---

## 逐项审计

### 1. 战略一致性（4.5/5）

**优点：**
- 「当前功能完整度约 Calibre-Web 的 30%」的判断经代码验证准确——39 个 API 端点中大量存在 bug 或安全漏洞，实际可用质量更低
- 分层架构（基础设施 → 书库管理 → 高级体验 → AI 增值）逻辑清晰，与「AI-Native Calibre-Web」定位完全一致
- 正确识别了「没有 AI 的好用书库用户会用，有 AI 但书都管不好用户会走」这一核心矛盾
- Phase 分层与竞品分析（001）中「自部署 + AI = 空白象限」的战略判断高度一致

**问题：**
- 文档标题是「AI-Native Calibre-Web + TTS」，但路线图 Phase 1.5-2.0 全是传统书库功能，AI 要到 Phase 3 才出现。从社区传播角度看，用户安装后前几个版本完全感受不到「AI-Native」——**叙事断裂风险**
- README 中已经声称「AI conversational assistant for reading」为 Available Now，但 Server 端 AI 集成完全不存在（model_options 是空壳）——**对外宣传与实际能力不符**

**建议：**
- 在 Phase 2.0 中嵌入一个最小 AI 功能（如书籍导入时自动调用 LLM 补全元数据/生成简短摘要），让用户从第一个版本就能感受到「AI-Native」的差异化，哪怕只是一个 API 代理到 OpenAI/Ollama
- 立即修正 README 中 Feature 列表，将未实现的功能移到 Roadmap，避免信任损失

---

### 2. 优先级判断（3.5/5）

**优点：**
- Phase 1.5 安全修复放在第一位完全正确，7 个 P0 漏洞（特别是明文密码日志、可预测 token、无验证密码重置）中任何一个都足以让产品「不可部署」
- Phase 2.0 的 6 个模块排序基本合理——元数据编辑 > 标签书架 > OPDS > 搜索 > 统计 > 笔记

**问题：**
- **WebDAV 被严重忽视**。Anx Reader 原生支持 WebDAV 同步（009 文档确认），KOReader 等主流阅读器也依赖 WebDAV。路线图中 WebDAV 完全不在 Phase 2.0 内，仅在 009 文档中被标为 P2。但从「Server 独立可用」的角度看，WebDAV 比 OPDS 更紧迫——OPDS 是只读浏览，WebDAV 是读写同步
- **笔记同步（2.0.6）优先级应该提前**。Anx Reader 的笔记系统已经很完整（多色高亮、导出、分享卡片），用户 Fork 后第一件事就是期望笔记能跨设备同步。笔记同步应该和阅读进度同步同级（Phase 2.0 前半段），而不是排在统计后面
- **阅读统计（2.0.5）可以延后**。统计是「锦上添花」功能，不影响核心体验。用户不会因为没有热力图而卸载，但会因为笔记不能同步而卸载
- **分页（2.0.4）不应该和全文搜索绑定**。当前搜索硬编码返回 10 条，这是一个基础 bug，应该在 Phase 1.5 就修掉，不需要等到搜索增强

**建议：**
- 将 WebDAV Server 端实现提升到 Phase 2.0，排在 OPDS 之前或并列。理由：Anx Reader 用户已经习惯 WebDAV，Server 提供 WebDAV 可以零改动接入现有 App
- 调整 Phase 2.0 内部排序为：元数据编辑 → 标签书架 → WebDAV → 笔记同步 → OPDS → 搜索增强 → 统计
- 分页参数化从 2.0.4 提前到 1.5

---

### 3. 技术可行性（4/5）

**优点：**
- API 路径设计规范，RESTful 风格一致（`/reader/books/:id`、`/reader/tags`、`/reader/shelves`）
- 新增数据模型（Shelf、ShelfBook、ReadingSession、Note）设计合理，GORM tag 使用正确
- OPDS 1.2 的端点规划覆盖了核心需求（catalog/search/new/popular/authors/tags）
- 正确选择了 SQLite FTS5 作为搜索方案——对于自托管场景，不应该引入额外依赖（Elasticsearch/MeiliSearch）

**问题：**
- **Note 模型中 CFI 字段设计不够**。EPUB CFI（Canonical Fragment Identifier）用于 EPUB 定位没问题，但 PDF 怎么定位？需要额外的 `page_number` + `rect` 字段。Anx Reader 支持 6 种格式，CFI 只适用于 EPUB
- **ReadingSession 模型缺少设备信息**。多设备场景下，用户可能在手机和平板上同时阅读，需要 `DeviceID` 字段来区分和合并会话
- **OPDS 端点缺少认证机制**。OPDS 1.2 规范支持 HTTP Basic Auth，但路线图中未提及 OPDS 的认证方案。如果 OPDS 不做认证，任何人都能浏览你的书库
- **批量操作（`/reader/books/batch POST`）的设计过于简单**。批量删除+批量打标签+批量移动用一个 POST 端点，需要定义清晰的 action 枚举和请求体结构，否则会变成一个万能接口
- **搜索方案中 PostgreSQL tsvector 的多语言支持被低估**。中文用户是核心群体，但 tsvector 对中文支持很差，需要额外的分词扩展（zhparser/pg_jieba）。SQLite FTS5 同样需要考虑中文分词 tokenizer

**建议：**
- Note 模型增加 `PageNumber int` 和 `Position string`（通用定位字段），CFI 仅作为 EPUB 场景的 Position 值
- ReadingSession 增加 `DeviceID string` 字段
- OPDS 路由加上可选的 HTTP Basic Auth 中间件
- 搜索方案明确中文分词策略：SQLite FTS5 + simple tokenizer（按字分词）作为 MVP，后续再考虑 jieba 分词

---

### 4. 竞品对标准确性（4/5）

**优点：**
- 与 Calibre-Web 的逐功能对比表准确且全面
- 正确识别了 Omnigram 超越 Calibre-Web 的地方（多数据库支持）
- 「30% 功能完整度」的判断经代码验证合理——有 39 个端点但大量带 bug，实际可用功能约等于：登录 + 扫描 + 列表 + 下载 + 进度同步

**问题：**
- **缺少与 Kavita 的深度对比**。Kavita 是 Calibre-Web 最强的竞争者（8,800+ ⭐），内置 Web 阅读器、OPDS、阅读统计、元数据编辑——这些恰恰是 Omnigram Phase 2.0 要做的所有功能。路线图应该明确标注「Phase 2.0 完成后 = 达到 Kavita 基准线」
- **Audiobookshelf 的对比不够充分**。Audiobookshelf 的 API 设计和多端同步做得很好，是 Server 端架构的好参考，但路线图中未提及从 Audiobookshelf 学习什么
- **缺少 Komga 的对比**。Komga（3,800+ ⭐）是 Kotlin 写的漫画/书库服务器，OPDS 实现是业界标杆，路线图中 OPDS 实现应参考 Komga 的端点设计

**建议：**
- 在差距分析表中增加 Kavita 列，明确 Phase 2.0 后与 Kavita 的差距
- OPDS 实现参考 Komga 的 OPDS 端点（Komga 的 OPDS 被认为是开源项目中最规范的实现之一）

---

### 5. 用户价值排序（3.5/5）

**优点：**
- 正确识别了目标用户（NAS 囤积者、自托管极客）的核心需求：能管、能找、能读
- 「Server 应该独立可用」的决策正确——不强绑定 Omnigram App 是明智的

**问题：**
- **用户的「Aha moment」没有被路线图保障**。用户安装 Omnigram Server 后的期望流程是：`Docker 部署 → 指向书库目录 → 自动扫描 → 打开浏览器看到书库 → 惊叹`。但路线图选择了 API-First（Q1 选项 A），用户装完后打开浏览器只会看到一个空白页或 404——**没有 Aha moment**
- **API-First 的选择在自托管生态中是错误的**。Calibre-Web、Kavita、Audiobookshelf、Komga 都有 Web UI。自托管用户的第一反应是打开浏览器看看。没有 Web UI 意味着用户必须先安装 App 才能看到任何东西，这对于 r/selfhosted 社区的首次体验是致命的
- **邮件推送（Send-to-Kindle）被标为「可后做」，但这可能低估了需求**。很多 Calibre-Web 用户的核心工作流就是：浏览 Web → 发送到 Kindle。不过考虑到开发资源有限，延后是合理的

**建议：**
- **强烈建议在 Phase 2.0 增加 Web UI**。技术方案推荐 React + Vite，构建产物通过 `go:embed` 嵌入 Go 二进制（保持单一部署）。AI 辅助下开发效率与服务端模板相当，但 UX 质量远超。竞品（Kavita/Audiobookshelf/Jellyfin/Immich）无一使用服务端模板引擎。目标：用户 Docker 部署后打开浏览器能看到自己的书库
- 或者，至少提供一个 `/` 路径的落地页，展示 Server 状态 + 连接指南 + OPDS 地址，而不是 404

---

### 6. 风险与遗漏（3.5/5）

**优点：**
- 正确识别了安全漏洞的严重性并将其排在 Phase 1.5 首位
- Q2（Server 独立可用 vs 必须配合 App）的决策正确
- Q3（AI 放 Phase 3）的判断务实

**被忽略的重大问题：**

1. **WebDAV 被遗漏是最大的战略失误**。Anx Reader 原生支持 WebDAV 同步（这是其最常用的同步方式），KOReader、Moon+ Reader 等主流阅读器也支持 WebDAV。Omnigram Server 如果提供 WebDAV，可以零成本接入所有这些客户端——比 OPDS 的价值更大（OPDS 是只读目录，WebDAV 是读写文件系统）。WebDAV 应该在 Phase 2.0 中，优先级不低于 OPDS

2. **文件格式支持的局限性未被提及**。当前扫描仅对 EPUB 能提取完整元数据，其他格式（PDF/MOBI/AZW3/FB2/TXT）的元数据提取能力未知。路线图中没有「增强非 EPUB 格式元数据提取」的任务，但 Anx Reader 支持 6 种格式——如果 Server 只能管好 EPUB，其他格式的书就是「瞎子」

3. **数据迁移路径缺失**。目标用户很可能从 Calibre-Web 迁移过来。路线图中没有「从 Calibre 数据库导入」的功能。Calibre 使用 SQLite + metadata.db，提供一个导入工具可以大幅降低迁移成本

4. **备份与恢复方案缺失**。自托管用户最怕数据丢失。当前使用 BadgerDB 存储封面等二进制数据 + SQLite/PG 存储元数据，但路线图中没有备份/恢复/导出功能

5. **README 中的对外宣传与实际能力严重不符**。README 声称 OPDS 是 "Available Now"，但代码中 OPDS 路由零注册。声称 AI assistant 可用，但 Server 端 AI 集成为空壳。这对开源项目的信誉是致命的——用户 star 后发现功能不存在，会直接转为差评

6. **竞品动态风险**。Anx Reader 自身正在开发 OPDS 支持，如果 Anx Reader 团队决定自己做服务端（或与某个服务端项目合作），Omnigram 的 Fork 策略会面临上游竞争风险

**建议：**
- Phase 2.0 增加 WebDAV Server 实现
- Phase 2.0 增加非 EPUB 格式元数据提取增强（至少支持 PDF title/author 提取）
- Phase 2.0 或 2.5 增加 Calibre 数据库导入工具
- Phase 1.5 增加基础备份/导出功能（至少 DB dump + 配置导出）
- **立即修正 README**，将未实现功能移到 Roadmap

---

### 7. 时间线合理性（4/5）

**优点：**
- 分 Phase 推进的思路正确
- 调整后的时间线（App 对接推迟到 Server 成熟后）比原计划更合理

**关于工作量的重新评估（AI 辅助开发前提）：**

当前是 AI 辅助编程时代，「一个独立开发者 + AI」的生产力与传统独立开发者有本质区别。路线图中的任务大多是模式化的 CRUD API、协议实现、数据模型定义——这些恰恰是 AI 编码工具（Claude Code / Cursor / Copilot）最擅长加速的工作。重新评估：

  - Phase 1.5：15 项修复任务，多为定点修复（改几行代码），AI 辅助下 → **3-5 天**
  - Phase 2.0：30+ 个 CRUD API + 数据模型 + OPDS/WebDAV 协议实现 → **2-3 周**（CRUD 是 AI 最擅长的模式化代码，OPDS/WebDAV 有成熟规范和参考实现）
  - Phase 2.5：Web 阅读器（嵌入 foliate-js）+ TTS 任务队列 → **1-2 周**
  - Phase 3.0：LLM 集成 + RAG + Embedding → **1-2 周**（langchain 生态成熟，接入模式明确）
  - **总计：5-8 周（1.5-2 个月）**，这是合理且可达的时间线

真正的瓶颈不在编码速度，而在：
  - **设计决策**：API 接口设计、数据模型关系、协议兼容性等需要人来思考
  - **测试与调试**：AI 生成的代码需要集成测试验证，特别是 OPDS/WebDAV 协议兼容性
  - **用户体验打磨**：Web UI 的交互细节、错误提示文案等

- **没有定义 MVP**。路线图从 Phase 1.5 到 3.0 是一条线性路径，但没有明确「最小可发布版本」在哪里。即使编码速度很快，也应该尽早发布以获取社区反馈——反馈驱动的迭代比闭门开发更高效

- **Phase 2.0 的 6 个模块应该分批发布**，而不是等全部完成。可以考虑：
  - v0.1.0：安全修复 + 元数据编辑 + 分页 + WebDAV（最小可用）
  - v0.2.0：标签书架 + OPDS + 基础 Web UI
  - v0.3.0：搜索增强 + 笔记同步 + 统计
  - v0.4.0：Web 阅读器 + TTS 后台生成
  - v1.0.0：AI 功能

**建议：**
- 明确定义 MVP 版本号和功能边界
- Phase 2.0 内部做滚动发布（每周一个小版本），充分利用 AI 加速的编码速度快速迭代
- 将节省下来的时间投入到设计决策和用户体验打磨上——这些是 AI 无法替代的部分

---

## MVP 定义建议

Omnigram Server v0.1.0 的最小可发布功能集应该是：

- **安全修复**：7 个 P0 漏洞全部修复（非谈判项）
- **Docker 加固**：非 root 运行、移除默认凭证
- **基础 API 修复**：分页参数化、统一错误响应、CORS
- **元数据编辑**：PUT /reader/books/:id（用户最常用操作）
- **书籍删除**：DELETE /reader/books/:id
- **最小 Web 落地页**：`/` 路径展示 Server 状态 + 连接方式（Go template，几十行代码）
- **WebDAV**：基础文件读取（让 Anx Reader / KOReader 可以连接）

AI 辅助开发下，这个 MVP 约 **1 周**可完成（安全修复多为定点改几行代码，元数据编辑是标准 CRUD，WebDAV 有 Go 标准库支持）。发布后用户可以：
1. Docker 部署 → 扫描书库 → 通过 WebDAV 连接 Anx Reader/KOReader → 开始阅读
2. 通过 API 编辑书籍元数据
3. 打开浏览器看到 Server 运行状态

**尽早发布的核心目的不是节省时间，而是获取真实用户反馈来校准后续优先级。**

---

## 被遗漏的关键问题

1. **README 对外宣传与实际能力严重不符**——声称 OPDS、AI assistant 为 "Available Now" 但实际为空壳或不存在。开源项目最怕信任损失，必须立即修正
2. **WebDAV 完全缺失**——这是 Anx Reader 用户的核心同步方式，也是 KOReader 等客户端的标配协议，优先级应不低于 OPDS
3. **无 MVP 定义**——即使 AI 辅助下编码很快，也应该尽早发布获取反馈，需要明确 v0.1.0 的功能边界
4. **无 Calibre 数据迁移方案**——目标用户很可能从 Calibre-Web 迁来，提供导入工具可大幅降低迁移门槛
5. **非 EPUB 格式元数据提取能力未规划**——Server 扫描支持多种格式，但只有 EPUB 能提取完整元数据
6. **无备份/恢复方案**——自托管用户的核心需求，BadgerDB + 关系型 DB 的双存储增加了备份复杂度

---

## 路线图修改建议

如果只能改 3 个地方，我建议：

### 1. 在 Phase 2.0 增加 WebDAV Server 实现，优先级与 OPDS 并列

**理由：** WebDAV 是读写协议（vs OPDS 只读），Anx Reader 原生支持，KOReader/Moon+ Reader 等均支持。实现 WebDAV 等于立即打通整个阅读器生态的同步能力。Go 生态有成熟的 WebDAV 库（`golang.org/x/net/webdav`），实现成本可控。

### 2. 定义 MVP（v0.1.0）并在 Phase 1.5 完成后立即发布

**理由：** AI 辅助下编码速度不是瓶颈，但方向校准是。安全修复 + 元数据编辑 + WebDAV 基础支持 = 一个可用的最小产品。尽早发布到 GitHub Release，提交 awesome-selfhosted，用真实用户反馈来驱动后续优先级排序，比闭门规划更高效。

### 3. 在 Phase 2.0 增加 Web UI（React SPA + go:embed 嵌入）

**理由：** 自托管用户的第一反应是打开浏览器。没有 Web UI 的 Server 在 r/selfhosted 社区几乎不可能获得关注。

**技术选型：React + Vite，构建产物通过 `go:embed` 嵌入 Go 二进制，保持单一二进制部署。** 不建议使用 Go html/template——书库管理 UI 需要网格/列表视图、封面缩略图、元数据编辑表单、搜索过滤器、阅读统计图表等复杂交互，服务端模板引擎做这些会非常痛苦且体验差。竞品无一例外都使用现代前端框架（Kavita=Angular、Audiobookshelf=Vue、Jellyfin=React、Immich=Svelte）。AI 辅助下写 React 和写 Go 模板的速度差距极小（且 AI 生成 React 代码的质量更高，训练数据更充分），但产出的 UX 质量差距巨大。
