# Omnigram 测试策略

> 更新日期：2026-03-23

## 背景与约束

- **所有代码由 AI 生成**，测试用例也由 AI 编写
- 核心考量：**token 消耗要值得，时间不能浪费**
- AI 写测试验证 AI 写的代码存在**同源偏差**风险 — 两边可能犯同样的错
- 因此优先选择**外部视角**的测试工具（爬虫、HTTP 请求、截图 diff），而非内部逻辑断言

---

## 测试金字塔

```
                    ┌─────────────────┐
                    │  Firebase Robo  │  ← 零 token，自动爬虫遍历 App
                    │   (App E2E)     │
                 ┌──┴─────────────────┴──┐
                 │    Schemathesis Fuzz   │  ← 零 token，自动 fuzz API
                 │    (API Auto Fuzz)     │
              ┌──┴───────────────────────┴──┐
              │     Hurl Smoke Test          │  ← 低 token，声明式 API 冒烟
              │     (API Smoke)              │
           ┌──┴────────────────────────────┴──┐
           │     Golden Test (Flutter)         │  ← 一次性 token，UI 截图 diff
           │     (Visual Regression)           │
        ┌──┴──────────────────────────────────┴──┐
        │   flutter analyze / go vet / staticcheck │  ← 零 token，静态分析
        └─────────────────────────────────────────┘
```

---

## 选型详情

### 一、App 端测试

| 层级 | 工具 | Token 成本 | 发现什么 | 优先级 |
|------|------|-----------|---------|--------|
| L1 静态分析 | `flutter analyze` | 零 | 类型错误、dead code、lint | P0 |
| L2 自动爬虫 | Firebase Robo Test | 零 | crash、ANR、导航死路、布局溢出 | P0 |
| L3 视觉回归 | Golden Test | 一次性低 | UI 意外改变、布局错位 | P1 |
| L4 E2E 流程 | Maestro (备选) | 低 | 用户路径断裂、交互逻辑错误 | P2 |

**不采用的方案：**

| 方案 | 不采用原因 |
|------|-----------|
| Widget Test 逐按钮 | AI 写 mock 验证 AI 代码，同源偏差；provider 频繁变动导致测试过时快 |
| 高覆盖率 Integration Test | Robo Test 随机点 1000 次 > 人写 20 条固定路径 |
| Unit Test 覆盖 UI 逻辑 | Flutter UI 逻辑薄，投入产出不成比例 |

**工具说明：**

- **Firebase Robo Test:** Google 提供的自动化爬虫，上传 APK 后自动点击遍历所有可见界面，报告 crash 和 ANR。免费额度每天 5 台物理机 / 15 台虚拟机。
- **Golden Test:** Flutter 内置能力，生成每个页面的"黄金截图"，后续改动自动 diff 检测视觉回归。
- **Maestro:** YAML 声明式 E2E 测试框架，零代码编写用户流程，备选方案。

### 二、Server 端测试

| 层级 | 工具 | Token 成本 | 发现什么 | 优先级 |
|------|------|-----------|---------|--------|
| L1 静态分析 | `go vet` + `staticcheck` | 零 | 编译错误、常见 bug 模式 | P0 |
| L2 数据层测试 | `go test ./schema/...` | 零（已有） | ORM 映射错误、迁移问题 | P0 |
| L3 Swagger Fuzz | Schemathesis | 零 | 500 错误、响应与文档不匹配、边界情况 | P0 |
| L4 API 冒烟 | Hurl | 一次性低 | 端点不可达、认证链断裂、核心路径异常 | P0 |

**不采用的方案：**

| 方案 | 不采用原因 |
|------|-----------|
| Handler 单元测试 + Mock DB | AI 写 mock 验证 AI 的 handler，同源偏差 |
| httptest 逐端点测试 | 和 Hurl 功能重叠，但需大量 Go 代码 |
| 高覆盖率 unit test | 业务逻辑以 CRUD 为主，投入产出不成比例 |

**工具说明：**

- **Hurl:** Orange（法国电信）开源的 HTTP 测试工具，纯文本声明式，类似 curl 但支持断言和变量捕获。一个 `.hurl` 文件走完完整用户路径。
- **Schemathesis:** 基于 Swagger/OpenAPI 规范自动生成请求的 fuzz 测试工具，无需编写任何测试代码，自动发现 500 错误和文档偏差。

---

## CI 流程

### App 测试 Pipeline

```yaml
触发条件: push to main (app/lib/** 变更) / tag push / 手动
流程:
  1. flutter analyze          # 静态分析
  2. flutter build apk        # 构建 debug APK
  3. Firebase Robo Test       # 上传 APK，自动遍历
文件: .github/workflows/test-robo.yaml
```

### Server 测试 Pipeline

```yaml
触发条件: push to main (server/** 变更) / 手动
流程:
  1. docker compose up        # 启动 server + postgres
  2. hurl --test smoke.hurl   # API 冒烟测试
  3. schemathesis fuzz        # Swagger 自动 fuzz
文件: .github/workflows/test-api.yaml
```

---

## GitHub Secrets 需求

| 名称 | 类型 | 用途 | 必需 |
|------|------|------|------|
| `GCP_SA_KEY` | Secret | Firebase Test Lab 服务账号 | App 测试 |
| `GCP_PROJECT_ID` | Variable | GCP 项目 ID | App 测试 |

Server API 测试不需要额外 secrets — 在 CI 中自建临时环境。

---

## 核心原则

1. **外部视角优先** — 用爬虫和 HTTP 请求验证，而非 AI 写逻辑断言验证 AI 写的逻辑
2. **零 token 工具优先** — 静态分析、自动爬虫、fuzz 不消耗 AI token
3. **声明式 > 编程式** — Hurl / Maestro 的 YAML/文本比 Go/Dart 测试代码维护成本低
4. **冒烟 > 全覆盖** — 一条完整路径 > 100 个孤立断言
5. **自动发现 > 人工编写** — Schemathesis 和 Robo Test 自动探索，比人写用例覆盖面更广
