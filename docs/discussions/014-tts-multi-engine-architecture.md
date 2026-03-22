# 014 - TTS 多引擎架构设计

> 讨论日期：2026-03-21
> 状态：✅ 已决策（含二轮审计修订）
> 核心决策：废弃 Fish Speech，Server 端采用 Sidecar 容器方案，App 端用户按需下载模型

---

## 一、架构总览

```
┌─────────────────────────────────────────────────────────┐
│                    Omnigram App (Flutter)                 │
│                                                         │
│  TTS Provider 选择器（设置页，用户按需下载模型）              │
│  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐       │
│  │ 系统 TTS    │ │ sherpa-onnx │ │ 商业 API     │       │
│  │ (flutter_tts)│ │ (离线高质量) │ │ (用户自带Key)│       │
│  └──────┬──────┘ └──────┬──────┘ └──────┬───────┘       │
│         │               │               │               │
│         ▼               ▼               ▼               │
│  ┌──────────────────────────────────────────────┐       │
│  │        App 端 TTS 统一接口（本地播放）          │       │
│  └──────────────────────────────────────────────┘       │
│                         │                               │
│              ┌──────────┴──────────┐                    │
│              │ Server TTS（可选）   │                    │
│              │ 后台生成整本有声书   │                    │
│              └──────────┬──────────┘                    │
└─────────────────────────┼───────────────────────────────┘
                          │ HTTP（OpenAI 兼容 API）
┌─────────────────────────┼───────────────────────────────┐
│              Omnigram Server + Sidecar TTS               │
│                                                         │
│  ┌──────────────┐    ┌──────────────┐                   │
│  │ omni-server  │───▶│ TTS Sidecar  │                   │
│  │   (Go)       │HTTP│ (Docker)     │                   │
│  │              │    │              │                   │
│  │ TTSManager   │    │ Kokoro       │ ← CPU/GPU 均可    │
│  │  ├ Primary   │    │   或         │                   │
│  │  └ Fallback  │    │ IndexTTS-2   │ ← GPU（待评估）    │
│  │              │    │              │                   │
│  │ EdgeTTS      │    └──────────────┘                   │
│  │ (内置fallback)│                                      │
│  └──────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

**核心理念：**
- App 端负责「实时朗读」（翻页即读）——用户按需下载模型到手机
- Server 端负责「后台生成有声书」（按章节生成 MP3）——Sidecar 容器部署
- 用户可选择任意组合，不强制绑定
- **废弃 Fish Speech**：gRPC 集成维护成本高且有连接泄漏等 bug，Sidecar + OpenAI 兼容 API 更通用

---

## 二、关键决策

### 废弃 Fish Speech，统一 Sidecar 方案

| 对比 | Fish Speech（旧） | Sidecar（新） |
|------|-------------------|--------------|
| 协议 | gRPC（定制） | HTTP OpenAI 兼容 `/v1/audio/speech` |
| 集成 | 需要 proto 编译 + Go gRPC 客户端 | 标准 HTTP POST，几行代码 |
| 切换引擎 | 改代码 | 换 Docker 镜像 |
| 社区 | Fish Speech 专用 | 所有 OpenAI 兼容 TTS 通用 |
| 维护 | 连接泄漏等 bug（008 审计） | 容器隔离，重启即恢复 |

### Server 端引擎选型（按场景）

| 场景 | 引擎 | Docker 镜像 | 硬件 | 说明 |
|------|------|------------|------|------|
| **A. 默认推荐** | **Kokoro** | `ghcr.io/remsky/kokoro-fastapi` | CPU 即可，GPU 加速 | 82M 参数，CPU/GPU 双模式，OpenAI 兼容 API |
| **B. 最高质量有声书** | **IndexTTS-2** | ⚠️ 待评估（需 POC 验证） | GPU 8GB+ | 精确时长控制 + 情感表达，Apache 2.0 |
| **C. 零成本 fallback** | **Edge TTS** | 无需容器 | 无 | Go 直接调用，⚠️ 非官方 API，无 SLA，可能被限流 |
| **D. 高质量候选** | **Parler-TTS / Orpheus / Dia** | 待评估 | GPU | 与 IndexTTS-2 做 A/B 评估后择优 |

> **注意：** IndexTTS-2 目前没有现成的 OpenAI 兼容 API Docker 镜像，需自行包装 FastAPI + Dockerfile。在 Phase 2 启动前必须完成 POC 验证。Phase 1 的 GPU 用户先用 Kokoro GPU 模式（Kokoro-FastAPI 同时支持 CPU 和 GPU）。

### App 端引擎选型（用户按需下载）

| 引擎 | 模型大小 | 手机性能 | 质量 | 许可证 | 适合场景 |
|------|---------|---------|------|--------|---------|
| **flutter_tts**（系统引擎） | 0MB（已安装） | 实时 | ⭐⭐⭐ | — | 默认选项，零配置 |
| **Piper (VITS)** | 15-60MB | 实时（RTF < 0.5） | ⭐⭐⭐⭐ | MIT | 快速朗读，翻页即读 |
| **Kokoro** | ~300MB（q8 ~80MB） | 10秒语音≈8秒生成 | ⭐⭐⭐⭐⭐ | Apache 2.0 | 最高质量，适合预生成 |
| **MeloTTS** | ~100MB | 接近实时 | ⭐⭐⭐⭐ | MIT | 中文支持好、模型较小（⚠️ sherpa-onnx 兼容性需预研验证） |
| **Edge TTS** | 0MB | 取决于网络 | ⭐⭐⭐⭐ | ⚠️ 非官方免费 API | 零下载零配置，需联网 |
| **OpenAI TTS**（用户自带 Key） | 0MB | 取决于网络 | ⭐⭐⭐⭐⭐ | 商用 | 愿意花钱要最好质量 |
| **ElevenLabs**（用户自带 Key） | 0MB | 取决于网络 | ⭐⭐⭐⭐⭐ | 商用 | 声音克隆需求 |
| **Azure Speech**（用户自带 Key） | 0MB | 取决于网络 | ⭐⭐⭐⭐ | 商用 | 最便宜的商业选项 |
| **Omnigram Server** | 0MB | 取决于网络 | 取决于 Server 配置 | — | 有 NAS 的用户 |

---

## 三、Server 端部署方案（Sidecar）

### docker-compose.yml 示例

```yaml
version: '3'
services:
  omnigram-server:
    image: lxpio/omnigram-server:latest
    ports:
      - "8080:80"
    volumes:
      - ./books:/docs
      - ./data:/metadata
    environment:
      TTS_PROVIDER: kokoro                    # kokoro | edge | openai
      TTS_SIDECAR_URL: http://tts:8880        # Sidecar 容器地址
      TTS_TIMEOUT: 120s                       # 合成超时
      # TTS_OPENAI_API_KEY: sk-xxx            # 如果用 OpenAI TTS 代理
    depends_on:
      tts:
        condition: service_healthy

  # Kokoro（CPU/GPU 双模式，默认选择）
  tts:
    image: ghcr.io/remsky/kokoro-fastapi:latest
    # CPU 即可运行，有 GPU 加 deploy.resources
    # OpenAI 兼容 API: POST /v1/audio/speech
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8880/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s  # 模型加载需要 30-60 秒
    # 镜像大小：CPU ~5GB，GPU ~8-12GB，首次拉取需较长时间
```

### Go 端 TTS 架构

```go
// server/service/tts/provider.go
type TTSProvider interface {
    Name() string
    Synthesize(ctx context.Context, text string, opts SynthesisOptions) (io.ReadCloser, error)
    Voices() []Voice
    SupportsStreaming() bool
    HealthCheck(ctx context.Context) error
}

type SynthesisOptions struct {
    Voice      string
    Speed      float64
    Format     string // mp3, wav, ogg
    Language   string
    SampleRate int    // 44100 (默认)
    BitRate    int    // 128 (kbps, 默认)
    SSML       string // 可选，SSML 标记（预留，当前可不实现）
}

type Voice struct {
    ID       string
    Name     string
    Language string
    Gender   string
    Preview  string // 预览音频 URL
}

// server/service/tts/manager.go
// TTSManager 管理 Provider 生命周期、fallback 链、circuit breaker
type TTSManager struct {
    primary  TTSProvider       // 主引擎（Sidecar）
    fallback TTSProvider       // 降级引擎（Edge TTS）
    breaker  *CircuitBreaker   // 主引擎故障时自动切换到 fallback
    timeout  time.Duration     // 默认 120s
}

func (m *TTSManager) Synthesize(ctx context.Context, text string, opts SynthesisOptions) (io.ReadCloser, error) {
    ctx, cancel := context.WithTimeout(ctx, m.timeout)
    defer cancel()

    if m.breaker.Allow() {
        // 单次重试（仅对 timeout/connection refused，不重试 4xx/5xx）
        result, err := m.primary.Synthesize(ctx, text, opts)
        if err != nil && isRetryable(err) {
            result, err = m.primary.Synthesize(ctx, text, opts)
        }
        if err == nil {
            m.breaker.Success()
            return result, nil
        }
        m.breaker.Fail()
        log.W("primary TTS failed, falling back", zap.Error(err))
    }

    if m.fallback != nil {
        return m.fallback.Synthesize(ctx, text, opts)
    }
    return nil, fmt.Errorf("all TTS providers unavailable")
}

// server/service/tts/sidecar.go
// 通用 Sidecar Provider — 适用于所有 OpenAI 兼容的 TTS 容器
type SidecarProvider struct {
    name    string
    baseURL string
    client  *http.Client  // 设置 Timeout: 120s
}

func (p *SidecarProvider) Synthesize(ctx context.Context, text string, opts SynthesisOptions) (io.ReadCloser, error) {
    body := map[string]any{
        "model": p.name,
        "input": text,
        "voice": opts.Voice,
        "speed": opts.Speed,
        "response_format": opts.Format,
    }
    req, _ := http.NewRequestWithContext(ctx, "POST", p.baseURL+"/v1/audio/speech", toJSON(body))
    req.Header.Set("Content-Type", "application/json")
    resp, err := p.client.Do(req)
    if err != nil {
        return nil, err
    }
    if resp.StatusCode != 200 {
        resp.Body.Close()
        return nil, fmt.Errorf("TTS sidecar returned %d", resp.StatusCode)
    }
    return resp.Body, nil  // 调用方负责 Close()
}

// server/service/tts/edge.go
// Edge TTS Provider — 直接调用微软免费 API，无需 Sidecar
// ⚠️ 非官方 API，无 SLA，仅作为 fallback
type EdgeTTSProvider struct { ... }
```

### 有声书章节级生成流程

```
用户在 App/Web 点击「生成有声书」或点击某章的「听」按钮
→ Server 创建有声书任务（持久化到数据库）
→ 按章节拆分 → 创建章节级子任务

章节级生成：
→ 每章独立调用 TTSProvider.Synthesize()
→ 生成 MP3 存储到 /metadata/audiobooks/{book_id}/chapter_{n}.mp3
→ 每章完成后立即可播放（"边生成边听"）
→ 进度通过 SSE 推送到 App（"第 5/30 章已完成"）

三种生成模式：
1. 按需单章：用户点击某章的"听"按钮 → 优先生成该章
2. 后台全量：用户启动"生成有声书" → 逐章排队处理
3. 智能预生成：基于阅读进度，自动预生成后续 N 章

容错：
- 任务状态持久化到数据库（GORM task + chapter_task 两级）
- Sidecar 崩溃后从失败章节继续，已完成章节不重做
- 并发控制：默认 1 个合成任务并行（Sidecar 不支持高并发）
- 多用户公平调度：轮询调度，防止单用户独占资源

存储：
- 30 万字的书生成 MP3 约 500MB-1GB
- 逐章独立存储，支持单章删除/重新生成
- 可配置自动清理策略（如保留最近 N 本）

API:
POST /tts/audiobook/:book_id                创建有声书生成任务（全量或指定章节范围）
POST /tts/audiobook/:book_id/chapter/:idx   按需生成单章（优先级最高）
GET  /tts/tasks/:id                         查询任务进度
GET  /tts/tasks/:id/stream                  SSE 进度推送
GET  /tts/audiobook/:book_id                获取已生成的有声书（章节列表+状态）
GET  /tts/audiobook/:book_id/:chapter       下载/流式播放单章音频
DELETE /tts/audiobook/:book_id              删除已生成的有声书
```

**前置依赖：章节文本提取**
- 有声书生成的第一步是从电子书中提取每章纯文本
- EPUB：按 spine 顺序 + HTML 解析（相对简单）
- PDF：TOC 解析或 AI 推断章节边界（极其困难）
- **Phase 1 只支持 EPUB 有声书生成**，PDF 放后期

**长文本分片合成**
- TTS 引擎对单次输入有长度限制（Kokoro ~500 字符，OpenAI ~4096 字符）
- 一个章节可能 5000-10000 字，需要：文本 → 按句/段分割 → 逐片合成 → 拼接为章节 MP3
- 分片不能在句子中间切断，按句号/问号/感叹号分割

**音频后处理**
- 生成的 MP3 嵌入 ID3 标签（书名、作者、章节名、封面），导出到任何播放器都有完整元数据
- 可与 Audiobookshelf 联动：Omnigram 生成有声书 → 导出 → Audiobookshelf 管理播放

> **详细设计：** 有声书章节级生成的完整架构设计（任务队列、持久化、断点续传、并发控制、文本提取、分片策略、App 端播放器 UX）将在 015 文档中展开。

---

## 四、App 端实现方案

### 统一集成：sherpa-onnx Flutter 包

通过 [sherpa_onnx](https://pub.dev/packages/sherpa_onnx) 一个包集成开源模型（Piper/Kokoro），底层统一 ONNX Runtime 推理。

> **注意：** MeloTTS 的 sherpa-onnx 兼容性需先做预研验证，确认可行后再列入实施计划。

### 模型管理器

```
App 设置 → TTS 引擎
├── 📱 系统语音（默认，已安装，0MB）           [使用中 ✓]
├── ⬇️ Piper — 快速朗读（推荐）               15MB  [下载]  [🔊 试听]
├── ⬇️ Kokoro — 最高质量                     300MB  [下载]  [🔊 试听]
├── ⬇️ MeloTTS — 中文支持好                  100MB  [下载]  [🔊 试听]
├── 🌐 Edge TTS — 免费在线                     0MB   [启用]  ⚠️ 非官方API
├── 🔑 OpenAI TTS                                   [配置 API Key]
├── 🔑 ElevenLabs                                   [配置 API Key]
├── 🔑 Azure Speech                                 [配置 API Key]
└── 🖥️ Omnigram Server                              [已连接 ✓]
```

**模型管理功能：**
- 从远程 JSON 或 App 内置配置拉取可用模型列表
- **试听功能**：每个引擎预置 10 秒样本音频（嵌入 App 包内，< 1MB），下载前可试听
- **智能推荐**：根据设备性能/语言/网络状态自动高亮推荐引擎
- 用户点击下载 → 下载 ONNX 模型到本地沙盒
- **断点续传**：HTTP Range 请求，中断后从断点继续
- **完整性校验**：SHA-256 校验下载文件
- 用户随时切换、删除已下载模型释放空间
- **内存管理**：加载模型时检测可用内存，切换引擎时卸载上一个模型
- **低端设备降级**：低内存设备或电池 < 20% 时自动推荐 flutter_tts 或 Edge TTS

**中国大陆模型分发：**
- 优先级：(1) 自有 CDN/OSS 镜像 (2) hf-mirror.com fallback (3) HuggingFace 原始地址
- 模型列表 JSON 包含多个下载源，App 自动选择最快的

### API Key 安全存储

商业 API Key（OpenAI/ElevenLabs/Azure）必须安全存储：
- 使用 `flutter_secure_storage` 包（iOS Keychain / Android EncryptedSharedPreferences）
- **禁止**使用 SharedPreferences 明文存储
- Key 不上传到 Server，数据不出设备

### App 端代码架构

```dart
// app/lib/service/tts/tts_provider.dart
abstract class TTSProvider {
  String get name;
  String get displayName;
  bool get isAvailable;       // 模型是否已下载或 Key 已配置
  List<TTSVoice> get voices;
  Future<void> speak(String text, {String? voice, double? speed});
  Stream<Uint8List> synthesizeStream(String text, {String? voice}); // 流式合成
  Future<void> stop();
  Future<void> dispose();
}

class SystemTTSProvider extends TTSProvider { ... }      // flutter_tts
class SherpaOnnxProvider extends TTSProvider { ... }     // sherpa_onnx（Piper/Kokoro）
class EdgeTTSProvider extends TTSProvider { ... }        // 微软免费 API（⚠️ 非官方）
class OpenAITTSProvider extends TTSProvider { ... }      // 用户自带 Key，直连 API
class ElevenLabsTTSProvider extends TTSProvider { ... }  // 用户自带 Key
class AzureTTSProvider extends TTSProvider { ... }       // 用户自带 Key
class ServerTTSProvider extends TTSProvider { ... }      // 连接 Omnigram Server

// App 端 TTSManager — 管理 Provider 选择和自动 fallback
class TTSManager {
  TTSProvider _active;                    // 用户选择的引擎
  final SystemTTSProvider _fallback;      // 永远可用的 fallback

  Future<void> speak(String text, ...) async {
    try {
      await _active.speak(text, ...);
    } catch (e) {
      // 当前引擎不可用（模型损坏/内存不足/网络错误），自动降级
      await _fallback.speak(text, ...);
    }
  }

  // 删除模型时：如果正在使用，先切换到 fallback 再删除
  Future<void> deleteModel(String modelId) async { ... }
}
```

### Piper 模型精选

Piper 有 40+ 语言、数百个模型。App 端不展示全部，而是按语言筛选后推荐精选模型（每种语言 1-2 个最佳），减少用户决策负担。

### 多语言混合文本处理（预留）

中文书夹杂英文段落、英文书引用法语——单一引擎处理混合语言效果不佳。预留扩展点：
- 文本预处理管线：语言检测 → 按语言分段 → 选择对应引擎/音色 → 合成 → 拼接
- Phase 1 暂不实现，Kokoro 本身支持 8 语言可初步覆盖

### 基于 Anx Reader 现有能力

Anx Reader 已有完整 TTS 功能（多音色、语速、定时停止）。Fork 后在其基础上：
1. 添加 Provider 选择器层
2. 添加模型下载管理器
3. 不需要重写 TTS 播放逻辑和 UI

---

## 五、风险与合规

### Edge TTS 风险

⚠️ 微软 Edge TTS 免费 API 是浏览器嵌入式服务，第三方应用调用可能违反其服务条款。历史上曾多次限流/更改端点，无 SLA 保障。

**处理方式：**
- 仅作为 fallback，不推荐为主力引擎
- App 端在 Edge TTS 选项旁标注"非官方 API，可能随时失效"
- 建议有预算的用户使用 Azure Speech 免费额度（50 万字符/月）替代

### 版权合规

电子书 → 有声书涉及版权法"衍生作品"条款。自托管场景下用户对自购书籍做个人使用的 TTS 生成，在多数法域属于合理使用（fair use / private use）。

**处理方式：**
- App UI 和 Server 文档中增加免责声明："TTS 功能仅供个人合法使用。用户应确保对源书籍拥有合法访问权，并对生成内容的合规性自行负责。"
- 不提供生成有声书的公开分享功能

### 数据持久化

有声书音频存储在 `/metadata/audiobooks/`，通过 Docker volume `./data:/metadata` 持久化。升级/迁移 Docker 时此目录不可丢失。文档和部署指南中需显式提醒。

### Sidecar 镜像大小

Kokoro-FastAPI Docker 镜像：CPU 版 ~5GB，GPU 版 ~8-12GB。首次拉取耗时较长，用户需有心理预期。可考虑提供国内镜像加速。

### 模型训练数据合规

模型代码许可证（Apache 2.0 / MIT）≠ 训练数据许可。声音克隆类模型（如 IndexTTS）用户上传他人声音做克隆可能涉及声音权（voice rights）。文档和 UI 中应提示用户仅使用自己的声音或授权声音。

---

## 六、废弃项

| 废弃内容 | 理由 | 处理方式 | 时间 |
|---------|------|---------|------|
| `fishtts/` 目录 | Fish Speech gRPC 集成废弃 | 删除 | Phase 1 第一个 PR |
| `server/service/m4t/` | Fish Speech handler/setup | 删除（用 `service/tts/` 替代） | Phase 1 第一个 PR |
| Fish Speech Docker 镜像 | 不再需要 | 从 docker-compose 移除 | Phase 1 第一个 PR |
| gRPC proto 文件 | 不再需要 | 删除 | Phase 1 第一个 PR |
| README.md 中 Fish Speech 引用 | 与新架构不一致 | 更新为 Kokoro/多引擎描述 | Phase 1 第一个 PR |
| 012 文档中 m4t 模块引用 | 与新架构不一致 | 更新为 tts 模块 | 同步更新 |

---

## 七、实施优先级

```
Phase 1（v0.1）：
├── 废弃 Fish Speech：删除 fishtts/、m4t/、proto、更新 README 和 012 文档
├── Server: TTSProvider 接口 + TTSManager（含 fallback + circuit breaker）
├── Server: SidecarProvider 实现（Kokoro-FastAPI，CPU/GPU 双模式）
├── Server: EdgeTTSProvider 实现（内置 fallback）
├── Server: docker-compose.yml 加可选 tts sidecar（含 healthcheck）
├── App: flutter_tts（已有，默认）
└── App: Edge TTS Provider

Phase 2（v0.2）：
├── Server: 有声书章节级生成任务队列（详见 015 文档）
│   └── 含 EPUB 章节文本提取、长文本分片、ID3 标签嵌入
├── Server: IndexTTS-2 POC 评估（验证 Docker 镜像 + OpenAI 兼容 API）
│   ├── 同时评估 Parler-TTS / Orpheus / Dia 作为候选
│   └── 评估标准：中英文各 10 段 MOS 评分、单章耗时、镜像大小、API 兼容性、许可证
├── App: sherpa-onnx 集成 + 模型管理器（试听、智能推荐、断点续传）
├── App: Piper（精选模型）+ Kokoro 模型下载
│   └── Kokoro q8 vs fp16 质量对比实测，确认量化是否可接受
├── App: TTSManager（Provider fallback + 模型删除保护）
└── App: flutter_secure_storage 存储 API Key

Phase 3（v0.3）：
├── Server: 最高质量引擎上线（IndexTTS-2 或 POC 胜出的候选）
├── Server: OpenAI TTS 代理
├── App: 商业 API 直连（OpenAI/ElevenLabs/Azure）
├── App: MeloTTS 模型（sherpa-onnx 兼容性验证通过后）
└── App: Server TTS 连接
```

---

## 八、关键技术参考

### Server 端 Docker 镜像

| 项目 | 说明 |
|------|------|
| [Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI) | Kokoro Docker + OpenAI 兼容 API，CPU/GPU 双模式 |
| [kokoro-web](https://github.com/eduardolat/kokoro-web) | Kokoro + Web UI + OpenAI 兼容 API |
| [kokoro-tts](https://github.com/neosun100/kokoro-tts) | All-in-One Docker（Web UI + REST + WebSocket） |
| [IndexTTS-2](https://github.com/indexteam/IndexTTS) | 时长控制 + 情感表达（⚠️ 需自行包装 API Server） |

### 评估结论（详见 015-tts-model-evaluation.md）

| 模型 | 推荐 | 说明 |
|------|------|------|
| [Qwen3-TTS 1.7B](https://github.com/QwenLM/Qwen3-TTS) | 🥇 **GPU 有声书首选** | 中文最强（含方言）、10 语言、97ms 延迟、现成 Docker + OpenAI API |
| [Chatterbox Turbo](https://github.com/resemble-ai/chatterbox) | 🥈 **轻量 GPU 首选** | 盲测胜 ElevenLabs、仅 4GB VRAM、23 语言、MIT 许可 |
| [Orpheus 3B](https://github.com/canopyai/Orpheus-TTS) | 🥉 全能型备选 | 中英文都好、情感标签、Docker 成熟 |
| IndexTTS-2 | 后备 | 质量好但无现成 Docker/API 镜像，待生态成熟 |
| ~~Parler-TTS~~ | ❌ 淘汰 | 不支持中文 + 无声音克隆 + 无 Docker 生态 |
| ~~Dia 1.6B~~ | ❌ 淘汰 | 仅英文，场景太窄 |

### App 端

| 项目 | 说明 |
|------|------|
| [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) | 统一推理框架，5 个模型族，80+ 语言 |
| [sherpa_onnx Flutter](https://pub.dev/packages/sherpa_onnx) | Flutter 包，已有 TTS 示例 |
| [flutter_tts](https://pub.dev/packages/flutter_tts) | 系统 TTS 引擎 |
| [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) | API Key 安全存储（Keychain/Keystore） |
| [Kokoro ONNX 模型](https://huggingface.co/onnx-community/Kokoro-82M-v1.0-ONNX) | fp16/q8/q4 量化 |

### 开源 TTS 模型

| 模型 | GitHub | 许可证 | 说明 |
|------|--------|--------|------|
| Kokoro 82M | [hexgrad/kokoro](https://github.com/hexgrad/kokoro) | Apache 2.0 | CPU 可跑，8 语言 54 音色 |
| IndexTTS-2 | [indexteam/IndexTTS](https://github.com/indexteam/IndexTTS) | Apache 2.0 | 时长控制，情感表达 |
| Piper | [rhasspy/piper](https://github.com/rhasspy/piper) | MIT | 15-60MB，40+ 语言 |
| MeloTTS | [myshell-ai/MeloTTS](https://github.com/myshell-ai/MeloTTS) | MIT | 中文支持好，模型较小 |
