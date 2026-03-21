---
title: 安装指南
description: Omnigram 详细安装与配置说明
---

## Docker Compose（推荐）

Docker Compose 是部署 Omnigram 的推荐方式。服务器镜像同时支持 `amd64` 和 `arm64` 架构，可运行在标准服务器、树莓派和 Apple Silicon Mac 上。

### 基本配置

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
    restart: unless-stopped
```

启动服务：

```bash
docker compose up -d
```

### 卷挂载

| 宿主机路径 | 容器路径 | 用途 |
|-----------|---------|------|
| `./books` | `/docs` | 电子书库（EPUB、PDF 等） |
| `./data` | `/metadata` | 数据库、封面和服务器元数据 |

`/docs` 卷用于服务器索引您的书籍。将电子书放入此目录，可以使用任意文件夹结构。

`/metadata` 卷存储 SQLite 数据库、提取的封面图片和其他服务器状态。**请定期备份此目录。**

### 环境变量

| 变量 | 默认值 | 说明 |
|------|-------|------|
| `OMNI_USER` | — | 管理员用户名（首次运行时必填） |
| `OMNI_PASSWORD` | — | 管理员密码（首次运行时必填） |
| `OMNI_DB_TYPE` | `sqlite` | 数据库类型：`sqlite` 或 `postgres` |
| `OMNI_DB_DSN` | — | PostgreSQL 连接字符串（使用 `postgres` 时） |
| `OMNI_PORT` | `80` | 容器内监听端口 |

## 数据库选项

### SQLite（默认）

SQLite 是默认选项，无需额外配置。数据库文件存储在 `/metadata` 卷中。适合个人使用和小型团队。

### PostgreSQL

对于大型部署或需要使用现有 PostgreSQL 实例的情况：

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
      OMNI_DB_TYPE: postgres
      OMNI_DB_DSN: "host=db user=omnigram password=secret dbname=omnigram sslmode=disable"
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: omnigram
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: omnigram
    restart: unless-stopped

volumes:
  pgdata:
```

## 多架构支持

官方 Docker 镜像支持以下架构：

- `linux/amd64` — 标准 x86 服务器、Intel/AMD 桌面
- `linux/arm64` — 树莓派 4/5、Apple Silicon（通过 Rosetta）、ARM 服务器

Docker 会自动拉取适合您平台的镜像。

## 反向代理

如果在反向代理（Nginx、Caddy、Traefik）后运行 Omnigram，将代理指向 `http://localhost:8080`（或您映射的宿主机端口）。

Caddy 配置示例：

```
books.example.com {
    reverse_proxy localhost:8080
}
```

## 连接客户端

服务器启动后：

1. **Omnigram App** — 从 [GitHub Releases](https://github.com/lxpio/omnigram/releases) 下载，输入您的服务器地址
2. **OPDS 客户端** — 使用任何兼容 OPDS 的阅读器（Moon+ Reader、KOReader、Librera），连接服务器的 OPDS 端点
