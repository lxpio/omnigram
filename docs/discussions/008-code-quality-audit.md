# 008 - 代码质量审计报告

> 审计日期：2026-03-21
> 状态：🔴 需要修复
> 审计范围：Go 后端 (`server/`) + Flutter 前端 (`app/`)
> 审计方式：逐文件代码扫描，不信任文档，只看代码

---

## 总览

| 模块 | 评分 | 一句话 |
|------|------|--------|
| **Go 后端** | ⭐ 2.5/5 | 安全问题多，错误处理不规范，测试几乎为零 |
| **Flutter 前端** | ⭐ 2.5/5 | 架构问题（嵌套 MaterialApp），关键 bug（拦截器丢失），大量死代码 |
| **综合** | ⭐ 2.5/5 | 原型阶段的代码，需要大量加固才能作为正式产品发布 |

---

## 一、Go 后端审计

### 各模块评分

| 模块 | 评分 | 最严重问题 |
|------|------|-----------|
| 项目结构 | 3/5 | Schema 层耦合了存储层 |
| 入口文件 | 3/5 | ListenAndServe 错误被静默吞掉 |
| 路由/中间件 | 2.5/5 | API Key 认证被注释掉了（失效） |
| GORM/模型 | 2.5/5 | OpenDB 吞掉错误；Title 解析会 panic |
| 服务层 | 2/5 | 错误响应后缺少 return，double write |
| 安全 | 1.5/5 | 明文密码日志、math/rand 生成 token、默认凭证 |
| 测试 | 1/5 | 无 handler/auth/集成测试 |
| 依赖 | 3/5 | yaml.v2 弃用、legacy protobuf |
| 构建 | 3/5 | Docker arg 拼写错误 |
| Docker | 2.5/5 | 以 root 运行，默认凭证 |

### 🔴 严重问题（必须修复）

#### 1. 明文密码写入日志
```
文件: schema/init_data.go:57
代码: log.I("初始化数据, 用户信息: ", u.Name, u.Credential)
风险: 密码明文出现在日志文件中
```

#### 2. Session Token 可预测
```
文件: schema/session.go:117-123, utils/utils.go:3
问题: 使用 math/rand 生成 session token 和 API key
修复: 改用 crypto/rand
```

#### 3. 错误响应后缺少 return（double write）
```
文件: service/user/handler.go:60-64
问题: 发送 500 错误响应后未 return，继续执行到 200 成功响应
同样问题: handler.go:377-382
```

#### 4. OpenDB 吞掉错误
```
文件: store/orm.go:35
问题: gorm.Open() 失败时返回 nil error，db 可能为 nil
```

#### 5. 密码重置无验证
```
文件: service/user/handler.go:345-347
问题: code 字段存在但从未校验，任何人可重置任何用户密码
```

#### 6. Title 解析 panic
```
文件: schema/book.go:479-481
代码: if len(mdata.Creator) > 0 { m.Title = mdata.Title[0].Value }
问题: 检查的是 Creator 长度，访问的是 Title —— Title 为空时会 panic
```

#### 7. API Key 认证失效
```
文件: service/user/middleware.go:43-55
问题: API Key 验证逻辑被整段注释掉
```

### 🟡 中等问题

| 文件 | 问题 |
|------|------|
| `app.go:89` | `SetTrustedProxies(["0.0.0.0/0"])` — 信任所有代理 |
| `service/reader/setup.go:37` | 文件上传用了 GET 方法，应为 POST |
| `service/m4t/handler.go:20` | gRPC 连接无 TLS |
| `service/m4t/setup.go:65` | gRPC 连接泄漏（无 Close） |
| `conf/models.go` | 整个文件为死代码（旧版 OpenAI 模型映射） |
| `upstream/` 包 | `NewProxyHandler` 从未被调用 |
| `service/user/helper.go:5-7` | `cleanUserSession` 内含 `panic("implement me")` |
| `store/localdir.go:98-99` | 生产代码中残留 `println("close file")` |
| `Dockerfile:43` | 默认凭证 `admin/123456` 硬编码为 ENV |
| `schema/favorite_book.go:34` | SQL 参数绑定错误（userID 绑到 LIMIT） |
| `schema/read_process.go:76` | 列名 `update_at` 与 GORM tag `updated_at` 不匹配 |

---

## 二、Flutter 前端审计

### 各模块评分

| 模块 | 评分 | 最严重问题 |
|------|------|-----------|
| 项目结构 | 3.5/5 | models vs entities 命名混淆 |
| 依赖健康 | 2/5 | Isar 预发布版、beta 依赖、test 包在 dependencies |
| 应用初始化 | 2.5/5 | **嵌套 MaterialApp**（关键架构问题） |
| 状态管理 | 3/5 | async 方法中用 ref.watch（应为 ref.read） |
| 路由 | 2.5/5 | **无认证守卫**、unsafe cast |
| API 客户端 | 2.5/5 | **拦截器被静默丢弃**（关键 bug） |
| UI 质量 | 3/5 | 硬编码颜色，暗色模式失效 |
| 代码卫生 | 2/5 | ~80 行 OpenAI 死代码、大量注释代码 |
| 测试 | 1/5 | **测试文件中含硬编码凭证**，无真实测试 |
| 构建 | 3/5 | 缺少 lint/test target |

### 🔴 严重问题（必须修复）

#### 1. 测试文件泄露凭证
```
文件: test/provider/book_service_test.dart:141
代码: 硬编码 auth token '71eaeb4809c25803e66d5edf9a60060251b40740'
风险: 凭证泄露到版本控制
```

#### 2. 嵌套 MaterialApp
```
文件: lib/main.dart:73-85
问题: MaterialApp 嵌套 MaterialApp.router
后果: 重复导航栈、主题冲突、本地化问题
修复: 移除外层 MaterialApp
```

#### 3. API 拦截器被丢弃
```
文件: lib/providers/api.provider.dart:207-217
问题: 构建了 myInterceptors（含设备头信息、调试日志），但 Openapi() 传入的是原始 interceptors
后果: 设备头和调试日志拦截器完全不生效
```

#### 4. test 包在 dependencies 而非 dev_dependencies
```
文件: pubspec.yaml:29
问题: test 包被打包进生产 APK
```

#### 5. Access Token 写入日志
```
文件: lib/providers/auth.provider.dart:60
代码: debugPrint('set access token: ...')
风险: 敏感 token 出现在调试日志中
```

### 🟡 中等问题

| 文件 | 问题 |
|------|------|
| `main.dart:28` | `Platform.isAndroid` 在 Web 上会崩溃 |
| `router.dart:55,69` | `state.extra as BookEntity` — 不安全的类型转换 |
| `router.dart:157-179` | 认证重定向逻辑被完全注释掉 |
| `auth.provider.dart:40,116` | async 方法中使用 `ref.watch()` 应为 `ref.read()` |
| `select_book.dart:12-22` | 可变状态（late, non-final）违反 Riverpod 不可变模式 |
| `constants.dart` | ~80 行 OpenAI 模型常量完全未使用（死代码） |
| `root_layout.dart:50` | 硬编码粉色 `Color.fromARGB(255, 234, 158, 192)` |
| `home_small_screen.dart:111` | 硬编码 `Colors.white` 阴影，暗色模式失效 |
| `pubspec.yaml` | Isar ^4.0.0-dev.14（预发布）、flutter_html beta、hive_flutter 可能未使用 |
| `pubspec.yaml` | 3 个语法高亮包重叠（highlight + flutter_highlight + flutter_highlighter） |
| `api.provider.dart:182-200` | `getDeviceHeaders()` 异步回调返回同步 map —— 首次调用永远为空 |

---

## 三、综合优先级排序

### P0 — 安全 & 数据风险（立即修复）

| # | 问题 | 位置 |
|---|------|------|
| 1 | 明文密码写入日志 | `server/schema/init_data.go:57` |
| 2 | 测试文件泄露凭证 | `app/test/provider/book_service_test.dart:141` |
| 3 | Access Token 写入日志 | `app/lib/providers/auth.provider.dart:60` |
| 4 | math/rand 生成安全 token | `server/schema/session.go:117-123` |
| 5 | 密码重置无验证 | `server/service/user/handler.go:345-347` |

### P1 — 会导致崩溃或功能失效的 Bug

| # | 问题 | 位置 |
|---|------|------|
| 6 | 嵌套 MaterialApp | `app/lib/main.dart:73-85` |
| 7 | API 拦截器被丢弃 | `app/lib/providers/api.provider.dart:217` |
| 8 | 错误响应后 double write | `server/service/user/handler.go:60-64` |
| 9 | OpenDB 吞掉错误 | `server/store/orm.go:35` |
| 10 | Title 解析 panic | `server/schema/book.go:479-481` |
| 11 | API Key 认证失效 | `server/service/user/middleware.go:43-55` |
| 12 | 路由无认证守卫 | `app/lib/routes/router.dart:157-179` |

### P2 — 技术债务（重构前清理）

| # | 问题 | 位置 |
|---|------|------|
| 13 | test 包在 dependencies | `app/pubspec.yaml:29` |
| 14 | Isar 预发布依赖 | `app/pubspec.yaml` |
| 15 | 全局可变状态 | `server/store/`, `server/service/` 全局变量 |
| 16 | ~80 行 OpenAI 死代码 | `app/lib/utils/constants.dart`, `server/conf/models.go` |
| 17 | panic("implement me") | `server/service/user/helper.go:5-7` |
| 18 | Docker 以 root 运行 | `server/Dockerfile` |
| 19 | SQL 参数绑定错误 | `server/schema/favorite_book.go:34` |
| 20 | 生产代码残留 println | `server/store/localdir.go:98-99`, `server/upstream/proxy.go:60` |

---

## 四、测试现状

| 层级 | 后端 | 前端 |
|------|------|------|
| 单元测试 | 8 个文件，仅覆盖数据解析 | 5 个文件，基本为空或含硬编码路径 |
| API/Handler 测试 | ❌ 无 | — |
| Widget 测试 | — | ❌ 无（widget_test.dart 为空文件） |
| 集成测试 | ❌ 无 | ❌ 无 |
| CI 测试 | ❌ 无自动化测试 | ❌ 无自动化测试 |

---

## 五、结论与建议

### 代码现状定性

> **当前代码处于「能跑的原型」阶段，距离可发布的产品级代码有显著差距。**
> 
> 主要问题集中在三个方面：
> 1. **安全**：明文密码日志、可预测 token、无验证的密码重置
> 2. **健壮性**：错误处理不规范（吞掉错误、double write、panic）
> 3. **工程质量**：无测试、大量死代码、全局可变状态

### 建议修复路线

```
Week 1: 修 P0 安全问题（5 项）
Week 2: 修 P1 崩溃/功能 bug（7 项）
Week 3: 清理 P2 技术债务
Week 4: 补充核心路径测试（auth、book CRUD）
```

之后再开始新功能开发（AI 摘要、语义搜索等）。
