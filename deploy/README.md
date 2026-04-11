# VPS 部署指南 — Omnigram 宣传站 + Demo

## 架构概览

```
客户端 --TLS 443--> CF CDN (SaaS) --TLS 9443--> Nginx
                                                   ├── omnigram.lxpio.com → 静态文件 (/var/www/omnigram-site/)
                                                   └── demo.omnigram.lxpio.com → omnigram-server:8080
                                                                                    └── PostgreSQL (pgvector)
```

| 域名 | 用途 | 部署方式 |
|------|------|---------|
| `omnigram.lxpio.com` | 产品宣传站 (Astro 静态站) | Nginx 直接托管静态文件 |
| `demo.omnigram.lxpio.com` | 在线 Demo | Docker (omnigram-server + PostgreSQL) |

## CI/CD 流程

### 宣传站

触发条件：push 到 `main` 分支且 `site/**` 有变更

```
site/** 变更 → GitHub Actions → astro build
                                  ├── 部署到 GitHub Pages（omnigram.nexptr.com）
                                  └── rsync 到 VPS /var/www/omnigram-site/
```

Workflow: `.github/workflows/site.yaml`

**GitHub Secrets 需求：**

| Secret | 值 | 说明 |
|--------|-----|------|
| `VPS_HOST` | VPS IP | 部署目标 |
| `VPS_PORT` | SSH 端口 | 如 3322 |
| `VPS_SSH_KEY` | SSH 私钥 | 用于 rsync 部署 |

### Demo 服务器

使用已有的 `lxpio/omnigram-server:latest` 镜像（由 `docker.yaml` 在 tag 发布时构建推送到 DockerHub）。

## VPS 首次部署

### 1. 前提条件

- Docker & Docker Compose v2 已安装
- Nginx 已配置反代（由 VPS 统一管理）
- CF for SaaS 已配置域名验证和 Origin Rule

### 2. 部署步骤

```bash
# 1. 复制 deploy 目录到 VPS
scp -P 3322 -r deploy/ root@vps2:/opt/omnigram/

# 2. 配置环境变量
ssh -p 3322 root@vps2
cd /opt/omnigram
cp .env.example .env
vim .env  # 设置 demo 账号密码和数据库密码

# 3. 启动服务
docker compose -f docker-compose.vps.yml pull
docker compose -f docker-compose.vps.yml up -d

# 4. 首次部署宣传站静态文件（后续由 CI/CD 自动更新）
# 本地构建:
cd site && npm ci && npx astro build
# 上传到 VPS:
rsync -avz dist/ root@vps2:/var/www/omnigram-site/ -e 'ssh -p 3322'

# 5. 验证
curl -H "Host: demo.omnigram.lxpio.com" http://localhost:8080/healthz
```

## 更新部署

### 宣传站更新

push 到 main 分支后 GitHub Actions 自动 rsync 到 VPS，无需手动操作。

### Demo 服务器更新

```bash
cd /opt/omnigram
docker compose -f docker-compose.vps.yml pull omnigram-server
docker compose -f docker-compose.vps.yml up -d omnigram-server
```

## Nginx 配置

宣传站和 Demo 共享 VPS 上的 Nginx 9443 端口（SSL），由 CF CDN 通过 Origin Rule 回源：

```nginx
# /etc/nginx/sites-available/omnigram
server {
    listen 9443 ssl;
    server_name omnigram.lxpio.com;
    ssl_certificate /etc/nginx/ssl/self.crt;
    ssl_certificate_key /etc/nginx/ssl/self.key;

    root /var/www/omnigram-site;
    index index.html;

    location / {
        try_files $uri $uri/ $uri.html /index.html;
    }

    location /_astro/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;
}

server {
    listen 9443 ssl;
    server_name demo.omnigram.lxpio.com;
    ssl_certificate /etc/nginx/ssl/self.crt;
    ssl_certificate_key /etc/nginx/ssl/self.key;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

## Cloudflare 配置

通过 CF for SaaS (Custom Hostnames) 接入，nexptr.com 作为回退源：

- **Fallback Origin**: `fallback.nexptr.com` → VPS2 IP (Proxied)
- **Custom Hostnames**: `omnigram.lxpio.com`, `demo.omnigram.lxpio.com`
- **Configuration Rule**: Full SSL 模式
- **Origin Rule**: 回源端口 9443

lxpio.com DNS 记录：
- `omnigram` CNAME → `fallback.nexptr.com`
- `demo.omnigram` CNAME → `fallback.nexptr.com`

## 文件清单

```
deploy/
├── docker-compose.vps.yml     # Docker Compose (demo server + PostgreSQL)
├── .env.example               # 环境变量模板
└── README.md                  # 本文件

site/
├── Dockerfile                 # 宣传站镜像构建（仅 GitHub Pages 备用）
└── nginx.conf                 # 容器内 Nginx 配置（仅容器部署时使用）

.github/workflows/
├── site.yaml                  # 宣传站 CI: build → GitHub Pages + rsync VPS
└── docker.yaml                # Demo 服务器镜像构建（tag 触发）
```

## 自动更新（可选）

Demo 服务器可用 Watchtower 自动拉取更新：

```bash
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --interval 300 \
  --cleanup
```

## 故障排查

```bash
# 查看容器状态
docker compose -f docker-compose.vps.yml ps

# 查看 Demo 服务器日志
docker compose -f docker-compose.vps.yml logs omnigram-server

# 重启服务
docker compose -f docker-compose.vps.yml restart omnigram-server

# 完全重建
docker compose -f docker-compose.vps.yml down
docker compose -f docker-compose.vps.yml up -d
```
