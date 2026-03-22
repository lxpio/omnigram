# 016 - App 品牌替换计划（Anx Reader → Omnigram）

> 创建日期：2026-03-22
> 状态：📋 待执行
> 范围：将 Fork 自 Anx Reader 的 App 中所有品牌元素替换为 Omnigram
> 前置：009-fork-anx-reader-plan.md（Fork 决策），assets/img/（Omnigram 品牌资产）

---

## 一、替换原则

1. **用户可见的品牌全部替换**——App 名称、图标、水印、分享卡片、关于页
2. **保留 Anx Reader 致谢**——关于页保留 "Based on Anx Reader" + MIT 许可声明（009 文档要求）
3. **内部类名不改**——`AnxToast`、`AnxLog` 等纯内部类名保留，避免全代码库重构
4. **外部链接暂保留**——`anx.anxcye.com` 文档链接待 Omnigram 文档站上线后替换
5. **字体服务保留**——`fonts.anxcye.com` 继续使用 Anx Reader 字体服务

---

## 二、品牌资产来源

Omnigram 品牌资产位于项目根目录 `assets/img/`：

| 文件 | 用途 |
|------|------|
| `logo_white.svg` | Logo 图标（SVG，可生成各尺寸 PNG） |
| `logo_with_letter_dark.svg` | Logo + 文字（暗色背景） |
| `logo_with_letter_white.svg` | Logo + 文字（亮色背景） |
| `icon-192x192.png` | 192px 图标 |
| `icon-256x256.png` | 256px 图标 |
| `icon-384x384.png` | 384px 图标 |
| `icon-512x512.png` | 512px 图标 |
| `apple-touch-icon.png` | iOS 触摸图标 |
| `favicon-16x16.png` | 16px favicon |
| `favicon-32x32.png` | 32px favicon |
| `favicon.ico` | ICO 格式 favicon |
| `android-chrome-128x128.png` | Android Chrome 128px |
| `android-chrome-192x192.png` | Android Chrome 192px |
| `android-chrome-512x512.png` | Android Chrome 512px |

---

## 三、第一优先级：用户可见品牌（必须改）

### 3.1 App 图标（各平台）

**Android 启动图标：**

| 文件路径 | 需要尺寸 | 来源 |
|---------|---------|------|
| `app/android/app/src/main/res/mipmap-mdpi/ic_launcher_background.png` | 48x48 | 从 logo_white.svg 生成 |
| `app/android/app/src/main/res/mipmap-mdpi/ic_launcher_monochrome.png` | 48x48 | 同上 |
| `app/android/app/src/main/res/mipmap-hdpi/ic_launcher_background.png` | 72x72 | 同上 |
| `app/android/app/src/main/res/mipmap-hdpi/ic_launcher_monochrome.png` | 72x72 | 同上 |
| `app/android/app/src/main/res/mipmap-xhdpi/ic_launcher_background.png` | 96x96 | 同上 |
| `app/android/app/src/main/res/mipmap-xhdpi/ic_launcher_monochrome.png` | 96x96 | 同上 |
| `app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher_background.png` | 144x144 | 同上 |
| `app/android/app/src/main/res/mipmap-xxhdpi/ic_launcher_monochrome.png` | 144x144 | 同上 |
| `app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_background.png` | 192x192 | 可直接用 icon-192x192.png |
| `app/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_monochrome.png` | 192x192 | 同上 |
| `app/android/app/src/main/ic_launcher-playstore.png` | 512x512 | 可直接用 icon-512x512.png |

**iOS 图标：**

| 文件路径 | 改动 |
|---------|------|
| `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Anx-logo.png` | 替换为 Omnigram logo，重命名为 `omnigram-logo.png` |
| `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Anx-logo-dark.png` | 替换，重命名为 `omnigram-logo-dark.png` |
| `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Anx-logo-tined.png` | 替换，重命名为 `omnigram-logo-tinted.png` |
| `app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json` | 更新文件名引用 |

**macOS 图标：**

| 文件路径 | 改动 |
|---------|------|
| `app/macos/Runner/Assets.xcassets/AppIcon.appiconset/*` | 替换所有尺寸图标（16/32/64/128/256/512/1024px） |

**Web 图标：**

| 文件路径 | 改动 |
|---------|------|
| `app/web/favicon.png` | 替换为 favicon-32x32.png |
| `app/web/icons/Icon-192.png` | 替换为 icon-192x192.png |
| `app/web/icons/Icon-512.png` | 替换为 icon-512x512.png |
| `app/web/icons/Icon-maskable-192.png` | 替换为 icon-192x192.png |
| `app/web/icons/Icon-maskable-512.png` | 替换为 icon-512x512.png |

**文档图片：**

| 文件路径 | 改动 |
|---------|------|
| `app/docs/images/Anx-logo.jpg` | 替换为 Omnigram logo |

### 3.2 App 名称（16 种语言本地化）

所有 `app/lib/l10n/app_*.arb` 文件中的 `"Anx Reader"` 替换为 `"Omnigram"`。

**涉及文件（16 个）：**
- `app_en.arb`、`app_zh-CN.arb`、`app_zh-TW.arb`、`app_zh.arb`、`app_zh-LZH.arb`
- `app_ru.arb`、`app_ar.arb`、`app_de.arb`、`app_es.arb`、`app_fr.arb`
- `app_it.arb`、`app_ja.arb`、`app_ko.arb`、`app_pt.arb`、`app_tr.arb`、`app_ro.arb`

**关键字段替换：**
```json
"appName": "Anx Reader"          → "Omnigram"
"appAbout": "About Anx Reader"   → "About Omnigram"
// 其他包含 "Anx Reader" 的字段逐一替换
```

> **注意：** 捐赠相关文案（如 "Support Anx Reader development"）改为 "Support Omnigram development" 或移除。

### 3.3 窗口标题

| 文件 | 行号 | 原始 | 替换为 |
|------|------|------|--------|
| `app/lib/main.dart` | 199 | `title: 'Anx Reader'` | `title: 'Omnigram'` |
| `app/lib/utils/window_position_validator.dart` | 128 | `setTitle('Anx Reader')` | `setTitle('Omnigram')` |

### 3.4 关于页面

**文件：** `app/lib/widgets/settings/about.dart`

| 行号 | 原始 | 替换为 |
|------|------|--------|
| 169 | `title: const Text('Based on Anx Reader')` | 保留（致谢声明） |
| 170 | `subtitle: const Text('MIT Licensed · github.com/Anxcye/anx-reader')` | 保留 |
| 182 | `https://anx.anxcye.com/privacy` | 替换为 Omnigram 隐私政策 URL 或暂时移除 |
| 191 | `https://anx.anxcye.com/terms` | 替换为 Omnigram 服务条款 URL 或暂时移除 |
| 200 | `https://anx.anxcye.com/docs` | 替换为 `https://omnigram.lxpio.com/docs` |
| 226 | `https://anx.anxcye.com` | 替换为 `https://omnigram.lxpio.com` |
| 241 | `https://t.me/AnxReader` | 替换为 Omnigram 社区链接或移除 |

### 3.5 分享/导出品牌

| 文件 | 改动 |
|------|------|
| `app/lib/widgets/book_share/excerpt_share_card.dart:89-92` | `_getAnxReaderLogo()` → 使用 Omnigram logo，水印文字改为 "Omnigram" |
| `app/lib/widgets/book_share/excerpt_share_bottom_sheet.dart:140` | 文件名 `'AnxReader_${...}'` → `'Omnigram_${...}'` |
| `app/lib/page/book_player/image_viewer.dart:118` | 文件名 `"AnxReader_${...}"` → `"Omnigram_${...}"` |
| `app/lib/utils/save_img.dart:86` | 路径 `"Pictures/AnxReader"` → `"Pictures/Omnigram"` |
| `app/lib/utils/save_img.dart:162` | 文件名 `"AnxReader_${...}"` → `"Omnigram_${...}"` |
| `app/lib/page/settings_page/sync.dart:187` | 备份文件名 `'AnxReader-Backup-...'` → `'Omnigram-Backup-...'` |
| `app/lib/page/settings_page/sync.dart:291` | 日志文件名 `'AnxReader-Log-...'` → `'Omnigram-Log-...'` |

### 3.6 AI 助手身份

| 文件 | 改动 |
|------|------|
| `app/lib/service/ai/langchain_registry.dart:174` | `'You are "Anx Reader AI"...'` → `'You are "Omnigram AI"...'` |

### 3.7 应用商店描述

| 文件 | 改动 |
|------|------|
| `app/fastlane/metadata/android/en-US/full_description.txt` | "Anx Reader" → "Omnigram" |
| `app/fastlane/metadata/android/zh-CN/full_description.txt` | "Anx Reader" → "Omnigram" |
| `app/fastlane/metadata/android/ru-RU/full_description.txt` | "Anx Reader" → "Omnigram" |

---

## 四、第二优先级：文档和配置

### 4.1 文档文件

| 文件 | 改动 |
|------|------|
| `app/README.md` | 品牌替换 + logo 替换 + 下载链接更新 |
| `app/README_zh.md` | 同上 |
| `app/README_tr.md` | 同上 |
| `app/README_RU.md` | 同上 |
| `app/CONTRIBUTING.md` | "Anx Reader" → "Omnigram"（保留 Anx Reader 致谢段落） |

### 4.2 构建配置

| 文件 | 改动 |
|------|------|
| `app/android/fastlane/Appfile:1` | 确认包名已为 `com.lxpio.omnigram`（Phase 1 已改） |
| `app/ios/fastlane/Matchfile:1` | Git repo URL 和 bundle ID 更新 |
| `app/scripts/compile_windows_setup-inno.iss` | Windows 安装程序品牌名替换 |

### 4.3 服务标识

| 文件 | 改动 |
|------|------|
| `app/lib/service/tts/azure_tts_backend.dart:91` | `'User-Agent': 'AnxReader'` → `'Omnigram'` |
| `app/lib/service/sync/webdav_client.dart:75` | `'Anx Reader WebDAV Test\n'` → `'Omnigram WebDAV Test\n'` |

---

## 五、第三优先级：外部链接（待文档站上线后替换）

| 文件 | 链接 | 处理 |
|------|------|------|
| `app/lib/page/settings_page/sync.dart:68` | `https://anx.anxcye.com/docs/sync/webdav` | 待替换为 `https://omnigram.lxpio.com/docs/...` |
| `app/lib/page/settings_page/subpage/fonts.dart:40` | `https://fonts.anxcye.com/${font.preview}` | **保留**（仍使用 Anx Reader 字体服务） |
| `app/lib/service/translate/deepl.dart:122` | `https://anx.anxcye.com/docs/translate/deepl` | 待替换 |
| `app/lib/service/translate/microsoft_api.dart:97` | `https://anx.anxcye.com/docs/translate/azure` | 待替换 |
| `app/lib/service/translate/google_api.dart:94` | `https://anx.anxcye.com/docs/translate/google` | 待替换 |
| `app/lib/service/tts/aliyun/aliyun_tts_backend.dart:51` | `https://anx.anxcye.com/docs/tts/aliyun` | 待替换 |
| `app/lib/service/tts/azure_tts_backend.dart:36` | `https://anx.anxcye.com/docs/tts/azure` | 待替换 |
| `app/lib/service/tts/openai_tts_backend.dart:40` | `https://anx.anxcye.com/docs/tts/openai` | 待替换 |

---

## 六、不改的项目

| 项目 | 理由 |
|------|------|
| `AnxToast` / `AnxLog` / `AnxError` / `AnxPlatform` 等内部类名 | 纯内部使用，改名需全代码库重构，收益低风险高 |
| `anx_headless_webview.dart` / `anx_button.dart` 等内部 widget | 同上 |
| `fonts.anxcye.com` 字体服务 | 继续使用 Anx Reader 字体 CDN |

---

## 七、执行步骤

```
Step 1: 生成图标（使用 logo_white.svg 或现有 PNG 生成各平台所需尺寸）
        └── 工具：flutter_launcher_icons 或手动 ImageMagick
            flutter_launcher_icons.yaml:
              android: true
              ios: true
              macos: true
              web: true
              image_path: "assets/img/icon-512x512.png"

Step 2: 批量文本替换
        └── 所有 .arb 文件中 "Anx Reader" → "Omnigram"
        └── 所有 .dart 文件中用户可见的 "Anx Reader" → "Omnigram"
        └── 文件名前缀 "AnxReader_" → "Omnigram_"
        └── 保存路径 "AnxReader" → "Omnigram"

Step 3: 更新关于页面
        └── 主品牌改为 Omnigram
        └── 保留 "Based on Anx Reader" 致谢
        └── 外链暂时指向 omnigram.lxpio.com 或移除

Step 4: 更新文档
        └── README 品牌替换
        └── CONTRIBUTING 品牌替换
        └── Fastlane 商店描述替换

Step 5: 构建验证
        └── flutter analyze lib/
        └── flutter build apk --debug
        └── 确认 App 名称、图标、关于页面正确

Step 6: 提交
        └── git commit -m "feat(app): replace Anx Reader branding with Omnigram"
```

---

## 八、预估工作量

AI 辅助下约 **1-2 小时**：
- 图标生成：10 分钟（flutter_launcher_icons 自动生成）
- 文本替换：30 分钟（大部分可批量替换）
- 关于页面调整：10 分钟
- 文档更新：15 分钟
- 构建验证：15 分钟
