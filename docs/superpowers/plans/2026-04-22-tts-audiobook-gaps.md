# TTS 完整链路缺口修复 — 实施计划

> **Spec：** `docs/superpowers/specs/2026-04-22-tts-audiobook-gaps-design.md`
> **For agentic workers:** 使用 `superpowers:subagent-driven-development` 或 `superpowers:executing-plans` 逐任务执行。

**Goal:** 补齐 server 端 audiobook 功能到用户手里的最后一公里：Dockerfile 加 ffmpeg、sidecar 动态拉 voices、客户端加有声书 UI。

**Tech Stack:** Go（server）、Flutter + Riverpod（client）、Docker

---

## File Map

| Action | File | 职责 |
|--------|------|------|
| Modify | `server/Dockerfile` | 最终镜像 `apk add ffmpeg` |
| Modify | `server/service/tts/sidecar.go` | `Voices()` 改为查询 `/v1/voices` + 5 分钟缓存 + fallback |
| Modify | `server/service/tts/sidecar.go` (tests) | 新增 httptest 覆盖成功/失败路径 |
| Create | `app/lib/page/book_detail/audiobook_button.dart` | 生成/进度/打开按钮 |
| Create | `app/lib/providers/audiobook_provider.dart` | Riverpod 状态：任务查询 + SSE 订阅 |
| Create | `app/lib/page/audiobook/audiobook_page.dart` | 章节列表 + 下载 + 外部播放 |
| Modify | `app/lib/page/book_detail.dart` | 操作区加 `AudiobookButton` |
| Modify | `app/lib/service/api/tts_api.dart` | 如缺 SSE stream 方法则补 |
| Modify | `app/lib/l10n/app_en.arb` + `app_zh-CN.arb` | 新 L10n keys |
| Modify | `docs/superpowers/PROGRESS.md` | 追加登记 |
| Modify | `site/src/content/docs/{,zh/}getting-started/tts-setup.md` | 修掉「Sprint 4 roadmap」错话 |

---

### Task 1: Server Dockerfile 加 ffmpeg

**文件：** `server/Dockerfile`

- [ ] **Step 1: 改 Dockerfile**

在最终 `FROM alpine:3.23.3` 的 stage（第 40 行之后）新增一步：

```dockerfile
RUN apk add --no-cache ffmpeg
```

位置建议放在 `addgroup` 前面（和 `mkdir` 同层），避免 layer 缓存失效。

- [ ] **Step 2: 本地构建 + 验证**

```bash
cd server
docker build -t omnigram-server:ffmpeg-test .
docker run --rm omnigram-server:ffmpeg-test ffmpeg -version | head -1
```

期望：输出 `ffmpeg version ...`，而不是 command not found。

- [ ] **Step 3: 启动日志验证**

```bash
docker run --rm -e OMNI_USER=admin -e OMNI_PASSWORD=admin omnigram-server:ffmpeg-test 2>&1 | grep -i ffmpeg
```

期望日志出现：`TTS: ffmpeg found at /usr/bin/ffmpeg, audio post-processing enabled`。

- [ ] **Step 4: Commit**

```bash
git add server/Dockerfile
git commit -m "build(server): bundle ffmpeg in docker image for TTS post-processing"
```

---

### Task 2: SidecarProvider 动态 voices

**文件：** `server/service/tts/sidecar.go`

- [ ] **Step 1: 新增 cache 字段**

给 `SidecarProvider` struct 添加：

```go
type SidecarProvider struct {
    // existing fields...
    voicesMu     sync.RWMutex
    voicesCache  []Voice
    voicesExpiry time.Time
}
```

- [ ] **Step 2: 实现动态 `Voices()`**

替换 `sidecar.go:80-87` 的硬编码实现：

```go
func (p *SidecarProvider) Voices() []Voice {
    p.voicesMu.RLock()
    if time.Now().Before(p.voicesExpiry) && len(p.voicesCache) > 0 {
        voices := p.voicesCache
        p.voicesMu.RUnlock()
        return voices
    }
    p.voicesMu.RUnlock()

    // Try to fetch from sidecar
    fetched, err := p.fetchVoices()
    if err != nil || len(fetched) == 0 {
        log.W("TTS: sidecar voices fetch failed, using fallback: " + fmtErr(err))
        return fallbackVoices
    }

    p.voicesMu.Lock()
    p.voicesCache = fetched
    p.voicesExpiry = time.Now().Add(5 * time.Minute)
    p.voicesMu.Unlock()
    return fetched
}

func (p *SidecarProvider) fetchVoices() ([]Voice, error) {
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()
    req, err := http.NewRequestWithContext(ctx, "GET", p.baseURL+"/v1/voices", nil)
    if err != nil { return nil, err }
    if p.apiKey != "" { req.Header.Set("Authorization", "Bearer "+p.apiKey) }
    resp, err := p.client.Do(req)
    if err != nil { return nil, err }
    defer resp.Body.Close()
    if resp.StatusCode != http.StatusOK {
        return nil, fmt.Errorf("voices endpoint returned %d", resp.StatusCode)
    }
    var payload struct {
        Data []struct {
            ID       string `json:"id"`
            Name     string `json:"name"`
            Language string `json:"language"`
            Gender   string `json:"gender"`
        } `json:"data"`
    }
    if err := json.NewDecoder(resp.Body).Decode(&payload); err != nil {
        return nil, err
    }
    voices := make([]Voice, 0, len(payload.Data))
    for _, v := range payload.Data {
        name := v.Name
        if name == "" { name = v.ID }
        voices = append(voices, Voice{ID: v.ID, Name: name, Language: v.Language, Gender: v.Gender})
    }
    return voices, nil
}

var fallbackVoices = []Voice{
    {ID: "af_heart", Name: "Heart", Language: "en", Gender: "female"},
    {ID: "af_star", Name: "Star", Language: "en", Gender: "female"},
    {ID: "am_adam", Name: "Adam", Language: "en", Gender: "male"},
}
```

- [ ] **Step 3: httptest 覆盖**

新建 `server/service/tts/sidecar_test.go`：

```go
func TestSidecarProvider_Voices_Fetch(t *testing.T) {
    // mock 返回 {"data": [...]}，断言 Voices() 返回列表 + 命中 cache
}
func TestSidecarProvider_Voices_Fallback(t *testing.T) {
    // mock 返回 500，断言 Voices() 回退到 fallback，不 panic
}
```

- [ ] **Step 4: Verify**

```bash
cd server && go test ./service/tts/... -run TestSidecarProvider
```

- [ ] **Step 5: Commit**

```bash
git add server/service/tts/sidecar.go server/service/tts/sidecar_test.go
git commit -m "feat(tts): query sidecar /v1/voices dynamically with 5min cache + fallback"
```

---

### Task 3: 客户端 AudiobookProvider + API 补齐

**文件：**
- `app/lib/providers/audiobook_provider.dart`（新建）
- `app/lib/service/api/tts_api.dart`（如缺 SSE 流方法则补）

- [ ] **Step 1: 核对 `tts_api.dart` 是否有 SSE stream 方法**

```bash
grep -n 'streamTask\|/tts/tasks/.*stream' app/lib/service/api/tts_api.dart
```

如无，添加：

```dart
Stream<ServerAudiobookTask> streamTask(String taskId) {
  return _api.stream(
    '/tts/tasks/$taskId/stream',
    fromJson: (data) => ServerAudiobookTask.fromJson(data),
  );
}
```

如果 `OmnigramApi` 没有 `stream()` 方法，改用 `Dio` + `ResponseType.stream` 自己解析 `data: {...}\n\n`。

- [ ] **Step 2: AudiobookProvider**

```dart
@riverpod
class AudiobookNotifier extends _$AudiobookNotifier {
  @override
  Future<ServerAudiobookTask?> build(String bookId) async {
    try {
      return await ref.read(ttsApiProvider).getAudiobook(bookId);
    } catch (e) {
      return null; // 404 = 未生成
    }
  }

  Future<void> generate() async {
    final task = await ref.read(ttsApiProvider).createAudiobook(bookId);
    state = AsyncData(task);
    _listenStream(task.id);
  }

  Future<void> delete() async {
    await ref.read(ttsApiProvider).deleteAudiobook(bookId);
    state = const AsyncData(null);
  }

  void _listenStream(String taskId) {
    ref.read(ttsApiProvider).streamTask(taskId).listen((t) {
      state = AsyncData(t);
    }, onError: (_) {/* 打印日志，不 break UI */});
  }
}
```

- [ ] **Step 3: codegen + analyze**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
flutter analyze lib/providers/audiobook_provider.dart
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/providers/audiobook_provider.dart app/lib/service/api/tts_api.dart
git commit -m "feat(app): add audiobook provider with task status + SSE stream"
```

---

### Task 4: AudiobookButton 组件

**文件：** `app/lib/page/book_detail/audiobook_button.dart`（新建）

- [ ] **Step 1: 三态按钮**

- `null` / 404 → 🎧 「生成有声书」
- `running` / `pending` → 🎧 + 进度环 + 「生成中 x%」
- `completed` → 🎧 「打开有声书」

点击未生成时弹 BottomSheet 确认（展示章节数 + 当前 companion voice + 预估时长），点击完成后 push `AudiobookPage`。

- [ ] **Step 2: L10n keys**

添加到 `app_en.arb` / `app_zh-CN.arb`：

```json
"audiobookGenerate": "Generate audiobook",
"audiobookGenerating": "Generating {percent}%",
"audiobookOpen": "Open audiobook",
"audiobookConfirmTitle": "Generate audiobook?",
"audiobookConfirmBody": "{chapters} chapters · voice: {voice} · ~{minutes} min",
"audiobookGenerate.confirm": "Start",
"audiobookNeedsServer": "Connect to a server to generate audiobooks"
```

（中文对应翻译）

- [ ] **Step 3: 集成到 book_detail.dart**

在操作区（阅读按钮附近）加 `AudiobookButton(bookId: book.id)`。Server 未连接时按钮灰掉 + tooltip `audiobookNeedsServer`。

- [ ] **Step 4: Verify + Commit**

```bash
cd app && flutter gen-l10n && flutter analyze lib/
git add app/lib/page/book_detail/audiobook_button.dart app/lib/page/book_detail.dart app/lib/l10n/
git commit -m "feat(app): audiobook generate button with progress in book detail"
```

---

### Task 5: AudiobookPage（章节列表 + 外部播放）

**文件：** `app/lib/page/audiobook/audiobook_page.dart`（新建）

- [ ] **Step 1: 章节列表**

`ListView.builder` 展示章节标题 / 时长 / 下载状态。每行右侧有「试听」「下载」按钮。

- [ ] **Step 2: 下载 + 外部打开**

调用 `ttsApiProvider.downloadChapter(bookId, chapterIdx, savePath)`，save 到 `getApplicationDocumentsDirectory()/audiobooks/{bookId}/{idx}.mp3`。下载完成用 `open_filex` package（或 url_launcher）打开。

- [ ] **Step 3: 删除按钮**

页面 AppBar 右侧菜单加「删除有声书」。

- [ ] **Step 4: Commit**

```bash
git add app/lib/page/audiobook/
git commit -m "feat(app): audiobook page with chapter download and external player"
```

---

### Task 6: 修正文档 + PROGRESS

**文件：**
- `site/src/content/docs/zh/getting-started/tts-setup.md`
- `site/src/content/docs/getting-started/tts-setup.md`
- `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: 改 tts-setup.md（中英）**

把「Sprint 4 roadmap 里，关注 CHANGELOG」那段改成：

> 有声书导出（整本合成成 MP3 下载到本地），在书籍详情页点**生成有声书**即可。详见客户端 Sprint 6 更新。

- [ ] **Step 2: 补 PROGRESS.md**

在 Layer 4 Phase 1 末尾 或 新建 Sprint 6 段落，登记：

```markdown
## Sprint 6 — TTS 完整链路 ✅

| 功能 | 状态 | 关键文件 | 提交 |
|------|------|----------|------|
| **Server 端有声书生成（追溯登记）** | ✅ | `server/service/tts/{audiobook_handler,worker,epub_extractor,text_chunker,audio_processor}.go` | `<hash>` |
| **Server Docker 打包 ffmpeg** | ✅ | `server/Dockerfile` | `<hash>` |
| **SidecarProvider 动态 voices** | ✅ | `server/service/tts/sidecar.go` | `<hash>` |
| **客户端有声书 UI** | ✅ | `app/lib/page/book_detail/audiobook_button.dart`, `app/lib/page/audiobook/audiobook_page.dart`, `app/lib/providers/audiobook_provider.dart` | `<hash>` |
```

在「更新记录」顶部加一行：

```markdown
| 2026-04-22 | **Sprint 6 · TTS 完整链路** ✅：Docker 打包 ffmpeg（启用章节静音裁剪+LUFS 归一+ID3 标签）、SidecarProvider 动态拉 `/v1/voices`（5min 缓存+fallback）、客户端书籍详情页接入「生成有声书」+ 章节下载 + 外部播放。追溯登记 server 端 audiobook pipeline |
```

- [ ] **Step 3: Commit**

```bash
git add site/src/content/docs/ docs/superpowers/PROGRESS.md
git commit -m "docs: log Sprint 6 TTS completion and correct tts-setup roadmap line"
```

---

### Task 7: 端到端验证

- [ ] **Step 1: 构建新 server 镜像推到测试机**

```bash
make docker TAG=sprint6-test
# 部署到测试机，观察日志里 ffmpeg found
```

- [ ] **Step 2: 跑 hurl 冒烟**

- `GET /tts/voices`：Kokoro 起着时返回 ≥ 10 个声音（不是 3 个）
- `POST /tts/audiobook/{book_id}`：返回任务 ID
- `GET /tts/tasks/{id}`：任务状态能轮询到 `completed`
- `GET /tts/audiobook/{book_id}/{chapter}`：下载到 mp3，`ffprobe` 看得到 ID3 title

- [ ] **Step 3: 客户端手动验证**

- 详情页点生成 → 看进度 → 完成后下载章节 → 外部播放器播出
- 断开 server 连接 → 按钮灰掉 + tooltip

- [ ] **Step 4: 最终 commit（如还有 fixup）**

```bash
git commit -am "test: sprint6 e2e verified on staging"
```
