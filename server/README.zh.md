# omnigram-server

<div style="font-size: 1.5rem;">
  <a href="./README.zh.md">中文</a> | <a href="./README.md">English</a>
</div>
</br>

omnigram-server 是使用 Golang 编写的个人内容管理后端服务，提供类似 jellyfin 和 navidrome 文档搜刮与管理功能。
客户端支持请前往 [Omnigram](github.com/lxpio/omnigram).

> 提醒：中国境内网站，个人是不允许进行在线出版的，维护公开的书籍网站是违法违规的行为！仅作为个人学习使用！

### 文档

您可以在 https://omnigram.lxpio.com/zh 找到官方文档（包含安装手册）。

### 目标与功能介绍

1. 提供 NAS 私有化电子书库搜刮服务（当前仅支持 Epub 格式）；
2. 使用 TTS 模型实现，提供电子书阅读服务（需要额外动模型服务参考 [m4t_server](docs/zh/m4t-server.zh.md)）；
3. 提供 Chat 模型支持对电子书进行理解分析，支持对自己简单日记进行扩展书写和润色；

## 部署方式

### 快速启动

### docker

```bash
# 这里需要替换${MY_DIR}自己实际包含epub文件目录
docker run --rm -v ${MY_DIR}:/docs -p 8080:80 lxpio/omnigram-server:latest
```

TODO

### linux server

使用 Mysql 或者 Postgresql 数据库

1. 修改配置文件 conf.yaml

### 开发计划

- [x] 支持多用户管理与用户分级
- [x] 支持 TTS 阅读；
- [] 支持浏览管理

## 常见问题

常见问题请参阅使用指南

手动安装请参考[开发指南](docs/dev.md)

## 项目依赖以及三分框架使用说明

TODO

## 鸣谢

TODO

### 支持本项目

我已经致力于本项目并且将我会持续更新文档、新增功能和修复问题。但是独木不成林，我需要您一起完善改项目。

