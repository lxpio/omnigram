# TTS Now-Playing UX — Implementation Plan (2 of 2)

> **Spec:** `docs/superpowers/specs/2026-04-27-tts-adaptive-degradation-design.md`
> **Plan 1:** `plans/2026-04-27-tts-adaptive-routing.md` (must be merged first)
> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Apple Music-class Now-Playing experience on top of Plan 1's routing primitives — a stateful player session that drives the three `TtsAudioSource` implementations, plus a mini bar (always-on while a session is active) and a swipe-up full-screen Now-Playing surface with cover, sentence stream, transport controls, and the ambient routing pill.

**Architecture:** A single `TtsPlayerSession` orchestrator owns playback state for a `(book, chapter, voice)` tuple. It resolves `PlaybackMode` via Plan 1's `ttsPlaybackMode` provider, instantiates the matching `TtsAudioSource`, drives `prepare()`/`play()`, listens to `completionStream` to advance chapters, fetches `ChapterAlignment` for sentence-level highlight, and subscribes to the audiobook SSE stream so it can flip the pill to 🟢 when a server pre-gen catches up. The session is exposed via a `keepAlive` Riverpod provider; UI surfaces (mini bar, Now-Playing) watch it and call its methods.

**Tech Stack:** Flutter 3.41, Riverpod v2 with `@riverpod` codegen, `audioplayers` (already used by Plan 1's sources), `path_provider`, freezed for state.

**Out of scope:**
- `audio_service` lockscreen / Bluetooth controls — leave for follow-up; the existing `TtsHandler` flow already covers this for the legacy reader path. Mixing two audio_service handlers is risky; Now-Playing ships as in-app only.
- Mid-chapter crossfade between modes (per spec §7).
- Replacing `SyncListeningPage` (the eyes-on EPUB+audio sync page from Sprint 7). Now-Playing is the eyes-off complement, not a replacement.
- Look-ahead prefetch beyond N+1, N+2.

---

## File Map

| Action | File | Responsibility |
|---|---|---|
| Create | `app/lib/models/tts/playback_state.dart` | Freezed `PlaybackState` (mode, isPlaying, position, duration, sentenceIndex, alignment, serverProgressPercent, …) |
| Create | `app/lib/service/tts/tts_player_session.dart` | The orchestrator class — owns audio source, alignment, SSE subscription, position stream |
| Create | `app/lib/providers/tts_player_session_provider.dart` | Riverpod `keepAlive` provider exposing the session |
| Create | `app/test/service/tts/tts_player_session_test.dart` | Unit tests for chapter-boundary upgrade, prefetch trigger, sentence index advance |
| Create | `app/lib/widgets/tts/server_status_pill.dart` | Pill widget consumed by both mini bar + Now-Playing |
| Create | `app/lib/widgets/tts/pill_detail_sheet.dart` | Bottom sheet shown when user taps the pill |
| Create | `app/lib/widgets/tts/sentence_stream.dart` | Apple Music-style three-line sentence view, tap-to-seek |
| Create | `app/lib/widgets/tts/mini_player_bar.dart` | Pinned bar widget |
| Create | `app/lib/page/now_playing/now_playing_page.dart` | Full-screen modal sheet |
| Create | `app/lib/widgets/tts/now_playing_transport.dart` | Transport row (prev / -15s / play / +15s / next) |
| Create | `app/lib/widgets/tts/now_playing_utility_row.dart` | Speed picker + sleep timer + chapter list trigger |
| Create | `app/lib/widgets/tts/sleep_timer_sheet.dart` | Sleep timer picker + countdown logic |
| Modify | `app/lib/page/audiobook/audiobook_page.dart` | Chapter rows: tap = start session in Now-Playing |
| Modify | `app/lib/page/omnigram_home.dart` | Mount the mini player bar above the bottom nav |
| Modify | `app/lib/page/reader/...` chapter drawer | Add `ChapterStatusDot` to chapter list (small) |
| Modify | `app/lib/l10n/app_en.arb` + `app_zh-CN.arb` | New L10n keys |
| Modify | `docs/superpowers/PROGRESS.md` | Plan 2 entry |

---

## Phase A — Player session brain

### Task 1: PlaybackState model

**Files:** Create `app/lib/models/tts/playback_state.dart`

- [ ] **Step 1: Implement model**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/service/tts/tts_router.dart';

part 'playback_state.freezed.dart';
part 'playback_state.g.dart';

@freezed
abstract class PlaybackState with _$PlaybackState {
  const PlaybackState._();
  const factory PlaybackState({
    String? bookId,
    String? coverUrl,
    String? bookTitle,
    @Default(0) int chapterIndex,
    @Default('') String chapterTitle,
    @Default(0) int totalChapters,
    @Default(PlaybackMode.liveServer) PlaybackMode mode,
    @Default(false) bool isPlaying,
    @Default(false) bool isPreparing,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(-1) int sentenceIndex,
    ChapterAlignment? alignment,
    @Default(0) int serverProgressPercent,
    @Default(false) bool serverReadyForCurrentChapter,
    @Default(1.0) double speed,
    String? errorMessage,
  }) = _PlaybackState;

  factory PlaybackState.fromJson(Map<String, dynamic> json) => _$PlaybackStateFromJson(json);

  bool get hasSession => bookId != null;
  bool get hasAlignment => alignment != null && alignment!.sentences.isNotEmpty;
}
```

- [ ] **Step 2: Codegen + analyze**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs && flutter analyze lib/models/tts/playback_state.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add app/lib/models/tts/playback_state.dart
git commit -m "feat(app): PlaybackState model for Now-Playing session"
```

---

### Task 2: TtsPlayerSession — failing tests

**Files:** Create `app/test/service/tts/tts_player_session_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:omnigram/service/tts/tts_player_session.dart';
import 'package:omnigram/service/tts/tts_router.dart';

class _FakeSource implements TtsAudioSource {
  final _position = StreamController<Duration>.broadcast();
  final _completion = StreamController<void>.broadcast();
  bool prepared = false;
  bool playing = false;
  Duration current = Duration.zero;

  @override
  Future<void> prepare({required int chapterIndex}) async {
    prepared = true;
  }

  @override
  Future<void> play() async {
    playing = true;
  }

  @override
  Future<void> pause() async {
    playing = false;
  }

  @override
  Future<void> seek(Duration position) async {
    current = position;
    _position.add(position);
  }

  @override
  Future<void> dispose() async {
    await _position.close();
    await _completion.close();
  }

  @override
  Stream<Duration> get positionStream => _position.stream;

  @override
  Stream<void> get completionStream => _completion.stream;

  void emitPosition(Duration d) => _position.add(d);
  void completeChapter() => _completion.add(null);
}

void main() {
  group('TtsPlayerSession.sentenceIndexFor', () {
    final alignment = ChapterAlignment(
      schemaVersion: 1,
      chapterIndex: 0,
      chapterTitle: '',
      audioFile: '',
      audioDurationMs: 10000,
      voice: '',
      provider: '',
      generatedAt: '',
      sentences: const [
        SentenceAlignment(index: 0, text: 'a', startMs: 0, endMs: 1000, charOffset: 0),
        SentenceAlignment(index: 1, text: 'b', startMs: 1000, endMs: 2500, charOffset: 1),
        SentenceAlignment(index: 2, text: 'c', startMs: 2500, endMs: 5000, charOffset: 2),
      ],
    );

    test('returns -1 before first sentence', () {
      expect(
        TtsPlayerSession.sentenceIndexFor(alignment: alignment, position: const Duration(milliseconds: -10)),
        -1,
      );
    });
    test('returns 0 for position inside first sentence', () {
      expect(
        TtsPlayerSession.sentenceIndexFor(alignment: alignment, position: const Duration(milliseconds: 500)),
        0,
      );
    });
    test('returns 1 at exact start of second sentence', () {
      expect(
        TtsPlayerSession.sentenceIndexFor(alignment: alignment, position: const Duration(milliseconds: 1000)),
        1,
      );
    });
    test('returns last sentence past audio end', () {
      expect(
        TtsPlayerSession.sentenceIndexFor(alignment: alignment, position: const Duration(milliseconds: 10000)),
        2,
      );
    });
  });

  group('TtsPlayerSession.chapterBoundaryUpgrade', () {
    test('upgrades when next-chapter mode differs from current', () {
      expect(
        TtsPlayerSession.shouldShowUpgradeToast(
          previous: PlaybackMode.localFallback,
          next: PlaybackMode.pregenServer,
        ),
        true,
      );
    });
    test('no toast when both modes equal', () {
      expect(
        TtsPlayerSession.shouldShowUpgradeToast(
          previous: PlaybackMode.localFallback,
          next: PlaybackMode.localFallback,
        ),
        false,
      );
    });
    test('no toast when downgrading', () {
      expect(
        TtsPlayerSession.shouldShowUpgradeToast(
          previous: PlaybackMode.pregenServer,
          next: PlaybackMode.localFallback,
        ),
        false,
      );
    });
  });
}
```

- [ ] **Step 2: Run — must fail (session not defined)**

```bash
cd app && flutter test test/service/tts/tts_player_session_test.dart
```

Expected: compile error referencing missing `tts_player_session.dart`.

- [ ] **Step 3: Commit**

```bash
git add app/test/service/tts/tts_player_session_test.dart
git commit -m "test(app): TtsPlayerSession sentence index + upgrade toast"
```

---

### Task 3: TtsPlayerSession implementation

**Files:** Create `app/lib/service/tts/tts_player_session.dart`

- [ ] **Step 1: Implement**

```dart
import 'dart:async';

import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/models/tts/playback_state.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:omnigram/service/tts/tts_router.dart';

typedef AudioSourceFactory = TtsAudioSource Function(PlaybackMode mode);
typedef ChapterTextFetcher = Future<String> Function(int chapterIndex);
typedef ChapterAlignmentFetcher = Future<ChapterAlignment?> Function(int chapterIndex);
typedef ModeResolver = PlaybackMode Function({required int chapterIndex});
typedef PrefetchHook = void Function(int chapterIndex);
typedef UpgradeToast = void Function();

/// Stateful orchestrator for the Now-Playing session. Owns at most one
/// `TtsAudioSource` at a time and rebuilds it whenever the resolved
/// `PlaybackMode` changes — currently only at chapter boundaries.
class TtsPlayerSession {
  TtsPlayerSession({
    required this.bookId,
    required this.bookTitle,
    required this.coverUrl,
    required this.totalChapters,
    required this.fetchChapterTitle,
    required this.fetchChapterAlignment,
    required this.audioSourceFactory,
    required this.modeResolver,
    required this.prefetchHook,
    required this.upgradeToast,
  });

  final String bookId;
  final String bookTitle;
  final String? coverUrl;
  final int totalChapters;
  final Future<String> Function(int chapterIndex) fetchChapterTitle;
  final ChapterAlignmentFetcher fetchChapterAlignment;
  final AudioSourceFactory audioSourceFactory;
  final ModeResolver modeResolver;
  final PrefetchHook prefetchHook;
  final UpgradeToast upgradeToast;

  TtsAudioSource? _source;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<void>? _completeSub;

  final _stateController = StreamController<PlaybackState>.broadcast();
  Stream<PlaybackState> get stream => _stateController.stream;
  PlaybackState _state = const PlaybackState();
  PlaybackState get state => _state;

  void _emit(PlaybackState s) {
    _state = s;
    _stateController.add(s);
  }

  Future<void> start({required int chapterIndex}) async {
    await _teardownSource();
    final mode = modeResolver(chapterIndex: chapterIndex);
    _emit(_state.copyWith(
      bookId: bookId,
      bookTitle: bookTitle,
      coverUrl: coverUrl,
      totalChapters: totalChapters,
      chapterIndex: chapterIndex,
      mode: mode,
      isPreparing: true,
      isPlaying: false,
      position: Duration.zero,
      sentenceIndex: -1,
      alignment: null,
      errorMessage: null,
    ));

    prefetchHook(chapterIndex);
    if (chapterIndex + 1 < totalChapters) prefetchHook(chapterIndex + 1);
    if (chapterIndex + 2 < totalChapters) prefetchHook(chapterIndex + 2);

    final title = await fetchChapterTitle(chapterIndex);
    final alignment = await fetchChapterAlignment(chapterIndex);

    final source = audioSourceFactory(mode);
    _source = source;
    try {
      await source.prepare(chapterIndex: chapterIndex);
    } catch (e) {
      _emit(_state.copyWith(isPreparing: false, errorMessage: e.toString()));
      return;
    }

    _posSub = source.positionStream.listen(_onPosition);
    _completeSub = source.completionStream.listen((_) => _onChapterComplete());

    _emit(_state.copyWith(
      chapterTitle: title,
      alignment: alignment,
      isPreparing: false,
      isPlaying: true,
    ));
    await source.play();
  }

  Future<void> play() async {
    final s = _source;
    if (s == null) return;
    await s.play();
    _emit(_state.copyWith(isPlaying: true));
  }

  Future<void> pause() async {
    final s = _source;
    if (s == null) return;
    await s.pause();
    _emit(_state.copyWith(isPlaying: false));
  }

  Future<void> seek(Duration position) async {
    final s = _source;
    if (s == null) return;
    await s.seek(position);
    _emit(_state.copyWith(position: position, sentenceIndex: sentenceIndexFor(alignment: _state.alignment, position: position)));
  }

  Future<void> seekToSentence(int sentenceIdx) async {
    final a = _state.alignment;
    if (a == null || sentenceIdx < 0 || sentenceIdx >= a.sentences.length) return;
    final ms = a.sentences[sentenceIdx].startMs;
    await seek(Duration(milliseconds: ms));
  }

  Future<void> nextChapter() async {
    if (_state.chapterIndex + 1 >= totalChapters) return;
    await start(chapterIndex: _state.chapterIndex + 1);
  }

  Future<void> prevChapter() async {
    if (_state.chapterIndex <= 0) return;
    await start(chapterIndex: _state.chapterIndex - 1);
  }

  Future<void> setSpeed(double speed) async {
    // audioplayers exposes setPlaybackRate via the source's player; we don't
    // forward it through TtsAudioSource yet — Plan 2 tracks speed in state
    // for the UI, real rate is wired in Task 13 by extending the interface.
    _emit(_state.copyWith(speed: speed));
  }

  Future<void> stop() async {
    await _teardownSource();
    _emit(const PlaybackState());
  }

  /// Mark current chapter as ready (called by SSE listener in the provider).
  void markServerReady() {
    if (_state.mode == PlaybackMode.localFallback) {
      _emit(_state.copyWith(serverReadyForCurrentChapter: true, serverProgressPercent: 100));
    }
  }

  void updateServerProgress(int percent) {
    _emit(_state.copyWith(serverProgressPercent: percent));
  }

  /// Force-restart the current chapter using the latest resolved mode. Used
  /// when the user taps the 🟢 pill during local fallback.
  Future<void> upgradeNow() async {
    await start(chapterIndex: _state.chapterIndex);
  }

  void _onPosition(Duration p) {
    final idx = sentenceIndexFor(alignment: _state.alignment, position: p);
    _emit(_state.copyWith(position: p, sentenceIndex: idx));
  }

  Future<void> _onChapterComplete() async {
    if (_state.chapterIndex + 1 >= totalChapters) {
      await pause();
      return;
    }
    final previousMode = _state.mode;
    final nextIndex = _state.chapterIndex + 1;
    final nextMode = modeResolver(chapterIndex: nextIndex);
    if (shouldShowUpgradeToast(previous: previousMode, next: nextMode)) {
      upgradeToast();
    }
    await start(chapterIndex: nextIndex);
  }

  Future<void> _teardownSource() async {
    await _posSub?.cancel();
    await _completeSub?.cancel();
    final s = _source;
    _source = null;
    if (s != null) await s.dispose();
  }

  Future<void> dispose() async {
    await _teardownSource();
    await _stateController.close();
  }

  // ── Pure helpers (testable) ────────────────────────────────────────

  /// Binary-search the sentence window containing `position`. Returns -1 if
  /// no alignment is present or the position is before the first sentence.
  static int sentenceIndexFor({required ChapterAlignment? alignment, required Duration position}) {
    if (alignment == null) return -1;
    final ms = position.inMilliseconds;
    final ss = alignment.sentences;
    if (ss.isEmpty || ms < ss.first.startMs) return -1;
    if (ms >= ss.last.endMs) return ss.last.index;
    int lo = 0, hi = ss.length - 1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final s = ss[mid];
      if (ms < s.startMs) {
        hi = mid - 1;
      } else if (ms >= s.endMs) {
        lo = mid + 1;
      } else {
        return s.index;
      }
    }
    return ss[lo.clamp(0, ss.length - 1)].index;
  }

  /// Whether to show "已切到高质量版本" toast at chapter boundary (spec §7).
  static bool shouldShowUpgradeToast({required PlaybackMode previous, required PlaybackMode next}) {
    return previous == PlaybackMode.localFallback &&
        (next == PlaybackMode.pregenServer || next == PlaybackMode.liveServer);
  }
}
```

- [ ] **Step 2: Run tests — expect PASS**

```bash
cd app && flutter test test/service/tts/tts_player_session_test.dart
```

Expected: 7 passing.

- [ ] **Step 3: Commit**

```bash
git add app/lib/service/tts/tts_player_session.dart
git commit -m "feat(app): TtsPlayerSession orchestrator + sentence index search"
```

---

### Task 4: TtsPlayerSession Riverpod provider

**Files:** Create `app/lib/providers/tts_player_session_provider.dart`

- [ ] **Step 1: Implement provider**

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/models/tts/playback_state.dart';
import 'package:omnigram/providers/audiobook_provider.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/providers/tts_capability_provider.dart';
import 'package:omnigram/providers/tts_playback_mode_provider.dart';
import 'package:omnigram/service/tts/live_server_source.dart';
import 'package:omnigram/service/tts/local_fallback_source.dart';
import 'package:omnigram/service/tts/pregen_server_source.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:omnigram/service/tts/tts_player_session.dart';
import 'package:omnigram/service/tts/tts_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_player_session_provider.g.dart';

class _SessionHolder {
  TtsPlayerSession? session;
}

/// App-wide singleton holding at most one active Now-Playing session.
@Riverpod(keepAlive: true)
class TtsPlayerSessionController extends _$TtsPlayerSessionController {
  final _holder = _SessionHolder();
  StreamSubscription<ServerAudiobookTask>? _sseSub;

  @override
  PlaybackState build() {
    ref.onDispose(() async {
      await _sseSub?.cancel();
      await _holder.session?.dispose();
    });
    return const PlaybackState();
  }

  TtsPlayerSession? get session => _holder.session;

  Future<void> startSession({
    required Book book,
    required int chapterIndex,
  }) async {
    final conn = ref.read(serverConnectionProvider);
    final api = ref.read(serverConnectionProvider.notifier).tts;
    final omni = ref.read(serverConnectionProvider.notifier).api;
    if (api == null || omni == null || conn.serverUrl == null) {
      state = state.copyWith(errorMessage: 'Not connected to server');
      return;
    }
    final voiceFullId = Prefs().selectedVoiceFullId;
    if (voiceFullId.isEmpty) {
      state = state.copyWith(errorMessage: 'No voice selected');
      return;
    }
    final voiceId = voiceFullId.contains(':')
        ? voiceFullId.split(':').sublist(1).join(':')
        : voiceFullId;

    final info = await api.getAudiobook(book.id).catchError((_) => null);
    final totalChapters = info?.task.totalChapters ?? book.totalChapter;

    Future<String> fetchChapterText(int idx) async {
      // Server's audiobook handler is responsible for splitting the EPUB
      // into chapter texts. For LiveServer / LocalFallback we ask the
      // alignment endpoint for the sentences and join — alignment is the
      // canonical source of chapter text for adaptive routing.
      final align = await api.getChapterAlignment(book.id, idx).catchError((_) => null);
      if (align == null) return '';
      return align.sentences.map((s) => s.text).join('\n');
    }

    Future<String> fetchTitle(int idx) async {
      if (info == null) return '#${idx + 1}';
      for (final c in info.chapters) {
        if (c.chapterIndex == idx) return c.chapterTitle;
      }
      return '#${idx + 1}';
    }

    Future<ChapterAlignment?> fetchAlignment(int idx) async {
      try {
        return await api.getChapterAlignment(book.id, idx);
      } catch (_) {
        return null;
      }
    }

    TtsAudioSource sourceFor(PlaybackMode mode) {
      switch (mode) {
        case PlaybackMode.liveServer:
          return LiveServerSource(
            api: omni,
            bookId: book.id,
            voice: voiceId,
            language: null,
            fetchChapterText: fetchChapterText,
          );
        case PlaybackMode.pregenServer:
          return PregenServerSource(api: api, bookId: book.id);
        case PlaybackMode.localFallback:
          return LocalFallbackSource(
            bookId: book.id,
            voice: voiceId,
            fetchChapterText: fetchChapterText,
          );
      }
    }

    PlaybackMode resolveMode({required int chapterIndex}) {
      return ref.read(ttsPlaybackModeProvider(
        bookId: book.id,
        chapterIndex: chapterIndex,
        serverUrl: conn.serverUrl!,
        voiceFullId: voiceFullId,
      ));
    }

    void prefetch(int idx) {
      final tier = ref.read(ttsCapabilityCacheProvider)['${conn.serverUrl}::$voiceFullId']?.tier;
      if (tier == null) return;
      // Status looked up indirectly via ttsPlaybackMode — if it would route to
      // localFallback, that means server pre-gen is needed.
      final mode = resolveMode(chapterIndex: idx);
      if (mode != PlaybackMode.localFallback) return;
      try {
        api.createChapterAudio(book.id, idx);
      } catch (_) {
        // best-effort
      }
    }

    await _holder.session?.dispose();
    final s = TtsPlayerSession(
      bookId: book.id,
      bookTitle: book.title,
      coverUrl: book.coverImage,
      totalChapters: totalChapters,
      fetchChapterTitle: fetchTitle,
      fetchChapterAlignment: fetchAlignment,
      audioSourceFactory: sourceFor,
      modeResolver: resolveMode,
      prefetchHook: prefetch,
      upgradeToast: () => state = state.copyWith(),
    );
    _holder.session = s;
    s.stream.listen((newState) => state = newState);

    // Re-subscribe SSE for the audiobook so the session sees ready signals.
    await _sseSub?.cancel();
    final task = info?.task;
    if (task != null && task.id.isNotEmpty) {
      _sseSub = api.streamTask(task.id).listen((updated) {
        // server returns `done_chapters/total_chapters` on each update; use as overall progress
        final pct = updated.totalChapters == 0
            ? 0
            : ((updated.doneChapters / updated.totalChapters) * 100).round();
        s.updateServerProgress(pct);
        // chapter-specific ready signal: refetch audiobook info, see if our chapter flipped.
        api.getAudiobook(book.id).then((fresh) {
          for (final c in fresh.chapters) {
            if (c.chapterIndex == s.state.chapterIndex && c.status == 2) {
              s.markServerReady();
              break;
            }
          }
        }).catchError((_) {});
      });
    }

    await s.start(chapterIndex: chapterIndex);
  }

  Future<void> play() => _holder.session?.play() ?? Future.value();
  Future<void> pause() => _holder.session?.pause() ?? Future.value();
  Future<void> seek(Duration position) => _holder.session?.seek(position) ?? Future.value();
  Future<void> seekToSentence(int idx) => _holder.session?.seekToSentence(idx) ?? Future.value();
  Future<void> nextChapter() => _holder.session?.nextChapter() ?? Future.value();
  Future<void> prevChapter() => _holder.session?.prevChapter() ?? Future.value();
  Future<void> setSpeed(double s) => _holder.session?.setSpeed(s) ?? Future.value();
  Future<void> upgradeNow() => _holder.session?.upgradeNow() ?? Future.value();

  Future<void> stop() async {
    await _sseSub?.cancel();
    _sseSub = null;
    await _holder.session?.dispose();
    _holder.session = null;
    state = const PlaybackState();
  }
}
```

- [ ] **Step 2: Codegen + analyze**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs && flutter analyze lib/providers/tts_player_session_provider.dart
```

Expected: no errors. If `Book.coverImage` / `Book.totalChapter` differ, adjust to actual field names — find them with:

```bash
grep -n "coverImage\|coverUrl\|totalChapter\|cover\b" app/lib/models/book.dart | head
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/providers/tts_player_session_provider.dart
git commit -m "feat(app): tts player session provider with SSE upgrade signal"
```

---

## Phase B — UI primitives

### Task 5: ServerStatusPill widget

**Files:** Create `app/lib/widgets/tts/server_status_pill.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/models/tts/playback_state.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/service/tts/tts_router.dart';
import 'package:omnigram/widgets/tts/pill_detail_sheet.dart';

/// Visible only in non-default playback states (spec §8.4). Default states
/// (LiveServer / PregenServer running smoothly) render an empty SizedBox.
class ServerStatusPill extends ConsumerWidget {
  const ServerStatusPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    if (s.mode != PlaybackMode.localFallback) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, label) = _styleFor(s, scheme);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (s.serverReadyForCurrentChapter) {
          ref.read(ttsPlayerSessionControllerProvider.notifier).upgradeNow();
        } else {
          showModalBottomSheet(
            context: context,
            builder: (_) => const PillDetailSheet(),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: fg, fontSize: 12)),
      ),
    );
  }

  (Color, Color, String) _styleFor(PlaybackState s, ColorScheme scheme) {
    if (s.serverReadyForCurrentChapter) {
      return (Colors.green.shade100, Colors.green.shade900, '🟢 高质量版本就绪');
    }
    if (s.serverProgressPercent > 0) {
      return (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        '🔵 服务器生成中 · ${s.serverProgressPercent}%',
      );
    }
    return (
      Colors.amber.shade100,
      Colors.amber.shade900,
      '🟡 本地声音 · 服务器准备中',
    );
  }
}
```

- [ ] **Step 2: Analyze + commit**

```bash
cd app && flutter analyze lib/widgets/tts/server_status_pill.dart
git add app/lib/widgets/tts/server_status_pill.dart
git commit -m "feat(app): ServerStatusPill ambient routing indicator"
```

---

### Task 6: PillDetailSheet

**Files:** Create `app/lib/widgets/tts/pill_detail_sheet.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/service/tts/tts_router.dart';

class PillDetailSheet extends ConsumerWidget {
  const PillDetailSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final pct = s.serverProgressPercent;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('你正在听本地声音', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              '我们的服务器现在合成跟不上你的播放速度，所以先用手机内置的声音陪你听着。'
              '同时服务器在后台准备一份更自然的版本，下一章自动切过去。',
            ),
            if (pct > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: pct / 100),
              const SizedBox(height: 4),
              Text('服务器进度：$pct%'),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Prefs().ttsDefaultMode = TtsDefaultMode.alwaysLocal.prefValue;
                    Navigator.pop(context);
                  },
                  child: const Text('我不要服务器版'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('好'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze + commit**

```bash
cd app && flutter analyze lib/widgets/tts/pill_detail_sheet.dart
git add app/lib/widgets/tts/pill_detail_sheet.dart
git commit -m "feat(app): pill detail sheet — explain local fallback in plain language"
```

---

### Task 7: SentenceStream widget

**Files:** Create `app/lib/widgets/tts/sentence_stream.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';

/// Apple Music-style three-line sentence view: prev / current / next, where
/// the current sentence is large and high-contrast. Tapping any visible
/// sentence seeks to its `start_ms`.
class SentenceStream extends ConsumerWidget {
  const SentenceStream({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final theme = Theme.of(context);

    if (!s.hasAlignment) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Text(
          s.chapterTitle.isEmpty ? '现在播放：第 ${s.chapterIndex + 1} 章' : s.chapterTitle,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    final sentences = s.alignment!.sentences;
    final cur = s.sentenceIndex.clamp(0, sentences.length - 1);
    final prev = cur > 0 ? sentences[cur - 1] : null;
    final next = cur + 1 < sentences.length ? sentences[cur + 1] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prev != null)
            _line(
              ref,
              prev.index,
              prev.text,
              style: theme.textTheme.titleSmall?.copyWith(color: theme.disabledColor),
            ),
          const SizedBox(height: 12),
          _line(
            ref,
            sentences[cur].index,
            sentences[cur].text,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (next != null)
            _line(
              ref,
              next.index,
              next.text,
              style: theme.textTheme.titleSmall?.copyWith(color: theme.disabledColor),
            ),
        ],
      ),
    );
  }

  Widget _line(WidgetRef ref, int sentenceIndex, String text, {TextStyle? style}) {
    return InkWell(
      onTap: () => ref.read(ttsPlayerSessionControllerProvider.notifier).seekToSentence(sentenceIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text, style: style),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze + commit**

```bash
cd app && flutter analyze lib/widgets/tts/sentence_stream.dart
git add app/lib/widgets/tts/sentence_stream.dart
git commit -m "feat(app): SentenceStream — Apple Music-style three-line sentence view"
```

---

### Task 8: MiniPlayerBar

**Files:** Create `app/lib/widgets/tts/mini_player_bar.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/page/now_playing/now_playing_page.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/widgets/tts/server_status_pill.dart';

/// Pinned to scaffold bottom while a session is active. Tap to expand to
/// Now-Playing; swipe-down dismisses the session entirely (matches the
/// "swipe right = dismiss" idea from the spec but adapted for vertical).
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    if (!s.hasSession) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final currentSentence = s.hasAlignment && s.sentenceIndex >= 0 && s.sentenceIndex < s.alignment!.sentences.length
        ? s.alignment!.sentences[s.sentenceIndex].text
        : s.chapterTitle;

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const NowPlayingPage(),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (s.coverUrl != null && s.coverUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(s.coverUrl!, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 40, height: 40)),
                )
              else
                const SizedBox(width: 40, height: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentSentence, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
                    Text(s.chapterTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const ServerStatusPill(),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(s.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  final ctl = ref.read(ttsPlayerSessionControllerProvider.notifier);
                  s.isPlaying ? ctl.pause() : ctl.play();
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () => ref.read(ttsPlayerSessionControllerProvider.notifier).nextChapter(),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => ref.read(ttsPlayerSessionControllerProvider.notifier).stop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze + commit**

```bash
cd app && flutter analyze lib/widgets/tts/mini_player_bar.dart
git add app/lib/widgets/tts/mini_player_bar.dart
git commit -m "feat(app): mini player bar — always-on while session active"
```

---

## Phase C — Now-Playing full-screen

### Task 9: Transport row + utility row + sleep timer sheet

**Files:** Create `app/lib/widgets/tts/now_playing_transport.dart`, `app/lib/widgets/tts/now_playing_utility_row.dart`, `app/lib/widgets/tts/sleep_timer_sheet.dart`

- [ ] **Step 1: Implement transport row**

`now_playing_transport.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';

class NowPlayingTransport extends ConsumerWidget {
  const NowPlayingTransport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final ctl = ref.read(ttsPlayerSessionControllerProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_previous),
          onPressed: s.chapterIndex > 0 ? ctl.prevChapter : null,
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.replay_10),
          onPressed: () => ctl.seek(Duration(milliseconds: (s.position.inMilliseconds - 15000).clamp(0, 1 << 30))),
        ),
        IconButton.filledTonal(
          iconSize: 56,
          icon: Icon(s.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () => s.isPlaying ? ctl.pause() : ctl.play(),
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.forward_10),
          onPressed: () => ctl.seek(Duration(milliseconds: s.position.inMilliseconds + 15000)),
        ),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_next),
          onPressed: s.chapterIndex + 1 < s.totalChapters ? ctl.nextChapter : null,
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Implement utility row**

`now_playing_utility_row.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/widgets/tts/sleep_timer_sheet.dart';

class NowPlayingUtilityRow extends ConsumerWidget {
  const NowPlayingUtilityRow({super.key});

  static const _speeds = [0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final ctl = ref.read(ttsPlayerSessionControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton<double>(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('${s.speed}×')],
            ),
            onSelected: (v) => ctl.setSpeed(v),
            itemBuilder: (_) => _speeds
                .map((v) => PopupMenuItem(value: v, child: Text('${v}×')))
                .toList(),
          ),
          TextButton.icon(
            icon: const Icon(Icons.bedtime_outlined),
            label: const Text('睡眠'),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => const SleepTimerSheet(),
              );
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.list),
            label: const Text('章节'),
            onPressed: () {
              // chapter list — Plan 2 reuses AudiobookPage; pop and let user
              // pick from there (cheap; we don't duplicate navigation).
              Navigator.maybePop(context);
            },
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Implement sleep timer sheet**

`sleep_timer_sheet.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';

class SleepTimerSheet extends ConsumerStatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  ConsumerState<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends ConsumerState<SleepTimerSheet> {
  Timer? _timer;

  void _arm(Duration d) {
    _timer?.cancel();
    _timer = Timer(d, () {
      ref.read(ttsPlayerSessionControllerProvider.notifier).pause();
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${d.inMinutes} 分钟后停止')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final m in [10, 15, 30, 45, 60])
              ListTile(
                title: Text('$m 分钟'),
                onTap: () => _arm(Duration(minutes: m)),
              ),
            ListTile(
              title: const Text('取消定时'),
              onTap: () {
                _timer?.cancel();
                _timer = null;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Analyze + commit**

```bash
cd app && flutter analyze lib/widgets/tts/now_playing_transport.dart lib/widgets/tts/now_playing_utility_row.dart lib/widgets/tts/sleep_timer_sheet.dart
git add app/lib/widgets/tts/now_playing_transport.dart app/lib/widgets/tts/now_playing_utility_row.dart app/lib/widgets/tts/sleep_timer_sheet.dart
git commit -m "feat(app): Now-Playing transport, utility row, sleep timer"
```

---

### Task 10: NowPlayingPage

**Files:** Create `app/lib/page/now_playing/now_playing_page.dart`

- [ ] **Step 1: Implement**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
import 'package:omnigram/widgets/tts/now_playing_transport.dart';
import 'package:omnigram/widgets/tts/now_playing_utility_row.dart';
import 'package:omnigram/widgets/tts/sentence_stream.dart';
import 'package:omnigram/widgets/tts/server_status_pill.dart';

class NowPlayingPage extends ConsumerWidget {
  const NowPlayingPage({super.key});

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$ss' : '$m:$ss';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(ttsPlayerSessionControllerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(s.bookTitle ?? ''),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            if (s.coverUrl != null && s.coverUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(s.coverUrl!, width: 220, height: 220, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 220, height: 220)),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text(s.chapterTitle, style: theme.textTheme.titleMedium, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                const ServerStatusPill(),
              ],
            ),
            const SizedBox(height: 12),
            const Expanded(child: SentenceStream()),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(_format(s.position), style: theme.textTheme.bodySmall),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: s.duration.inMilliseconds.toDouble().clamp(1.0, double.infinity),
                      value: s.position.inMilliseconds.toDouble().clamp(0.0, s.duration.inMilliseconds.toDouble()),
                      onChanged: (v) => ref.read(ttsPlayerSessionControllerProvider.notifier).seek(Duration(milliseconds: v.round())),
                    ),
                  ),
                  Text(_format(s.duration), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const NowPlayingTransport(),
            const NowPlayingUtilityRow(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze + commit**

```bash
cd app && flutter analyze lib/page/now_playing/now_playing_page.dart
git add app/lib/page/now_playing/now_playing_page.dart
git commit -m "feat(app): Now-Playing full-screen page"
```

---

## Phase D — Wire-up

### Task 11: AudiobookPage chapter tap → start session

**Files:** Modify `app/lib/page/audiobook/audiobook_page.dart`

- [ ] **Step 1: Replace `_downloadAndOpen` flow**

In the chapter tile, change the trailing button from "download and open in external player" to "play in Now-Playing". Find the existing `IconButton` with `Icons.download_outlined` and replace its `onPressed` with:

```dart
onPressed: () async {
  await ref.read(ttsPlayerSessionControllerProvider.notifier).startSession(
    book: widget.book,
    chapterIndex: chapter.chapterIndex,
  );
  if (!mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const NowPlayingPage(),
    ),
  );
},
```

Also change the icon from `Icons.download_outlined` to `Icons.play_arrow`.

- [ ] **Step 2: Add the new imports**

```dart
import 'package:omnigram/page/now_playing/now_playing_page.dart';
import 'package:omnigram/providers/tts_player_session_provider.dart';
```

- [ ] **Step 3: Analyze**

```bash
cd app && flutter analyze lib/page/audiobook/audiobook_page.dart
```

Expected: no errors. The old `_downloadAndOpen` method becomes dead code; delete it and its `_downloading` map field if they're now fully unused.

- [ ] **Step 4: Commit**

```bash
git add app/lib/page/audiobook/audiobook_page.dart
git commit -m "feat(app): AudiobookPage chapter tap launches Now-Playing session"
```

---

### Task 12: Mount MiniPlayerBar in OmnigramHome scaffold

**Files:** Modify `app/lib/page/omnigram_home.dart`

- [ ] **Step 1: Wrap the bottom area**

Find the `Scaffold` `bottomNavigationBar` (or equivalent) and wrap it so the mini bar sits *above* the nav:

```dart
bottomNavigationBar: Column(
  mainAxisSize: MainAxisSize.min,
  children: const [
    MiniPlayerBar(),
    /* existing nav widget */,
  ],
),
```

If the existing structure uses something other than `bottomNavigationBar`, slot the `MiniPlayerBar` into the same vertical position above primary navigation. Hunt for the structure with:

```bash
grep -n "bottomNavigationBar\|BottomNavigationBar\|NavigationBar\b" app/lib/page/omnigram_home.dart | head
```

- [ ] **Step 2: Add import**

```dart
import 'package:omnigram/widgets/tts/mini_player_bar.dart';
```

- [ ] **Step 3: Analyze + manual check**

```bash
cd app && flutter analyze lib/page/omnigram_home.dart
flutter run -d <device>
```

Open AudiobookPage for a book with at least one ready chapter, tap a chapter, return to home — mini bar should be visible across all four tabs.

- [ ] **Step 4: Commit**

```bash
git add app/lib/page/omnigram_home.dart
git commit -m "feat(app): mount MiniPlayerBar above bottom navigation"
```

---

### Task 13: Reader chapter drawer dots

**Files:** Modify reader chapter drawer widget

- [ ] **Step 1: Locate the reader chapter drawer**

```bash
grep -rn "ChapterListDrawer\|chapter.*drawer\|chapter.*list" app/lib/page/reader/ app/lib/widgets/reader/ 2>/dev/null | head
```

- [ ] **Step 2: Inject `ChapterStatusDot`**

In the chapter list item builder, after the chapter title row, add a small status dot that watches `audiobookProvider(bookId)` and resolves the per-chapter status. Reuse the same status mapping from `audiobook_page.dart`:

```dart
final asyncInfo = ref.watch(audiobookProvider(bookId));
final status = asyncInfo.maybeWhen(
  data: (info) {
    if (info == null) return ChapterAudioStatus.notGenerated;
    for (final c in info.chapters) {
      if (c.chapterIndex == chapterIndex) {
        return switch (c.status) {
          2 => ChapterAudioStatus.ready,
          1 => ChapterAudioStatus.generating,
          _ => ChapterAudioStatus.notGenerated,
        };
      }
    }
    return ChapterAudioStatus.notGenerated;
  },
  orElse: () => ChapterAudioStatus.notGenerated,
);
// Render: ChapterStatusDot(status: status)
```

- [ ] **Step 3: Analyze + commit**

```bash
cd app && flutter analyze <touched files>
git add <touched files>
git commit -m "feat(app): chapter status dots in reader chapter drawer"
```

If the existing drawer is too tangled to integrate cleanly, mark this task `DONE_WITH_CONCERNS` and ship without it — it's a small surface and can land separately.

---

### Task 14: L10n keys

**Files:** Modify `app/lib/l10n/app_en.arb` + `app_zh-CN.arb`

- [ ] **Step 1: Add keys**

Append (anchor: just before `ttsAdvanced`):

```json
"nowPlayingChapters": "Chapters",
"nowPlayingSleep": "Sleep",
"nowPlayingSleepArmed": "Stops in {minutes} min",
"@nowPlayingSleepArmed": {"placeholders": {"minutes": {"type": "int"}}},
"nowPlayingSleepCancel": "Cancel timer",
"pillLocalQueued": "Local voice · server preparing",
"pillServerProgress": "Server {percent}%",
"@pillServerProgress": {"placeholders": {"percent": {"type": "int"}}},
"pillServerReady": "High-quality version ready",
"pillSheetTitle": "You are listening with the local voice",
"pillSheetBody": "Your server cannot keep up in real time, so we are using the on-device voice for now. The server is preparing a higher-quality version in the background.",
"pillSheetForceLocal": "Always use local",
"pillSheetOk": "OK",
"upgradeToast": "Switched to high-quality version"
```

(Translate to zh-CN appropriately.)

- [ ] **Step 2: Replace literal strings in widgets** (`pill_detail_sheet.dart`, `sleep_timer_sheet.dart`, `server_status_pill.dart`, `now_playing_utility_row.dart`) to call `L10n.of(context).<key>`. The earlier tasks intentionally hardcoded zh strings to make iteration fast — switch to L10n now so other locales render correctly.

- [ ] **Step 3: Run gen-l10n + analyze**

```bash
cd app && flutter gen-l10n && flutter analyze lib/widgets/tts/ lib/page/now_playing/
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/l10n/ app/lib/widgets/tts/ app/lib/page/now_playing/
git commit -m "i18n(app): Now-Playing strings"
```

---

### Task 15: Update PROGRESS.md

**Files:** Modify `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: Update Sprint 8 entry**

Find the Sprint 8 section added in Plan 1, change the Plan 2 row from ⏳ to ✅:

```markdown
| Plan 2 · Now-Playing UX | ✅ | `service/tts/tts_player_session.dart` · `widgets/tts/{mini_player_bar,server_status_pill,sentence_stream,...}.dart` · `page/now_playing/now_playing_page.dart` |
```

Add an updated 更新记录 entry:

```markdown
| 2026-04-2X | **Sprint 8 · TTS Now-Playing Plan 2** ✅：`TtsPlayerSession` 编排器（章节边界自动升档、SSE 升档信号、句级高亮位置追踪），mini player bar 应用全局常驻，全屏 Now-Playing（封面 + 三句滚动 + 完整 transport + 速度/睡眠定时），`ServerStatusPill` 周边可见 + 详情 sheet，`AudiobookPage` 章节点击改为内置播放器，i18n 全覆盖。 |
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/PROGRESS.md
git commit -m "docs(progress): Sprint 8 plan-2 — Now-Playing complete"
```

---

## Verification checklist

- [ ] `cd app && flutter test test/service/tts/tts_player_session_test.dart` — 7 passing
- [ ] `cd app && flutter analyze lib/` — no new issues from this plan
- [ ] Manual: trigger probe RED tier (e.g., aim app at a slow server) → tap a not-yet-generated chapter in AudiobookPage → Now-Playing opens → audio plays via local fallback → 🟡 pill visible in mini bar + Now-Playing → SSE updates push 🔵 progress → when server completes the chapter, pill goes 🟢 → tap pill or wait for chapter end → toast "已切到高质量版本" appears, next chapter plays via PregenServer
- [ ] Manual: GREEN tier server → tap chapter → no pill appears, real-time playback starts immediately
- [ ] Manual: switch to a different tab while playing → mini bar stays visible, audio continues
- [ ] Manual: tap mini bar → Now-Playing opens; swipe down → returns to mini bar, audio still playing
- [ ] Manual: arm sleep timer for 1 min → audio pauses after 1 min
- [ ] Manual: tap a sentence in SentenceStream → audio jumps to that sentence's start
