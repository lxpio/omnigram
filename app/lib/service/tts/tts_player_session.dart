import 'dart:async';

import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/models/tts/playback_state.dart';
import 'package:omnigram/service/tts/sentence_splitter.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:omnigram/service/tts/tts_router.dart';

typedef AudioSourceFactory = TtsAudioSource Function({
  required PlaybackMode mode,
  required int chapterIndex,
  required List<Sentence> sentences,
  ChapterAlignment? alignment,
});
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
    required this.chapterTitles,
    required this.fetchChapterText,
    required this.fetchChapterAlignment,
    required this.audioSourceFactory,
    required this.modeResolver,
    required this.prefetchHook,
    required this.upgradeToast,
  });

  final String bookId;
  final String bookTitle;
  final String? coverUrl;
  final List<String> chapterTitles;
  final ChapterTextFetcher fetchChapterText;
  final ChapterAlignmentFetcher fetchChapterAlignment;
  final AudioSourceFactory audioSourceFactory;
  final ModeResolver modeResolver;
  final PrefetchHook prefetchHook;
  final UpgradeToast upgradeToast;

  int get totalChapters => chapterTitles.length;

  String _titleAt(int idx) {
    if (idx < 0 || idx >= chapterTitles.length) return '#${idx + 1}';
    final t = chapterTitles[idx];
    return t.isEmpty ? '#${idx + 1}' : t;
  }

  TtsAudioSource? _source;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<int>? _idxSub;
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
      chapterTitles: chapterTitles,
      chapterIndex: chapterIndex,
      chapterTitle: _titleAt(chapterIndex),
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

    // Local-first: pull plain chapter text from the book, split into sentences
    // app-side, then drive whichever source matches the resolved mode. Pre-gen
    // additionally needs the server's alignment (for position → sentence
    // index mapping inside the chapter mp3); the other modes synthesise per
    // sentence and don't use it.
    final text = await fetchChapterText(chapterIndex);
    final sentences = splitSentences(text);
    if (sentences.isEmpty) {
      _emit(_state.copyWith(
        isPreparing: false,
        errorMessage: 'Chapter has no readable text',
      ));
      return;
    }

    final alignment = mode == PlaybackMode.pregenServer
        ? await fetchChapterAlignment(chapterIndex)
        : null;
    if (mode == PlaybackMode.pregenServer && alignment == null) {
      _emit(_state.copyWith(
        isPreparing: false,
        errorMessage: 'Pre-gen alignment missing',
      ));
      return;
    }

    final source = audioSourceFactory(
      mode: mode,
      chapterIndex: chapterIndex,
      sentences: sentences,
      alignment: alignment,
    );
    _source = source;
    try {
      await source.prepare();
    } catch (e) {
      _emit(_state.copyWith(isPreparing: false, errorMessage: e.toString()));
      return;
    }

    _idxSub = source.sentenceIndexStream.listen(_onSentenceIndex);
    _posSub = source.positionStream.listen(_onPosition);
    _completeSub = source.completionStream.listen((_) => _onChapterComplete());

    if (_state.speed != 1.0) {
      await source.setSpeed(_state.speed);
    }

    _emit(_state.copyWith(
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
    _emit(_state.copyWith(position: position));
  }

  Future<void> seekToSentence(int sentenceIdx) async {
    final s = _source;
    if (s == null) return;
    await s.seekToSentence(sentenceIdx);
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
    await _source?.setSpeed(speed);
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
    _emit(_state.copyWith(position: p));
  }

  void _onSentenceIndex(int idx) {
    if (idx == _state.sentenceIndex) return;
    _emit(_state.copyWith(sentenceIndex: idx));
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
    await _idxSub?.cancel();
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
