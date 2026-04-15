---
title: 快速开始
description: 使用 Docker 一分钟内部署 Omnigram
---

## 前提条件

- 已安装 [Docker](https://docs.docker.com/get-docker/) 和 Docker Compose (v2+)
- 准备好电子书目录（EPUB、PDF 等格式）

## 1. 创建 Compose 文件

创建一个目录和 `docker-compose.yml` 文件：

```bash
mkdir -p omnigram && cd omnigram
```

```yaml
# docker-compose.yml
services:
  omnigram-server:
    image: lxpio/omnigram-server:latest
    ports:
      - "8080:80"
    volumes:
      - /path/to/your/books:/docs        # 你的电子书目录
      - omnigram_data:/metadata           # 服务器数据（持久化）
    environment:
      DB_DRIVER: postgres
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: omnigram
      DB_PASSWORD: omnigram
      DB_NAME: omnigram
      OMNI_USER: admin                    # 管理员用户名
      OMNI_PASSWORD: changeme            # 请修改！
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  db:
    image: pgvector/pgvector:pg17
    environment:
      POSTGRES_USER: omnigram
      POSTGRES_PASSWORD: omnigram
      POSTGRES_DB: omnigram
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U omnigram"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  pgdata:
  omnigram_data:
```

:::caution[修改书籍路径]
将 `/path/to/your/books` 替换为你实际的电子书目录，例如群晖上的 `/volume1/ebooks` 或 Linux 服务器上的 `/disk1/books`。
:::

## 2. 启动服务

```bash
docker compose up -d
```

等待数据库就绪和服务器启动（约 10 秒）：

```bash
docker compose logs -f omnigram-server
```

看到以下输出表示启动成功：

```
omnigram-server  | HTTP server address: 0.0.0.0:80
```

## 3. 登录并扫描书籍

1. 浏览器打开 **http://你的服务器IP:8080**
2. 使用上面设置的用户名和密码登录
3. 进入 **设置 > 书库 > 扫描** 导入书籍
4. 扫描会索引书籍目录中所有的 EPUB/PDF 文件

## 下一步

- 查看[安装指南](/zh/docs/getting-started/installation)了解 TTS、AI、反向代理等高级配置
- 下载 [Omnigram App](https://github.com/lxpio/omnigram/releases) 连接到你的服务器
- 尝试使用 [OPDS 客户端](https://zh.wikipedia.org/wiki/OPDS)，如 Moon+ Reader 或 KOReader
