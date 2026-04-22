---
title: Text-to-Speech (TTS) Setup
description: Add local text-to-speech to Omnigram — from zero to first synthesis
---

Omnigram's TTS is delivered via a standalone sidecar container, decoupled from the server so you can pick an engine that matches your hardware. This guide is for **users who already have `omnigram-server` running** and want to add local TTS.

## Do you need local TTS?

Pick your scenario:

| Scenario | Recommendation | Deploy effort |
|----------|----------------|---------------|
| Occasional use / don't mind network latency | **Edge TTS** (built-in) | ⭐ Zero deploy |
| Fully offline, privacy-first, long reading sessions | **Kokoro** (this guide) | ⭐⭐ Pull image |
| Highest Chinese quality, you have a GPU | **Qwen3-TTS** | ⭐⭐⭐⭐ Local build required |
| Multilingual + modest GPU | **Chatterbox** | ⭐⭐⭐ Local build required |

For the fastest path, jump to [Option A: Edge TTS](#option-a-zero-deploy-edge-tts) — takes five seconds.

---

## Option A: Zero deploy (Edge TTS)

Edge TTS calls Microsoft's online endpoint. The server has it built in — **no extra container needed**.

### Steps

1. Edit your `docker-compose.yml`, add to `omnigram-server`'s `environment`:

   ```yaml
   environment:
     # ...existing config
     TTS_PROVIDER: edge
   ```

2. Restart:

   ```bash
   docker compose up -d
   ```

3. Open the client → open any book → tap the speak button in the reader toolbar.

:::note[Limitations]
Edge TTS requires internet and Microsoft may rate-limit. **Not recommended** for bulk audiobook generation.
:::

---

## Option B: Local Kokoro (recommended)

Kokoro is the default local TTS: CPU-capable, multilingual (incl. English + Chinese), reliable quality, MIT license.

### Hardware requirements

| Mode | Memory | Speed (approx.) | Notes |
|------|--------|-----------------|-------|
| CPU | 4 GB free RAM | ~1× realtime | Fine for most NAS / homeservers |
| GPU | 2 GB VRAM | ~10–20× realtime | Requires NVIDIA GPU + nvidia-container-toolkit |

First pull is ~**5 GB**; make sure you have disk space.

### Step 1: Edit docker-compose.yml

**Add a new `tts` service**, and on `omnigram-server` **add three env vars + depends_on**:

```yaml
services:
  omnigram-server:
    image: lxpio/omnigram-server:latest
    # ...keep your existing ports/volumes/other environment
    environment:
      # ...existing config
      # ── New: TTS ──
      TTS_PROVIDER: kokoro
      TTS_SIDECAR_URL: http://tts:8880
      TTS_TIMEOUT: 120s
    depends_on:
      db:
        condition: service_healthy
      tts:                             # ← new
        condition: service_healthy     # ← new

  # ── New service: Kokoro TTS ──
  tts:
    image: ghcr.io/remsky/kokoro-fastapi:latest
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8880/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s   # Model loads in 30–60s
```

:::tip[Do not expose the TTS port]
`tts` is only accessed by `omnigram-server` over Docker's internal network. **Do not** add a `ports:` mapping — avoids unnecessary exposure.
:::

### Step 2: Pull and start

```bash
docker compose pull tts
docker compose up -d
```

First start downloads model files (stored in a named volume; subsequent starts are fast). Expect 1–3 minutes.

### Step 3: Verify

```bash
docker compose ps
```

`tts` should reach `Up (healthy)`. If it's still `starting`, wait another 30 seconds.

Check server can see it:

```bash
docker compose logs omnigram-server | grep -i tts
```

Open a book in the client and hit the speak button — audio should start within 1–3 seconds.

---

## Enable GPU acceleration (optional)

If the host has an NVIDIA GPU with [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) installed, switch to:

```yaml
  tts:
    image: ghcr.io/remsky/kokoro-fastapi:latest-gpu
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8880/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

Then:

```bash
docker compose up -d tts
docker compose logs -f tts   # Confirm CUDA / GPU in the logs
```

---

## Option C: Higher Chinese quality (Qwen3-TTS, GPU + local build)

If Chinese is your primary language and you have ≥6 GB VRAM, switch to Qwen3-TTS.

:::caution[Local build required]
The upstream repo [groxaxo/Qwen3-TTS-Openai-Fastapi](https://github.com/groxaxo/Qwen3-TTS-Openai-Fastapi) **does not publish prebuilt images**. First build pulls the CUDA base image (~3 GB) and compiles flash-attn — expect **20–40 minutes** and **15–20 GB** of disk (including model cache). Plan the time and space.
:::

### Step 1: Clone and build

```bash
cd /opt
git clone https://github.com/groxaxo/Qwen3-TTS-Openai-Fastapi.git qwen3-tts
cd qwen3-tts
# Edit docker-compose.yml: device_ids: ['2'] → ['0'] (upstream hardcodes GPU #2)
docker compose build qwen3-tts-gpu
```

### Step 2: Start Qwen3-TTS

Qwen3-TTS's own compose uses `network_mode: host` on port 8880, which collides with the `tts` sidecar in Omnigram's compose. Run it as a **separate stack** and point the server at the host:

```bash
cd /opt/qwen3-tts
docker compose up -d qwen3-tts-gpu
# First start downloads the model from HuggingFace (~4 GB):
docker compose logs -f qwen3-tts-gpu
```

Wait for `Uvicorn running on http://0.0.0.0:8880`, then `http://<host>:8880/health` should return JSON.

### Step 3: Update Omnigram compose

**Remove** the previous `tts:` service block, and change the sidecar URL on `omnigram-server` to point at the host:

```yaml
services:
  omnigram-server:
    environment:
      TTS_PROVIDER: kokoro                           # unchanged (API-compatible)
      TTS_SIDECAR_URL: http://host.docker.internal:8880
      TTS_TIMEOUT: 180s                              # Qwen3 first-token latency is higher
    extra_hosts:
      - "host.docker.internal:host-gateway"          # required on Linux
    depends_on:
      db:
        condition: service_healthy
      # drop the tts dependency
```

Then `docker compose up -d omnigram-server`.

:::tip[Why not merge into one compose file]
Qwen3-TTS's image uses host networking with a hardcoded `8880` port — it conflicts with the sidecar network model Omnigram's compose assumes. Running it as a separate stack is simpler and keeps upgrade paths independent.
:::

---

## Troubleshooting

### `tts` container stuck in `unhealthy` / `starting`

- First boot is downloading the model; **give it 3 minutes**
- Low disk may break extraction — ensure at least 8 GB free
- Logs: `docker compose logs tts`

### Client says "TTS service unavailable"

- Confirm reachability from the server:

  ```bash
  docker compose exec omnigram-server wget -qO- http://tts:8880/health
  ```

  Should return something like `{"status":"ok"}`.
- If it fails, make sure both services are on the **same compose network** (they are, automatically, if in the same compose file).

### Choppy audio in CPU mode

- Kokoro CPU mode wants ≥4 cores, otherwise synthesis can't keep up with playback
- Lower speed / shorten paragraphs, or switch to Edge TTS / GPU mode

### How do I roll back to Edge TTS?

Stop and remove the `tts` container, set `TTS_PROVIDER: edge`, remove `TTS_SIDECAR_URL`:

```bash
docker compose rm -sf tts
# Edit compose, then
docker compose up -d omnigram-server
```

---

## Next steps

- Tune speed / voice in the client under **Settings → Reading Experience → Voice**
- Want to **render an entire book into MP3**? On the book detail page, tap **Generate audiobook** — chapters are synthesized one by one and can be downloaded to your device for playback with any system player (client UI lands in Sprint 6).
