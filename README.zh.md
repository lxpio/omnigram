#

<picture>
  <source
    srcset="./assets/img/logo_with_letter_dark.svg"
    media="(prefers-color-scheme: dark)"
  />
  <source
    srcset="./assets/img/logo_with_letter_white.svg"
    media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)"
  />
  <img src="./assets/img/logo_with_letter_white.svg" />
</picture>

<div style="font-size: 1.5rem;">
  <a href="./README.md">English</a> | <a href="./README.zh.md">中文</a>
</div>
</br>

![docs action](https://github.com/lxpio/omnigram/actions/workflows/docs.yaml/badge.svg) 
![docs action](https://github.com/lxpio/omnigram/actions/workflows/docker.yaml/badge.svg) 
![docs action](https://github.com/lxpio/omnigram/actions/workflows/build_app.yaml/badge.svg)

## 关于

> **Jellyfin 管视频，Immich 管照片，Omnigram 管书籍。**

Omnigram 是一个 **AI 原生的自托管书库管理与阅读服务**。通过 Docker 一键部署到你的 NAS 或家庭服务器，将电子书收藏变成一个智能的、可搜索的、可收听的个人图书馆。

基于 Go 后端 + Flutter 多平台客户端构建，Omnigram 将书库管理、AI 辅助阅读、TTS 有声书生成融为一体 —— 这是目前市面上没有任何工具能提供的。

### 为什么选 Omnigram？

- 📚 **Calibre-Web** 能管书，但没有 AI、没有 TTS、界面老旧
- 🎧 **Audiobookshelf** 能播有声书，但不能从电子书生成有声书
- 📖 **Anx Reader** 阅读体验好，但没有服务端 —— 只能单设备使用
- 💸 **Readwise Reader** 功能强大，但月费 $8.99 且不支持自托管

**Omnigram 填补了这个空白：自托管 + AI + 阅读 —— 一站式解决。**

## 特性

### 已实现
- [x] 多格式电子书阅读（EPUB、PDF）
- [x] iOS & Android 原生客户端
- [x] TTS 语音朗读，支持自定义引擎（Fish Audio）
- [x] AI 对话助手辅助阅读
- [x] 自托管书库，支持 NAS 存储
- [x] 书籍搜索、笔记、书签、收藏、下载
- [x] 多用户管理，OPDS 协议支持
- [x] Docker 一键部署

### 规划中
- [ ] AI 书籍摘要与章节洞察
- [ ] 全书库语义搜索
- [ ] AI 跨书知识关联
- [ ] 高质量多角色 TTS 有声书生成
- [ ] AI 翻译增强 + 双语对照阅读
- [ ] WebDAV 协议支持
- [ ] Web 阅读器
- [ ] Windows、Linux、Mac 桌面客户端

## 基本构架

![base_struct](assets/img/struct.svg)

## 官方文档

您可以在 <https://omnigram.lxpio.com/zh> 找到官方文档（包含安装手册）。

## 示例

对于APP 后端，你可以使用实例地址： https://omnigram-demo.lxpio.com:9443 。由于

```
凭证信息：
用户名：admin
密码： 123456
```

## 二次开发



### 编译

#### App 编译

```bash

git clone github.com/lxpio/omnigram.git
cd omnigram/app
make
```

#### Omnigram Server 编译

```bash

git clone github.com/lxpio/omnigram.git
cd omnigram/server
make 

# make docker 
```

#### 语音服务

当当前App支持FishTTS API Server，参考 [FishTTS](https://github.com/fishaudio/fish-speech)。

```bash

git clone https://github.com/fishaudio/fish-speech.git
cd fish-speech

pip install -e .
python -m tools.api_server --listen 0.0.0.0:8999 --llama-checkpoint-path "checkpoints/fish-speech-1.5"     --decoder-checkpoint-path "checkpoints/fish-speech-1.5/firefly-gan-vq-fsq-8x1024-21hz-generator.pth"

```


## 技术栈

| 组件 | 技术 |
|------|------|
| **服务端** | Go 1.23 + Gin + GORM |
| **客户端** | Flutter 3.24 + Riverpod |
| **语音合成** | Fish Audio (gRPC) |
| **数据库** | SQLite/PostgreSQL + BadgerDB |
| **部署** | Docker / Docker Compose |

## 感谢

本项目使用了大量 [Immich](https://github.com/immich-app/immich) 的代码，感谢其开源精神。

核心依赖库：

- [riverpod](https://docs-v2.riverpod.dev/docs) — 状态管理
- [isar](https://isar.dev) — 本地数据库
- [fish-speech](https://github.com/fishaudio/fish-speech) — TTS 引擎


