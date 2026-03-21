# 003 - 开源 NAS 生态调研：是否已有竞品覆盖

> 日期：2026-03-20
> 状态：✅ 已确认
> 结论：商用 NAS、开源 NAS 平台、平台上的可安装应用——三层都没人覆盖「AI + 电子书」

## 调研背景

在确定「AI-Native 自部署书库管理 + 阅读服务」方向后，需要确认：主流 NAS（商用 + 开源）是否已经具备这些能力？是否会被降维打击？

## 商用 NAS 厂商

| 能力 | Synology (群晖) | QNAP (威联通) | 绿联 / 极空间 | Omnigram |
|------|-----------------|---------------|-------------|----------|
| 文件存储 | ✅ 强 | ✅ 强 | ✅ 强 | ✅ |
| 文档预览 | ✅ Office 格式 | ✅ 类似 | ✅ 基础 | — |
| EPUB/PDF 阅读 | ❌ 无 | ❌ 无 | ❌ 无 | ✅ **核心** |
| 电子书库管理 | ❌ 需装 Docker | ❌ 需装 Docker | ❌ 无 | ✅ **核心** |
| OPDS 书源 | ❌ 无 | ❌ 无 | ❌ 无 | ✅ 已有 |
| TTS 听书 | ❌ 无 | ❌ 无 | ❌ 无 | ✅ **核心** |
| AI 能力 | ⚠️ 仅照片人脸/物体识别 | ⚠️ QuAI 仅图像视频 | ⚠️ 仅照片 | ✅ LLM 阅读助手 |
| 全文搜索 | ⚠️ 文件名+Office 内容 | ⚠️ Qsirch 类似 | ❌ 弱 | ✅ 语义搜索 |
| 多用户/权限 | ✅ 强 | ✅ 强 | ✅ 基础 | ✅ 已有 |
| Docker 支持 | ✅ Container Manager | ✅ Container Station | ⚠️ 部分 | ✅ Docker 部署 |

**结论：** 商用 NAS 厂商的 AI 仅在照片/视频领域，完全不碰电子书和文本 AI。原因：
1. 核心业务是卖硬件，软件只是配套
2. 电子书是小众垂直场景，不值得投入
3. LLM/TTS 对硬件要求高，低功耗 NAS CPU 跑不动
4. 阅读是深度交互场景，NAS 厂商 UI 能力有限

## 开源 NAS / Homeserver 平台

| 项目 | 定位 | 应用生态 | 电子书能力 | AI 能力 |
|------|------|---------|-----------|--------|
| **TrueNAS SCALE** | 企业级存储 + Docker/VM | ✅ 丰富应用市场 | ❌ 无内置 | ❌ 无 |
| **CasaOS** (ZimaBoard) | 轻量家庭 NAS，Docker 一键装 | ✅ 100,000+ Docker | ❌ 无内置 | ❌ 无 |
| **OpenMediaVault** | Debian NAS，插件扩展 | ✅ 插件 + Docker | ❌ 无内置 | ❌ 无 |
| **Runtipi** | Homeserver 编排器 | ✅ 应用商店 | ❌ 无内置 | ❌ 无 |
| **Umbrel** | 简约 Homeserver | ✅ 应用商店 | ❌ 无内置 | ❌ 无 |
| **YunoHost** | 自托管平台 | ✅ 应用目录 | ❌ 无内置 | ❌ 无 |
| **Unraid** | NAS + Docker + VM | ✅ 社区应用 | ❌ 无内置 | ❌ 无 |

**结论：** 所有开源 NAS/Homeserver 项目本质上都是「操作系统 / 容器编排平台」，它们不做任何垂直应用。电子书管理的解决方案统一是：用户自己去装第三方 Docker 容器。

## 平台上可安装的阅读相关应用

| 应用 | 能力 | AI | TTS | 问题 |
|------|------|----|----|------|
| **Calibre-Web** | 书库管理 + 基础 Web 阅读 | ❌ | ❌ | UI 老旧，无 AI，无 TTS |
| **Kavita** | 书库/漫画管理 + Web 阅读 | ❌ | ❌ | 偏漫画，无 AI |
| **Audiobookshelf** | 有声书/播客播放 | ❌ | ❌ | 仅播放已有音频，不做 TTS 生成 |
| **Komga** | 漫画管理 | ❌ | ❌ | 仅漫画 |

**没有一个带 AI，没有一个做 TTS 生成。**

## 核心结论

### 三层都没人覆盖

```
商用 NAS（群晖/威联通）    → ❌ 不做电子书，不做 AI 阅读
开源 NAS 平台              → ❌ 只做容器编排，不做垂直应用
现有可安装应用              → ❌ Calibre-Web 老旧无 AI，Audiobookshelf 不做 TTS
```

### Omnigram 的生态位类比

每个 NAS 用户都有三大类媒体需要管理：

```
影视 → Jellyfin / Plex / Emby        ✅ 成熟
照片 → Immich / PhotoPrism           ✅ 成熟
书籍 → Calibre-Web（老旧无 AI）       ❌ 空缺 ← Omnigram 的机会
```

> **Jellyfin 之于影视 = Immich 之于照片 = Omnigram 之于电子书**

### 推广路径（参考 Immich 成功经验）

Immich 的增长路径：
1. Docker 一键部署 → 自部署用户低门槛使用
2. 在 r/selfhosted 发帖爆火
3. 进入各平台应用商店（CasaOS、Runtipi、Umbrel）
4. 被 awesome-selfhosted 收录
5. GitHub 50k+ stars

Omnigram 可以复制这条路：
1. **Docker 一键部署**（`docker compose up`）
2. **提交到各平台应用商店**：CasaOS AppStore、Runtipi AppStore、Umbrel App Store
3. **提交到 awesome-selfhosted** 的 `Document Management - E-books` 分类
4. **r/selfhosted 发帖**：「I built an AI-powered, self-hosted ebook manager with TTS」
5. 社区口碑传播

### Omnigram 不会被 NAS 厂商降维打击

- NAS 厂商关注的是存储/照片/影视，电子书不在他们的路线图上
- Omnigram 是 NAS 生态的**补充**，不是竞争
- 群晖用户装 Omnigram Docker = 和他们装 Jellyfin、Immich 一样的逻辑
