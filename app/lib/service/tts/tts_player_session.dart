import 'dart:async';

import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/models/tts/playback_state.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:omnigram/service/tts/tts_router.dart';

typedef AudioSourceFactory = TtsAudioSource Function(PlaybackMode mode);
typedef ChapterTitleFetcher = Future<String> Function(int chapterIndex);
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
  final ChapterTitleFetcher fetchChapterTitle;
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
    _emit(_state.copyWith(
      position: position,
      sentenceIndex: sentenceIndexFor(alignment: _state.alignment, position: position),
    ));
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
    // The TtsAudioSource interface does not yet expose a rate setter; Plan 2
    // tracks speed in state for the UI, real audio rate plumbing is a
    // follow-up that extends the interface.
    _emit(_state.copyWith(speed: speed));
  }

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

  /// Binary-search the sentence containing `position`. Returns -1 when
  /// alignment is null or the position is before the first sentence.
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
