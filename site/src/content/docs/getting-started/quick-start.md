---
title: Quick Start
description: Deploy Omnigram with Docker in under a minute
---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose (v2+)
- A directory with your ebook collection (EPUB, PDF, etc.)

## 1. Create Compose File

Create a directory and a `docker-compose.yml` file:

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
      - /path/to/your/books:/docs        # Your ebook directory
      - omnigram_data:/metadata           # Server data (persistent)
    environment:
      DB_DRIVER: postgres
      DB_HOST: db
      DB_PORT: 5432
      DB_USER: omnigram
      DB_PASSWORD: omnigram
      DB_NAME: omnigram
      OMNI_USER: admin                    # Admin username
      OMNI_PASSWORD: changeme            # Change this!
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

:::caution[Change the book path]
Replace `/path/to/your/books` with the actual path to your ebook directory, e.g. `/volume1/ebooks` on Synology or `/disk1/books` on a Linux server.
:::

## 2. Start the Server

```bash
docker compose up -d
```

Wait for the database to become healthy and the server to start (~10 seconds):

```bash
docker compose logs -f omnigram-server
```

You should see:

```
omnigram-server  | HTTP server address: 0.0.0.0:80
```

## 3. Log In & Scan Books

1. Open **http://your-server-ip:8080** in your browser
2. Log in with the username and password you set above
3. Go to **Settings > Library > Scan** to import your books
4. The scan will index all EPUB/PDF files in your book directory

## Next Steps

- [Installation Guide](/docs/getting-started/installation) for TTS, AI, reverse proxy, and advanced configuration
- Download the [Omnigram App](https://github.com/lxpio/omnigram/releases) and connect to your server
- Try [OPDS clients](https://en.wikipedia.org/wiki/OPDS) like Moon+ Reader or KOReader
