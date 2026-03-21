---
title: Quick Start
description: Deploy Omnigram with Docker in 30 seconds
---

## Prerequisites

- Docker and Docker Compose installed
- A directory with your ebook collection

## Deploy

Create a `docker-compose.yml`:

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

Start the server:

```bash
docker compose up -d
```

Open `http://localhost:8080` in your browser.

## Next Steps

- [Installation Guide](/docs/getting-started/installation) for advanced configuration
- Connect the [Omnigram App](https://github.com/lxpio/omnigram) to your server
- Try [OPDS clients](https://en.wikipedia.org/wiki/OPDS) like Moon+ Reader or KOReader
