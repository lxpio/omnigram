# 012 - Omnigram Server Phase 2.0 技术设计文档

> 创建日期：2026-03-21
> 修订日期：2026-03-21（整合 012-review.md 审计意见）
> 状态：📐 设计中
> 范围：Phase 1.5（安全加固）+ Phase 2.0（v0.1.0 ~ v0.3.0 全量设计）
> 前置：011-server-gap-analysis.md（产品路线图）、008-code-quality-audit.md（代码审计）

---

## 一、架构总览

### 当前架构

```
┌──────────────────────────────────────────────────────────────┐
│                     Omnigram Server (Go)                      │
│                                                              │
│  cmd/omni-server/main.go → server.App → gin.Engine           │
│                                                              │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │ user/   │  │ reader/ │  │  sys/   │  │  m4t/   │        │
│  │ 认证管理 │  │ 书库阅读 │  │ 系统扫描 │  │ TTS语音 │        │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘        │
│       │            │            │            │               │
│  ┌────┴────────────┴────────────┴────────────┘               │
│  │              middleware (OAuth + Admin)                    │
│  └────────────────────┬──────────────────────                │
│                       │                                      │
│  ┌────────────────────┴──────────────────────┐               │
│  │            store (GORM + BadgerDB)         │               │
│  │  omnigram.db │ file_meta.db │ badger/      │               │
│  └────────────────────────────────────────────┘               │
└──────────────────────────────────────────────────────────────┘
```

### 目标架构（Phase 2.0 完成后）

```
┌──────────────────────────────────────────────────────────────────────┐
│                      Omnigram Server (Go)                            │
│                                                                      │
│  cmd/omni-server/main.go → server.App → gin.Engine                   │
│                                                                      │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ │
│  │ user/  │ │reader/ │ │  sys/  │ │  m4t/  │ │ webdav/│ │  ai/   │ │
│  │认证管理 │ │书库阅读 │ │系统扫描 │ │TTS语音 │ │文件同步 │ │AI增强  │ │
│  └────┬───┘ └───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘ │
│       │         │          │          │          │          │        │
│  ┌────┴─────────┴──────────┴──────────┴──────────┴──────────┘        │
│  │           middleware (OAuth + Admin + CORS + Logger)               │
│  └─────────────────────────┬─────────────────────────                │
│                            │                                         │
│  ┌─────────────────────────┴─────────────────────────┐               │
│  │              store (GORM + BadgerDB + FTS5)        │               │
│  │  omnigram.db │ file_meta.db │ badger/ │ fts5.db   │               │
│  └───────────────────────────────────────────────────┘               │
│                                                                      │
│  ┌───────────────────────────────────────────────────┐               │
│  │           Web UI (React + Vite → go:embed)         │               │
│  │  书库浏览 │ 元数据编辑 │ Admin面板 │ 暗色模式      │               │
│  └───────────────────────────────────────────────────┘               │
└──────────────────────────────────────────────────────────────────────┘

外部连接：
  ├── Omnigram App (Flutter) ←→ REST API + WebDAV
  ├── KOReader / Moon+ Reader ←→ WebDAV + OPDS
  ├── 浏览器 ←→ Web UI (SPA)
  └── LLM 服务 ←→ OpenAI API / Ollama (可选)
```

### 新增目录结构

```
server/
├── service/
│   ├── user/          # 现有 — 认证管理
│   ├── reader/        # 现有 — 书库阅读（扩展：元数据编辑/标签/书架/笔记/统计）
│   │   └── opds/      # 现有 struct — 补全路由注册
│   ├── sys/           # 现有 — 系统管理
│   ├── m4t/           # 现有 — TTS 语音
│   ├── webdav/        # 新增 — WebDAV 文件服务
│   └── ai/            # 新增 — AI LLM 集成
├── schema/
│   ├── book.go        # 现有 — 扩展元数据提取（PDF/MOBI）
│   ├── shelf.go       # 新增 — 书架模型
│   ├── annotation.go  # 新增 — 笔记/高亮/书签模型
│   ├── reading_session.go  # 新增 — 阅读会话模型
│   └── ...
├── store/
│   ├── orm.go         # 现有 — 扩展 FTS5 初始化
│   ├── fts.go         # 新增 — 全文搜索封装
│   └── ...
├── web/               # 新增 — Web UI 前端
│   ├── package.json
│   ├── vite.config.ts
│   ├── src/
│   │   ├── App.tsx
│   │   ├── pages/
│   │   ├── components/
│   │   └── api/
│   └── dist/          # 构建产物 → go:embed
└── embed.go           # 新增 — go:embed 嵌入 Web UI
```

---

## 二、Phase 1.5 安全加固（详细修复方案）

### 2.1 P0 安全修复

#### Fix 1: 明文密码日志
```go
// schema/init_data.go:57
// Before:
log.I("初始化数据, 用户信息: ", u.Name, u.Credential)
// After:
log.I("初始化数据, 用户信息: ", u.Name, "[REDACTED]")
```

#### Fix 2: crypto/rand 替换 math/rand
```go
// schema/session.go — RandomString 函数
// Before:
import "math/rand"
func RandomString(n int) string {
    // math/rand — 可预测
}
// After:
import "crypto/rand"
func RandomString(n int) string {
    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    b := make([]byte, n)
    if _, err := rand.Read(b); err != nil {
        panic(err)
    }
    for i := range b {
        b[i] = charset[int(b[i])%len(charset)]
    }
    return string(b)
}

// utils/utils.go 同样替换
```

#### Fix 3: Double write
```go
// service/user/handler.go:60-64
// Before:
if err != nil {
    c.JSON(500, gin.H{"error": err.Error()})
}
c.JSON(200, gin.H{"data": result})
// After:
if err != nil {
    c.JSON(500, gin.H{"error": err.Error()})
    return  // ← 加 return
}
c.JSON(200, gin.H{"data": result})

// handler.go:377-382 同样修复
```

#### Fix 4: OpenDB 错误处理
```go
// store/orm.go — OpenDB / WaitDB
// 确保 gorm.Open 失败时返回明确的 error，而非 nil
// 调用方必须检查 error
```

#### Fix 5: 密码重置验证
```go
// service/user/handler.go:345-347
// Before:
func resetPasswordHandle(c *gin.Context) {
    // code 字段存在但从未校验
}
// After:
func resetPasswordHandle(c *gin.Context) {
    code := c.PostForm("code")
    if code == "" || !verifyResetCode(userID, code) {
        c.JSON(400, ErrorResponse{Code: "INVALID_CODE", Message: "Invalid reset code"})
        return
    }
    // ... 执行重置
}
```

#### Fix 6: Title 解析 panic
```go
// schema/book.go:479-481
// Before:
if len(mdata.Creator) > 0 {
    m.Title = mdata.Title[0].Value  // ← Creator 和 Title 检查不匹配
}
// After:
if len(mdata.Title) > 0 {
    m.Title = mdata.Title[0].Value
}
if len(mdata.Creator) > 0 {
    m.Author = mdata.Creator[0].Value
}
```

#### Fix 7: API Key 认证
```go
// service/user/middleware.go:43-55
// 取消注释 API Key 验证逻辑
// 添加从 Header "X-API-Key" 或 Query "api_key" 读取
// 查表验证 → 设置用户上下文
```

### 2.2 基础加固

#### 统一错误响应
```go
// 新增 schema/response.go
package schema

type ErrorResponse struct {
    Code    string `json:"code"`              // 错误码：UNAUTHORIZED, NOT_FOUND, VALIDATION_ERROR 等
    Message string `json:"message"`           // 人类可读消息
    Details any    `json:"details,omitempty"` // 可选详情
}

type PagedResponse struct {
    Data       any   `json:"data"`
    Page       int   `json:"page"`
    PageSize   int   `json:"page_size"`
    TotalCount int64 `json:"total_count"`
    TotalPages int   `json:"total_pages"`
}

// 辅助函数
func Success(c *gin.Context, data any) {
    c.JSON(200, gin.H{"data": data})
}

func SuccessPaged(c *gin.Context, data any, page, pageSize int, total int64) {
    c.JSON(200, PagedResponse{
        Data:       data,
        Page:       page,
        PageSize:   pageSize,
        TotalCount: total,
        TotalPages: int(math.Ceil(float64(total) / float64(pageSize))),
    })
}

func Error(c *gin.Context, status int, code, message string) {
    c.JSON(status, ErrorResponse{Code: code, Message: message})
    c.Abort()
}
```

#### CORS 中间件
```go
// middleware/cors.go
func CORSMiddleware(allowOrigins string) gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Header("Access-Control-Allow-Origin", allowOrigins)
        c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization, X-API-Key")
        c.Header("Access-Control-Max-Age", "86400")
        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }
        c.Next()
    }
}
```

配置文件新增：
```yaml
# conf.yaml
server:
  cors_origins: "*"  # 生产环境改为具体域名，如 "https://example.com"
```

#### 分页参数化
```go
// schema/pagination.go
type Pagination struct {
    Page     int `form:"page" json:"page"`
    PageSize int `form:"page_size" json:"page_size"`
}

func (p *Pagination) Normalize() {
    if p.Page < 1 {
        p.Page = 1
    }
    if p.PageSize < 1 || p.PageSize > 100 {
        p.PageSize = 20
    }
}

func (p *Pagination) Offset() int {
    return (p.Page - 1) * p.PageSize
}
```

#### 请求日志中间件
```go
// middleware/logger.go
func RequestLogger() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        c.Next()
        log.I("request",
            zap.String("method", c.Request.Method),
            zap.String("path", c.Request.URL.Path),
            zap.Int("status", c.Writer.Status()),
            zap.Duration("latency", time.Since(start)),
        )
    }
}
```

#### Docker 加固
```dockerfile
# Dockerfile 修改
# 1. 添加非 root 用户
RUN addgroup -g 1000 omnigram && adduser -u 1000 -G omnigram -s /bin/sh -D omnigram
USER omnigram

# 2. 移除默认凭证
ENV CONFIG_FILE=/conf/conf.yaml
# OMNI_PASSWORD 和 OMNI_USER 不再设默认值
# docker-entrypoint.sh 检查是否设置，未设置则生成随机密码并打印
```

#### 健康检查端点

Docker 部署需要 `GET /healthz` 返回服务和数据库连接状态，用于 `docker-compose` 的 `healthcheck` 指令。

```go
// service/sys/health.go（新增）

func healthzHandle(c *gin.Context) {
    // 检查 SQLite 连接
    sqlDB, err := store.FileMetaStore().DB()
    if err != nil {
        c.JSON(503, gin.H{"status": "unhealthy", "error": "db connection failed"})
        return
    }
    if err := sqlDB.Ping(); err != nil {
        c.JSON(503, gin.H{"status": "unhealthy", "error": "db ping failed"})
        return
    }
    c.JSON(200, gin.H{"status": "healthy", "version": version.Version})
}

// 路由注册（无需认证）
router.GET("/healthz", healthzHandle)
```

Docker Compose 使用：
```yaml
services:
  omnigram:
    image: omnigram-server
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:8080/healthz"]
      interval: 30s
      timeout: 5s
      retries: 3
```

#### 登录接口限流

防止暴力破解登录，对 `/auth/login` 加 rate limit（基于 IP 的滑动窗口限流）。

```go
// middleware/rate_limit.go（新增）

type RateLimiter struct {
    mu       sync.Mutex
    attempts map[string][]time.Time
    window   time.Duration
    limit    int
}

func NewRateLimiter(window time.Duration, limit int) *RateLimiter {
    return &RateLimiter{
        attempts: make(map[string][]time.Time),
        window:   window,
        limit:    limit,
    }
}

func (rl *RateLimiter) Allow(key string) bool {
    rl.mu.Lock()
    defer rl.mu.Unlock()
    
    now := time.Now()
    windowStart := now.Add(-rl.window)
    
    // 清理过期记录
    valid := make([]time.Time, 0)
    for _, t := range rl.attempts[key] {
        if t.After(windowStart) {
            valid = append(valid, t)
        }
    }
    rl.attempts[key] = valid
    
    if len(valid) >= rl.limit {
        return false
    }
    rl.attempts[key] = append(rl.attempts[key], now)
    return true
}

func RateLimitMiddleware(limiter *RateLimiter) gin.HandlerFunc {
    return func(c *gin.Context) {
        key := c.ClientIP()
        if !limiter.Allow(key) {
            c.JSON(429, ErrorResponse{Code: "RATE_LIMITED", Message: "Too many attempts, try again later"})
            c.Abort()
            return
        }
        c.Next()
    }
}

// 注册（仅对 /auth/login）：
// loginLimiter := middleware.NewRateLimiter(15*time.Minute, 10) // 15 分钟内最多 10 次
// auth.POST("/login", middleware.RateLimitMiddleware(loginLimiter), loginHandle)
```

#### 优雅关闭

使用 `http.Server` + `Shutdown(ctx)` 处理 SIGTERM，避免请求中断。

```go
// server/app.go — 替换 router.Run()

func (m *App) Run() error {
    router := m.initGinRoute(m.level)
    
    srv := &http.Server{
        Addr:    m.conf.APIAddr,
        Handler: router,
    }
    
    // 在 goroutine 中启动服务
    go func() {
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.F("Server failed to start", zap.Error(err))
        }
    }()
    
    // 等待中断信号
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    log.I("Shutting down server...")
    
    // 给活跃请求 30 秒完成
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()
    if err := srv.Shutdown(ctx); err != nil {
        log.F("Server forced to shutdown", zap.Error(err))
    }
    
    log.I("Server exited")
    return nil
}
```

---

## 三、v0.1.0 MVP 设计

### 3.1 书籍元数据管理 API

#### 路由注册（扩展 reader/setup.go）
```go
// service/reader/setup.go — 新增路由
book.PUT("/books/:book_id", updateBookHandle)           // 编辑元数据
book.DELETE("/books/:book_id", deleteBookHandle)         // 删除书籍
book.PUT("/books/:book_id/cover", uploadCoverHandle)     // 上传封面
book.POST("/upload", bookUploadHandle)                   // 修复：GET → POST
```

#### 编辑元数据 API
```
PUT /reader/books/:book_id
Content-Type: application/json

{
    "title": "新标题",
    "author": "新作者",
    "description": "新描述",
    "publisher": "出版社",
    "language": "zh",
    "series": "系列名",
    "series_index": "1",
    "publish_date": "2025-01-01",
    "rating": 4.5,
    "tags": ["科幻", "经典"]
}

Response 200:
{
    "data": { ... book object ... }
}
```

#### 删除书籍 API
```
DELETE /reader/books/:book_id?delete_file=true

Response 200:
{
    "data": { "id": "...", "deleted": true }
}
```

#### 上传封面 API
```
PUT /reader/books/:book_id/cover
Content-Type: multipart/form-data
Body: cover (image file, max 5MB)

Response 200:
{
    "data": { "cover_url": "/img/covers/..." }
}
```

#### Handler 实现
```go
// service/reader/handler_book_edit.go（新文件）

func updateBookHandle(c *gin.Context) {
    bookID := c.Param("book_id")
    
    var req struct {
        Title       *string   `json:"title"`
        Author      *string   `json:"author"`
        Description *string   `json:"description"`
        Publisher   *string   `json:"publisher"`
        Language    *string   `json:"language"`
        Series      *string   `json:"series"`
        SeriesIndex *string   `json:"series_index"`
        PublishDate *string   `json:"publish_date"`
        Rating      *float32  `json:"rating"`
        Tags        *[]string `json:"tags"`
    }
    
    if err := c.ShouldBindJSON(&req); err != nil {
        schema.Error(c, 400, "VALIDATION_ERROR", err.Error())
        return
    }
    
    book, err := schema.FirstBookById(orm, bookID)
    if err != nil {
        schema.Error(c, 404, "NOT_FOUND", "Book not found")
        return
    }
    
    // 使用指针字段实现 partial update（nil = 不更新）
    updates := map[string]any{}
    if req.Title != nil       { updates["title"] = *req.Title }
    if req.Author != nil      { updates["author"] = *req.Author }
    if req.Description != nil { updates["description"] = *req.Description }
    if req.Publisher != nil   { updates["publisher"] = *req.Publisher }
    if req.Language != nil    { updates["language"] = *req.Language }
    if req.Series != nil      { updates["series"] = *req.Series }
    if req.SeriesIndex != nil { updates["series_index"] = *req.SeriesIndex }
    if req.PublishDate != nil { updates["pubdate"] = *req.PublishDate }
    if req.Rating != nil      { updates["rating"] = *req.Rating }
    
    if err := orm.Model(&book).Updates(updates).Error; err != nil {
        schema.Error(c, 500, "DB_ERROR", err.Error())
        return
    }
    
    // 标签更新（如果提供）
    if req.Tags != nil {
        updateBookTags(orm, bookID, *req.Tags)
    }
    
    schema.Success(c, book)
}

func deleteBookHandle(c *gin.Context) {
    bookID := c.Param("book_id")
    deleteFile := c.Query("delete_file") == "true"
    
    book, err := schema.FirstBookById(orm, bookID)
    if err != nil {
        schema.Error(c, 404, "NOT_FOUND", "Book not found")
        return
    }
    
    // 事务包裹关联数据删除，保证一致性
    err = orm.Transaction(func(tx *gorm.DB) error {
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
    
    // 删除封面
    store.GetKV().Delete(store.GetCoverBucket(book.Identifier), book.CoverURL)
    
    schema.Success(c, gin.H{"id": bookID, "deleted": true})
}
```

### 3.2 WebDAV Server

#### 技术方案
```go
// service/webdav/setup.go（新文件）

import "golang.org/x/net/webdav"

var davHandler *webdav.Handler

func Initialize(ctx context.Context) {
    cf := conf.GetConfig()
    davHandler = &webdav.Handler{
        Prefix:     "/dav",
        FileSystem: NewOmnigramFS(cf.EpubOptions.DataPath, cf.EpubOptions.SyncPath),
        LockSystem: webdav.NewMemLS(),
        Logger: func(r *http.Request, err error) {
            if err != nil {
                log.W("WebDAV error", zap.Error(err))
            }
        },
    }
}

func Setup(router *gin.Engine) {
    // WebDAV 使用 HTTP Basic Auth（OPDS/WebDAV 标准）
    dav := router.Group("/dav", BasicAuthMiddleware())
    dav.Any("/*path", gin.WrapH(davHandler))
}
```

#### 自定义文件系统（双区权限控制）

WebDAV 路径结构：
```
/dav/
├── books/           # 只读 — 书库文件浏览和下载
└── sync/            # 可写 — 阅读进度/笔记/配置同步
    └── {user}/      # 按用户隔离（从 BasicAuth 获取用户名）
```

**设计原则：** 书库文件目录只读（保护原始文件），同步目录可写（支持 Anx Reader / KOReader 数据同步）。

```go
// service/webdav/filesystem.go（新文件）

// OmnigramFS 实现 webdav.FileSystem 接口
// 双区设计：books/ 只读，sync/ 可写
type OmnigramFS struct {
    booksRoot string // 书库文件根目录（只读）
    syncRoot  string // 同步数据根目录（可写）
}

func NewOmnigramFS(booksRoot, syncRoot string) *OmnigramFS {
    return &OmnigramFS{booksRoot: booksRoot, syncRoot: syncRoot}
}

// OpenFile 实现 webdav.FileSystem 接口
func (fs *OmnigramFS) OpenFile(ctx context.Context, name string, flag int, perm os.FileMode) (webdav.File, error) {
    // 同步目录：允许读写（Anx Reader/KOReader 进度同步需要写入）
    if strings.HasPrefix(name, "/sync/") {
        syncPath := filepath.Join(fs.syncRoot, strings.TrimPrefix(name, "/sync/"))
        return os.OpenFile(syncPath, flag, perm)
    }
    // 书库目录：只允许读取，禁止写入/删除
    if flag&(os.O_WRONLY|os.O_RDWR|os.O_CREATE|os.O_TRUNC) != 0 {
        return nil, os.ErrPermission
    }
    booksPath := name
    if strings.HasPrefix(name, "/books/") {
        booksPath = strings.TrimPrefix(name, "/books/")
    }
    return os.Open(filepath.Join(fs.booksRoot, booksPath))
}

func (fs *OmnigramFS) Stat(ctx context.Context, name string) (os.FileInfo, error) {
    if strings.HasPrefix(name, "/sync/") {
        return os.Stat(filepath.Join(fs.syncRoot, strings.TrimPrefix(name, "/sync/")))
    }
    booksPath := name
    if strings.HasPrefix(name, "/books/") {
        booksPath = strings.TrimPrefix(name, "/books/")
    }
    return os.Stat(filepath.Join(fs.booksRoot, booksPath))
}

// Mkdir — 仅 sync/ 目录允许创建子目录
func (fs *OmnigramFS) Mkdir(ctx context.Context, name string, perm os.FileMode) error {
    if strings.HasPrefix(name, "/sync/") {
        return os.MkdirAll(filepath.Join(fs.syncRoot, strings.TrimPrefix(name, "/sync/")), perm)
    }
    return os.ErrPermission
}

// RemoveAll — 仅 sync/ 目录允许删除
func (fs *OmnigramFS) RemoveAll(ctx context.Context, name string) error {
    if strings.HasPrefix(name, "/sync/") {
        return os.RemoveAll(filepath.Join(fs.syncRoot, strings.TrimPrefix(name, "/sync/")))
    }
    return os.ErrPermission
}

// Rename — 仅 sync/ 目录允许重命名
func (fs *OmnigramFS) Rename(ctx context.Context, oldName, newName string) error {
    if strings.HasPrefix(oldName, "/sync/") && strings.HasPrefix(newName, "/sync/") {
        old := filepath.Join(fs.syncRoot, strings.TrimPrefix(oldName, "/sync/"))
        new := filepath.Join(fs.syncRoot, strings.TrimPrefix(newName, "/sync/"))
        return os.Rename(old, new)
    }
    return os.ErrPermission
}
```

配置文件新增：
```yaml
# conf.yaml
epub_options:
  data_path: "/data/books"
  sync_path: "/data/sync"   # 新增：WebDAV 同步目录
```

#### HTTP Basic Auth（WebDAV/OPDS 共用）
```go
// service/webdav/basic_auth.go

func BasicAuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        username, password, ok := c.Request.BasicAuth()
        if !ok {
            c.Header("WWW-Authenticate", `Basic realm="Omnigram"`)
            c.AbortWithStatus(401)
            return
        }
        
        user, err := schema.FirstUserByAccount(store.UserStore(), username)
        if err != nil || !user.VerifyPassword(password) {
            c.Header("WWW-Authenticate", `Basic realm="Omnigram"`)
            c.AbortWithStatus(401)
            return
        }
        
        c.Set(middleware.XUserIDTag, user.ID)
        c.Set(middleware.XUserInfoTag, user)
        c.Next()
    }
}
```

### 3.3 Web UI 架构

#### 技术栈
```
React 18 + TypeScript + Vite
UI: shadcn/ui (Radix UI + Tailwind CSS)
状态: TanStack Query (React Query)
路由: React Router v6
图标: Lucide Icons
构建: go:embed 嵌入 Go 二进制
```

#### 目录结构
```
server/web/
├── package.json
├── vite.config.ts
├── tsconfig.json
├── tailwind.config.js
├── index.html
├── public/
│   └── favicon.svg
└── src/
    ├── main.tsx
    ├── App.tsx
    ├── api/
    │   ├── client.ts          # Axios instance + auth
    │   ├── books.ts           # Book API hooks
    │   ├── auth.ts            # Auth API hooks
    │   └── system.ts          # System API hooks
    ├── components/
    │   ├── ui/                # shadcn/ui 组件
    │   ├── BookCard.tsx       # 书籍卡片（封面+标题+作者）
    │   ├── BookGrid.tsx       # 书籍网格视图
    │   ├── BookList.tsx       # 书籍列表视图
    │   ├── BookDetail.tsx     # 书籍详情 + 元数据编辑
    │   ├── SearchBar.tsx      # 搜索 + 过滤
    │   ├── Sidebar.tsx        # 侧边栏导航
    │   ├── Header.tsx         # 顶部导航栏
    │   └── ThemeToggle.tsx    # 亮/暗主题切换
    ├── pages/
    │   ├── LoginPage.tsx      # 登录页
    │   ├── LibraryPage.tsx    # 书库主页（网格/列表切换）
    │   ├── BookPage.tsx       # 书籍详情页
    │   ├── AdminPage.tsx      # 用户管理 + 系统设置
    │   └── SettingsPage.tsx   # 个人设置
    ├── hooks/
    │   ├── useAuth.ts
    │   ├── useBooks.ts
    │   └── useTheme.ts
    ├── lib/
    │   └── utils.ts
    └── styles/
        └── globals.css        # Tailwind 全局样式
```

#### go:embed 嵌入
```go
// server/embed.go
package server

import "embed"

//go:embed web/dist/*
var webUI embed.FS

// 在 initGinRoute 中注册：
func (m *App) initGinRoute(level zapcore.Level) *gin.Engine {
    router := gin.Default()
    
    // ... 现有 service 路由 ...
    
    // Web UI — SPA fallback
    router.NoRoute(func(c *gin.Context) {
        // API 路径返回 404 JSON
        if strings.HasPrefix(c.Request.URL.Path, "/api/") ||
           strings.HasPrefix(c.Request.URL.Path, "/auth/") ||
           strings.HasPrefix(c.Request.URL.Path, "/reader/") ||
           strings.HasPrefix(c.Request.URL.Path, "/sys/") ||
           strings.HasPrefix(c.Request.URL.Path, "/m4t/") ||
           strings.HasPrefix(c.Request.URL.Path, "/dav/") ||
           strings.HasPrefix(c.Request.URL.Path, "/opds/") {
            c.JSON(404, ErrorResponse{Code: "NOT_FOUND", Message: "API endpoint not found"})
            return
        }
        // 其他路径返回 SPA index.html
        serveWebUI(c)
    })
    
    return router
}

func serveWebUI(c *gin.Context) {
    path := c.Request.URL.Path
    
    // 尝试提供静态文件（JS/CSS/图片）
    f, err := webUI.Open("web/dist" + path)
    if err == nil {
        f.Close()
        sub, _ := fs.Sub(webUI, "web/dist")
        c.FileFromFS(path, http.FS(sub))
        return
    }
    
    // SPA fallback — 所有路径返回 index.html
    indexFile, _ := webUI.ReadFile("web/dist/index.html")
    c.Data(200, "text/html", indexFile)
}
```

#### Web UI 核心页面设计

**书库主页 (LibraryPage)**
```
┌──────────────────────────────────────────────────────┐
│  🔍 搜索...          [网格] [列表]  [⚙ 设置]  [🌙]   │
├──────────┬───────────────────────────────────────────┤
│          │                                           │
│ 📚 全部   │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐       │
│ ⭐ 收藏   │  │     │ │     │ │     │ │     │       │
│ 📖 在读   │  │ 封面 │ │ 封面 │ │ 封面 │ │ 封面 │       │
│ ✅ 已读   │  │     │ │     │ │     │ │     │       │
│          │  ├─────┤ ├─────┤ ├─────┤ ├─────┤       │
│ 🏷️ 标签   │  │标题  │ │标题  │ │标题  │ │标题  │       │
│  ├ 科幻   │  │作者  │ │作者  │ │作者  │ │作者  │       │
│  ├ 历史   │  └─────┘ └─────┘ └─────┘ └─────┘       │
│  └ 技术   │                                           │
│          │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐       │
│ 📂 书架   │  │     │ │     │ │     │ │     │       │
│  ├ 待读   │  │ ... │ │ ... │ │ ... │ │ ... │       │
│  └ 精选   │  └─────┘ └─────┘ └─────┘ └─────┘       │
│          │                                           │
│ 👤 Admin  │  ◀ 1  2  3  4  5 ▶                      │
└──────────┴───────────────────────────────────────────┘
```

### 3.4 非 EPUB 元数据提取增强

#### PDF 元数据
```go
// schema/book_pdf.go（新文件）

import "github.com/pdfcpu/pdfcpu/pkg/api"

func (book *Book) GetPDFMetadata() error {
    ctx, err := api.ReadContextFile(book.Path)
    if err != nil {
        return err
    }
    
    if ctx.Title != "" {
        book.Title = ctx.Title
    }
    if ctx.Author != "" {
        book.Author = ctx.Author
    }
    if ctx.CreationDate != "" {
        book.PublishDate = ctx.CreationDate
    }
    if ctx.Subject != "" {
        book.Description = ctx.Subject
    }
    
    return nil
}
```

#### 扩展 GetMetadataFromFile
```go
// schema/book.go — 修改现有方法
func (book *Book) GetMetadataFromFile() error {
    switch book.FileType {
    case EPUB:
        return book.getEpubMetadata()  // 现有逻辑
    case PDF:
        return book.GetPDFMetadata()   // 新增
    case MOBI, AZW3:
        return book.GetMobiMetadata()  // 新增（解析 EXTH header）
    case FB2:
        return book.GetFB2Metadata()   // 新增（解析 XML）
    default:
        // TXT/MD — 从文件名推断标题
        book.Title = strings.TrimSuffix(filepath.Base(book.Path), filepath.Ext(book.Path))
        return nil
    }
}
```

---

## 四、v0.2.0 设计

### 4.1 标签 & 书架系统

#### 数据模型
```go
// schema/shelf.go（新文件）

type Shelf struct {
    ID          int64  `json:"id" gorm:"primaryKey;autoIncrement"`
    UserID      int64  `json:"user_id" gorm:"index;not null"`
    Name        string `json:"name" gorm:"type:varchar(200);not null"`
    Description string `json:"description,omitempty" gorm:"type:text"`
    CoverURL    string `json:"cover_url,omitempty" gorm:"type:varchar(255)"`
    SortOrder   int    `json:"sort_order" gorm:"default:0"`
    BookCount   int    `json:"book_count" gorm:"-"` // 计算字段
    CTime       int64  `json:"ctime" gorm:"autoCreateTime:milli"`
    UTime       int64  `json:"utime" gorm:"autoUpdateTime:milli"`
}

type ShelfBook struct {
    ID        int64  `json:"id" gorm:"primaryKey;autoIncrement"`
    ShelfID   int64  `json:"shelf_id" gorm:"uniqueIndex:idx_shelf_book;not null"`
    BookID    string `json:"book_id" gorm:"uniqueIndex:idx_shelf_book;type:char(24);not null"`
    SortOrder int    `json:"sort_order" gorm:"default:0"`
    CTime     int64  `json:"ctime" gorm:"autoCreateTime:milli"`
}
```

#### API 路由
```go
// service/reader/setup.go — 新增
book.GET("/tags", listTagsHandle)
book.POST("/tags", createTagHandle)
book.DELETE("/tags/:tag_id", deleteTagHandle)
book.PUT("/books/:book_id/tags", updateBookTagsHandle)

book.GET("/shelves", listShelvesHandle)
book.POST("/shelves", createShelfHandle)
book.GET("/shelves/:shelf_id", getShelfHandle)
book.PUT("/shelves/:shelf_id", updateShelfHandle)
book.DELETE("/shelves/:shelf_id", deleteShelfHandle)
book.POST("/shelves/:shelf_id/books", addBooksToShelfHandle)
book.DELETE("/shelves/:shelf_id/books", removeBooksFromShelfHandle)
```

#### API 规范

```
GET /reader/tags
Response: { "data": [{ "id": 1, "tag": "科幻", "count": 42 }, ...] }

POST /reader/tags
Body: { "tag": "新标签" }
Response: { "data": { "id": 2, "tag": "新标签" } }

PUT /reader/books/:book_id/tags
Body: { "tags": ["科幻", "经典", "必读"] }
Response: { "data": { "book_id": "...", "tags": [...] } }

GET /reader/shelves
Response: { "data": [{ "id": 1, "name": "待读", "book_count": 15, ... }] }

POST /reader/shelves
Body: { "name": "精选书单", "description": "..." }
Response: { "data": { "id": 2, "name": "精选书单", ... } }

POST /reader/shelves/:shelf_id/books
Body: { "book_ids": ["abc123", "def456"] }
Response: { "data": { "added": 2 } }

DELETE /reader/shelves/:shelf_id/books
Body: { "book_ids": ["abc123"] }
Response: { "data": { "removed": 1 } }
```

### 4.2 笔记 & 高亮 & 评分同步

#### 数据模型
```go
// schema/annotation.go（新文件）

type AnnotationType string

const (
    AnnotationNote      AnnotationType = "note"
    AnnotationHighlight AnnotationType = "highlight"
    AnnotationBookmark  AnnotationType = "bookmark"
)

type Annotation struct {
    ID         int64          `json:"id" gorm:"primaryKey;autoIncrement"`
    UserID     int64          `json:"user_id" gorm:"index:idx_annotation_user_book;not null"`
    BookID     string         `json:"book_id" gorm:"index:idx_annotation_user_book;type:char(24);not null"`
    DeviceID   string         `json:"device_id,omitempty" gorm:"type:varchar(50)"`
    Chapter    string         `json:"chapter,omitempty" gorm:"type:varchar(200)"`
    Content    string         `json:"content" gorm:"type:text"`
    SelectedText string       `json:"selected_text,omitempty" gorm:"type:text"` // 高亮的原文
    CFI        string         `json:"cfi,omitempty" gorm:"type:varchar(500)"`   // EPUB CFI
    PageNumber int            `json:"page_number,omitempty" gorm:"default:0"`   // PDF 页码
    Position   string         `json:"position,omitempty" gorm:"type:varchar(500)"` // 通用定位
    Color      string         `json:"color,omitempty" gorm:"type:varchar(20)"`
    Type       AnnotationType `json:"type" gorm:"type:varchar(20);not null"`
    CTime      int64          `json:"ctime" gorm:"autoCreateTime:milli"`
    UTime      int64          `json:"utime" gorm:"autoUpdateTime:milli"`
}
```

#### API 路由
```go
// service/reader/setup.go — 新增
book.PUT("/books/:book_id/rating", updateBookRatingHandle)
book.GET("/books/:book_id/annotations", listAnnotationsHandle)
book.POST("/books/:book_id/annotations", createAnnotationHandle)
book.PUT("/books/:book_id/annotations/:annotation_id", updateAnnotationHandle)
book.DELETE("/books/:book_id/annotations/:annotation_id", deleteAnnotationHandle)

router.POST("/sync/annotations", oauthMD, syncAnnotationsHandle) // 批量同步
```

#### 批量同步 API（Anx Reader 兼容）
```
POST /sync/annotations
Body: {
    "device_id": "iphone-xxx",
    "last_sync_time": 1711000000000,
    "annotations": [
        {
            "book_id": "abc123",
            "type": "highlight",
            "content": "这是一段重要的话",
            "selected_text": "原文内容",
            "cfi": "/6/4[chap01]!/4/2/1:0",
            "color": "#FFD700",
            "ctime": 1711000001000,
            "utime": 1711000001000
        }
    ]
}

Response: {
    "data": {
        "synced": 5,
        "server_annotations": [ ... 服务端有但客户端没有的 ... ]
    }
}
```

### 4.3 OPDS 目录服务

#### 路由注册
```go
// service/reader/opds/setup.go（新文件）

func Setup(router *gin.Engine) {
    // OPDS 使用 HTTP Basic Auth
    opdsGroup := router.Group("/opds/v1.2", BasicAuthMiddleware())
    
    opdsGroup.GET("/catalog", catalogHandler)
    opdsGroup.GET("/search", searchHandler)
    opdsGroup.GET("/new", newBooksHandler)
    opdsGroup.GET("/popular", popularBooksHandler)
    opdsGroup.GET("/authors", authorsHandler)
    opdsGroup.GET("/authors/:name", authorBooksHandler)
    opdsGroup.GET("/tags/:tag", tagBooksHandler)
    opdsGroup.GET("/shelves", shelvesHandler)
    opdsGroup.GET("/shelves/:id", shelfBooksHandler)
    opdsGroup.GET("/books/:id/download", downloadHandler)
}
```

#### OPDS Catalog 根目录
```go
func catalogHandler(c *gin.Context) {
    feed := opds.BuildNavigationFeed("omnigram:catalog", "Omnigram Library", "/opds/v1.2/catalog",
        []opds.Entry{
            {ID: "new", Title: "最新入库", Link: []opds.Link{{Href: "/opds/v1.2/new", Type: opds.DirMime, Rel: opds.DirRel}}},
            {ID: "popular", Title: "最受欢迎", Link: []opds.Link{{Href: "/opds/v1.2/popular", Type: opds.DirMime, Rel: opds.DirRel}}},
            {ID: "authors", Title: "按作者", Link: []opds.Link{{Href: "/opds/v1.2/authors", Type: opds.DirMime, Rel: opds.DirRel}}},
            {ID: "tags", Title: "按标签", Link: []opds.Link{{Href: "/opds/v1.2/tags", Type: opds.DirMime, Rel: opds.DirRel}}},
            {ID: "shelves", Title: "书架", Link: []opds.Link{{Href: "/opds/v1.2/shelves", Type: opds.DirMime, Rel: opds.DirRel}}},
        },
    )
    
    // OPDS Search 描述
    feed.Link = append(feed.Link, opds.Link{
        Href: "/opds/v1.2/search?q={searchTerms}",
        Type: "application/opensearchdescription+xml",
        Rel:  "search",
    })
    
    c.XML(200, feed)
}
```

#### Book → OPDS Entry 转换
```go
func bookToEntry(book *schema.Book, baseURL string) opds.Entry {
    entry := opds.Entry{
        ID:      "urn:omnigram:book:" + book.ID,
        Updated: time.UnixMilli(book.UTime).UTC().Format(opds.AtomTime),
        Title:   book.Title,
        Author:  opds.Author{Name: book.Author},
        Summary: opds.Summary{Type: "text", Text: truncate(book.Description, 200)},
        Link: []opds.Link{
            // 下载链接
            {Href: baseURL + "/opds/v1.2/books/" + book.ID + "/download",
             Type: mimeForFileType(book.FileType), Rel: opds.FileRel},
        },
    }
    
    // 封面链接
    if book.CoverURL != "" {
        entry.Link = append(entry.Link, opds.Link{
            Href: baseURL + "/img/covers/" + book.CoverURL,
            Type: "image/jpeg", Rel: opds.CoverRel,
        })
    }
    
    return entry
}
```

### 4.4 Calibre 数据库导入

#### CLI 命令
```go
// cmd/omni-server/main.go — 新增 import 子命令
// omni-server import --calibre /path/to/calibre --config /conf/conf.yaml

func importCalibre(calibrePath string) error {
    // 1. 打开 Calibre metadata.db（SQLite）
    // 2. 读取 books 表 → 映射到 schema.Book
    // 3. 读取 authors 表 → join books_authors_link
    // 4. 读取 tags 表 → join books_tags_link
    // 5. 读取 series 表 → join books_series_link
    // 6. 读取封面 cover.jpg → 存入 BadgerDB
    // 7. 按 ISBN/title+author 去重
    // 8. 输出导入报告
}
```

#### Calibre metadata.db 表映射
```
Calibre                         → Omnigram
─────────────────────────────── → ─────────────────
books.title                     → Book.Title
books.sort                      → Book.AuthorSort
books.timestamp                 → Book.CTime
books.pubdate                   → Book.PublishDate
books.series_index              → Book.SeriesIndex
books.isbn                      → Book.ISBN
books.path                      → (构建完整路径)
authors.name (via link)         → Book.Author
tags.name (via link)            → BookTagShip
series.name (via link)          → Book.Series
publishers.name (via link)      → Book.Publisher
comments.text (via link)        → Book.Description
ratings.rating (via link)       → Book.Rating
languages.lang_code (via link)  → Book.Language
identifiers (via link)          → Book.ISBN/ASIN/UUID
cover.jpg (in book path)        → BadgerDB cover
```

### 4.5 备份/恢复 CLI

自托管用户的核心需求——数据可备份、可迁移。

#### CLI 命令
```go
// cmd/omni-server/main.go — 新增 backup/restore 子命令

// 备份：omni-server backup --output /backups/omnigram-2026-03-21.tar.gz
// 恢复：omni-server restore --input /backups/omnigram-2026-03-21.tar.gz --config /conf/conf.yaml

func backupData(outputPath string) error {
    // 1. 暂停写入（可选：PRAGMA wal_checkpoint）
    // 2. 打包 omnigram.db + file_meta.db + badger/ + conf.yaml → tar.gz
    // 3. 记录版本号和创建时间到 backup-meta.json
    // 4. 输出备份文件路径和大小
    
    files := []string{
        filepath.Join(dataDir, "omnigram.db"),
        filepath.Join(dataDir, "file_meta.db"),
        filepath.Join(dataDir, "badger"),
        confPath,
    }
    
    meta := BackupMeta{
        Version:   version.Version,
        CreatedAt: time.Now().UTC(),
        DBVersion: getCurrentMigrationVersion(),
    }
    
    return createTarGz(outputPath, files, meta)
}

func restoreData(inputPath string) error {
    // 1. 验证 backup-meta.json 中的版本兼容性
    // 2. 停止服务（如果正在运行）
    // 3. 解压覆盖 omnigram.db + file_meta.db + badger/
    // 4. 运行数据库迁移（如果版本不同）
    // 5. 输出恢复报告
    
    meta, err := readBackupMeta(inputPath)
    if err != nil {
        return fmt.Errorf("invalid backup: %w", err)
    }
    
    log.I("Restoring from backup", 
        zap.String("version", meta.Version),
        zap.Time("created_at", meta.CreatedAt))
    
    return extractTarGz(inputPath, dataDir)
}
```

Docker 用户备份示例：
```bash
# 创建备份
docker exec omnigram omni-server backup --output /data/backup.tar.gz

# 从宿主机拷贝
docker cp omnigram:/data/backup.tar.gz ./backup.tar.gz
```

---

## 五、v0.3.0 设计

### 5.1 搜索增强（SQLite FTS5）

> **已知限制：** FTS5 使用 `unicode61` tokenizer 对中文做字符级分词（每个字一个 token），搜索精度不如词级分词。MVP 阶段可接受，后续可选方案：引入 [bleve](https://github.com/blevesearch/bleve) 全文搜索库（纯 Go，支持中文分词插件），或维持现状按需优化。

#### FTS5 初始化
```go
// store/fts.go（新文件）

func InitFTS(db *gorm.DB) error {
    // 创建 FTS5 虚拟表
    return db.Exec(`
        CREATE VIRTUAL TABLE IF NOT EXISTS books_fts USING fts5(
            book_id,
            title,
            author,
            description,
            tags,
            publisher,
            content='books',
            content_rowid='rowid',
            tokenize='unicode61'
        )
    `).Error
}

// 同步触发器（书籍创建/更新时自动同步到 FTS）
func CreateFTSTriggers(db *gorm.DB) error {
    triggers := []string{
        `CREATE TRIGGER IF NOT EXISTS books_ai AFTER INSERT ON books BEGIN
            INSERT INTO books_fts(book_id, title, author, description, tags, publisher)
            VALUES (new.id, new.title, new.author, new.description, new.tags, new.publisher);
        END`,
        `CREATE TRIGGER IF NOT EXISTS books_ad AFTER DELETE ON books BEGIN
            INSERT INTO books_fts(books_fts, book_id, title, author, description, tags, publisher)
            VALUES ('delete', old.id, old.title, old.author, old.description, old.tags, old.publisher);
        END`,
        `CREATE TRIGGER IF NOT EXISTS books_au AFTER UPDATE ON books BEGIN
            INSERT INTO books_fts(books_fts, book_id, title, author, description, tags, publisher)
            VALUES ('delete', old.id, old.title, old.author, old.description, old.tags, old.publisher);
            INSERT INTO books_fts(book_id, title, author, description, tags, publisher)
            VALUES (new.id, new.title, new.author, new.description, new.tags, new.publisher);
        END`,
    }
    for _, t := range triggers {
        if err := db.Exec(t).Error; err != nil {
            return err
        }
    }
    return nil
}
```

#### 搜索 API
```
GET /reader/search?q=关键词&format=epub&language=zh&tag=科幻&sort=title&order=asc&page=1&page_size=20

Response: {
    "data": [...],
    "page": 1,
    "page_size": 20,
    "total_count": 142,
    "total_pages": 8
}
```

```go
// 搜索排序字段白名单（防止 SQL 注入）
var allowedSortFields = map[string]string{
    "title":  "title",
    "author": "author",
    "utime":  "u_time",
    "ctime":  "c_time",
    "rating": "rating",
}

func searchBooksHandle(c *gin.Context) {
    q := c.Query("q")
    format := c.Query("format")
    language := c.Query("language")
    tag := c.Query("tag")
    sort := c.DefaultQuery("sort", "utime")
    order := c.DefaultQuery("order", "desc")
    
    // 白名单校验：防止 sort/order 参数 SQL 注入
    sortColumn, ok := allowedSortFields[sort]
    if !ok {
        sortColumn = "u_time"
    }
    if order != "asc" && order != "desc" {
        order = "desc"
    }
    
    var pagination schema.Pagination
    c.ShouldBindQuery(&pagination)
    pagination.Normalize()
    
    var books []schema.Book
    var total int64
    
    query := orm.Model(&schema.Book{})
    
    // FTS5 全文搜索
    if q != "" {
        query = query.Where("id IN (SELECT book_id FROM books_fts WHERE books_fts MATCH ?)", q)
    }
    
    // 过滤器
    if format != "" {
        query = query.Where("file_type = ?", schema.ParseFileType(format))
    }
    if language != "" {
        query = query.Where("language = ?", language)
    }
    if tag != "" {
        query = query.Where("id IN (SELECT book_id FROM book_tag_ships WHERE tag = ?)", tag)
    }
    
    // 总数
    query.Count(&total)
    
    // 排序 + 分页（使用白名单校验后的值）
    orderClause := sortColumn + " " + order
    query.Order(orderClause).Offset(pagination.Offset()).Limit(pagination.PageSize).Find(&books)
    
    schema.SuccessPaged(c, books, pagination.Page, pagination.PageSize, total)
}
```

### 5.2 阅读统计

#### 数据模型
```go
// schema/reading_session.go（新文件）

type ReadingSession struct {
    ID        int64  `json:"id" gorm:"primaryKey;autoIncrement"`
    UserID    int64  `json:"user_id" gorm:"index:idx_session_user;not null"`
    BookID    string `json:"book_id" gorm:"index:idx_session_book;type:char(24);not null"`
    DeviceID  string `json:"device_id,omitempty" gorm:"type:varchar(50)"`
    StartTime int64  `json:"start_time" gorm:"not null"`
    EndTime   int64  `json:"end_time" gorm:"not null"`
    Duration  int64  `json:"duration" gorm:"not null"` // 秒
    PagesRead int    `json:"pages_read" gorm:"default:0"`
}
```

#### API
```
POST /reader/sessions
Body: { "book_id": "abc", "device_id": "iphone", "start_time": ..., "end_time": ..., "duration": 1800, "pages_read": 15 }

GET /reader/stats/overview
Response: { "data": { "total_books": 500, "reading": 12, "completed": 45, "total_reading_time": 360000 } }

GET /reader/stats/daily?from=2026-01-01&to=2026-03-21
Response: { "data": [{ "date": "2026-03-20", "duration": 3600, "pages": 30 }, ...] }

GET /reader/stats/books?limit=10
Response: { "data": [{ "book_id": "abc", "title": "...", "total_duration": 18000 }, ...] }
```

### 5.3 最小 AI 集成

#### LLM Provider 抽象
```go
// service/ai/provider.go（新文件）

type LLMProvider interface {
    Complete(ctx context.Context, prompt string) (string, error)
    Name() string
}

// OpenAI 兼容 Provider（支持 OpenAI / Ollama / DeepSeek 等）
type OpenAIProvider struct {
    BaseURL string
    APIKey  string
    Model   string
    client  *http.Client
}

func (p *OpenAIProvider) Complete(ctx context.Context, prompt string) (string, error) {
    // POST /v1/chat/completions
    // 标准 OpenAI 兼容接口
}
```

#### 配置扩展
```yaml
# conf/conf.yaml 新增
ai_options:
  enabled: false                    # 默认关闭
  provider: "openai"               # openai / ollama
  base_url: "https://api.openai.com/v1"  # 或 http://localhost:11434/v1
  api_key: ""
  model: "gpt-4o-mini"             # 或 llama3.2
  auto_metadata: true              # 导入时自动补全元数据
  auto_summary: true               # 导入时自动生成摘要
```

#### 导入时自动增强
```go
// service/ai/metadata.go

func EnhanceBookMetadata(book *schema.Book) error {
    if !conf.GetConfig().AIOptions.Enabled {
        return nil
    }
    
    provider := GetProvider()
    
    prompt := fmt.Sprintf(`Given this book:
Title: %s
Author: %s
Description: %s

Please provide in JSON format:
1. A brief 1-2 sentence summary (field: "summary")
2. 3-5 relevant tags/categories (field: "tags")
3. The language of the book (field: "language") 
4. If description is empty, write a brief description (field: "description")

Only fill in fields that are missing or empty. Return valid JSON.`, 
        book.Title, book.Author, book.Description)
    
    result, err := provider.Complete(context.Background(), prompt)
    if err != nil {
        log.W("AI metadata enhancement failed", zap.Error(err))
        return nil // 不影响导入流程
    }
    
    // 解析 JSON 结果，仅填充空字段
    var enhancement struct {
        Summary     string   `json:"summary"`
        Tags        []string `json:"tags"`
        Language    string   `json:"language"`
        Description string   `json:"description"`
    }
    json.Unmarshal([]byte(result), &enhancement)
    
    if book.Description == "" && enhancement.Description != "" {
        book.Description = enhancement.Description
    }
    if book.Language == "" && enhancement.Language != "" {
        book.Language = enhancement.Language
    }
    // tags 和 summary 通过额外字段存储
    
    return nil
}
```

#### AI 配置 API（Web UI 用）
```
GET /sys/ai/status
Response: { "data": { "enabled": true, "provider": "ollama", "model": "llama3.2", "status": "connected" } }

PUT /sys/ai/config  (Admin only)
Body: { "enabled": true, "provider": "ollama", "base_url": "http://localhost:11434/v1", "model": "llama3.2" }
```

### 5.4 批量操作

```go
// service/reader/setup.go — 新增
book.POST("/books/batch/delete", batchDeleteHandle)
book.POST("/books/batch/tag", batchTagHandle)
book.POST("/books/batch/shelf", batchShelfHandle)
```

```
POST /reader/books/batch/delete
Body: { "book_ids": ["abc", "def", "ghi"], "delete_files": false }
Response: { "data": { "deleted": 3 } }

POST /reader/books/batch/tag
Body: { "book_ids": ["abc", "def"], "tags": ["经典", "必读"], "action": "add" }  // add | remove | set
Response: { "data": { "updated": 2 } }

POST /reader/books/batch/shelf
Body: { "book_ids": ["abc", "def"], "shelf_id": 1, "action": "add" }  // add | remove
Response: { "data": { "updated": 2 } }
```

---

## 六、数据库迁移策略

### 自动迁移
```go
// store/migrate.go（新文件）

func AutoMigrate(db *gorm.DB) error {
    return db.AutoMigrate(
        // 现有模型
        &schema.User{},
        &schema.Session{},
        &schema.APIToken{},
        &schema.Book{},
        &schema.BookTagShip{},
        &schema.ReadProgress{},
        &schema.FavBook{},
        // v0.2.0 新增
        &schema.Shelf{},
        &schema.ShelfBook{},
        &schema.Annotation{},
        // v0.3.0 新增
        &schema.ReadingSession{},
    )
}
```

### 版本化迁移
```go
// 对于破坏性变更，使用版本号控制
// store/migrations/
//   v0_1_0.go  — Phase 1.5 安全字段变更
//   v0_2_0.go  — 新增 Shelf/Annotation 表 + FTS5
//   v0_3_0.go  — 新增 ReadingSession 表
```

---

## 七、API 版本与路由汇总

### 完整路由表（Phase 2.0 完成后）

```
# ─── 认证（现有） ─────────────────────────────────
POST   /auth/login
POST   /auth/token
POST   /auth/token/refresh
POST   /auth/logout                    [OAuth]
POST   /auth/accounts/:uid/apikeys     [OAuth]
GET    /auth/accounts/:uid/apikeys     [OAuth]
DELETE /auth/accounts/:uid/apikeys/:kid [OAuth]
POST   /auth/accounts/:uid/reset       [OAuth]

# ─── 用户（现有） ─────────────────────────────────
GET    /user/userinfo                  [OAuth]
POST   /admin/accounts                 [OAuth+Admin]
GET    /admin/accounts                 [OAuth+Admin]
GET    /admin/accounts/:uid            [OAuth+Admin]
DELETE /admin/accounts/:uid            [OAuth+Admin]

# ─── 书库（现有 + 扩展） ──────────────────────────
GET    /reader/stats                   [OAuth]
GET    /reader/index                   [OAuth]
GET    /reader/books                   [OAuth]         ← 增强搜索
GET    /reader/search                  [OAuth]         ← v0.3.0 FTS5
GET    /reader/recent                  [OAuth]
GET    /reader/fav                     [OAuth]
GET    /reader/personal                [OAuth]
POST   /reader/upload                  [OAuth]         ← 修复 GET→POST
GET    /reader/download/books/:bid     [OAuth]

GET    /reader/books/:bid              [OAuth]
PUT    /reader/books/:bid              [OAuth]         ← v0.1.0 新增
DELETE /reader/books/:bid              [OAuth]         ← v0.1.0 新增
PUT    /reader/books/:bid/cover        [OAuth]         ← v0.1.0 新增
GET    /reader/books/:bid/progress     [OAuth]
PUT    /reader/books/:bid/progress     [OAuth]
PUT    /reader/books/:bid/rating       [OAuth]         ← v0.2.0 新增
PUT    /reader/books/:bid/tags         [OAuth]         ← v0.2.0 新增

# ─── 笔记/高亮（v0.2.0 新增） ──────────────────────
GET    /reader/books/:bid/annotations  [OAuth]
POST   /reader/books/:bid/annotations  [OAuth]
PUT    /reader/books/:bid/annotations/:aid [OAuth]
DELETE /reader/books/:bid/annotations/:aid [OAuth]

# ─── 标签（v0.2.0 新增） ──────────────────────────
GET    /reader/tags                    [OAuth]
POST   /reader/tags                    [OAuth]
DELETE /reader/tags/:tid               [OAuth]

# ─── 书架（v0.2.0 新增） ──────────────────────────
GET    /reader/shelves                 [OAuth]
POST   /reader/shelves                 [OAuth]
GET    /reader/shelves/:sid            [OAuth]
PUT    /reader/shelves/:sid            [OAuth]
DELETE /reader/shelves/:sid            [OAuth]
POST   /reader/shelves/:sid/books      [OAuth]
DELETE /reader/shelves/:sid/books      [OAuth]

# ─── 阅读会话（v0.3.0 新增） ──────────────────────
POST   /reader/sessions               [OAuth]
GET    /reader/stats/overview          [OAuth]
GET    /reader/stats/daily             [OAuth]
GET    /reader/stats/monthly           [OAuth]
GET    /reader/stats/books             [OAuth]

# ─── 批量操作（v0.3.0 新增） ──────────────────────
POST   /reader/books/batch/delete      [OAuth]
POST   /reader/books/batch/tag         [OAuth]
POST   /reader/books/batch/shelf       [OAuth]

# ─── 同步（现有 + 扩展） ──────────────────────────
POST   /sync/full                      [OAuth]
POST   /sync/delta                     [OAuth]
POST   /sync/annotations              [OAuth]         ← v0.2.0 新增

# ─── 封面图片（现有） ─────────────────────────────
GET    /img/covers/*path               [OAuth]

# ─── TTS（现有） ──────────────────────────────────
POST   /m4t/tts/stream                [OAuth]
POST   /m4t/tts/simple                [OAuth]
GET    /m4t/tts/speakers              [OAuth]
POST   /m4t/tts/speakers              [OAuth]
DELETE /m4t/tts/speakers/:aid         [OAuth]

# ─── 系统（现有 + 扩展） ──────────────────────────
GET    /healthz                        [NoAuth]        ← v0.1.0 新增
GET    /sys/ping
GET    /sys/info                       [OAuth]
PUT    /sys/info                       [OAuth+Admin]
GET    /sys/scan/status                [OAuth+Admin]
POST   /sys/scan/stop                  [OAuth+Admin]
POST   /sys/scan/run                   [OAuth+Admin]
GET    /sys/ai/status                  [OAuth]         ← v0.3.0 新增
PUT    /sys/ai/config                  [OAuth+Admin]   ← v0.3.0 新增

# ─── WebDAV（v0.1.0 新增） ────────────────────────
*      /dav/books/*path                [BasicAuth]     ← 只读：书库文件浏览
*      /dav/sync/*path                 [BasicAuth]     ← 读写：进度/笔记同步

# ─── OPDS（v0.2.0 新增） ─────────────────────────
GET    /opds/v1.2/catalog              [BasicAuth]
GET    /opds/v1.2/search               [BasicAuth]
GET    /opds/v1.2/new                  [BasicAuth]
GET    /opds/v1.2/popular              [BasicAuth]
GET    /opds/v1.2/authors              [BasicAuth]
GET    /opds/v1.2/authors/:name        [BasicAuth]
GET    /opds/v1.2/tags/:tag            [BasicAuth]
GET    /opds/v1.2/shelves              [BasicAuth]
GET    /opds/v1.2/shelves/:id          [BasicAuth]
GET    /opds/v1.2/books/:id/download   [BasicAuth]

# ─── Web UI（v0.1.0 新增） ────────────────────────
GET    /*                              [NoAuth → SPA]  ← go:embed React
```

**总计：~88 个端点（现有 39 + 新增 ~49）**

---

## 八、构建与部署

### Makefile 更新
```makefile
# server/Makefile 新增
.PHONY: web
web:
	cd web && npm install && npm run build

.PHONY: build
build: web
	go build -o bin/omni-server ./cmd/omni-server

.PHONY: dev
dev:
	cd web && npm run dev &
	go run ./cmd/omni-server -conf conf/conf.yaml

.PHONY: docker
docker: web
	docker build -t omnigram-server .
```

### Dockerfile 更新
```dockerfile
# 新增 Node.js 构建阶段
FROM node:20-alpine AS webbuilder
COPY web/ /web/
WORKDIR /web
RUN npm ci && npm run build

# Go 构建阶段
FROM golang:1.23.1-alpine3.20 AS gobuilder
COPY --from=webbuilder /web/dist /omnigram-server/web/dist
COPY / /omnigram-server
# ... 现有构建逻辑 ...
```

---

## 九、测试策略

| 层级 | 覆盖范围 | 工具 |
|------|---------|------|
| API 测试 | 每个新增端点 | Go `httptest` + `testify` |
| 数据模型测试 | CRUD + 边界条件 | GORM + SQLite in-memory |
| WebDAV 兼容测试 | KOReader / cadaver CLI | 手动 + 脚本 |
| OPDS 兼容测试 | Moon+ Reader / FBReader | 手动验证 |
| Web UI 测试 | 核心页面渲染 + 交互 | Vitest + Playwright (可选) |
| 集成测试 | Docker 端到端 | docker-compose + curl |

---

## 十、修订记录

| 日期 | 修订内容 |
|------|---------|
| 2026-03-21 | 初版（Phase 1.5 + v0.1.0 ~ v0.3.0 全量设计） |
| 2026-03-21 | 整合 012-review.md 审计意见，主要变更：|

**审计修复清单：**

| # | 类型 | 修复内容 |
|---|------|---------|
| 1 | 🔴 严重 | WebDAV 改为双区设计：`/dav/books/` 只读 + `/dav/sync/` 可写（支持 Anx Reader / KOReader 同步） |
| 2 | 🔴 严重 | 搜索 handler `sort`/`order` 参数增加白名单校验（防止 SQL 注入） |
| 3 | 🟡 中等 | CORS `Allow-Origin` 改为从配置文件读取（`server.cors_origins`） |
| 4 | 🟡 中等 | `deleteBookHandle` 用 `orm.Transaction` 包裹关联删除（保证一致性） |
| 5 | 🟡 中等 | `serveWebUI` 中 `subFS()` 替换为标准库 `fs.Sub()` |
| 6 | 🟡 中等 | FTS5 中文字符级分词标注为已知限制 |
| 7 | 🟢 新增 | Phase 1.5 增加 `GET /healthz` 健康检查端点 |
| 8 | 🟢 新增 | Phase 1.5 增加 `/auth/login` IP 限流（15 分钟 10 次） |
| 9 | 🟢 新增 | Phase 1.5 增加优雅关闭（`http.Server` + `Shutdown` + SIGTERM） |
| 10 | 🟢 新增 | v0.2.0 增加备份/恢复 CLI（`omni-server backup` / `restore`） |
