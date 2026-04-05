# Onboarding 流程设计

> **日期：** 2026-04-05
> **状态：** Approved
> **关联：** PROGRESS.md 跨层级功能 — Onboarding 流程 §10.8

---

## 1. 概述

渐进式 onboarding：首次启动仅做语言选择 + 导入第一本书（或连接服务端），最小化用户门槛。AI、同步等高级功能通过现有空状态系统和设置页自然发现，不做额外渐进提示。

## 2. 设计决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 首次步骤数 | **2 步**（语言 + 导入） | 降低流失，确保用户有书可读 |
| 渐进提示 | **不做** | 现有空状态已适配伴侣性格三档文案，YAGNI |
| 旧 onboarding | **保留不触发** | 设置页手动查看仍可用 |
| 触发位置 | **OmnigramHome** | 新 UI 架构，替代旧 HomePage |

## 3. 首次启动流程

### Step 1: 语言选择

- 全屏页面，居中布局
- Omnigram logo + 欢迎文案
- 语言下拉菜单（复用现有 onboarding_screen 的语言列表）
- "下一步"按钮

### Step 2: 导入书籍 / 连接服务端

- 标题："开始你的阅读之旅"
- 两个主要行动按钮：
  - **"导入本地书籍"** — 调用现有 `FilePicker` + `importBookList()` 流程
  - **"连接 Omnigram 服务端"** — 跳转到 `ServerConnectionPage`
- "跳过，稍后再说" 文字链接 — 直接进入主界面
- 导入成功或服务端连接成功后自动进入主界面

### 完成后

- 设置 `Prefs().lastAppVersion = currentVersion`
- 导航到 `OmnigramHome`（replace，不可返回）

## 4. ���术改动

### 4.1 新建 OnboardingFlow widget

- 路径：`app/lib/page/onboarding_flow.dart`
- 2 页 `PageView`，共用一个 `PageController`
- 无需 `introduction_screen` 包依赖
- 轻量实现：StatefulWidget + PageView

### 4.2 修改 OmnigramHome 启动检测

- 路径：`app/lib/page/omnigram_home.dart`
- 在 `initState` 中检查 `Prefs().lastAppVersion == null`
- 如果是首次启动：`Navigator.pushReplacement` 到 `OnboardingFlow`
- `OnboardingFlow` 完成后 `Navigator.pushReplacement` 回 `OmnigramHome`

### 4.3 保留旧 onboarding

- `onboarding_screen.dart` 不删除
- `InitializationCheck` 中移除自动触发逻辑（或仅在旧 HomePage 中保留）
- 设置页"查看引导"入口仍指向旧 onboarding

## 5. L10n

新增 ARB key：
- `onboardingWelcome` — "Welcome to Omnigram"
- `onboardingChooseLanguage` — "Choose your language"
- `onboardingNext` — "Next"
- `onboardingStartJourney` — "Start your reading journey"
- `onboardingImportBooks` — "Import local books"
- `onboardingConnectServer` — "Connect to Omnigram Server"
- `onboardingSkip` — "Skip for now"

中英文各 7 个 key。

## 6. 不改的部分

- 旧 `onboarding_screen.dart` 保留
- `InitializationCheck` 逻辑不大改（只确保不在新 UI 重复触发）
- AI 配置、同步配置、伴侣人格 — 全部留在设置页
- 空状态系统不修改

## 7. 测试要点

- 首次启动（`lastAppVersion == null`）→ 显示 OnboardingFlow
- 选择语言后 app locale 生效
- 导入书籍 → 自动完成 onboarding → 进入主界面，书架有书
- 连接服务端 → 自动完成 → 进入主界面，触发同步
- 跳过 → 进入空书架主界面
- 非首次启动 → 直接进入 OmnigramHome
- `lastAppVersion` 正确设置后不再触发
