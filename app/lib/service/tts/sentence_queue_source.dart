import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:omnigram/service/tts/sentence_splitter.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';

/// Function that synthesises one sentence to a local audio file. Returns the
/// absolute path. May be expensive (network round-trip or on-device model
/// inference); the source parallelises one sentence ahead via prefetch.
typedef SentenceSynthesizer = Future<String> Function(int sentenceIndex, Sentence sentence);

/// Drives sentence-by-sentence playback for live-synth modes (local fallback
/// + live server). The pre-gen mode has its own implementation since it plays
/// a single chapter mp3 and only needs sentence index for highlight.
///
/// Gapless transitions: we keep two `AudioPlayer` instances ping-ponging.
/// While one is playing, the other pre-loads the next sentence's file in the
/// background; on completion we swap roles instead of paying setSource cost
/// in front of the user. If the next file isn't ready yet (synth still in
/// flight) we fall back to loading on the active player — there's an audible
/// gap, but only for that one transition.
class SentenceQueueSource implements TtsAudioSource {
  SentenceQueueSource({
    required this.sentences,
    required this.synthesize,
  });

  final List<Sentence> sentences;
  final SentenceSynthesizer synthesize;

  final _playerA = AudioPlayer();
  final _playerB = AudioPlayer();
  int _activeIdx = 0;
  AudioPlayer get _active => _activeIdx == 0 ? _playerA : _playerB;
  AudioPlayer get _idle => _activeIdx == 0 ? _playerB : _playerA;

  /// Sentence index currently loaded on the idle player. -1 = nothing loaded
  /// (e.g., after a seek before the next preload completes).
  int _idleLoadedForIndex = -1;

  final _sentenceIndexController = StreamController<int>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _completionController = StreamController<void>.broadcast();

  /// Path cache survives chapter — going back/forward to a prior sentence
  /// reuses the synth file rather than re-running the model / API.
  final Map<int, String> _cache = {};
  final Map<int, Future<String>> _inflight = {};

  int _currentIndex = -1;
  bool _disposed = false;
  double _speed = 1.0;

  StreamSubscription<Duration>? _activePosSub;
  StreamSubscription<Duration>? _activeDurSub;
  StreamSubscription<void>? _activeCompleteSub;

  @override
  Future<void> prepare() async {
    if (sentences.isEmpty) return;
    await _seekToInternal(0);
  }

  @override
  Future<void> play() => _active.resume();

  @override
  Future<void> pause() => _active.pause();

  @override
  Future<void> seek(Duration position) => _active.seek(position);

  @override
  Future<void> seekToSentence(int sentenceIndex) async {
    if (sentenceIndex < 0 || sentenceIndex >= sentences.length) return;
    // Drop whatever the idle player had — likely stale after a jump.
    await _idle.stop();
    _idleLoadedForIndex = -1;
    await _seekToInternal(sentenceIndex);
  }

  @override
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    // Only the active player has a loaded source — calling setPlaybackRate
    // on a player without a source throws on iOS. The idle player gets the
    // rate applied later, in _preloadIdle / cold-path setSource, both of
    // which read _speed after attaching the file.
    try {
      await _active.setPlaybackRate(speed);
    } catch (_) {
      // Ignore — happens if active hasn't loaded yet (e.g., setSpeed called
      // before the very first prepare). _seekToInternal will re-apply rate
      // once the source is set.
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _activePosSub?.cancel();
    await _activeDurSub?.cancel();
    await _activeCompleteSub?.cancel();
    await _playerA.dispose();
    await _playerB.dispose();
    await _sentenceIndexController.close();
    await _positionController.close();
    await _durationController.close();
    await _completionController.close();
  }

  @override
  Stream<int> get sentenceIndexStream => _sentenceIndexController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Stream<void> get completionStream => _completionController.stream;

  // ── Internal ───────────────────────────────────────────────────────

  /// Load sentence [idx] into the active player from scratch. Used on initial
  /// prepare and on user seeks; chapter-progression transitions use the
  /// faster swap path in `_onActiveComplete`.
  Future<void> _seekToInternal(int idx) async {
    _currentIndex = idx;
    final path = await _ensureSynth(idx);
    if (_disposed) return;
    await _active.setSource(DeviceFileSource(path));
    if (_speed != 1.0) {
      await _active.setPlaybackRate(_speed);
    }
    _sentenceIndexController.add(idx);
    _bindActive();
    _preloadIdle(idx + 1);
  }

  /// Re-route position + completion streams from whoever is active right now.
  /// Called after every active swap so stale events from the previous active
  /// don't leak into the public streams.
  void _bindActive() {
    _activePosSub?.cancel();
    _activeDurSub?.cancel();
    _activeCompleteSub?.cancel();
    _activePosSub = _active.onPositionChanged.listen(_positionController.add);
    _activeDurSub = _active.onDurationChanged.listen(_durationController.add);
    _activeCompleteSub = _active.onPlayerComplete.listen((_) => _onActiveComplete());
  }

  Future<void> _onActiveComplete() async {
    if (_disposed) return;
    final next = _currentIndex + 1;
    if (next >= sentences.length) {
      _completionController.add(null);
      return;
    }
    _currentIndex = next;

    if (_idleLoadedForIndex == next) {
      // Hot path: idle has next loaded → swap and resume. Sub-100ms gap.
      _activeIdx = 1 - _activeIdx;
      _idleLoadedForIndex = -1;
      _bindActive();
      _sentenceIndexController.add(next);
      try {
        await _active.resume();
      } catch (_) {
        _completionController.add(null);
        return;
      }
      _preloadIdle(next + 1);
      return;
    }

    // Cold path: synth wasn't ready in time. Load + play on the active
    // player; there's an audible gap but only this once.
    try {
      final path = await _ensureSynth(next);
      if (_disposed) return;
      await _active.setSource(DeviceFileSource(path));
      if (_speed != 1.0) {
        await _active.setPlaybackRate(_speed);
      }
      _bindActive();
      _sentenceIndexController.add(next);
      await _active.resume();
      _preloadIdle(next + 1);
    } catch (_) {
      _completionController.add(null);
    }
  }

  /// Pre-load sentence [idx] onto the idle player so the next chapter
  /// transition is gapless. Cooperative — silently no-ops if the user has
  /// since seeked away (idleLoadedForIndex would be invalidated by the seek).
  Future<void> _preloadIdle(int idx) async {
    if (idx < 0 || idx >= sentences.length) {
      _idleLoadedForIndex = -1;
      return;
    }
    final targetActiveIdx = _activeIdx;
    try {
      final path = await _ensureSynth(idx);
      if (_disposed) return;
      // If user seeked / chapter advanced while we were synthesising, the
      // idx we set up to preload is no longer "next" — drop it.
      if (_currentIndex + 1 != idx) return;
      // Or if the active swapped in the meantime, abort.
      if (_activeIdx != targetActiveIdx) return;
      await _idle.setSource(DeviceFileSource(path));
      if (_speed != 1.0) {
        await _idle.setPlaybackRate(_speed);
      }
      _idleLoadedForIndex = idx;
    } catch (_) {
      // Synth failure — leave idle empty; cold path will try again at
      // transition time.
    }
  }

  Future<String> _ensureSynth(int idx) async {
    final cached = _cache[idx];
    if (cached != null && File(cached).existsSync()) return cached;
    final inflight = _inflight[idx];
    if (inflight != null) return inflight;
    final fut = synthesize(idx, sentences[idx]).then((path) {
      _cache[idx] = path;
      _inflight.remove(idx);
      return path;
    }).catchError((Object e) {
      _inflight.remove(idx);
      throw e;
    });
    _inflight[idx] = fut;
    return fut;
  }
}
