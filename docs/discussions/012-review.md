# 012-server-phase2-design 审计意见

> 审计日期：2026-03-21
> 审计角色：开源自托管产品架构师 + 技术产品经理
> 审计对象：012-server-phase2-design.md（Phase 1.5 + Phase 2.0 全量技术设计）
> 对照文档：011-server-gap-analysis.md（产品路线图）、011-review.md（路线图审计意见）

## 总评

综合评分：4.5/5
一句话评价：**高质量的技术设计文档，与路线图高度一致，吸收了审计意见中的绝大部分建议。需要修复 WebDAV 只读限制、搜索 SQL 注入两个关键问题，其余为小调整。**

---

## 一、审计建议采纳情况

### 已采纳（10/12）

| # | 审计建议 | 012 中的体现 | 评价 |
|---|---------|-------------|------|
| 1 | WebDAV 提升优先级 | v0.1.0 就包含 WebDAV | 完全采纳 |
| 2 | 定义 MVP + 滚动发布 | v0.1.0 / v0.2.0 / v0.3.0 三个里程碑 | 完全采纳 |
| 3 | React + Vite + go:embed | Web UI 技术栈 shadcn/ui + TanStack Query | 完全采纳，技术选型合理 |
| 4 | Annotation 增加 DeviceID | `DeviceID string` 字段已加入 | 完全采纳 |
| 5 | Annotation 增加 PageNumber/Position | 两个字段都有，CFI 仅用于 EPUB | 完全采纳 |
| 6 | 批量操作拆分端点 | `/batch/delete`、`/batch/tag`、`/batch/shelf` | 完全采纳，比原设计更清晰 |
| 7 | OPDS 加认证 | HTTP Basic Auth 中间件 | 完全采纳 |
| 8 | Calibre 导入工具 | v0.2.0 CLI 命令 `omni-server import --calibre` | 完全采纳 |
| 9 | 非 EPUB 元数据提取 | PDF（pdfcpu）/ MOBI（EXTH）/ FB2（XML）/ TXT（文件名） | 完全采纳，覆盖全格式 |
| 10 | 早期 AI 触点 | v0.3.0 导入时自动补全元数据 + 生成摘要 | 完全采纳 |

### 未采纳（2/12）

| # | 审计建议 | 状态 | 影响 |
|---|---------|------|------|
| 11 | 备份/恢复方案 | 未提及 | 中 — 自托管用户核心需求 |
| 12 | 立即修正 README | 未提及（012 是技术设计文档，不涉及） | 高 — 需单独处理 |

---

## 二、需要修复的关键问题

### 问题 1：WebDAV 只读限制——不满足同步需求（严重）

**位置：** 第 518-536 行，`OmnigramFS`

**现状：** 所有写操作（`O_WRONLY`、`O_RDWR`、`O_CREATE`、`Mkdir`、`RemoveAll`、`Rename`）全部返回 `os.ErrPermission`。

**问题：** Anx Reader 的 WebDAV 同步是**双向读写**的——上传阅读进度文件、同步笔记、同步配置。KOReader 的 WebDAV 同步同样需要写入 `koreader/` 目录下的进度和统计文件。只读 WebDAV 本质上是一个 HTTP 文件下载服务，不是同步协议。

**建议修改：**

```go
type OmnigramFS struct {
    root     string
    syncRoot string // 可写的同步目录
}

func (fs *OmnigramFS) OpenFile(ctx context.Context, name string, flag int, perm os.FileMode) (webdav.File, error) {
    // 同步目录允许读写
    if strings.HasPrefix(name, "/sync/") {
        return os.OpenFile(filepath.Join(fs.syncRoot, strings.TrimPrefix(name, "/sync/")), flag, perm)
    }
    // 书库目录只允许读取
    if flag&(os.O_WRONLY|os.O_RDWR|os.O_CREATE|os.O_TRUNC) != 0 {
        return nil, os.ErrPermission
    }
    return os.Open(filepath.Join(fs.root, name))
}

func (fs *OmnigramFS) Mkdir(ctx context.Context, name string, perm os.FileMode) error {
    if strings.HasPrefix(name, "/sync/") {
        return os.MkdirAll(filepath.Join(fs.syncRoot, strings.TrimPrefix(name, "/sync/")), perm)
    }
    return os.ErrPermission
}
```

**原则：** 书库文件目录只读（保护原始文件），同步目录可写（支持客户端数据同步）。WebDAV 路径结构：
```
/dav/
├── books/       # 只读 — 书库文件浏览和下载
└── sync/        # 可写 — 阅读进度/笔记/配置同步
    └── {user}/  # 按用户隔离
```

---

### 问题 2：搜索 handler SQL 注入（严重）

**位置：** 第 1095-1128 行，`searchBooksHandle`

**现状：**
```go
sort := c.DefaultQuery("sort", "utime")
order := c.DefaultQuery("order", "desc")
orderClause := sort + " " + order
query.Order(orderClause)
```

`sort` 和 `order` 来自用户 Query 参数，直接拼接到 SQL ORDER BY 子句。攻击者可以构造：
```
GET /reader/search?sort=1;DROP TABLE books--&order=asc
```

**这恰恰是 Phase 1.5 要修的那类安全问题——在新代码中引入了旧问题。**

**建议修改：**
```go
var allowedSortFields = map[string]string{
    "title":  "title",
    "author": "author",
    "utime":  "u_time",
    "ctime":  "c_time",
    "rating": "rating",
}

func searchBooksHandle(c *gin.Context) {
    sort := c.DefaultQuery("sort", "utime")
    order := c.DefaultQuery("order", "desc")

    sortColumn, ok := allowedSortFields[sort]
    if !ok {
        sortColumn = "u_time"
    }
    if order != "asc" && order != "desc" {
        order = "desc"
    }

    query.Order(sortColumn + " " + order)
    // ...
}
```

---

## 三、需要调整的中等问题

### 问题 3：FTS5 中文分词为已知限制

**位置：** 第 1044 行，`tokenize='unicode61'`

`unicode61` 对中文做字符级分词（每个字一个 token）。搜索「三体」可以命中，但搜索体验不如词级分词（如「刘慈欣」拆成「刘」「慈」「欣」三个 token，搜索「慈欣」也会命中无关结果）。

**判断：** MVP 阶段可接受——比原来的 `LIKE '%keyword%'` 已有显著提升。但应在文档中标注为已知限制。

**后续方向：**
- 方案 A：引入 [bleve](https://github.com/blevesearch/bleve) 全文搜索库（纯 Go，支持中文分词插件）
- 方案 B：SQLite FTS5 + [jieba-rs](https://github.com/nickelc/jieba-rs) 自定义 tokenizer（需要 CGO）
- 方案 C：维持现状，中文用户量大时再优化

### 问题 4：CORS Allow-Origin 应可配置

**位置：** 第 259 行，`Access-Control-Allow-Origin: *`

硬编码通配符在开发阶段没问题，但生产环境（尤其是有认证的 API）应该可配置。

**建议：**
```go
func CORSMiddleware(allowOrigins string) gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Header("Access-Control-Allow-Origin", allowOrigins) // 从配置读取
        // ...
    }
}
```

配置文件新增：
```yaml
server:
  cors_origins: "*"  # 生产环境改为具体域名
```

### 问题 5：deleteBookHandle 缺少事务

**位置：** 第 441-468 行

删除关联数据（BookTagShip、ReadProgress、FavBook）和删除书籍记录分散在 4 个独立的 ORM 调用中。如果中途失败（如删除 ReadProgress 成功但删除 Book 失败），数据会处于不一致状态。

**建议：**
```go
func deleteBookHandle(c *gin.Context) {
    // ...
    err := orm.Transaction(func(tx *gorm.DB) error {
        tx.Where("book_id = ?", bookID).Delete(&schema.BookTagShip{})
        tx.Where("book_id = ?", bookID).Delete(&schema.ReadProgress{})
        tx.Where("book_id = ?", bookID).Delete(&schema.FavBook{})
        return tx.Delete(&book).Error
    })
    if err != nil {
        schema.Error(c, 500, "DB_ERROR", err.Error())
        return
    }
    // 文件删除放在事务外（文件操作不可回滚）
    if deleteFile && book.Path != "" {
        os.Remove(book.Path)
    }
    // ...
}
```

### 问题 6：serveWebUI 中使用了未定义的 subFS 函数

**位置：** 第 668 行

```go
c.FileFromFS(path, http.FS(subFS(webUI, "web/dist")))
```

`subFS` 不是标准库函数，应使用 `fs.Sub`：

```go
sub, _ := fs.Sub(webUI, "web/dist")
c.FileFromFS(path, http.FS(sub))
```

---

## 四、设计亮点

值得肯定的设计决策：

1. **Annotation 统一模型** — 将 Note/Highlight/Bookmark 统一为 `Annotation` 类型，用 `AnnotationType` 枚举区分，比 011 中分散的 Note 模型更优雅
2. **指针字段实现 Partial Update** — `updateBookHandle` 中用 `*string` 指针区分「未传」和「传空值」，避免了零值覆盖问题，这是 Go API 设计的最佳实践
3. **批量同步 API 设计** — `POST /sync/annotations` 的双向同步设计（客户端上传 + 服务端返回差异）合理，`last_sync_time` 增量同步减少传输量
4. **AI 集成的渐进式设计** — 默认关闭、不影响导入流程、失败时静默降级（`return nil`），是正确的可选功能设计
5. **完整路由表汇总** — 第七节的 85 个端点完整列表按版本标注，是很好的 API 参考文档
6. **Calibre 导入表映射** — metadata.db 的字段映射表清晰完整，包含了 identifiers 和 cover 的处理

---

## 五、待补充项

| # | 缺失项 | 建议 | 优先级 |
|---|--------|------|--------|
| 1 | 备份/恢复 CLI | 增加 `omni-server backup` / `omni-server restore` 命令，导出 SQLite DB + BadgerDB 快照 + 配置文件为 tar.gz | 建议 v0.2.0 加入 |
| 2 | README 修正 | 将 OPDS、AI assistant 从 "Available Now" 移到 "Roadmap"，避免信任损失 | 立即处理 |
| 3 | 健康检查端点 | Docker 部署需要 `GET /healthz` 返回 DB 连接状态，用于 `docker-compose` 的 `healthcheck` | 建议 v0.1.0 加入 |
| 4 | API 限流 | 公网部署时防止暴力破解登录，至少对 `/auth/login` 加 rate limit | 建议 v0.1.0 加入 |
| 5 | 优雅关闭 | `gin.Engine` 应使用 `http.Server` + `Shutdown(ctx)` 处理 SIGTERM，避免请求中断 | 建议 v0.1.0 加入 |

---

## 六、总结

012 设计文档是一份**可直接执行的高质量技术方案**。与 011 路线图和审计意见的对齐度达到 83%（10/12 建议被采纳）。

**开工前必须修的 2 件事：**
1. WebDAV 增加同步目录的写权限（否则 Anx Reader / KOReader 无法同步）
2. 搜索 handler 的 sort/order 参数加白名单校验（否则新代码引入 SQL 注入）

**建议补充的 2 件事：**
1. 备份/恢复 CLI 命令
2. 修正 README 中的功能宣传

其余问题为小调整，可在开发过程中顺手修复。
