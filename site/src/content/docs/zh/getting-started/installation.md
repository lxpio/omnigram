---
title: 安装指南
description: Omnigram 详细安装与配置说明
---

## Docker Compose（推荐）

Docker Compose 是部署 Omnigram 的推荐方式。服务器镜像同时支持 `amd64` 和 `arm64` 架构，可运行在标准服务器、树莓派、NAS 和 Apple Silicon Mac 上。

### 完整配置

完整配置包含 PostgreSQL（带 pgvector 支持 AI 功能）和 Kokoro TTS：

```yaml
services:
  omnigram-server:
    image: lxpio/omnigram-server:latest
    ports:
      - "8080:80"
    volumes:
      - /path/to/your/books:/docs
      - omnigram_data:/metadata
    environment:
      # 数据库
      DB_DRIVER: postgres
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: omnigram
      DB_PASSWORD: omnigram
      DB_NAME: omnigram
      # 管理员账户（仅首次运行生效）
      OMNI_USER: admin
      OMNI_PASSWORD: changeme
      # TTS（可选）
      TTS_PROVIDER: kokoro
      TTS_SIDECAR_URL: http://tts:8880
      TTS_TIMEOUT: 120s
      # AI（可选）
      # AI_ENABLED: "true"
      # AI_PROVIDER: openai
      # AI_BASE_URL: https://api.openai.com/v1
      # AI_API_KEY: sk-xxx
      # AI_MODEL: gpt-4o
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

  # Kokoro TTS（可选 — 不需要语音朗读可删除）
  tts:
    image: ghcr.io/remsky/kokoro-fastapi:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8880/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    restart: unless-stopped

volumes:
  pgdata:
  omnigram_data:
```

:::tip[不需要 TTS？]
删除 `tts` 服务和 `TTS_*` 环境变量即可。服务器不依赖 TTS 也能正常运行。
:::

### 卷挂载

| 宿主机路径 | 容器路径 | 用途 |
|-----------|---------|------|
| `/path/to/your/books` | `/docs` | 电子书库（EPUB、PDF 等） |
| `omnigram_data`（命名卷） | `/metadata` | 数据库、封面、搜索索引、服务器状态 |
| `pgdata`（命名卷） | `/var/lib/postgresql/data` | PostgreSQL 数据 |

`/docs` 卷用于服务器索引你的书籍。将电子书放入此目录，支持任意文件夹结构 — 会递归扫描所有子目录。

:::caution[备份数据]
`/metadata` 和 `pgdata` 卷包含你所有的书库数据，请定期备份。
:::

### 环境变量

#### 服务器

| 变量 | 默认值 | 说明 |
|------|-------|------|
| `OMNI_USER` | `admin` | 管理员用户名（首次启动时设置） |
| `OMNI_PASSWORD` | *(随机生成)* | 管理员密码（未设置则自动生成，显示在日志中） |

#### 数据库

| 变量 | 默认值 | 说明 |
|------|-------|------|
| `DB_DRIVER` | `sqlite` | 数据库驱动：`sqlite` 或 `postgres` |
| `DB_HOST` | — | PostgreSQL 主机 |
| `DB_PORT` | `5432` | PostgreSQL 端口 |
| `DB_USER` | — | PostgreSQL 用户名 |
| `DB_PASSWORD` | — | PostgreSQL 密码 |
| `DB_NAME` | — | PostgreSQL 数据库名 |
| `DB_SSLMODE` | `disable` | PostgreSQL SSL 模式 |

#### TTS（语音朗读）

| 变量 | 默认值 | 说明 |
|------|-------|------|
| `TTS_PROVIDER` | — | TTS 引擎：`kokoro`、`edge` 或 `openai` |
| `TTS_SIDECAR_URL` | — | TTS sidecar 容器地址 |
| `TTS_TIMEOUT` | `120s` | TTS 合成超时时间 |
| `TTS_OPENAI_API_KEY` | — | OpenAI TTS API 密钥（使用 `openai` 时） |

#### AI

| 变量 | 默认值 | 说明 |
|------|-------|------|
| `AI_ENABLED` | `false` | 启用 AI 功能 |
| `AI_PROVIDER` | — | AI 提供商：`openai`、`anthropic`、`ollama` 等 |
| `AI_BASE_URL` | — | AI API 地址 |
| `AI_API_KEY` | — | AI API 密钥 |
| `AI_MODEL` | — | AI 模型名称 |

## 数据库选项

### SQLite（默认）

SQLite 是默认选项，无需额外配置。数据库文件存储在 `/metadata` 卷中，适合个人使用和小型书库。

```yaml
services:
  omnigram-server:
    image: lxpio/omnigram-server:latest
    ports:
      - "8080:80"
    volumes:
      - ./books:/docs
      - omnigram_data:/metadata
    environment:
      OMNI_USER: admin
      OMNI_PASSWORD: changeme
    restart: unless-stopped

volumes:
  omnigram_data:
```

:::note
SQLite 模式不支持 pgvector，因此 AI 语义搜索功能不可用。如需完整 AI 功能，请使用 PostgreSQL。
:::

### PostgreSQL + pgvector（推荐）

PostgreSQL 配合 pgvector 支持向量相似搜索和完整 AI 功能。请使用 `pgvector/pgvector:pg17` 镜像（不是普通的 `postgres`）：

```yaml
services:
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
```

## TTS 引擎

Omnigram 支持多种 TTS 引擎作为 Docker sidecar：

| 引擎 | 镜像 | 显存 | 语言 | 备注 |
|------|------|-----|------|------|
| **Kokoro**（默认） | `ghcr.io/remsky/kokoro-fastapi:latest` | CPU 或 GPU | 多语言 | 质量和速度的良好平衡 |
| **Qwen3-TTS** | `groxaxo/qwen3-tts-openai:latest` | 6GB+ GPU | 10 种 | 中文质量最佳 |
| **Chatterbox** | `resemble-ai/chatterbox:latest` | 4GB GPU | 23 种 | 轻量级，MIT 许可 |
| **Edge TTS** | *(内置)* | 无需 | 多语言 | 免费，无需额外容器 |

使用 Edge TTS（无需额外容器）：

```yaml
environment:
  TTS_PROVIDER: edge
```

## 多架构支持

官方 Docker 镜像支持以下架构：

- `linux/amd64` — 标准 x86 服务器、Intel/AMD 桌面、大多数 NAS
- `linux/arm64` — 树莓派 4/5、Apple Silicon、ARM NAS

Docker 会自动拉取适合你平台的镜像。

## 反向代理

如果在反向代理后运行 Omnigram，将其指向 `http://localhost:8080`（或你映射的端口）。

### Caddy

```
books.example.com {
    reverse_proxy localhost:8080
}
```

### Nginx

```nginx
server {
    listen 80;
    server_name books.example.com;

    client_max_body_size 500M;   # 支持大文件上传

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Traefik（Docker labels）

```yaml
services:
  omnigram-server:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.omnigram.rule=Host(`books.example.com`)"
      - "traefik.http.services.omnigram.loadbalancer.server.port=80"
```

## 常见问题

### `/metadata` 权限被拒绝

服务器在容器内以 `omnigram` 用户（uid 1000）运行。如果看到 `Permission denied` 错误，修复卷权限：

```bash
# 命名卷
docker run --rm -v omnigram_data:/metadata alpine chown -R 1000:1000 /metadata

# 绑定挂载
sudo chown -R 1000:1000 /path/to/data
```

### 无法拉取 Docker 镜像（国内网络）

如果 Docker Hub 不可访问，在 `/etc/docker/daemon.json` 中添加镜像加速器：

```json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me"
  ]
}
```

然后重启 Docker：

```bash
sudo systemctl restart docker
```

### 扫描报错："value too long for type character varying"

部分电子书的元数据字段过长。升级到最新版服务器（已支持更长字段），升级后重新扫描即可。

## 连接客户端

服务器启动后：

1. **Omnigram App** — 从 [GitHub Releases](https://github.com/lxpio/omnigram/releases) 下载，输入服务器地址（如 `http://192.168.1.100:8080`）
2. **OPDS 客户端** — 使用任何兼容 OPDS 的阅读器（Moon+ Reader、KOReader、Librera），OPDS 端点为 `http://你的服务器:8080/opds`
3. **WebDAV** — 通过 WebDAV 挂载书库，地址为 `http://你的服务器:8080/webdav`
