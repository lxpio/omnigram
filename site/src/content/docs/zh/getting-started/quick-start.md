---
title: 快速开始
description: 使用 Docker 在 30 秒内部署 Omnigram
---

## 前提条件

- 已安装 Docker 和 Docker Compose
- 准备好电子书目录

## 部署

创建 `docker-compose.yml` 文件：

```yaml
version: '3'
services:
  omnigram:
    image: lxpio/omnigram-server:latest
    ports:
      - "8080:80"
    volumes:
      - ./books:/docs
      - ./data:/metadata
    environment:
      OMNI_USER: admin
      OMNI_PASSWORD: changeme
```

启动服务：

```bash
docker compose up -d
```

在浏览器中打开 `http://localhost:8080`。

## 下一步

- 查看[安装指南](/zh/docs/getting-started/installation)了解高级配置
- 将 [Omnigram App](https://github.com/lxpio/omnigram) 连接到您的服务器
- 尝试使用 [OPDS 客户端](https://zh.wikipedia.org/wiki/OPDS)，如 Moon+ Reader 或 KOReader
