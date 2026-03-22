# 015 - TTS 模型评估报告

> 评估日期：2026-03-22
> 状态：✅ 评估完成
> 目标：为 Omnigram Server 端有声书生成 + App 端实时朗读选择最优 TTS 模型
> 前置：014-tts-multi-engine-architecture.md

---

## 一、评估背景

Omnigram 需要在两个场景下选择 TTS 模型：

| 场景 | 需求 | 硬件约束 |
|------|------|---------|
| **Server 端有声书生成** | 最高质量、中英文、情感表达、按章节批量生成 | GPU 8GB+（有 GPU 用户）或 CPU（NAS 用户） |
| **App 端实时朗读** | 低延迟、小模型、离线可用、翻页即读 | 手机 CPU/NPU，内存有限 |

评估范围：2025-2026 年主流开源 TTS 模型，排除纯商业 API。

---

## 二、Server 端候选模型全景对比

### 2.1 GPU 场景（有声书生成，追求最高质量）

| 模型 | 参数量 | 中文 | 英文 | 声音克隆 | 情感控制 | 多人对话 | GPU VRAM | 延迟 | Docker + OpenAI API | 许可证 | GitHub ⭐ |
|------|--------|------|------|---------|---------|---------|---------|------|-------------------|--------|----------|
| **Qwen3-TTS 1.7B** | 1.7B | ⭐⭐⭐⭐⭐ 最强（含方言） | ⭐⭐⭐⭐ | ✅ 零样本 | ✅ 表达力强 | ❌ | 6GB+ | **97ms** | ✅ [现成](https://github.com/groxaxo/Qwen3-TTS-Openai-Fastapi) | Apache 2.0 | 6k+ |
| **Chatterbox Turbo** | 350M | ⭐⭐⭐⭐ 23语言 | ⭐⭐⭐⭐⭐ 盲测胜 ElevenLabs | ✅ 零样本 | ✅ 副语言标签 | 2026 规划 | **4GB+** | 极低（1步扩散） | ✅ 社区有 | **MIT** | 11k+ |
| **IndexTTS-2** | ~1B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ 零样本 | ✅ 时长控制 | ❌ | 8GB+ | 中等 | ⚠️ 需自行包装 | Apache 2.0 | 8k+ |
| **Orpheus 3B** | 3B | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ 零样本 | ✅ 情感标签 | ❌ | 8GB+ | ~200ms | ✅ [多个可用](https://github.com/blak-code-tech/orpheus-tts) | Apache 2.0 | 5k+ |
| **Fish Speech V1.5** | ~1B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ | 一般 | ❌ | 8GB+ | 中等 | ✅ 官方 API | 受限商用 | 18k+ |
| **CosyVoice2-0.5B** | 0.5B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ | 一般 | ❌ | 6GB+ | **150ms** | ⚠️ 需自行包装 | Apache 2.0 | 10k+ |
| **Dia 1.6B** | 1.6B | ❌ 仅英文 | ⭐⭐⭐⭐⭐ | ✅ 零样本 | ✅ 笑/咳嗽/叹气 | ✅ **双人对话** | 10GB | 中等 | ✅ [OpenAI 兼容](https://github.com/devnen/Dia-TTS-Server) | Apache 2.0 | 25k+ |
| **Parler-TTS** | ~600M | ❌ 主要英文 | ⭐⭐⭐⭐ | ❌ 无 | ✅ 自然语言描述 | ❌ | 6GB+ | 中等 | ❌ 需自行包装 | Apache 2.0 | 4k+ |
| **F5-TTS** | ~300M | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ **最强克隆** | 一般 | ❌ | 6GB+ | 中等 | ⚠️ 社区有 | CC-BY-NC | 15k+ |
| **Higgs Audio V2** | 3B | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ | ✅ 多情感 | ✅ 多人 | 12GB+ | 中等 | ⚠️ 需自行包装 | Llama 衍生 | HF 热榜 |
| **MiraTTS** | — | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ 零样本 | 一般 | ❌ | 6GB+ | **极快**（batch 3000%） | ⚠️ 需自行包装 | Apache 2.0 | 新 |
| **GLM-TTS** | — | ⭐⭐⭐⭐⭐ 智谱 | ⭐⭐⭐⭐ | ✅ 零样本 | 一般 | ❌ | 8GB+ | 200%+ | ⚠️ 需自行包装 | Apache 2.0 | 新 |
| **VibeVoice 1.5B** | 1.5B | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ 零样本 | ✅ seed/LoRA | ❌ | 6GB+ | **极快**（batch 1000%） | ⚠️ 需自行包装 | MIT→已撤源 | 微软 |

> **新增说明（来源：[tts-audiobook-tool](https://github.com/zeropointnine/tts-audiobook-tool) 实测数据）：**
> - **MiraTTS**：batch 模式 3000% 实时速度（GTX 3080 Ti），是所有模型中最快的。适合大批量有声书生成。
> - **GLM-TTS**：智谱出品，中文质量预期较好，需要 CUDA（代码中硬编码了 CUDA 操作）。
> - **VibeVoice 1.5B**：微软出品，支持 LoRA 微调声音，batch 模式 1000% 实时。⚠️ 微软已从 GitHub 撤源，需使用社区 fork。

### 2.2 CPU 场景（NAS 用户，无 GPU）

| 模型 | 参数量 | 中文 | 英文 | 质量 | CPU 性能 | 许可证 |
|------|--------|------|------|------|---------|--------|
| **Kokoro 82M** | 82M | ⭐⭐⭐⭐ 8语言 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 10秒语音≈10秒生成 | Apache 2.0 |
| **Piper (VITS)** | 15-60M | ⭐⭐⭐ 40+语言 | ⭐⭐⭐ | ⭐⭐⭐ | **实时以上** | MIT |
| **MeloTTS** | ~50M | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | 接近实时 | MIT |
| **Qwen3-TTS 0.6B** | 0.6B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 较慢（需验证） | Apache 2.0 |

---

## 三、有声书场景专项评估

有声书生成的特殊需求：长文本稳定性、章节间音色一致性、情感节奏、多角色。

### 3.1 评估维度

| 维度 | 权重 | 说明 |
|------|------|------|
| 中文质量 | 30% | Omnigram 核心用户群包含大量中文用户 |
| 英文质量 | 20% | 英文有声书需求同样重要 |
| 长文本稳定性 | 20% | 有声书需要连续数小时的稳定输出，不能中途变调/变速 |
| Docker + API 成熟度 | 15% | Sidecar 方案要求开箱即用的 Docker 镜像 + OpenAI 兼容 API |
| 硬件门槛 | 10% | VRAM 要求越低，覆盖面越大 |
| 许可证 | 5% | 商业友好优先 |

### 3.2 评分

| 模型 | 中文(30%) | 英文(20%) | 稳定性(20%) | Docker+API(15%) | 硬件(10%) | 许可证(5%) | **加权总分** |
|------|-----------|-----------|------------|-----------------|-----------|-----------|-------------|
| **Qwen3-TTS 1.7B** | 5 | 4 | 4 | 5 | 4 | 5 | **4.55** |
| **Chatterbox Turbo** | 4 | 5 | 4 | 4 | 5 | 5 | **4.40** |
| **IndexTTS-2** | 5 | 4 | 5 | 2 | 3 | 5 | **4.10** |
| **Orpheus 3B** | 4 | 5 | 4 | 4 | 3 | 5 | **4.15** |
| **CosyVoice2** | 5 | 4 | 3 | 2 | 4 | 5 | **3.85** |
| **Dia 1.6B** | 0 | 5 | 4 | 4 | 3 | 5 | **2.95** |
| **Fish Speech** | 5 | 5 | 4 | 4 | 3 | 3 | **4.25** |
| **Parler-TTS** | 0 | 4 | 3 | 1 | 4 | 5 | **2.30** |

### 3.3 排名

| 排名 | 模型 | 总分 | 一句话 |
|------|------|------|--------|
| 🥇 | **Qwen3-TTS 1.7B** | 4.55 | 中文最强 + 10 语言 + 97ms 延迟 + 阿里维护 + 现成 Docker + OpenAI API。**有声书 Server 端首选。** |
| 🥈 | **Chatterbox Turbo** | 4.40 | 盲测胜 ElevenLabs + 350M 极轻量（仅需 4GB VRAM）+ 23 语言 + MIT 许可。**轻量 GPU 场景首选。** |
| 🥉 | **Fish Speech V1.5** | 4.25 | 中英文质量顶级，但许可证受限商用。已废弃 gRPC 集成，不再推荐。 |
| 4 | **Orpheus 3B** | 4.15 | 中英文都好 + Docker 生态成熟，但 3B 参数 VRAM 需求高。**全能型备选。** |
| 5 | **IndexTTS-2** | 4.10 | 时长控制和稳定性最优，但无现成 Docker/API 镜像，集成成本高。**待 Docker 生态成熟后再评估。** |
| 6 | **CosyVoice2** | 3.85 | 延迟最低但 Docker 需自行包装，长文本稳定性一般。 |
| 7 | **Dia 1.6B** | 2.95 | 英文对话无敌，但不支持中文，场景太窄。 |
| 8 | **Parler-TTS** | 2.30 | 不支持中文 + 无声音克隆 + 无 Docker 生态。**淘汰。** |

---

## 四、App 端候选模型评估

App 端核心需求：小模型、低延迟、离线可用、省电。

### 4.1 通过 sherpa-onnx 可集成的模型

| 模型 | 模型大小 | 手机 RTF | 质量 | 中文 | 离线 | sherpa-onnx 支持 | 许可证 |
|------|---------|---------|------|------|------|-----------------|--------|
| **Piper (VITS)** | 15-60MB | < 0.5 | ⭐⭐⭐⭐ | ✅ 40+语言 | ✅ | ✅ 官方支持 | MIT |
| **Kokoro 82M** | 80-300MB | ~0.8 | ⭐⭐⭐⭐⭐ | ✅ 8语言 | ✅ | ✅ 官方支持 | Apache 2.0 |
| **MeloTTS** | ~100MB | ~0.7 | ⭐⭐⭐⭐ | ✅ 中文好 | ✅ | ⚠️ 需验证 | MIT |

### 4.2 在线 API 方案

| 方案 | 质量 | 中文 | 延迟 | 成本 | 说明 |
|------|------|------|------|------|------|
| **Edge TTS** | ⭐⭐⭐⭐ | ✅ | 低 | 免费 | ⚠️ 非官方 API，无 SLA |
| **OpenAI TTS** | ⭐⭐⭐⭐⭐ | ✅ | 中 | $15/百万字符 | 用户自带 Key |
| **ElevenLabs** | ⭐⭐⭐⭐⭐ | ✅ | 低 | $5/月起 | 声音克隆 |
| **Azure Speech** | ⭐⭐⭐⭐ | ✅ | 低 | 50万字符/月免费 | 最便宜 |
| **Omnigram Server** | 取决于配置 | ✅ | 取决于网络 | 自托管 | 有 NAS 用户 |

### 4.3 App 端推荐

| 排名 | 方案 | 推荐场景 |
|------|------|---------|
| 默认 | **flutter_tts**（系统引擎） | 零配置，开箱即用 |
| 升级 1 | **Edge TTS** | 联网时质量好，免费，无需下载 |
| 升级 2 | **Piper** | 离线快速朗读，模型小（15MB），翻页即读 |
| 升级 3 | **Kokoro q8** | 离线最高质量（~80MB），适合预生成 |
| 高端 | **商业 API 直连** | 用户自带 Key，追求极致 |
| NAS 用户 | **Omnigram Server** | 利用服务端算力 |

---

## 五、最终选型决策

### Server 端

| 场景 | 选型 | 理由 |
|------|------|------|
| **GPU 有声书（中文为主）** | 🥇 **Qwen3-TTS 1.7B** | 中文最强（含方言）、现成 Docker + OpenAI 兼容 API、阿里持续维护 |
| **GPU 有声书（英文为主 / 轻量 GPU）** | 🥈 **Chatterbox Turbo** | 盲测胜 ElevenLabs、仅需 4GB VRAM、MIT 许可、23 语言 |
| **CPU（无 GPU NAS 用户）** | **Kokoro 82M** | CPU 可跑、质量远超体积、现成 Docker |
| **零成本 fallback** | **Edge TTS** | Go 直接调用、免费、⚠️ 无 SLA |
| **API 代理** | **OpenAI TTS** | 用户自带 Key，Server 端代理 |

### App 端

| 引擎 | 优先级 | 阶段 |
|------|--------|------|
| flutter_tts | 默认 | Phase 1 |
| Edge TTS | 免费在线 | Phase 1 |
| Piper (via sherpa-onnx) | 离线快速 | Phase 2 |
| Kokoro (via sherpa-onnx) | 离线高质量 | Phase 2 |
| 商业 API 直连 | 用户自带 Key | Phase 3 |
| Server TTS | NAS 用户 | Phase 3 |

### 相比 014 文档的变更

| 项目 | 014 原方案 | 本次评估结论 | 理由 |
|------|-----------|-------------|------|
| GPU 有声书首选 | IndexTTS-2（待评估） | **Qwen3-TTS 1.7B** | 中文最强 + 现成 Docker + API，IndexTTS-2 无现成镜像 |
| 待评估候选 | Parler-TTS / Orpheus / Dia | **Chatterbox Turbo + Orpheus**（Parler/Dia 淘汰） | Parler 不支持中文+无克隆，Dia 仅英文 |
| IndexTTS-2 | Phase 2 POC | **降级为后备**，待 Docker 生态成熟 | 质量好但无现成 API Server |
| 新增 | — | **Qwen3-TTS** | 评估时发现的最强中文 TTS |
| 新增 | — | **Chatterbox Turbo** | 评估时发现的最轻量高质量方案 |

---

## 六、有声书质量控制（tts-audiobook-tool 启发）

> 来源：[tts-audiobook-tool](https://github.com/zeropointnine/tts-audiobook-tool) — 支持 9+ 模型的开源有声书生成工具，积累了大量实践经验。

### 6.1 核心质量措施

| 措施 | 说明 | Omnigram 实施优先级 |
|------|------|-------------------|
| **STT 纠错** | 用 Whisper 转写合成音频，与源文本对比 WER，超阈值自动重试并选最优结果 | P0（有声书质量的杀手级功能） |
| **停顿控制 (Caesura)** | 段落间/句子间/短语间插入不同长度的静音，基于语义层级自动调整 | P1 |
| **响度归一化 (LUFS)** | 最终章节文件级别 LUFS 归一化（非逐段落，否则音量跳变） | P1 |
| **首尾裁切** | 裁掉合成音频首尾静音和杂音（某些模型短句末尾产生噪音） | P1 |
| **重复短语检测** | 检测并拒绝重复词组的合成结果 | P2 |
| **音乐幻觉检测** | 拒绝包含音乐/唱歌的合成结果（VibeVoice 等模型常见） | P2 |
| **词语替换表** | 用户定义 TTS 易读错的词的替换规则 | P2 |
| **分段策略多样化** | 支持段落/句子/短语/多句等分段方式，max_words 可配置（当前我们只有句子级） | P1 |

### 6.2 文本-音频同步（Omnigram 差异化特性）

tts-audiobook-tool 将文本+时间戳嵌入 FLAC/M4A 元数据，实现播放器文本高亮同步。

**Omnigram 的独特优势**：我们同时拥有 EPUB 原文和有声书音频，可以实现：
- 播放有声书时，在 EPUB 阅读页面实时高亮当前朗读的句子（类似 Kindle Whispersync）
- 这是 Audiobookshelf 做不到的（它没有原文阅读器）

**实现路径**：Whisper word-level timing → 映射到原文位置 → App 阅读器实时高亮

### 6.3 推理速度参考（tts-audiobook-tool 实测，GTX 3080 Ti）

| 模型 | 速度 | 备注 |
|------|------|------|
| MiraTTS | 3000% 实时 | batch=10，最快 |
| VibeVoice 1.5B | 1000% 实时 | batch=10 |
| Fish S1-mini | 500%+ 实时 | |
| Chatterbox Turbo | 500%+ 实时 | |
| Qwen3-TTS 1.7B | 300% 实时 | batch=5 |
| GLM-TTS | 200%+ 实时 | |
| Orpheus 3B / Higgs V2 | ~200% 实时 | |
| IndexTTS-2 | ~90% 实时 | GTX 3080 Ti 较慢 |

> **结论**：Qwen3-TTS 虽然不是最快，但 300% 实时速度足够有声书批量生成。如追求极致速度，MiraTTS 和 VibeVoice 值得关注。

---

## 七、待验证项（Phase 2 POC）

在正式集成前需要实际验证的事项：

| # | 验证项 | 通过标准 | 优先级 |
|---|--------|---------|--------|
| 1 | Qwen3-TTS Docker 部署 | `docker compose up` 一键启动 + `/v1/audio/speech` 可用 | P0 |
| 2 | Qwen3-TTS 中文有声书质量 | 10 段中文小说文本，人工评估自然度 ≥ 4/5 | P0 |
| 3 | Qwen3-TTS 长文本稳定性 | 连续合成 50 个章节（约 10 万字），无音色漂移/变调 | P0 |
| 4 | Chatterbox Turbo 4GB GPU 验证 | 在 4GB VRAM GPU 上正常运行，无 OOM | P1 |
| 5 | Chatterbox 中文质量 | 10 段中文文本，自然度 ≥ 3.5/5 | P1 |
| 6 | Kokoro q8 vs fp16 | 10 段文本 AB 对比，q8 自然度损失 ≤ 0.5 分 | P1 |
| 7 | sherpa-onnx + Kokoro 手机端 | iPhone 13 / Pixel 6 上加载+合成正常，内存 < 500MB | P1 |
| 8 | Qwen3-TTS 0.6B CPU 性能 | NAS CPU（如 N100）上合成 1000 字耗时 < 120 秒 | P2 |
| 9 | Whisper STT 纠错 Sidecar | faster-whisper Docker 部署 + 合成结果 WER 校验流程跑通 | P1 |
| 10 | 停顿控制 + 响度归一化 | ffmpeg 静音插入 + LUFS 归一化，AB 对比有无明显改善 | P1 |
| 11 | MiraTTS batch 速度验证 | 确认 batch=10 是否真能达到 3000% 实时 | P2 |

---

## 八、技术参考

### Server 端 Docker 镜像

| 模型 | Docker 方案 | 链接 |
|------|------------|------|
| Qwen3-TTS | OpenAI 兼容 FastAPI | [Qwen3-TTS-Openai-Fastapi](https://github.com/groxaxo/Qwen3-TTS-Openai-Fastapi) |
| Qwen3-TTS | 含 Docker 支持 | [Usimian/Qwen3-TTS](https://github.com/Usimian/Qwen3-TTS) |
| Chatterbox | Resemble AI 官方 | [resemble-ai/chatterbox](https://github.com/resemble-ai/chatterbox) |
| Kokoro | OpenAI 兼容 FastAPI | [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI) |
| Orpheus | 生产级 Docker | [orpheus-tts-docker](https://github.com/neosun100/orpheus-tts-docker) |
| Orpheus | OpenAI 兼容 API | [orpheus-tts (blak-code-tech)](https://github.com/blak-code-tech/orpheus-tts) |
| Dia | OpenAI 兼容 Server | [Dia-TTS-Server](https://github.com/devnen/Dia-TTS-Server) |
| IndexTTS-2 | 有声书工具集成 | [tts-audiobook-tool](https://github.com/zeropointnine/tts-audiobook-tool) |

### 有声书专用工具

| 项目 | 说明 |
|------|------|
| [tts-audiobook-tool](https://github.com/zeropointnine/tts-audiobook-tool) | 支持 Qwen3-TTS / IndexTTS2 / Higgs V2 / Fish S1 / Chatterbox 等多模型的有声书生成工具 + 播放器 Web App |

### 模型官方仓库

| 模型 | 链接 | 许可证 |
|------|------|--------|
| Qwen3-TTS | [QwenLM/Qwen3-TTS](https://github.com/QwenLM/Qwen3-TTS) | Apache 2.0 |
| Chatterbox | [resemble-ai/chatterbox](https://github.com/resemble-ai/chatterbox) | MIT |
| Kokoro | [hexgrad/kokoro](https://github.com/hexgrad/kokoro) | Apache 2.0 |
| Orpheus | [canopyai/Orpheus-TTS](https://github.com/canopyai/Orpheus-TTS) | Apache 2.0 |
| IndexTTS-2 | [indexteam/IndexTTS](https://github.com/indexteam/IndexTTS) | Apache 2.0 |
| Dia | [nari-labs/dia](https://github.com/nari-labs/dia) | Apache 2.0 |
| Fish Speech | [fishaudio/fish-speech](https://github.com/fishaudio/fish-speech) | 受限商用 |
| CosyVoice2 | [FunAudioLLM/CosyVoice](https://github.com/FunAudioLLM/CosyVoice) | Apache 2.0 |
| Piper | [rhasspy/piper](https://github.com/rhasspy/piper) | MIT |
| MeloTTS | [myshell-ai/MeloTTS](https://github.com/myshell-ai/MeloTTS) | MIT |
| Parler-TTS | [huggingface/parler-tts](https://github.com/huggingface/parler-tts) | Apache 2.0 |
| MiraTTS | [ysharma3501/MiraTTS](https://github.com/ysharma3501/MiraTTS) | Apache 2.0 |
| GLM-TTS | [zai-org/GLM-TTS](https://github.com/zai-org/GLM-TTS) | Apache 2.0 |
| VibeVoice | [vibevoice-community/VibeVoice](https://github.com/vibevoice-community/VibeVoice) | MIT（⚠️ 微软已撤源） |
| Oute TTS | [edwko/OuteTTS](https://github.com/edwko/OuteTTS) | Apache 2.0 |
