# Omnigram

<div style="font-size: 1.5rem;">
  <a href="./README.md">English</a> | <a href="./README.zh.md">中文</a>
</div>
</br>

A  project.
Omnigram is an open source app based on ChatGPT-Compatible API.


### Screen 

TODO

## Roadmap

- [x] ChatGPT Service
- [x] ChatGPT API Key & API URL setting
- [x] Conversations local storage
- [x] Add or delete conversations
- [x] Messages local storage
- [x] Support markdown
- [x] Support code block highlight
- [x] Support conversation settings
- [x] Support quote message
- [x] Support add prompts
- [x] Support system message
- [ ] Support delete message
- [ ] Add App level settings
- [ ] Support for code replication
- [ ] Support more chat scenarios
- [ ] Support chat stream output
- [ ] Add App level prompts manager
- [ ] Add prompts quick send button on chat page

## License

[GNU General Public License v3.0](./LICENSE)

## For dev



本项目创建过程使用了 [getx](https://github.com/jonataslaw/get_cli/blob/master/README-zh_CN.md),命令参考如下

```
flutter pub global activate get_cli

get create project



// 生成国际化文件:
// 注: 你在 'assets/locales' 目录下的翻译文件应该是json格式的
get generate locales assets/locales


// 在现有项目中生成所选结构:
get init

// 创建页面:
// (页面包括 controller, view, 和 binding)
// 注: 你可以随便命名, 例如: `get create page:login`
get create page:home
```


项目中使用了 objectbox 需要运行如下命令，

```bash
dart run build_runner build
```

同时需要如果要使用单测，需要运行脚步 参考 https://docs.objectbox.io/getting-started

```bash
# 这里如果是国内可能需要科学上网
bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)
```