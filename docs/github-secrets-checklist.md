# GitHub Secrets & Variables 配置清单

> 更新日期：2026-03-23
> 配置位置：GitHub → Settings → Secrets and variables → Actions

---

## 一、必须配置（当前使用中）

### Server Docker 构建

| Secret 名称 | 用途 | 来源 | 使用文件 |
|-------------|------|------|---------|
| `DOCKERHUB_USERNAME` | Docker Hub 用户名 | [hub.docker.com](https://hub.docker.com) 注册 | `docker.yaml` |
| `DOCKERHUB_TOKEN` | Docker Hub Access Token | Docker Hub → Account Settings → Security → Access Tokens | `docker.yaml` |

### App Android 构建

| Secret 名称 | 用途 | 格式 | 使用文件 |
|-------------|------|------|---------|
| `KEYSTORE_BASE64` | Android 签名密钥库 | `base64 -w 0 keystore.jks` 的输出 | `build-android.yaml` |
| `KEYSTORE_PASSWORD` | 密钥库密码 | 明文 | `build-android.yaml` |
| `KEY_PASSWORD` | 密钥密码 | 明文 | `build-android.yaml` |
| `KEY_ALIAS` | 密钥别名 | 明文（如 `omnigram`） | `build-android.yaml` |

### 通知

| Secret 名称 | 用途 | 格式 | 使用文件 |
|-------------|------|------|---------|
| `NOTIFICATION_URL` | Webhook 通知 Base URL | URL（如 `https://hooks.example.com`） | `setup-app.yaml`, `build-windows.yaml`, `release-app.yaml` |
| `TELEGRAM_TO` | Telegram 接收者 ID | 数字 ID（如 `123456789`） | `release-app.yaml` |
| `TELEGRAM_TOKEN` | Telegram Bot Token | `bot123456:ABC-DEF...` 格式 | `release-app.yaml` |

---

## 二、按需配置（特定平台启用时）

### Firebase Robo Test（自动化 UI 测试）

| Secret 名称 | 用途 | 获取方式 | 使用文件 |
|-------------|------|---------|---------|
| `GCP_SA_KEY` | GCP Service Account JSON 密钥 | GCP Console → IAM → Service Accounts → Keys → JSON | `test-robo.yaml` |

| Variable 名称 | 用途 | 格式 | 使用文件 |
|---------------|------|------|---------|
| `GCP_PROJECT_ID` | GCP 项目 ID | 明文（如 `omnigram-ci`） | `test-robo.yaml` |

> **注意：** `GCP_PROJECT_ID` 是 **Variable**（非 Secret），在 Settings → Secrets and variables → Actions → Variables tab 下添加。
>
> Service Account 需要两个角色：`Firebase Test Lab Admin` + `Storage Object Admin`。
>
> 需提前创建 GCS 存储桶：`{GCP_PROJECT_ID}-robo-results`。

### Windows 代码签名（SignPath）

| Secret 名称 | 用途 | 获取方式 | 使用文件 |
|-------------|------|---------|---------|
| `SIGNPATH_API_TOKEN` | SignPath API Token | [signpath.io](https://signpath.io) → Organization → API Tokens | `build-windows.yaml` |

> **注意：** `build-windows.yaml` 中还硬编码了 SignPath Organization ID（`254a26d6-...`）和 project-slug（`omnigram`）。如果使用自己的 SignPath 账号，需要修改这两个值。Alpha 版本会跳过签名。

### Apple App Store（归档中，需要时解除注释）

| Secret 名称 | 用途 | 获取方式 | 使用文件 |
|-------------|------|---------|---------|
| `ASC_KEY_ID` | App Store Connect API Key ID | App Store Connect → Users and Access → Keys | `_archived/build-appstore.yaml` |
| `ASC_ISSUER_ID` | App Store Connect Issuer ID | 同上页面顶部 | `_archived/build-appstore.yaml` |
| `ASC_KEY_P8_BASE64` | App Store Connect 私钥 | 下载的 `.p8` 文件 → `base64 -w 0 AuthKey_XXXX.p8` | `_archived/build-appstore.yaml` |
| `MATCH_PASSWORD` | Fastlane Match 密钥链密码 | 自定义密码，用于加密证书存储 | `_archived/build-appstore.yaml` |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Fastlane Match Git 认证 | `echo -n "user:token" \| base64` | `_archived/build-appstore.yaml` |
| `APP_BUNDLE_ID` | App Bundle ID | 如 `com.lxpio.omnigram` | `_archived/build-appstore.yaml` |

### Google Play Store（归档中，需要时解除注释）

| Secret 名称 | 用途 | 获取方式 | 使用文件 |
|-------------|------|---------|---------|
| `PLAY_STORE_JSON_KEY` | Google Play 服务账号密钥 | Google Cloud Console → IAM → Service Accounts → Keys → JSON → `base64 -w 0` | `_archived/build-playstore.yaml` |

---

## 三、自动提供（无需配置）

| Secret 名称 | 说明 |
|-------------|------|
| `GITHUB_TOKEN` | GitHub Actions 自动注入，用于 Issue 管理、Release 创建等 |

---

## 四、最小启动配置

如果只需要**最基本的功能**（Server Docker + Android APK），只需配置 **6 个 secrets**：

```
必须：
├── DOCKERHUB_USERNAME     ← Server Docker 推送
├── DOCKERHUB_TOKEN        ← Server Docker 推送
├── KEYSTORE_BASE64        ← Android 签名
├── KEYSTORE_PASSWORD      ← Android 签名
├── KEY_PASSWORD           ← Android 签名
└── KEY_ALIAS              ← Android 签名

推荐（通知）：
├── NOTIFICATION_URL       ← 构建通知 webhook
├── TELEGRAM_TO            ← Telegram 通知
└── TELEGRAM_TOKEN         ← Telegram 通知

按需（Robo Test）：
├── GCP_SA_KEY             ← GCP 服务账号密钥（Secret）
└── GCP_PROJECT_ID         ← GCP 项目 ID（Variable）

按需（Windows 签名）：
└── SIGNPATH_API_TOKEN     ← Windows 代码签名

按需（App Store 发布）：
├── ASC_KEY_ID
├── ASC_ISSUER_ID
├── ASC_KEY_P8_BASE64
├── MATCH_PASSWORD
├── MATCH_GIT_BASIC_AUTHORIZATION
└── APP_BUNDLE_ID

按需（Play Store 发布）：
└── PLAY_STORE_JSON_KEY
```

---

## 五、从旧 Secrets 迁移

原 `build_app.yaml` 使用的 secrets 需要重命名：

| 旧名称 | 新名称 | 说明 |
|--------|--------|------|
| `KEY_JKS` | `KEYSTORE_BASE64` | 内容相同（base64 编码的 keystore） |
| `ALIAS` | `KEY_ALIAS` | 内容相同 |
| `ANDROID_KEY_PASSWORD` | `KEY_PASSWORD` | 内容相同 |
| `ANDROID_STORE_PASSWORD` | `KEYSTORE_PASSWORD` | 内容相同 |

> **建议：** 在 GitHub Settings 中保留旧 secrets 一段时间，同时添加新名称的 secrets。确认新流水线正常后再删除旧的。

---

## 六、配置步骤

1. 打开 GitHub 仓库 → Settings → Secrets and variables → Actions
2. 点击 "New repository secret"
3. 按上表逐个添加
4. 对于 `KEYSTORE_BASE64` 等文件类 secret，先在本地执行 `base64 -w 0 <file>` 得到编码字符串

### 生成 Android Keystore（如果没有）

```bash
keytool -genkey -v -keystore omnigram.jks -keyalg RSA -keysize 2048 -validity 10000 -alias omnigram
# 记住设置的密码（对应 KEYSTORE_PASSWORD 和 KEY_PASSWORD）
# 别名为 omnigram（对应 KEY_ALIAS）

# 编码为 base64
base64 -w 0 omnigram.jks
# 输出即为 KEYSTORE_BASE64 的值
```
