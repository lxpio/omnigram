---
title: Installation Guide
description: Detailed installation and configuration for Omnigram
---

## Docker Compose (Recommended)

Docker Compose is the recommended way to deploy Omnigram. The server image supports both `amd64` and `arm64` architectures, so it runs on standard servers, Raspberry Pi, and Apple Silicon Macs.

### Basic Setup

Create a `docker-compose.yml` file:

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

Start the service:

```bash
docker compose up -d
```

### Volume Mounts

| Host Path | Container Path | Purpose |
|-----------|---------------|---------|
| `./books` | `/docs` | Your ebook library (EPUB, PDF, etc.) |
| `./data` | `/metadata` | Database, covers, and server metadata |

The `/docs` volume is read by the server to index your book collection. Place your ebooks here organized in any folder structure you prefer.

The `/metadata` volume stores the SQLite database, extracted cover images, and other server state. **Back up this directory regularly.**

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OMNI_USER` | — | Admin username (required on first run) |
| `OMNI_PASSWORD` | — | Admin password (required on first run) |
| `OMNI_DB_TYPE` | `sqlite` | Database type: `sqlite` or `postgres` |
| `OMNI_DB_DSN` | — | PostgreSQL connection string (when using `postgres`) |
| `OMNI_PORT` | `80` | Server listen port inside the container |

## Database Options

### SQLite (Default)

SQLite is the default and requires no extra configuration. The database file is stored in the `/metadata` volume. This is ideal for personal use and small teams.

### PostgreSQL

For larger deployments or when you want to use an existing PostgreSQL instance:

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

## Multi-Architecture Support

The official Docker image is built for:

- `linux/amd64` — Standard x86 servers, Intel/AMD desktops
- `linux/arm64` — Raspberry Pi 4/5, Apple Silicon (via Rosetta), ARM servers

Docker will automatically pull the correct image for your platform.

## Reverse Proxy

If you run Omnigram behind a reverse proxy (Nginx, Caddy, Traefik), point the proxy to `http://localhost:8080` (or whichever host port you mapped).

Example Caddy configuration:

```
books.example.com {
    reverse_proxy localhost:8080
}
```

## Connecting Clients

Once the server is running:

1. **Omnigram App** — Download from [GitHub Releases](https://github.com/lxpio/omnigram/releases) and enter your server URL
2. **OPDS Clients** — Use any OPDS-compatible reader (Moon+ Reader, KOReader, Librera) with the server's OPDS endpoint
