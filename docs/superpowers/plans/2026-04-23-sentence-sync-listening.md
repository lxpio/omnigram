# 句级同步听书 — 实施计划

> **Spec：** `docs/superpowers/specs/2026-04-23-sentence-sync-listening-design.md`
> **For agentic workers:** 使用 `superpowers:executing-plans`，按 Phase 顺序执行，每个 Task 完成后在 conversation 里报进度。

**Goal：** 把 Sprint 6 落地的"整章 MP3 下载"升级为"Audible 级句级同步高亮"体验，三端（server / app / web admin）打通。

**Tech Stack：** Go（server 切句 + worker 改造）、Flutter + Riverpod（app 播放器 + 同步）、existing `foliate-js`（CFI 权威）、`just_audio` dart 包（native audio engine）

---

## File Map

| Action | File | 职责 |
|--------|------|------|
| New | `server/service/tts/sentence_splitter.go` | 纯函数切句 + 多语言标点规则 |
| Modify | `server/service/tts/epub_extractor.go` | 章级抽取改为返回 `Chapter{Sentences []Sentence}` |
| Modify | `server/service/tts/worker.go` | `processChapter` 改为按句合成 + 累计时间戳 + 写 align.json |
| New | `server/service/tts/alignment.go` | AlignmentFile schema + Save/Load |
| Modify | `server/service/tts/setup.go` + handler | 新增 `/tts/audiobook/:id/:chapter/alignment`、`/tts/audiobook/:id/index` 端点 |
| Modify | `server/service/tts/audiobook_handler.go` | 支持 POST body `sentences[]` 注入模式 |
| Modify | `server/schema/audiobook.go` | AudiobookTask 加 `has_alignment bool`、ChapterTask 加 `align_path` |
| New | `app/lib/models/server/alignment.dart` | freezed `SentenceAlignment` / `ChapterAlignment` |
| Modify | `app/lib/service/api/tts_api.dart` | `getAlignment()`, `getAudiobookIndex()` |
| New | `app/lib/service/audiobook/audiobook_player.dart` | just_audio 封装 |
| New | `app/lib/service/audiobook/sync_controller.dart` | 时间→句索引→CFI 匹配 |
| New | `app/lib/page/audiobook/sync_listening_page.dart` | EPUB + mini-player 合一页面 |
| Modify | `app/lib/widgets/book_detail/audiobook_button.dart` | 点击"打开"跳新页而非旧章节列表 |
| Modify | `app/lib/l10n/app_en.arb` + `app_zh-CN.arb` | player UI keys |
| New | `web/src/pages/admin/audiobook-queue.tsx` | 批量生成队列管理 |
| Modify | `server/service/admin/handler.go` | 批量触发 endpoint |

---

## Phase 1 · Server ExtractSentences（2 天）

**目标：** Go 侧可靠切句，为后续 worker 改造提供数据源。

### Task 1.1: sentence_splitter.go

- [ ] 新建 `server/service/tts/sentence_splitter.go`
- [ ] 实现 `SplitSentences(text string, lang string) []Sentence`，其中 `Sentence` 结构：
  ```go
  type Sentence struct {
      Text       string
      CharOffset int  // 起始字符在原文中的位置
  }
  ```
- [ ] 规则（见 spec §5.1）：
  - 按 `。！？…!?.` + 空白 / 换行切分
  - 引号括号内标点不切
  - 段落分隔 `\n\n` 强制切
  - <10 char 合并前句
  - \>200 char 按 `，;` 兜底切
- [ ] `lang` 参数暂时只用于在 `"en"` 时允许 `.` 作为强分隔（中文 `.` 常见于小数/缩写，避免误切）

### Task 1.2: sentence_splitter_test.go

- [ ] 中文用例：《一九六二年四月三日，余华出生于浙江省杭州市。出生时体重七斤三两。》→ 2 句
- [ ] 引号容错：`小明说"真的吗？"然后离开了。` → 1 句
- [ ] 长句切分：200+ char 连续中文 → 按逗号切
- [ ] 英文混合：`The year 2.5 times as long...` → `.` 在数字中不切
- [ ] 边界：空字符串、全空白、仅标点 → 返回 `[]`

### Task 1.3: epub_extractor 升级

- [ ] 修改 `Chapter` 结构：
  ```go
  type Chapter struct {
      Index     int
      Title     string
      Href      string
      Text      string
      Sentences []Sentence  // NEW
  }
  ```
- [ ] `ExtractChapters` 最后一步调 `SplitSentences(text, lang)` 填充
- [ ] 向后兼容：`Text` 字段保留（老代码还在用）

### Task 1.4: go test + commit

```bash
cd server && go test ./service/tts/... -count=1
git add server/service/tts/sentence_splitter.go server/service/tts/sentence_splitter_test.go server/service/tts/epub_extractor.go
git commit -m "feat(tts): multilingual sentence splitter for audiobook alignment"
```

---

## Phase 2 · Worker 逐句合成 + 时间戳（2 天）

**目标：** 每章产出 `chapter_NNN.mp3` + `chapter_NNN.align.json`。

### Task 2.1: alignment schema

- [ ] 新建 `server/service/tts/alignment.go`:
  ```go
  type ChapterAlignment struct {
      SchemaVersion   int                 `json:"schema_version"`
      ChapterIndex    int                 `json:"chapter_index"`
      ChapterTitle    string              `json:"chapter_title"`
      AudioFile       string              `json:"audio_file"`
      AudioDurationMs int64               `json:"audio_duration_ms"`
      Voice           string              `json:"voice"`
      Provider        string              `json:"provider"`
      GeneratedAt     int64               `json:"generated_at"`
      Sentences       []SentenceAlignment `json:"sentences"`
  }
  type SentenceAlignment struct {
      Index      int    `json:"index"`
      Text       string `json:"text"`
      StartMs    int64  `json:"start_ms"`
      EndMs      int64  `json:"end_ms"`
      CharOffset int    `json:"char_offset"`
  }

  func (a *ChapterAlignment) Save(path string) error { /* json + 0644 */ }
  ```

### Task 2.2: worker.processChapter 改造

- [ ] 从 `epubChapters[idx].Sentences` 拿句列表（替代旧的 `ChunkText`）
- [ ] 循环内：
  ```go
  cumulativeMs := int64(0)
  alignment := &ChapterAlignment{ Sentences: []SentenceAlignment{} }
  for i, sent := range sentences {
      // 合成单句到临时文件
      tmpPath := filepath.Join(storageDir, fmt.Sprintf("tmp_%03d_%04d.mp3", chapter.ChapterIndex, i))
      if err := synthToFile(sent.Text, tmpPath); err != nil { ... }

      // ffprobe 量时长
      durMs, err := probeDurationMs(tmpPath)

      alignment.Sentences = append(alignment.Sentences, SentenceAlignment{
          Index: i, Text: sent.Text,
          StartMs: cumulativeMs,
          EndMs: cumulativeMs + durMs,
          CharOffset: sent.CharOffset,
      })
      cumulativeMs += durMs

      // 追加到最终 chapter_NNN.mp3
      appendFile(tmpPath, finalMp3Path)
      os.Remove(tmpPath)
  }
  alignment.AudioDurationMs = cumulativeMs
  alignment.Save(filepath.Join(storageDir, fmt.Sprintf("chapter_%03d.align.json", chapter.ChapterIndex)))
  ```
- [ ] 保留已有 ffmpeg 后处理（LUFS + ID3），在所有句合成+拼接完后对整章 MP3 做一次
- [ ] 注意：拼接 MP3 不能简单 `cat`，需用 ffmpeg concat（MP3 帧边界），或用裸帧追加（首帧保留头，后续句去掉 ID3 头）。**推荐 ffmpeg concat + `-c copy`** 不重编码

### Task 2.3: probeDurationMs helper

- [ ] `server/service/tts/audio_processor.go` 加 `ProbeDurationMs(path string) (int64, error)`：
  ```go
  cmd := exec.Command("ffprobe", "-v", "quiet", "-show_entries", "format=duration",
      "-of", "default=nw=1:nk=1", path)
  ```

### Task 2.4: ChapterTask schema 加 align_path

- [ ] `schema/audiobook.go` ChapterTask 加 `AlignPath string \`json:"align_path" gorm:"type:varchar(500)"\``
- [ ] AutoMigrate 走已有机制

### Task 2.5: 并发与失败处理

- [ ] 单句合成失败：重试 2 次 → 仍失败则用 1 秒静音代替（`ffmpeg -f lavfi -i anullsrc=...`），记录 ErrorMessage，**整章不失败**
- [ ] 这是 ambient 可靠性原则：**partial 优于全失败**

### Task 2.6: verify + commit

```bash
cd server && go test ./service/tts/... -count=1
go build ./...
git add server/service/tts/{alignment.go,worker.go,audio_processor.go} server/schema/audiobook.go
git commit -m "feat(tts): per-sentence synthesis with alignment JSON and graceful chapter fallback"
```

---

## Phase 3 · Alignment 端点 + Swagger（1 天）

### Task 3.1: handler

- [ ] 新增 `getChapterAlignmentHandler` 在 `audiobook_handler.go`：
  ```go
  // @Summary Get chapter alignment data
  // @Tags TTS
  // @Security BearerAuth
  // @Param book_id path string true "Book ID"
  // @Param chapter path int true "Chapter index"
  // @Success 200 {object} ChapterAlignment
  // @Failure 404
  // @Router /tts/audiobook/{book_id}/{chapter}/alignment [get]
  func getChapterAlignmentHandler(c *gin.Context) { ... }
  ```
- [ ] 路径：`/tts/audiobook/:book_id/:chapter/alignment`
- [ ] 读 `chapter.AlignPath`，直接回 JSON（不 SUCCESS 包装——这是数据文件）

### Task 3.2: audiobook index

- [ ] `getAudiobookIndexHandler` 返回全书 `{book_id, chapters:[{index, title, audio_file, align_file, duration_ms, sentence_count}]}`
- [ ] 路径：`/tts/audiobook/:book_id/index`

### Task 3.3: POST body 支持 sentences 注入

- [ ] `createAudiobookRequest` 加可选字段：
  ```go
  type createAudiobookRequest struct {
      Voice    string         `json:"voice"`
      Speed    float64        `json:"speed"`
      Format   string         `json:"format"`
      // Sentences, if non-empty, overrides server's own sentence splitter.
      // Use case: client already has foliate-js authoritative sentences+CFI.
      Sentences []ClientSentence `json:"sentences"`
  }
  type ClientSentence struct {
      ChapterIndex int    `json:"chapter_index"`
      Index        int    `json:"index"`
      Text         string `json:"text"`
  }
  ```
- [ ] 如 `Sentences` 非空：worker 用这个列表而非自己切分，按 chapter 分组

### Task 3.4: swagger regen + commit

```bash
cd server && make swagger
git add server/service/tts/ server/docs/
git commit -m "feat(tts): alignment + index endpoints and client-sentences ingestion"
```

---

## Phase 4 · AudiobookPlayer 基础播放（2 天）

### Task 4.1: just_audio 依赖

- [ ] `pubspec.yaml` 加 `just_audio: ^0.10.0`
- [ ] `flutter pub get`

### Task 4.2: AudiobookPlayer 封装

- [ ] 新建 `app/lib/service/audiobook/audiobook_player.dart`：
  ```dart
  class AudiobookPlayer {
    final _player = AudioPlayer();
    Future<void> loadChapter(String path) async { ... }
    Future<void> play() / pause() / seek(Duration);
    Stream<Duration> get positionStream;
    Stream<PlayerState> get stateStream;
    Future<void> setSpeed(double rate);
    Future<void> dispose();
  }
  ```
- [ ] 处理 iOS background audio（Info.plist 配置 audio category）
- [ ] Android foreground service 配置放到 AndroidManifest.xml
- [ ] 错误处理：文件不存在、解码失败

### Task 4.3: 下载管理

- [ ] 沿用 Sprint 6 `tts_api.downloadChapter(bookId, chapterIdx, savePath)`
- [ ] 下载位置：`getApplicationDocumentsDirectory()/audiobooks/{bookId}/chapter_NNN.mp3`
- [ ] **新增**：同时下载 `.align.json` 到同目录

### Task 4.4: verify + commit

```bash
cd app && flutter analyze lib/service/audiobook/
git add app/lib/service/audiobook/ app/pubspec.yaml app/pubspec.lock
git commit -m "feat(app): AudiobookPlayer wrapper over just_audio with chapter download"
```

---

## Phase 5 · 同步高亮（3 天）

### Task 5.1: alignment model

- [ ] `app/lib/models/server/alignment.dart`:
  ```dart
  @freezed
  class SentenceAlignment with _$SentenceAlignment {
    const factory SentenceAlignment({
      @Default(0) int index,
      @Default('') String text,
      @JsonKey(name: 'start_ms') @Default(0) int startMs,
      @JsonKey(name: 'end_ms') @Default(0) int endMs,
      @JsonKey(name: 'char_offset') @Default(0) int charOffset,
    }) = _SentenceAlignment;
  }
  @freezed
  class ChapterAlignment with _$ChapterAlignment { ... }
  ```
- [ ] `tts_api.dart` 新增 `getAlignment(bookId, chapter)`

### Task 5.2: SyncController

- [ ] 新建 `app/lib/service/audiobook/sync_controller.dart`：
  ```dart
  class AudiobookSyncController {
    final AudiobookPlayer player;
    final ChapterAlignment alignment;
    final EpubPlayerState epubState;  // ttsHighlightByCfi

    int _lastHighlightIndex = -1;
    StreamSubscription? _sub;

    void attach() {
      _sub = player.positionStream
        .distinct()
        .throttleTime(const Duration(milliseconds: 100))
        .listen(_onPosition);
    }

    Future<void> _onPosition(Duration pos) async {
      final idx = _binarySearchSentence(pos.inMilliseconds);
      if (idx != _lastHighlightIndex) {
        _lastHighlightIndex = idx;
        final cfi = await _resolveCfi(idx);
        if (cfi != null) await epubState.ttsHighlightByCfi(cfi);
      }
    }
  }
  ```

### Task 5.3: CFI 解析（文本匹配）

- [ ] `_resolveCfi(int sentIdx)`：
  1. 拿本章 foliate sentences：`await epubState.ttsCollectDetails(count: 999, includeCurrent: true, offset: 0)`
  2. 第一次尝试：按 index 直接匹配（`foliateSents[sentIdx].cfi`）
  3. 如文本差异大（Levenshtein ratio < 0.85）→ 在 foliateSents 里按文本模糊匹配
  4. 仍没命中 → null（调用方跳过高亮那次，继续播）
- [ ] 匹配结果缓存 `Map<int, String> _cfiCache` 避免重复查

### Task 5.4: 二分查找

```dart
int _binarySearchSentence(int ms) {
  int lo = 0, hi = alignment.sentences.length - 1;
  while (lo <= hi) {
    final mid = (lo + hi) >> 1;
    final s = alignment.sentences[mid];
    if (ms < s.startMs) hi = mid - 1;
    else if (ms >= s.endMs) lo = mid + 1;
    else return mid;
  }
  return (lo < alignment.sentences.length) ? lo : alignment.sentences.length - 1;
}
```

### Task 5.5: verify + commit

```bash
cd app && flutter analyze lib/service/audiobook/
git add app/lib/service/audiobook/sync_controller.dart app/lib/models/server/alignment.dart app/lib/service/api/tts_api.dart
git commit -m "feat(app): sync controller matching audio position to EPUB CFI"
```

---

## Phase 6 · 点击跳转 + 自动翻页（2 天）

### Task 6.1: SyncListeningPage UI

- [ ] 新建 `app/lib/page/audiobook/sync_listening_page.dart`
- [ ] 上半部分：复用 `EpubPlayer` widget（foliate-js webview），传入 book + startCfi
- [ ] 下半部分：mini-player —— 播放/暂停 + 进度条 + 倍速 + 章节指示
- [ ] `AudiobookSyncController` 在 initState 里 attach

### Task 6.2: 替换 AudiobookButton 跳转

- [ ] `widgets/book_detail/audiobook_button.dart` 里 `_openAudiobookPage` 跳 `SyncListeningPage` 而非旧 `AudiobookPage`
- [ ] 旧 `AudiobookPage` 保留，用于 "章节列表 + 外部播放" 场景（下载到本地后用系统播放器，仍有价值）。在 `SyncListeningPage` 的菜单里加 "导出到系统播放器" 跳到旧页

### Task 6.3: 点击句子跳转

- [ ] foliate-js 暴露 `onSentenceTap(cfi)` 事件（已有 tts tap hook？）—— 如果没有，在 epub_player.dart 里加 JS handler
- [ ] 映射 `cfi → sentenceIdx → alignment.startMs → player.seek`

### Task 6.4: 自动翻页

- [ ] SyncController 每次高亮后检查 `epubState.isInView(cfi)`（如 foliate 没 API，调用 `ttsHighlightByCfi` 内部的 scrollIntoView 行为——现有代码已实现自动滚动？先查查）
- [ ] 必要时显式 `state.nextPage()`

### Task 6.5: verify + commit

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
flutter analyze lib/
git add app/lib/page/audiobook/sync_listening_page.dart app/lib/widgets/book_detail/audiobook_button.dart app/lib/l10n/
git commit -m "feat(app): sync listening page with tap-to-seek and auto page flip"
```

---

## Phase 7 · Web Admin 批量生成（2 天）

### Task 7.1: server endpoint

- [ ] `POST /admin/audiobook/batch` body `{book_ids: [...], voice: "serena"}`
- [ ] 逐本 submit 到 worker queue（低优先级）
- [ ] 返回 submitted count

### Task 7.2: 队列状态查询

- [ ] `GET /admin/audiobook/queue` 返回 `[{book_id, title, status, progress, voice, queued_at, error}]`

### Task 7.3: Admin UI

- [ ] `web/src/pages/admin/audiobook-queue.tsx`
- [ ] 书列表 + 过滤（书架 / 已生成状态）
- [ ] 多选 + "批量生成" 按钮
- [ ] 队列实时状态（5s 轮询或 SSE）

### Task 7.4: verify + commit

```bash
cd server && go build ./... && make swagger
cd web && npm run build
git add server/service/admin/ server/docs/ web/src/pages/admin/audiobook-queue.tsx
git commit -m "feat(admin): batch audiobook generation with queue status UI"
```

---

## Phase 8 · 端到端验证 + docs（1 天）

### Task 8.1: e2e 脚本

- [ ] `testdata/hurl/audiobook-sync.hurl`：
  1. POST `/tts/audiobook/{id}`
  2. 轮询到 status=completed
  3. GET `/tts/audiobook/{id}/index` → 断言 chapters 数
  4. GET `/tts/audiobook/{id}/0/alignment` → 断言 sentences 数、时间戳单调递增
- [ ] 加到 `.github/workflows/test-api.yaml`

### Task 8.2: 真机验证

在 202 上跑 alpha tag → 拉 APK → 用 yuhua 那本书：

- 第一次播 → 首句 < 500 ms 开始
- 播 30 s 后高亮应追上音频
- 点击下一段文本 → 音频跳过来
- 翻页 → 高亮继续跟 audio（不回跳）
- 关闭 app → 重开书 → 能从上次位置继续

### Task 8.3: PROGRESS.md + tts-setup.md

- [ ] `docs/superpowers/PROGRESS.md` 新增 Sprint 7 章节，每 Phase 完成打勾
- [ ] `site/src/content/docs/{,zh/}getting-started/tts-setup.md` 补"句级同步听书"使用说明
- [ ] 更新记录加一行

### Task 8.4: 最终 commit + tag

```bash
git add testdata/hurl/audiobook-sync.hurl .github/workflows/test-api.yaml docs/superpowers/PROGRESS.md site/src/content/docs/
git commit -m "docs+test: Sprint 7 sentence-sync listening — PROGRESS, guide, hurl e2e"
git tag v1.15.0-alpha.1 -m "Sprint 7: sentence-sync listening (Audible-grade highlight)"
git push origin main v1.15.0-alpha.1
```

---

## 验收标准（spec §12 再确认）

| 指标 | 目标 |
|------|------|
| 首句开始播放 | < 500 ms |
| 句级高亮延迟 | < 150 ms |
| 点击文本 → seek | < 200 ms |
| foliate-server 切句一致性 | > 90% 匹配成功 |
| e2e hurl 通过率 | 100% |
| 整库预生成能力 | Web admin 可见、可触发、可监控 |

## 执行顺序

**建议作为 8 个 agent round 执行**：每轮聚焦 1 个 Phase，完成后测试 + commit + 进入下一轮。

Phase 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8

前 3 阶段（server）连跑，可在 alpha.13 先放出来测 API；
Phase 4-6（app 核心）需要客户端调试；
Phase 7（web admin）独立于 app，可与 Phase 4-6 并行。
