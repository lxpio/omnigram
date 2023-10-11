# Omnigram

<div style="font-size: 1.5rem;">
  <a href="./README.md">English</a> | <a href="./README.zh.md">中文</a>
</div>
</br>

## 关于

Omnigram 是Flutter编写的支持多平台（iOS、Android、Web、Windows、Linux、Mac）文件阅读和听书客户端，它支持多种格式，包括 EPUB 和 PDF。它还提供听书功能，支持使用 Bark TTS 模型以及其他 AI 聊天技术进行辅助阅读。此外，它还具备本地书籍管理功能，允许用户轻松管理书籍在 NAS 上的存储。其后端服务部署参阅 [omnigam-server](https://github.com/nexptr/omnigram-server).

## 特性

- 支持电子书、PDF、文档等NAS内容服务管理。
- 支持对话助手，支持 Markdown 语法，支持代码块高亮，支持对话设置。
- 电子书支持使用模型进行TTS阅读
-

## Roadmap

TODO

## License

[GNU General Public License v3.0](./LICENSE)

## For dev

本项目创建过程使用了 [riverpod](https://docs-v2.riverpod.dev/docs)

项目中使用了 objectbox 需要运行如下命令，

```bash
dart run build_runner build
```

同时需要如果要使用单测，需要运行脚步 参考 <https://docs.objectbox.io/getting-started>

```bash
# 这里如果是国内可能需要科学上网
bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)
```
