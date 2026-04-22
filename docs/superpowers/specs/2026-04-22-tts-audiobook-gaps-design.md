# TTS 完整链路缺口修复（Sprint 6）

> **日期：** 2026-04-22
> **状态：** Approved
> **背景：** `docs/superpowers/PROGRESS.md` 未追踪 server 端 audiobook 功能；代码走查发现 3 个缺口

---

## 1. 背景

审阅 server 端 `service/tts/` 与客户端 `service/api/tts_api.dart` 时发现：

- **Server 已实现整套 audiobook 生成 pipeline**（任务队列、章节切分、SSE 进度流、存储、下载、删除）
- **客户端已有对应 API 方法**但**零 UI 引用**——用户看不到入口
- Docker 镜像缺 `ffmpeg`，章节静音裁剪 / LUFS 归一 / ID3 标签全部 no-op
- SidecarProvider 的 voice 列表硬编码 3 个英文声音，Kokoro/Qwen3 的中文声音无法被客户端拉到

这三项共同把一个**已经完工的服务端功能**变成了**用户用不上**的状态。

## 2. 目标

1. 把 server audiobook 生成功能完整推到用户手里（客户端 UI + 下载管理）
2. 让 Docker 部署默认拥有完整 TTS 后处理能力
3. 让客户端能看到 sidecar 实际支持的所有声音
4. 在 PROGRESS.md 补登记已完成的 server 侧能力

## 3. 非目标

- 不新增 TTS 引擎（Kokoro/Qwen3/Edge/OpenAI/sherpa 已足够）
- 不做「有声书分享 / 播客流」（超出个人使用场景）
- 不做 audiobook 跨设备同步（走 server 下载即可，数据不在客户端长期存储）

## 4. 设计

### 4.1 Gap A：Server Dockerfile 补 ffmpeg

**文件：** `server/Dockerfile:40-52`

最终镜像基于 `alpine:3.23.3`，在非 root user 创建前 `apk add ffmpeg` 即可。Alpine 的 ffmpeg 包约 30 MB。

```dockerfile
FROM alpine:3.23.3
...
RUN apk add --no-cache ffmpeg && \
    addgroup -g 1000 omnigram && adduser ...
```

启动日志应从 `ffmpeg not found, audio post-processing disabled` 变为 `ffmpeg found at /usr/bin/ffmpeg, audio post-processing enabled`。

**验证：** 构建镜像、启动、观察日志；用 Hurl 生成一个章节有声书，检查输出 MP3 有 ID3 tag（`ffprobe` 可见 title/artist/album）。

### 4.2 Gap B：SidecarProvider 动态查询 voices

**文件：** `server/service/tts/sidecar.go`

Kokoro FastAPI 和 Qwen3-TTS 都暴露 OpenAI 兼容的 `GET /v1/voices`，返回 JSON 列表。方案：

1. `SidecarProvider` 新增 `voicesCache []Voice` + `voicesCacheExpiry time.Time`（TTL 5 分钟，避免每次 `/tts/voices` 都打 sidecar）
2. `Voices()` 懒加载：cache 未过期直接返回；否则 HTTP GET `{baseURL}/v1/voices`，失败时 fallback 到旧的 3 个硬编码声音（保证不 break）
3. 失败回退同时记一条 Warn，不让用户感知到失败（但我们能从日志发现）

响应格式（OpenAI 兼容）：
```json
{"data": [{"id": "af_heart", "name": "Heart", ...}, ...]}
```

部分 sidecar（Qwen3）可能返回自定义字段（language / gender），解析尽量容错：缺字段用空串。

**验证：** Qwen3 起来后访问 `http://server/tts/voices`，应该返回 ≥10 个声音，含中文。

### 4.3 Gap C：客户端有声书 UI

**位置：** 书籍详情页 `page/book_detail.dart`

#### 4.3.1 入口

在书籍详情页「操作区」（目前是阅读 / 收藏 / ... 那一排）新增按钮：

- 未生成：**🎧 生成有声书**
- 生成中：**🎧 正在生成 42%**（带进度环）
- 已完成：**🎧 有声书**（点击打开 audiobook 播放页）

状态判断流程：进入详情页时静默调用 `ttsApi.getAudiobook(bookId)`；404 = 未生成，其他状态字段决定展示。

#### 4.3.2 生成流程

点击「生成有声书」后：

1. 弹 BottomSheet 确认：展示预计章节数、使用的 TTS 声音（当前 companion voice）、预计时长（按章节数 × 2 分钟粗估）
2. 用户确认后 → `ttsApi.createAudiobook(bookId)` → 得到 `taskId`
3. 按钮立即变「正在生成」状态
4. 打开 SSE 连接 `/tts/tasks/:id/stream`，实时更新章节完成数 / 总数
5. 全部完成后按钮变「有声书」

**降级：** 没配置 sidecar 时，server 会用 Edge TTS；提示用户首句较慢是正常的。Server 未连接时按钮灰掉 + tooltip「需要连接服务器」。

#### 4.3.3 Audiobook 播放页

简单实现（不做完整播放器）：

- 章节列表：每章显示标题、时长、下载状态
- 每章右侧：**试听** / **下载** 按钮
- 下载到客户端本地后，由系统播放器打开（Android: `file://` + `MediaStore` / iOS: `url_launcher` + `UIDocumentInteractionController`）
- 不做 app 内播放器（复杂度高，章节级外部播放满足 90% 需求）

#### 4.3.4 删除

书籍详情 → 菜单 → 「删除有声书」→ 确认 → `ttsApi.deleteAudiobook(bookId)`。

## 5. 风险

| 风险 | 缓解 |
|------|------|
| 生成慢用户关 app | SSE 断开后重连；任务在 server 继续跑 |
| 大书章节多 → 存储爆炸 | Server 已存在 `/metadata/audiobooks/{bookId}` 目录，每本约 50–200 MB。后续再加清理策略 |
| Edge TTS 被限流 | 已有 fallback，但现在批量合成容易触发；提示用户用本地 sidecar |
| ffmpeg 增大镜像体积 | 仅 ~30 MB，可接受 |

## 6. 设计锚点与取舍

- **为什么不做 app 内播放器**：播放器本身是个产品，节点多（章节切换、后台播放、锁屏控件、速度调节、书签）。外部播放器方案先跑通，有用户反馈后再做。
- **为什么 voices 加缓存**：客户端打开设置页会频繁拉；sidecar 本身加载 voice 列表也不便宜。5 分钟 TTL 够了。
- **为什么 ffmpeg 不做成可选**：一次性 30 MB 换掉体验降级，不值得做开关。

## 7. 成功标准

- Docker 镜像启动日志不再出现 `ffmpeg not found`
- `/tts/voices` 返回 Kokoro/Qwen3 sidecar 的完整声音列表
- 书籍详情页有「生成有声书」入口，生成后可下载章节音频、用外部播放器播放
- PROGRESS.md 登记 audiobook server 功能（追溯）+ 本 Sprint 的 3 项修复
