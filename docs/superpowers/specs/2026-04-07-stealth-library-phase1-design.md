# 隐身书房 Phase 1：核心加密空间

> **日期：** 2026-04-07
> **状态：** Approved
> **关联：** PROGRESS.md Layer 5 — 隐身书房, 设计文档 §8, §10.4

---

## 1. 概述

独立加密数据库 + 生物识别入口 + 隐身书架基本 UI。Phase 2（AI 隔离、快速锁定、卸载策略）后续再做。

## 2. 生物识别服务

### 2.1 依赖

添加 `local_auth` 到 `pubspec.yaml`。

### 2.2 BiometricAuthService

新建 `app/lib/service/stealth/biometric_auth_service.dart`：

- `isAvailable()` → bool — 设备是否支持生物识别
- `authenticate()` → bool — 触发生物识别验证（指纹/面容）
- `getOrCreateKey()` → String — 验证成功后，从 `flutter_secure_storage` 读取 AES key；首次使用时生成随机 256-bit key 并存入

### 2.3 密钥管理

- 使用 `flutter_secure_storage`（已有依赖）存储 AES-256 key
- key name: `stealth_db_encryption_key`
- 首次调用 `getOrCreateKey()` 时，用 `crypto` 包生成 32 字节随机 key
- key 存在 platform keystore（Android Keystore / iOS Keychain），应用层无法直接读取明文

### 2.4 失败处理

- 生物识别失败 → 提示"验证失败"，不进入
- 设备不支持生物识别 → 入口不显示（降级为无隐身功能）

## 3. 隐身数据库

### 3.1 独立数据库

- 文件名：`stealth_database.db`（与 `app_database.db` 并行）
- 表结构：复用主库的表名和 schema（tb_books, tb_notes 等）
- `StealthDBHelper` 类，与 `DBHelper` 相同接口

### 3.2 应用层加密

- 使用 `crypto` 包（已有依赖）AES-256 加密
- **加密字段：** 书名 title、作者 author、描述 description、笔记内容 content/readerNote
- **不加密字段：** id、进度、时间戳、颜色等数值/结构字段
- 新建 `app/lib/service/stealth/encryption_service.dart`：
  - `encrypt(String plaintext, String key)` → String (base64 密文)
  - `decrypt(String ciphertext, String key)` → String

### 3.3 隐身 DAO

- 新建 `app/lib/dao/stealth/stealth_book_dao.dart` — 复用 BookDao 接口，读写 stealth DB，自动加解密
- 新建 `app/lib/dao/stealth/stealth_note_dao.dart` — 复用 BookNoteDao 接口

最小化 DAO：只做书籍 CRUD + 笔记 CRUD，不做同步、AI 缓存等（Phase 2）。

## 4. 隐身书架 UI

### 4.1 入口

- 设置页"关于 Omnigram" `_SettingsSection` 的 `onTap` 改为 short tap
- 新增 `onLongPress`：长按 → 触发 `BiometricAuthService.authenticate()` → 成功则导航到 `StealthHome`
- 设备不支持生物识别 → 不注册 `onLongPress`（入口完全隐藏）

### 4.2 StealthHome

新建 `app/lib/page/stealth/stealth_home.dart`：

- 简化版 OmnigramHome，只有两个 tab：书架 + 设置
- 顶部 AppBar 显示锁图标 + "Private Library" 文字
- 退出按钮 → `Navigator.pop()` 回到正常设置页
- 书架复用 `LibraryPage` 的布局，但数据源改为 `StealthBookDao`

### 4.3 隐身导入

- 隐身书架的导入 FAB 使用相同的 `FilePicker` 流程
- 导入的书文件复制到隐身专用目录（`stealth_books/`）
- 书文件本身不加密（太大），只加密元数据

### 4.4 隐身阅读

- 点击隐身书架中的书 → 正常打开阅读器
- 笔记/高亮写入 stealth DB（通过 StealthNoteDao）
- 阅读进度存入 stealth DB

## 5. 文件改动

| 文件 | 改动 |
|------|------|
| 修改 `pubspec.yaml` | 添加 `local_auth` |
| 新建 `service/stealth/biometric_auth_service.dart` | 生物识别 + 密钥管理 |
| 新建 `service/stealth/encryption_service.dart` | AES-256 加解密 |
| 新建 `dao/stealth/stealth_db_helper.dart` | 独立隐身数据库 |
| 新建 `dao/stealth/stealth_book_dao.dart` | 隐身书籍 DAO |
| 新建 `dao/stealth/stealth_note_dao.dart` | 隐身笔记 DAO |
| 新建 `page/stealth/stealth_home.dart` | 隐身空间主页 |
| 新建 `page/stealth/stealth_library_page.dart` | 隐身书架页 |
| 修改 `page/home/settings_page.dart` | "关于"长按入口 |
| 修改 `widgets/common/omnigram_card.dart` | 支持 onLongPress（如果还没有） |
| 修改 L10n ARB | 新增隐身相关 key |

## 6. L10n Keys

- `stealthPrivateLibrary` — "Private Library"
- `stealthExit` — "Exit private mode"
- `stealthAuthFailed` — "Authentication failed"
- `stealthAuthRequired` — "Authenticate to access private library"
- `stealthImportBooks` — "Import to private library"

## 7. 不做（留 Phase 2）

- AI 伴侣隔离（隐身空间暂无 AI 功能）
- 快速锁定（app 切后台自动锁定）
- 卸载策略（自动清除 keystore key）
- 隐身洞察页
- 隐身数据同步
- 失败次数限制（5次锁定30分钟）

## 8. 测试要点

- 设备支持生物识别 → 长按"关于"弹出验证 → 成功进入隐身空间
- 设备不支持 → 长按无反应
- 隐身书架导入书籍 → 主书架看不到
- 隐身笔记 → 主空间笔记/洞察不包含
- 退出隐身 → 回到设置页，无痕迹
- 加密验证：直接读 stealth_database.db 中的 title 字段是密文
