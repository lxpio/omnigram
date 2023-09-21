# Omnigram

<div style="font-size: 1.5rem;">
  <a href="./README.md">English</a> | <a href="./README.zh.md">中文</a>
</div>
</br>

## 关于

Omnigram 是一个支持NAS内容服务终端，支持多平台（iOS、Android、Web、Windows、Linux、Mac）的聊天机器人。其后端服务部署参阅 [omnigam-server](https://github.com/nexptr/omnigam-server).

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
