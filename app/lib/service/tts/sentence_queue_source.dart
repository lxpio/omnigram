import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:omnigram/service/tts/sentence_splitter.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';

/// Function that synthesises one sentence to a local audio file. Returns the
/// absolute path. May be expensive (network round-trip or on-device model
/// inference); the source paralleises one sentence ahead via prefetch.
typedef SentenceSynthesizer = Future<String> Function(int sentenceIndex, Sentence sentence);

/// Drives sentence-by-sentence playback for live-synth modes (local fallback
/// + live server). The pre-gen mode has its own implementation since it plays
/// a single chapter mp3 and only needs sentence index for highlight.
///
/// Boundary gap: completion of one file → start of the next leaves a small
/// audible gap. We mask it by prefetching the next sentence while the current
/// one plays, so the start delay is just file-load latency in audioplayers.
class SentenceQueueSource implements TtsAudioSource {
  SentenceQueueSource({
    required this.sentences,
    required this.synthesize,
  });

  final List<Sentence> sentences;
  final SentenceSynthesizer synthesize;

  final _player = AudioPlayer();
  final _sentenceIndexController = StreamController<int>.broadcast();
  final _completionController = StreamController<void>.broadcast();

  /// Map sentenceIndex → cached synth file path. Survives seeks within
  /// chapter so going back/forward is instant after the first pass.
  final Map<int, String> _cache = {};

  /// In-flight synth futures keyed by sentenceIndex; avoids double-synth
  /// when prefetch races a tap-jump.
  final Map<int, Future<String>> _inflight = {};

  int _currentIndex = -1;
  bool _disposed = false;
  StreamSubscription<void>? _completeSub;

  @override
  Future<void> prepare() async {
    if (sentences.isEmpty) return;
    await _seekToInternal(0);
    _prefetchNext(1);
  }

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  /// Position scrubbing within the current sentence's audio file.
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> seekToSentence(int sentenceIndex) async {
    if (sentenceIndex < 0 || sentenceIndex >= sentences.length) return;
    await _seekToInternal(sentenceIndex);
    _prefetchNext(sentenceIndex + 1);
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _completeSub?.cancel();
    await _player.dispose();
    await _sentenceIndexController.close();
    await _completionController.close();
  }

  @override
  Stream<int> get sentenceIndexStream => _sentenceIndexController.stream;

  @override
  Stream<Duration> get positionStream => _player.onPositionChanged;

  @override
  Stream<void> get completionStream => _completionController.stream;

  // ── Internal ───────────────────────────────────────────────────────

  Future<void> _seekToInternal(int idx) async {
    _currentIndex = idx;
    final path = await _ensureSynth(idx);
    if (_disposed) return;
    await _player.setSource(DeviceFileSource(path));
    _sentenceIndexController.add(idx);

    // Wire chapter completion to advance into the next sentence (or close
    // out the chapter when this is the last one). We rebind on every seek
    // so prior subscriptions don't fire after a manual jump.
    await _completeSub?.cancel();
    _completeSub = _player.onPlayerComplete.listen((_) async {
      if (_disposed) return;
      final next = _currentIndex + 1;
      if (next >= sentences.length) {
        _completionController.add(null);
        return;
      }
      try {
        await _seekToInternal(next);
        _prefetchNext(next + 1);
        await _player.resume();
      } catch (_) {
        // Surface as completion so the session can decide what to do; an
        // upstream error already emitted on the synth path.
        _completionController.add(null);
      }
    });
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

  void _prefetchNext(int idx) {
    if (idx < 0 || idx >= sentences.length) return;
    if (_cache.containsKey(idx) || _inflight.containsKey(idx)) return;
    // Fire-and-forget. Errors logged via inflight clean-up; the next
    // _ensureSynth will retry.
    _ensureSynth(idx).catchError((_) => '');
  }
}
