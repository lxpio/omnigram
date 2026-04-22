---
title: 语音朗读（TTS）部署
description: 为 Omnigram 添加本地语音朗读能力 — 从零部署到首次合成
---

Omnigram 的语音朗读（TTS）通过独立的 sidecar 容器提供，与服务器解耦，可根据硬件条件灵活选择引擎。本文档面向**已经跑起 `omnigram-server` 的普通用户**，指导你添加本地 TTS。

## 是否需要本地 TTS？

先判断你的场景：

| 场景 | 推荐 | 部署复杂度 |
|------|------|-----------|
| 只想偶尔听一小段 / 不在意延迟 | **Edge TTS**（内置） | ⭐ 零部署 |
| 希望完全离线、保护隐私、长时朗读 | **Kokoro**（本文主题） | ⭐⭐ pull 镜像 |
| 中文质量要求极高、有 GPU | **Qwen3-TTS** | ⭐⭐⭐⭐ 需本地构建 |
| 需要多语言 + 低显存 GPU | **Chatterbox** | ⭐⭐⭐ 需本地构建 |

如果你只想快速试用，直接跳到 [方案 A：Edge TTS](#方案-a零部署edge-tts)，五秒搞定。

---

## 方案 A：零部署（Edge TTS）

Edge TTS 调用微软在线接口，服务器内置支持，**无需额外容器**。

### 步骤

1. 编辑你的 `docker-compose.yml`，在 `omnigram-server` 的 `environment` 下添加：

   ```yaml
   environment:
     # ...已有配置
     TTS_PROVIDER: edge
   ```

2. 重启服务器：

   ```bash
   docker compose up -d
   ```

3. 打开客户端 → 打开任意书 → 点击底部工具栏的朗读按钮。

:::note[限制]
Edge TTS 需要联网，且微软可能限流。**不建议**大批量生成有声书。
:::

---

## 方案 B：本地 Kokoro（推荐）

Kokoro 是默认推荐的本地 TTS 引擎：CPU 可跑、支持中英多语言、质量可靠、MIT 许可。

### 硬件要求

| 模式 | 内存 | 速度（参考） | 说明 |
|------|------|------------|------|
| CPU | 4 GB 可用 RAM | 约 1× 实时 | 适合大多数 NAS / homeserver |
| GPU | 2 GB VRAM | 约 10–20× 实时 | 需要 NVIDIA GPU 与 nvidia-container-toolkit |

镜像首次拉取约 **5 GB**，请预留磁盘空间。

### 步骤 1：修改 docker-compose.yml

在现有 compose 文件中**新增 `tts` 服务**，并在 `omnigram-server` 上**新增三个环境变量 + depends_on**：

```yaml
services:
  omnigram-server:
    image: lxpio/omnigram-server:latest
    # ...保留你已有的 ports/volumes/其他 environment
    environment:
      # ...已有配置
      # ── 新增：TTS ──
      TTS_PROVIDER: kokoro
      TTS_SIDECAR_URL: http://tts:8880
      TTS_TIMEOUT: 120s
    depends_on:
      db:
        condition: service_healthy
      tts:                             # ← 新增
        condition: service_healthy     # ← 新增

  # ── 新增服务：Kokoro TTS ──
  tts:
    image: ghcr.io/remsky/kokoro-fastapi:latest
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8880/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s   # 模型加载需要 30–60 秒
```

:::tip[不需要开放 TTS 端口]
`tts` 服务只在 Docker 内网被 `omnigram-server` 访问，**不要**加 `ports:` 映射到宿主机，避免不必要的暴露。
:::

### 步骤 2：拉取镜像并启动

```bash
docker compose pull tts
docker compose up -d
```

首次启动 `tts` 容器会下载模型文件（写在命名卷中，第二次启动会很快）。预计耗时 1–3 分钟。

### 步骤 3：验证

查看状态：

```bash
docker compose ps
```

期望看到 `tts` 容器状态为 `Up (healthy)`。如果仍是 `starting`，再等 30 秒。

检查服务器日志确认探测成功：

```bash
docker compose logs omnigram-server | grep -i tts
```

打开客户端任选一本书，**点击朗读按钮** → 应该在 1–3 秒后开始出声。

---

## 启用 GPU 加速（可选）

如果机器有 NVIDIA GPU 且已安装 [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)，把 `tts` 服务改成：

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

然后：

```bash
docker compose up -d tts
docker compose logs -f tts   # 确认日志里出现 CUDA / GPU
```

---

## 方案 C：更高中文质量（Qwen3-TTS，需 GPU + 自行构建）

如果你主要读中文书，且有 ≥6 GB VRAM 的 NVIDIA GPU，可切换到 Qwen3-TTS。

:::caution[需要本地构建]
上游仓库 [groxaxo/Qwen3-TTS-Openai-Fastapi](https://github.com/groxaxo/Qwen3-TTS-Openai-Fastapi) **没有发布预构建镜像**，需要自己 build。首次构建会拉取 CUDA 基础镜像（约 3 GB）+ 编译 flash-attn，耗时 **20–40 分钟**，总占用约 **15–20 GB** 磁盘（含模型缓存）。请预留时间与空间。
:::

### 步骤 1：克隆并构建

```bash
cd /opt
git clone https://github.com/groxaxo/Qwen3-TTS-Openai-Fastapi.git qwen3-tts
cd qwen3-tts
# 编辑 docker-compose.yml：device_ids: ['2'] → ['0']（默认写死了 GPU #2）
docker compose build qwen3-tts-gpu
```

### 步骤 2：启动 Qwen3-TTS

Qwen3-TTS 官方 compose 里用 `network_mode: host`，监听 `:8880`，会与 Omnigram compose 里的 `tts` 服务冲突。推荐**独立 compose 启动**，然后让 `omnigram-server` 通过宿主机地址访问：

```bash
cd /opt/qwen3-tts
docker compose up -d qwen3-tts-gpu
# 首次启动会从 HuggingFace 下载模型（约 4 GB），查看进度：
docker compose logs -f qwen3-tts-gpu
```

等日志出现 `Uvicorn running on http://0.0.0.0:8880`，访问 `http://<服务器>:8880/health` 返回 JSON 即就绪。

### 步骤 3：改 Omnigram compose

**移除**之前的 `tts:` 服务块，只在 `omnigram-server` 改 sidecar URL 指向宿主机：

```yaml
services:
  omnigram-server:
    environment:
      TTS_PROVIDER: kokoro                           # 保持不变（接口兼容）
      TTS_SIDECAR_URL: http://host.docker.internal:8880
      TTS_TIMEOUT: 180s                              # Qwen3 首句较慢
    extra_hosts:
      - "host.docker.internal:host-gateway"          # Linux 需要显式添加
    depends_on:
      db:
        condition: service_healthy
      # 删掉 tts 依赖
```

然后 `docker compose up -d omnigram-server`。

:::tip[为什么不合并到同一份 compose]
Qwen3-TTS 官方镜像用 host 网络 + 写死 `8880` 端口，与 Omnigram 的 sidecar 容器网络模型冲突。独立运行最省事，后续升级也互不影响。
:::

---

## 常见问题

### `tts` 容器一直 `unhealthy` / `starting`

- 第一次启动在下载模型，**给它 3 分钟**再看
- 磁盘空间不足会导致解压失败，确认至少 8 GB 可用
- 查看日志：`docker compose logs tts`

### 朗读时客户端报错 "TTS 服务不可用"

- 确认 `omnigram-server` 能访问 `tts`：

  ```bash
  docker compose exec omnigram-server wget -qO- http://tts:8880/health
  ```

  期望返回 `{"status":"ok"}` 之类。
- 如果失败，检查两个服务是否在**同一个 compose 网络**（在同一份 compose 文件里就会自动在一起）。

### CPU 模式朗读卡顿

- Kokoro CPU 模式下推荐机器至少 4 核，否则合成跟不上播放
- 降低语速、缩短段落；或切换到 Edge TTS / GPU 模式

### 想换回 Edge TTS 怎么办

停掉并删除 `tts` 容器，把 `TTS_PROVIDER` 改成 `edge`，`TTS_SIDECAR_URL` 删掉：

```bash
docker compose rm -sf tts
# 编辑 compose 后
docker compose up -d omnigram-server
```

---

## 下一步

- 在客户端 **设置 → 阅读体验 → 语音** 里调整语速、音色
- 想把整本书**合成成 MP3 有声书**？在书籍详情页点「生成有声书」即可，章节逐步生成后可单独下载到本地用系统播放器收听（客户端 UI 在 Sprint 6 更新中）
