---
title: "快速入门"
sidebar_position: 10
---

本文旨在快速完成后端部署和使用，如果需要自定义的一些配置请参阅部署文档

## 环境依赖

请查阅[环境要求](../install/requirements)

## Docker 启动

默认情况下 docker 启动以后将创建默认管理员账号`admin`，密码默认为`123456`。

- 默认密码为`123456`，可以后续登录后更改，或者通过设置`OMNI_PASSWORD`变量进行更改。
- `my_local_docs_path`应该修改未自己实际存有 Epub，PDF 目录，登陆后可以设置扫描策略从而建立文件索引；
- 如果需要持久运行请参阅[最佳部署实践](../install/best_practice)

```bash
# 替换如下名字中 my_local_docs_path 未自己实际的文档目录
docker run -v <my_local_docs_path>:/docs -p 8080:80 lxpio/omnigram-server:v0.1.2-alpine
```

## 尝试手机端访问

### 下载 App

手机端应用可以从如下地址下载：

- [ ] 谷歌商城
- [ ] 苹果商城
- [x] [Github(apk)](https://github.com/nexptr/omnigram)

### 登陆 App

//TODO add login page

<!-- [] -->

### 扫描本地文件目录

//TODO add scan page

### 开始阅读

//TODO add reading page

## 接下来可以做什么

上述文档只是为了快速入门级的部署和体验，如果期待「读享」的完整的服务功能和体验。请前往 [最佳部署实践](../install/best_practice)
