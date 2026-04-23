# 句级同步听书（Sentence-Sync Listening）

> **日期：** 2026-04-23
> **状态：** Approved
> **Sprint：** 7
> **前置：** Sprint 6（server audiobook pipeline、ffmpeg 后处理、动态 voices、alpha.12 ctx-cancel 修复）

---

## 1. 产品愿景

**Omnigram 的有声书必须和文字形成一体的阅读体验**，而不是"又下载一个 MP3 文件"。

当用户按下播放：
- 屏幕上当前被朗读的**句子自动高亮**
- 翻页自动跟随朗读位置
- 暂停后再打开书，从停下那一句继续
- 点击任一句文本 → 音频跳转到对应位置
- 点击任一词 → 近似跳转（词级是后续优化）

这是 Audible Whispersync、Speechify 的核心记忆点。对我们的用户（个人 NAS 上有几千本私人藏书的深度读者），**这就是"AI 原生电子书"和"我下载了一个 MP3"的分水岭**。

## 2. 非目标

- 不做 Audible 式的"图书 + 专业朗读者原声"匹配——所有音频都是我们 TTS 合成的
- 不做声纹克隆 / 自定义声音采样（Sprint 8+）
- 不做词级对齐（章内全局词级 karaoke 是可选升级，优先级低于句级核心体验）
- 不做多设备同步"正在播放位置"（进度同步走已有 sync 通路即可）
- 不做后台播放的耳机/锁屏控制（另独立设计，此次不绑定）

## 3. 设计哲学：层次分明

三件事分三个地方做，互不重叠：

| 职责 | 位置 | 为什么 |
|------|------|------|
| **句子切分 + 时间戳** | Server | 一次生成，永久复用；不同客户端共用同一份 align.json |
| **CFI 权威定位** | 客户端 foliate-js | EPUB CFI 的唯一正确来源，版本间可能漂移——由渲染引擎自行负责 |
| **audio 时间 ↔ 高亮** | 客户端 Dart | 实时、低延迟、和 UI 状态机耦合最紧 |

**关键决策：server 产出的对齐数据不含 CFI。**

Server 只负责"这章第 3 句从 6900 ms 到 11240 ms，文本是'XXX'"。CFI 在**播放时**由 client 通过 foliate-js 即时解出。这样：

- Server 可完全独立于 app 运行（支持 web admin / cron / API 批量生成）
- foliate-js 升级 / CFI 算法调整时，align.json 不受影响
- 两种有声书触发路径（app 点按钮 / 服务器管理员触发）产出的数据结构**完全相同**

## 4. 数据模型

### 4.1 `chapter_NNN.align.json`

每章一个文件，和 `chapter_NNN.mp3` 并列存放在 `/metadata/audiobooks/{book_id}/`。

```json
{
  "schema_version": 1,
  "chapter_index": 3,
  "chapter_title": "一九六二年",
  "audio_file": "chapter_003.mp3",
  "audio_duration_ms": 780597,
  "voice": "serena",
  "provider": "kokoro",
  "generated_at": 1776928500,
  "sentences": [
    {
      "index": 0,
      "text": "一九六二年四月三日，余华出生于浙江省杭州市。",
      "start_ms": 0,
      "end_ms": 4280,
      "char_offset": 0
    },
    {
      "index": 1,
      "text": "出生时体重七斤三两。",
      "start_ms": 4280,
      "end_ms": 6840,
      "char_offset": 22
    }
  ]
}
```

字段含义：

| 字段 | 用途 |
|------|------|
| `index` | 章内句序号，0-based |
| `text` | 本句朗读的纯文本（已 strip HTML，无多余空白） |
| `start_ms` / `end_ms` | 音频时间轴上的起止点（ffprobe 精度，~10 ms） |
| `char_offset` | 本句在**章纯文本**里的起始字符偏移（用于与 foliate-js 切句做文本匹配） |

### 4.2 `audiobook.json`（全书级索引）

```json
{
  "schema_version": 1,
  "book_id": "202604151330220972209806",
  "book_title": "...",
  "author": "刘琳",
  "voice": "serena",
  "total_chapters": 6,
  "total_duration_ms": 1819000,
  "chapters": [
    {"index": 0, "title": "Contents",    "audio_file": "chapter_000.mp3", "align_file": "chapter_000.align.json", "duration_ms": 97304, "sentence_count": 15},
    {"index": 1, "title": "序言",        "audio_file": "chapter_001.mp3", "align_file": "chapter_001.align.json", "duration_ms": 319223, "sentence_count": 68},
    ...
  ]
}
```

### 4.3 API 端点

| 方法 | 路径 | 作用 |
|------|------|------|
| `POST` | `/tts/audiobook/:book_id` | （已有）触发整书生成；**新增可选** body `{ sentences: [...] }` 让 client 注入自定义切分 |
| `GET` | `/tts/audiobook/:book_id` | （已有）返回全书状态 |
| `GET` | `/tts/audiobook/:book_id/:chapter` | （已有）下载 MP3 |
| `GET` | `/tts/audiobook/:book_id/:chapter/alignment` | **新增**：返回 `chapter_NNN.align.json` |
| `GET` | `/tts/audiobook/:book_id/index` | **新增**：返回 `audiobook.json`（全书索引） |

## 5. 切句算法

### 5.1 Server 侧（独立模式）

Go 实现，规则一起检查：

1. **切分标点**：`。` `！` `？` `…` `.` `!` `?` + 后随空格或换行
2. **保留**：`，` `,` `、` `；` `;` —— 不切（太细会让句子碎成短语）
3. **强制切分**：`\n\n`（段落分隔）必切
4. **合并过短**：单句 <10 char 时合并进前一句，避免"a." / "X年"这种碎片
5. **强制切分**：单句 >200 char 时按 `，;` 兜底切分
6. **引号与括号**：位于成对引号/括号内的标点**不**切（避免 `"真的吗？"他问道` 切成两句）

### 5.2 Client 侧（注入模式）

App 端用 `foliate-js` 的 `ttsCollectDetails(999999)` 拿到权威的句子 + CFI，POST 时把 `sentences: [{index, text, cfi}]` 一并发给 server。server 跳过自己切分，直接用这个列表合成。返回的 `align.json` 里**依然不含 cfi**（CFI 属 client 侧概念），但 client 因为自己上传过，匹配时用 index 直接命中。

### 5.3 一致性兜底

匹配时（播放时 client 查 "当前 audio time 对应哪句 CFI"）：

```
1. server 返回的 sentences[i] → 问 foliate-js 第 i 句（同一 chapter）
   - 如果文本相似度 > 0.85（去空白后 Levenshtein ratio）→ 用该 CFI
2. 否则：在 foliate-js 的 sentences[] 里按文本模糊匹配
   - 命中 → 用该 CFI
3. 仍没命中：fallback 到"章级高亮"（整章半透明色块），音频继续播
```

这让"server 独立生成 vs foliate-js 切分不一致"的风险**完全被容错掉**——最差也是降级到章级，不是卡住。

## 6. 播放状态机

### 6.1 组件

- `AudiobookPlayer`（新）：封装 `just_audio` / `audioplayers`，负责 seek/pause/speed
- `AudiobookSyncController`（新）：订阅 audio `positionStream`，100 ms 节流，驱动高亮
- `AudiobookProvider`（已有）：任务状态 + 下载管理，**扩展**加载 `alignment.json`

### 6.2 高亮核心循环

```dart
audioPlayer.positionStream
  .throttle(100.ms)
  .listen((position) async {
    final ms = position.inMilliseconds;
    final sent = _binarySearchSentence(ms);   // 二分查找当前句
    if (sent.index != _lastHighlighted) {
      _lastHighlighted = sent.index;
      final cfi = await _resolveCfi(sent);    // foliate 匹配
      if (cfi != null) {
        await epubState.ttsHighlightByCfi(cfi);
        _maybeAutoPageFlip(cfi);
      }
    }
  });
```

### 6.3 点击 → 跳转

```dart
// 用户点击渲染页上的任一词
void onWordTap(String cfi) async {
  final sentIdx = await _findSentenceByCfi(cfi);   // foliate CFI → sentence index
  if (sentIdx != null) {
    final start = alignment.sentences[sentIdx].start_ms;
    await audioPlayer.seek(Duration(milliseconds: start));
  }
}
```

### 6.4 自动翻页

`positionStream` 触发高亮后：若 CFI 超出当前可视范围（foliate-js 暴露 `isInView(cfi)` 或类似 API），调用 `state.nextPage()`。

## 7. UI 设计

### 7.1 入口（沿用 Sprint 6 的 AudiobookButton）

书籍详情页的三态按钮不变：**生成 / 生成中 N% / 打开有声书**。

"打开有声书"不再跳 `AudiobookPage`（章节列表 + 外部播放器），**改为跳一个整本 EPUB 阅读器叠加了底部 mini-player 的同步界面**。

### 7.2 同步阅读界面

```
┌─────────────────────────────────────────┐
│  一九六二年                           ⋮ │   ← 章节标题栏
│                                         │
│  一九六二年四月三日，余华出生于浙江       │
│  省杭州市。出生时体重七斤三两。[高亮这句] │   ← 正在朗读的句子被半透明色块标记
│  他的父亲华自治……                       │
│                                         │
│                                         │
│             ═════════════               │   ← EPUB 正文（带高亮）
│                                         │
├─────────────────────────────────────────┤
│  ◀◀  ⏸  ▶▶    ───●────── 12:34/30:45  │   ← 底部 mini-player
│  1.0x  📖 一九六二年 · 第3段 / 共42段    │
└─────────────────────────────────────────┘
```

### 7.3 关键交互

| 操作 | 行为 |
|------|------|
| 点击句子 | 音频跳到该句起点 |
| 长按句子 | 呼出操作菜单（摘抄 / 翻译 / 复制），沿用现有选词菜单 |
| 双击播放/暂停区 | 播放/暂停切换（无需精确点到小按钮） |
| 左滑 / 右滑 | 下一章 / 上一章（同时 seek audio 到该章 0 ms） |
| 下滑底部条 | 收起 mini-player，变成纯阅读模式（音频继续播，但不高亮） |

### 7.4 离线下载指示

- 当前章未下载：tap "打开有声书" → 后台下载 + 占位转圈 + loading 2 秒以内开始播
- 下载策略：**当前章 + 下一章预下载**，其他章节按需

## 8. Web Admin 批量生成

### 8.1 入口

`web/admin` 里新增 **有声书队列** 页面：

- 全部书列表（可按书架/标签筛选）
- 多选 → 点 "批量生成有声书"
- 每本书一行：状态（未生成 / 生成中 N%  / 已完成 / 失败）+ 使用的声音 + 生成时间

### 8.2 并发与优先级

- 同一时刻 server 最多 1 个 audiobook worker（已有，避免 GPU 争用）
- batch 任务低优先级——用户"现在想听这本"的 app 触发**插队到前面**
- 失败自动重试 3 次

### 8.3 资源监控

dashboard 上新增 GPU 使用 + 队列长度 widget（复用 `/sys/stats`）。

## 9. 性能与成本

### 9.1 存储

- 每章 MP3：64 kbps（已有 ffmpeg 归一），30 min ≈ 15 MB
- 每章 align.json：~3 KB / 100 句 → 整书 ~50 KB
- 10 万字中文书 ≈ 60 MB 音频 + 0.5 MB 对齐数据

### 9.2 生成时间

（Sprint 6 实测）Qwen3-TTS on RTX 3090：**0.93× 实时**稳态。

- 10 万字 → 音频 ~2.2 h，合成 ~2.4 h
- **每句 ffprobe overhead 可忽略**（~10 ms/句，全书累计 <30 s）

### 9.3 整库估算

假设用户 1000 本平均 10 万字书 → 全库预生成要 **100 天 × 24h GPU** = 不现实。

**应对：**
- 默认不预生成，**按需**（用户点书才生成）
- admin 批量功能给"重点书架"（10–50 本）用，不是"整个库"
- 文档里写清楚预期（避免用户误以为"一夜之间所有书都有声"）

## 10. 风险与兜底

| 风险 | 应对 |
|------|------|
| server 切句与 foliate 不一致 → 高亮错位 | §5.3 文本模糊匹配 + 章级 fallback |
| audio player 卡顿（setState 太频繁） | positionStream throttle 100ms，highlight 只在 index 变化时触发 |
| 翻页与 audio 播放不同步（用户手动翻页） | 手动翻页**不**触发 seek；高亮跟随 audio，但若用户翻出了高亮页就停止 DOM 更新（只改 CSS 状态） |
| 长章节下载卡住 | 章节级 HTTP range 分段下载 + 断点续传（可延后，P1） |
| 生成失败章节影响用户体验 | `align.json` 允许部分缺失，client 回退到 "该章无高亮但能播" |
| 用户换声音后现有对齐失效 | 换声音 → 整章重生成（align.json 随之重生）；旧文件自动归档 |

## 11. 回归测试

- 已有 audiobook e2e（Sprint 6 yuhua 6 章）**必须继续通过**
- 新增：同一章用 app 注入 sentences vs server 自切 → 两份 align.json 时间戳差异 <3%
- 新增：foliate-js 切出的 sentences 数量 与 server 切出的数量 差异 <10%（允许标点处理不同）
- 新增：播放 30 s → 手动 seek 到 15 s → 高亮正确跳回

## 12. 成功标准

- 打开有声书后，**首句 <500 ms 开始播放并高亮**
- 句级高亮延迟 <150 ms（感知上不滞后）
- 点击文本任一句 → seek → 新句播放延迟 <200 ms
- 自动翻页无感（不闪、不跳回）
- Web admin 能批量触发，状态可视
- 整个功能在 server / app 任一侧挂掉时，**不崩**，另一侧回退到基础能力
