# TTS Adaptive Degradation & Now-Playing Experience

**Date:** 2026-04-27
**Status:** Draft for review
**Owner:** liuyou
**Related:**
- `specs/2026-04-11-tts-settings-redesign.md` — voice-first TTS settings
- `specs/2026-04-22-tts-audiobook-gaps-design.md` — server audiobook pipeline
- `specs/2026-04-23-sentence-sync-listening-design.md` — sentence-level alignment
- `PROGRESS.md` Sprint 6 (TTS 完整链路 ✅)

---

## 1. Problem

Omnigram is self-hosted. User hardware varies wildly: a Synology DS220+ cannot keep up with real-time Kokoro/Edge TTS the way a Mac mini M2 can. Today the app exposes a single "play" button that silently routes through real-time server synthesis. When the server can't keep up, the user sees buffering, dropouts, or long first-byte delays — and has no in-app way to discover *why*, *whether their setup can do better*, or *that there is a remote pre-generation path that already works*.

Meanwhile the server-side audiobook pipeline (batch generation, SSE progress, chapter alignment, queue admin) is fully built but only reachable through the admin web UI. The app has a "Generate audiobook" button on book detail, but users don't know **when to use it**, and there is no automatic bridge between "real-time playback failed" and "let's pre-generate this in the background."

Result: a capability the product already has is invisible to the people who most need it.

## 2. Goal

Users never face a "this doesn't work" button. Without ever learning what RTF means, they get:
- The best possible voice their server can deliver, picked automatically
- Zero-latency playback, even when the server is slow, via on-device fallback
- Server-quality audio whenever the server eventually catches up, with seamless chapter-boundary upgrade
- A first-class Now-Playing surface — Apple Music / Podcasts class — that surfaces this routing transparently as ambient information, not modals

## 3. Non-Goals

- Mid-chapter crossfade between local and server audio (timeline drift makes sentence sync brittle; not worth the engineering cost)
- System push notifications for "your chapter is ready" (self-hosted + privacy-first; in-app surfaces are sufficient)
- A separate "AI" or "TTS" tab — TTS routing is invisible plumbing inside the existing reader/audiobook surfaces
- Replacing existing voice-selection UX from `2026-04-11-tts-settings-redesign.md` — this spec sits *under* that, deciding *how to deliver* the voice the user picked
- Cross-server failover (one server, one routing decision)

## 4. Core Concept

Three interlocking state machines drive every decision; three UI surfaces make them visible.

```
[Server Capability]  ── decides default route ──┐
                                                 │
[Per-Chapter Audio Status]  ── overrides route ──┼──> [Playback Runtime Mode]
                                                 │            │
[User Override (rare)]  ─────────────────────────┘            │
                                                              ▼
                                              [Mini Bar + Now-Playing + Chapter dots + Pill]
```

## 5. State Machines

### 5.1 Server Capability — `ServerTtsCapability`
Probed once at login, cached 7 days, invalidated on server version change or manual "重新体检".

| Tier | Trigger | Default route |
|---|---|---|
| `GREEN` | first_byte < 1.5s **and** RTF < 0.6 | Real-time server synthesis |
| `YELLOW` | first_byte 1.5–3s **or** RTF 0.6–0.9 | Pre-generate by default; allow real-time on demand |
| `RED` | first_byte ≥ 3s **or** RTF ≥ 0.9 | Local-fallback + background pre-gen, always |
| `NA` | endpoint missing / probe failed / TTS disabled on server | Local-only, no upgrade path |

**Probe:** `POST /tts/probe` with a fixed ~120-character text and the user's currently selected voice. Server synthesizes synchronously, returns:
```json
{ "first_byte_ms": 820, "rtf": 0.42, "voice": "kokoro:af_bella", "server_build": "0.6.2" }
```

**Probe lifecycle:**
- Triggered automatically after successful login if no cached result OR cached result older than 7 days OR `server_build` changed
- Manual trigger: Settings → TTS → 服务器声音体检 → `[重新体检]`
- Invalidated when user switches selected voice (different voice = different RTF profile) — re-probe lazily on next listen attempt
- Stored in `SharedPreferences` keyed by `(server_url, voice_full_id)`

### 5.2 Per-Chapter Audio Status — `ChapterAudioStatus`
Source of truth: `GET /tts/audiobook/:id/index` (already exists). App fetches on book detail open and on `AudiobookPage` open; SSE keeps it live while a generation task is active for that book.

| State | Visual | Meaning |
|---|---|---|
| `NotGenerated` | ○ | Server has no sidecar for this chapter |
| `Generating(pct)` | ◐ 60% | In server queue or actively rendering |
| `Ready` | ● | High-quality server audio available for stream/download |
| `LocalCached` | ◌ | User has listened via local fallback; sherpa-onnx output cached on device for this chapter |

A chapter can be both `LocalCached` and `Ready` simultaneously — `Ready` always wins for routing.

### 5.3 Playback Runtime Mode — `PlaybackMode`
Computed per session, can change at chapter boundaries.

| Mode | What's playing | Pill |
|---|---|---|
| `LiveServer` | Server real-time synthesis stream | Hidden (default-state) |
| `PregenServer` | Server's pre-rendered chapter audio | Hidden (default-state) |
| `LocalFallback` | On-device sherpa-onnx output | Visible, color = server-side progress |

## 6. Routing Decision Matrix

Evaluated when the user presses play, and at every chapter boundary during continuous playback.

| Capability | Chapter Status | Action |
|---|---|---|
| `GREEN` | any | `LiveServer`. No prefetch — real-time is fine. |
| `YELLOW` | `Ready` | `PregenServer`. |
| `YELLOW` | `Generating` | `LocalFallback` + subscribe SSE; upgrade at chapter boundary. |
| `YELLOW` | `NotGenerated` | `LocalFallback` + background enqueue current + N+1, N+2. |
| `RED` | `Ready` | `PregenServer`. |
| `RED` | `Generating` | `LocalFallback` + subscribe SSE; upgrade at chapter boundary. |
| `RED` | `NotGenerated` | `LocalFallback` + background enqueue current + N+1, N+2. |
| `NA` | `Ready` | `PregenServer`. |
| `NA` | other | `LocalFallback`, no upgrade path. Pill 🟡 persistent. |

`YELLOW` and `RED` differ only in user-affordance: under `YELLOW`, the "总是用服务器实时" override in settings is offered as a soft suggestion ("你的服务器勉强能跑实时，要试试吗？"); under `RED` that override is hidden behind a confirmation. Auto-routing behavior is identical between the two tiers — keeping the matrix clean.

**Prefetch policy:** When in `RED` or `YELLOW` and entering a chapter that is `NotGenerated`, the app issues `POST /tts/audiobook/:book_id/chapter/:idx` with `priority=foreground` for the current chapter and `priority=prefetch` for the next two. Server's existing queue handles dedup.

**User override:** Settings → TTS → Default mode: `自动 (推荐)` / `总是用服务器实时` / `总是预生成` / `总是本地`. Default `自动` runs the matrix above. Other choices skip the matrix and force the chosen mode (with the obvious fallbacks if that mode is unavailable for a given chapter — e.g., "总是预生成" on a `NotGenerated` chapter still has to enqueue and either wait or local-fallback while waiting; the user picked the policy, the app does what's needed).

## 7. Chapter-Boundary Upgrade

When a chapter the user is currently listening to via `LocalFallback` becomes `Ready` mid-playback:

1. Pill turns 🟢 *高质量版本就绪*
2. Current chapter continues to play out on local audio (no mid-chapter swap)
3. On chapter advance, `PlaybackMode` recomputes → `PregenServer`
4. A one-shot toast surfaces at the boundary: *"已切到高质量版本"*
5. Pill becomes hidden (default state)

If the user wants to switch immediately, tapping the 🟢 pill restarts the current chapter from position 0 in `PregenServer`. (Restart from same position is not offered — sentence offsets in local vs. server audio do not align, so anchoring on chapter start is the only safe option.)

## 8. UI Surfaces

### 8.1 Mini Player Bar (always-on while audio is queued)

Pinned to the bottom of every primary tab and the reader. ~64dp tall, translucent blur background.

```
┌────────────────────────────────────────────────────────────────┐
│  ▣  当前句文本省略号…           ▶ / ⏸    ⏭            🟡 pill  │
│  封面 章节名 · 剩余 12:34                                       │
└────────────────────────────────────────────────────────────────┘
```

- **Left:** book cover thumb + chapter name + remaining time
- **Center:** the current sentence text (one line, marquee-ellipsis), play/pause, next-chapter
- **Right:** Pill (only when not in default state)
- **Tap the bar** → expand to Now-Playing
- **Swipe down on Now-Playing** → collapse back to mini bar
- **Swipe right on mini bar** → dismiss audio session entirely

### 8.2 Now-Playing Full-Screen

Modal sheet, presented via upward expansion from the mini bar.

```
┌─────────────────── ⌄ 收回 ───────────────────┐
│                                                │
│            [book cover, large]                 │
│              第 7 章 · 暗夜               🟡   │
│                                                │
│   prev sentence in dim gray, smaller           │
│                                                │
│   ▌ CURRENT SENTENCE, LARGE, HIGHLIGHTED ▐    │
│                                                │
│   next sentence in dim gray, smaller           │
│   …                                            │
│                                                │
│   ━━━━●─────────────  12:34 / 28:10            │
│                                                │
│   ⏮    ⏪15s    ▶ / ⏸   15s⏩    ⏭             │
│                                                │
│   1.0×    🌙 30min    ☰ 章节                   │
└────────────────────────────────────────────────┘
```

- **Cover** — top, large; `BlurHash` background tinted from cover dominant color
- **Pill** — sits to the right of the chapter title, the only place it appears in the full-screen view; tap behavior per §8.4
- **Sentence stream** — Apple Music lyrics style. Three sentences visible (prev, current, next); current sentence is the largest, highest-contrast, bold. Tapping any visible sentence seeks to its `start_ms` from `ChapterAlignment`. Long sentences wrap. Auto-scrolls as playback advances.
- **Progress bar** — chapter-relative, scrubbable. Drag = seek to nearest sentence boundary (snap behavior; the alignment JSON makes this trivial).
- **Transport row** — prev chapter, -15s, play/pause (large), +15s, next chapter
- **Bottom utility row** — speed (0.75/1.0/1.25/1.5/2.0), sleep timer, chapter list (opens a sheet on top of the player)

### 8.3 Per-Chapter Status Dots

Two surfaces:
- `AudiobookPage` chapter list — already shows progress; add the ○/◐/●/◌ dot to the right edge with a small mono-font label (e.g., `已生成`, `生成中 · 62%`, `本地`)
- Reader chapter drawer — same dot system, smaller

The dot is **the** signal users need to answer "can I just listen to this chapter offline / now?" without diving into the player.

### 8.4 The Pill

The pill is an accent, never the main event. It exists only in non-default playback states.

| Pill | When | Tap action |
|---|---|---|
| (hidden) | `LiveServer` or `PregenServer` | — |
| 🟡 *本地声音 · 服务器准备中* | `LocalFallback`, server progress 0% | Open detail sheet (§8.5) |
| 🔵 *服务器生成中 · N%* | `LocalFallback`, server progress > 0% | Open detail sheet |
| 🟢 *高质量版本就绪* | `LocalFallback`, server `Ready` for current chapter | Restart chapter in `PregenServer` immediately |
| 🟡 (持续) *本地声音* | `Capability == NA`, no upgrade path | Open detail sheet (explains why) |

Pill is rendered both in the mini bar (right edge) and in Now-Playing (right of chapter title). Same widget, two contexts.

### 8.5 Pill Detail Sheet

A small bottom sheet, ~40% screen. Plain-language explanation with a single primary action.

> 你正在听本地声音
>
> 我们的服务器现在合成跟不上你的播放速度，所以先用手机内置的声音陪你听着。
> 同时服务器在后台准备一份更自然的版本（约还需 4 分钟），下一章自动切过去。
>
> [我不要服务器版本，永远用本地]   [取消]

Linked from the pill, never auto-presented.

### 8.6 Settings → TTS Additions

A new section above existing voice picker:

```
服务器声音体检
  上次体检：2026-04-25 · 🟢 实时可用 (首字节 0.8s, RTF 0.42)
  [重新体检]

默认模式
  ◉ 自动 (推荐)
  ○ 总是用服务器实时
  ○ 总是预生成（不可用时本地兜底）
  ○ 总是本地
```

## 9. Data Flow

### 9.1 Login → probe
```
App login OK
  ├─ check cache for (server_url, current_voice)
  ├─ if miss / expired / build changed:
  │    POST /tts/probe { text, voice }  (timeout 8s)
  │    → save tier, first_byte_ms, rtf, server_build
  └─ else: use cached
```

### 9.2 Press play
```
Press play in reader / book detail
  ├─ resolve PlaybackMode via routing matrix (§6)
  ├─ if LiveServer: open audio stream from /tts/sentence
  ├─ if PregenServer: open chapter file from /tts/audiobook/:id/:ch.mp3
  ├─ if LocalFallback:
  │    ├─ start sherpa-onnx synth into ring buffer
  │    ├─ enqueue server pre-gen for current + next 2 chapters
  │    └─ subscribe SSE for this book's queue progress
  └─ start sentence highlight loop driven by ChapterAlignment timeline
```

### 9.3 Chapter boundary
```
audio reaches end of chapter N
  ├─ recompute PlaybackMode for chapter N+1 via §6
  ├─ if mode changed from LocalFallback → PregenServer:
  │    show one-shot toast "已切到高质量版本"
  └─ start chapter N+1 in new mode, scroll Now-Playing to first sentence
```

### 9.4 SSE upgrade signal
```
SSE event: chapter K of current book = Ready
  ├─ update chapter dots for that book
  ├─ if K == currently-playing chapter && mode == LocalFallback:
  │    pill state → 🟢
  └─ no auto-action; user opts in via pill tap or chapter-boundary upgrade
```

## 10. Engineering Footprint

### 10.1 Server
| Change | File | Notes |
|---|---|---|
| `POST /tts/probe` endpoint | new `server/service/tts/probe_handler.go` | Synchronous synth of fixed text, returns first_byte_ms + rtf + server_build. Rate-limited per user (10/hour, 1/minute). |
| Probe text fixture | `server/service/tts/probe_text.go` | A 120-char, neutral-prosody passage; one English, one Chinese, picked by voice locale. |
| Audiobook handler: foreground priority | `audiobook_handler.go` | Accept `priority=foreground` query param; bump to head of queue (existing queue supports this — verify in plan phase). |
| Swagger annotations | per CLAUDE.md rules | All new endpoints fully annotated; `make swagger` regenerated. |

### 10.2 App — routing & state
| Change | File | Notes |
|---|---|---|
| `tts_capability_provider.dart` | new | Loads cached capability; runs probe on login; exposes tier. |
| `tts_router.dart` | new | Pure function: `(capability, chapterStatus, override) → PlaybackMode`. Unit-tested against §6 matrix. |
| `tts_player_provider.dart` | refactor | Owns playback session; consumes `tts_router` decision; switches between `LiveServerSource`, `PregenServerSource`, `LocalFallbackSource` (three implementations of a common `TtsAudioSource` interface). |
| `local_tts_provider.dart` | wrap existing sherpa-onnx | Conform to `TtsAudioSource`. Pre-warm on app start to cut local first-byte latency. |
| Probe trigger on login | hook into auth provider | Fires fire-and-forget after successful login. |
| User override storage | `config/preferences.dart` | New key `tts_default_mode` enum. |

### 10.3 App — UI
| Change | File | Notes |
|---|---|---|
| Mini player bar | new `widgets/now_playing/mini_player_bar.dart` | Pinned to scaffold; visible whenever a session is queued. |
| Now-Playing full-screen | new `page/now_playing/now_playing_page.dart` | Modal route, swipe-down to dismiss. |
| Sentence stream widget | new `widgets/now_playing/sentence_stream.dart` | Drives off `ChapterAlignment`; tap-to-seek; auto-scroll. |
| Pill widget | new `widgets/tts/server_status_pill.dart` | Reused by mini bar + Now-Playing. |
| Pill detail sheet | new `widgets/tts/pill_detail_sheet.dart` | Plain-language explanation. |
| Chapter dots | edit `AudiobookPage` + reader chapter drawer | Reuse a single `ChapterStatusDot` widget. |
| Settings additions | edit existing TTS settings page | "声音体检" card + "默认模式" segmented control. |

### 10.4 Tests
- `tts_router_test.dart` — every cell of the §6 matrix
- `tts_capability_provider_test.dart` — cache hit/miss/expiry/build-change paths
- Probe endpoint integration test — happy path + slow-server path (artificial sleep to verify YELLOW/RED tiering)
- Chapter-boundary upgrade widget test — fake source progressing to chapter end with mode change

## 11. Failure & Edge Cases

| Case | Behavior |
|---|---|
| Probe times out (8s) | Treat as `NA`. User can retry from settings. |
| sherpa-onnx not available for current voice's locale | Local fallback unavailable → `LocalFallback` becomes "queue + cannot play yet" with a clearer pill *本章正在生成，约 4 分钟* and disable the play button; offer "试听已生成的章节" if any. |
| Network drops mid `LiveServer` | Auto-reconnect once; on second failure, switch to `LocalFallback` for the rest of the chapter and show pill. |
| Server pre-gen task fails | Chapter dot reverts to ○; pill in `LocalFallback` stays 🟡 forever for that chapter; user can manually retry from `AudiobookPage`. |
| User changes voice mid-session | Stop playback, clear local pre-warm cache, invalidate capability cache, re-probe lazily on next play. |
| User switches server (multi-server feature later) | Each `(server_url, voice)` keys its own capability cache; no interference. |
| Chapter alignment JSON missing for a `Ready` chapter | Fall back to plain mp3 playback in Now-Playing, sentence stream collapses to "现在播放：第 N 章" with no per-sentence highlight. |
| User is offline | Only `LocalCached` chapters or already-downloaded `Ready` chapters playable; mini bar shows offline indicator. |

## 12. Telemetry (local-only, opt-in)

For users who opt in to anonymous diagnostics (already an existing toggle):
- Probe distribution (tier counts, RTF histogram) — to inform default thresholds in future releases
- Mode-transition counts (`LocalFallback → PregenServer` upgrades, manual user overrides)
- Pill detail sheet open rate — to detect whether the explanation is needed often

No content, no voice samples, no chapter identifiers leave the device.

## 13. Migration / Rollout

- Existing users: capability cache empty → silent probe on next login. No UI change unless server is YELLOW/RED.
- Existing audiobook generation flow on book detail page is unchanged but now feels redundant; in a follow-up we may reduce its prominence (out of scope here).
- Feature gate: `experimental_tts_adaptive_routing` shared preference, default ON for fresh installs, OFF for upgrade installs for the first 7 days to allow opt-in via settings (sanity rollout). Removed in the release after.

## 14. Open Questions

1. **Probe text language** — voice locale is the obvious switch, but bilingual books? Probably fine to probe in voice locale only; revisit if user feedback says otherwise.
2. **Pre-warm sherpa-onnx on app start** vs. on first play — start adds memory cost, first-play adds ~500ms latency. Spec assumes app start; revisit after a memory profile.
3. **Mini bar dismissal gesture** — swipe-right is proposed; could conflict with reader page-turn gestures if reader uses horizontal swipe. Plan phase: confirm reader gesture map and pick an unambiguous dismiss action.

These do not block the plan; they are noted so the implementation plan can resolve them with concrete data.

---

**End of spec.**
