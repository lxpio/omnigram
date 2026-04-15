---
title: Installation Guide
description: Detailed installation and configuration for Omnigram
---

## Docker Compose (Recommended)

Docker Compose is the recommended way to deploy Omnigram. The server image supports both `amd64` and `arm64` architectures, so it runs on standard servers, Raspberry Pi, NAS devices, and Apple Silicon Macs.

### Full Setup

The full setup includes PostgreSQL (with pgvector for AI features) and Kokoro TTS:

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
      # Database
      DB_DRIVER: postgres
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: omnigram
      DB_PASSWORD: omnigram
      DB_NAME: omnigram
      # Admin account (first run only)
      OMNI_USER: admin
      OMNI_PASSWORD: changeme
      # TTS (optional)
      TTS_PROVIDER: kokoro
      TTS_SIDECAR_URL: http://tts:8880
      TTS_TIMEOUT: 120s
      # AI (optional)
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

  # Kokoro TTS (optional — remove if you don't need text-to-speech)
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

:::tip[Don't need TTS?]
Remove the `tts` service and the `TTS_*` environment variables. The server works fine without it.
:::

### Volume Mounts

| Host Path | Container Path | Purpose |
|-----------|---------------|---------|
| `/path/to/your/books` | `/docs` | Your ebook library (EPUB, PDF, etc.) |
| `omnigram_data` (named volume) | `/metadata` | Database, covers, search index, server state |
| `pgdata` (named volume) | `/var/lib/postgresql/data` | PostgreSQL data |

The `/docs` volume is read by the server to index your book collection. Place your ebooks here, organized in any folder structure you prefer — subdirectories are scanned recursively.

:::caution[Back up your data]
The `/metadata` and `pgdata` volumes contain all your library data. Back them up regularly.
:::

### Environment Variables

#### Server

| Variable | Default | Description |
|----------|---------|-------------|
| `OMNI_USER` | `admin` | Admin username (set on first run) |
| `OMNI_PASSWORD` | *(random)* | Admin password (auto-generated if not set, shown in logs) |

#### Database

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_DRIVER` | `sqlite` | Database driver: `sqlite` or `postgres` |
| `DB_HOST` | — | PostgreSQL host |
| `DB_PORT` | `5432` | PostgreSQL port |
| `DB_USER` | — | PostgreSQL username |
| `DB_PASSWORD` | — | PostgreSQL password |
| `DB_NAME` | — | PostgreSQL database name |
| `DB_SSLMODE` | `disable` | PostgreSQL SSL mode |

#### TTS (Text-to-Speech)

| Variable | Default | Description |
|----------|---------|-------------|
| `TTS_PROVIDER` | — | TTS engine: `kokoro`, `edge`, or `openai` |
| `TTS_SIDECAR_URL` | — | TTS sidecar container URL |
| `TTS_TIMEOUT` | `120s` | TTS synthesis timeout |
| `TTS_OPENAI_API_KEY` | — | OpenAI TTS API key (when using `openai` provider) |

#### AI

| Variable | Default | Description |
|----------|---------|-------------|
| `AI_ENABLED` | `false` | Enable AI features |
| `AI_PROVIDER` | — | AI provider: `openai`, `anthropic`, `ollama`, etc. |
| `AI_BASE_URL` | — | AI API base URL |
| `AI_API_KEY` | — | AI API key |
| `AI_MODEL` | — | AI model name |

## Database Options

### SQLite (Default)

SQLite is the default and requires no extra configuration. The database file is stored in the `/metadata` volume. Ideal for personal use and small libraries.

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
SQLite mode does not support pgvector, so AI-powered semantic search features will not be available. Use PostgreSQL for full AI capabilities.
:::

### PostgreSQL + pgvector (Recommended)

PostgreSQL with pgvector enables vector similarity search and full AI features. Use the `pgvector/pgvector:pg17` image (not plain `postgres`):

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

## TTS Engines

Omnigram supports multiple TTS engines as Docker sidecars:

| Engine | Image | VRAM | Languages | Notes |
|--------|-------|------|-----------|-------|
| **Kokoro** (default) | `ghcr.io/remsky/kokoro-fastapi:latest` | CPU or GPU | Multi | Good balance of quality and speed |
| **Qwen3-TTS** | `groxaxo/qwen3-tts-openai:latest` | 6GB+ GPU | 10 | Best Chinese quality |
| **Chatterbox** | `resemble-ai/chatterbox:latest` | 4GB GPU | 23 | Lightweight, MIT license |
| **Edge TTS** | *(built-in)* | None | Many | Free, no sidecar needed |

To use Edge TTS (no additional container needed):

```yaml
environment:
  TTS_PROVIDER: edge
```

## Multi-Architecture Support

The official Docker image is built for:

- `linux/amd64` — Standard x86 servers, Intel/AMD desktops, most NAS
- `linux/arm64` — Raspberry Pi 4/5, Apple Silicon, ARM NAS

Docker will automatically pull the correct image for your platform.

## Reverse Proxy

If you run Omnigram behind a reverse proxy, point it to `http://localhost:8080` (or your mapped host port).

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

    client_max_body_size 500M;   # For large ebook uploads

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Traefik (Docker labels)

```yaml
services:
  omnigram-server:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.omnigram.rule=Host(`books.example.com`)"
      - "traefik.http.services.omnigram.loadbalancer.server.port=80"
```

## Troubleshooting

### Permission denied on `/metadata`

The server runs as user `omnigram` (uid 1000) inside the container. If you see `Permission denied` errors for `/metadata`, fix volume ownership:

```bash
# For named volumes
docker run --rm -v omnigram_data:/metadata alpine chown -R 1000:1000 /metadata

# For bind mounts
sudo chown -R 1000:1000 /path/to/data
```

### Cannot pull Docker images (China)

If Docker Hub is unreachable, add a registry mirror to `/etc/docker/daemon.json`:

```json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me"
  ]
}
```

Then restart Docker:

```bash
sudo systemctl restart docker
```

### Scan errors: "value too long for type character varying"

Some ebooks have unusually long metadata fields. Upgrade to the latest server version which supports longer field lengths. Re-scan after upgrading.

## Connecting Clients

Once the server is running:

1. **Omnigram App** — Download from [GitHub Releases](https://github.com/lxpio/omnigram/releases), enter your server URL (e.g. `http://192.168.1.100:8080`)
2. **OPDS Clients** — Use any OPDS-compatible reader (Moon+ Reader, KOReader, Librera) with the OPDS endpoint at `http://your-server:8080/opds`
3. **WebDAV** — Mount your library via WebDAV at `http://your-server:8080/webdav`
