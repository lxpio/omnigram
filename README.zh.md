#
<picture>
  <source
    srcset="https://omnigram.nexptr.com/images/logo_with_letter_dark.svg"
    media="(prefers-color-scheme: dark)"
  />
  <source
    srcset="https://omnigram.nexptr.com/images/logo_with_letter_white.svg"
    media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)"
  />
  <img src="https://omnigram.nexptr.com/images/logo_with_letter_white.svg" />
</picture>

<div style="font-size: 1.5rem;">
  <a href="./README.md">English</a> | <a href="./README.zh.md">中文</a>
</div>
</br>

## 关于

Omnigram 是Flutter编写的支持多平台（iOS、Android、Web、Windows、Linux、Mac）文件阅读和听书客户端，它支持多种格式，包括 EPUB 和 PDF。它通过TTS模型提供听书功能，支持其他 AI 模型进行辅助阅读。此外，它还具备本地书籍管理功能，允许用户轻松管理书籍在 NAS 上的存储。其后端服务部署参阅 [omnigam-server](https://github.com/lxpio/omnigram-server)。或者参考[项目官方文档](https://omnigram.lxpio.com)

## 特性

- [x] 支持iOS、Android 端 EPUB 电子书阅读
- [x] 支持TTS语音朗读，支持自定义TTS引擎。
- [x] 支持本地书籍管理(NAS)，支持书籍搜索、阅读、听书、笔记、收藏、下载、删除、设置等
- [x] 支持对话助手，支持 Markdown 语法，支持代码块高亮，支持对话设置。
- [x] 电子书支持使用模型进行TTS阅读
- [ ] 支持PDF、文档等NAS内容服务管理。
- [ ] 支持Web、Windows、Linux、Mac。

## 官方文档

您可以在 <https://omnigram.lxpio.com/> 找到官方文档（包含安装手册）。

## 示例

![](/docs/images/login_page.png) ![](/docs/images/discover_screen.png)

## 二次开发

本项目创建过程使用三分库包括：

- [riverpod](https://docs-v2.riverpod.dev/docs)
- [objectbox](https://docs.objectbox.io/getting-started)

### 编译

```bash

git clone github.com/nexptr/omnigram.git
cd omnigram
flutter clean && dart run build_runner build

make
```
