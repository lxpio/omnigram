import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/service/api/tts_api.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:path_provider/path_provider.dart';

/// Plays a pre-generated chapter mp3 served by the audiobook task. Reuses the
/// server's alignment file to map playback position → sentence index so the
/// rest of the app can drive highlight uniformly across modes.
///
/// First play downloads the mp3 (and alignment) into the app docs dir;
/// subsequent plays / scrubs are local.
class PregenServerSource implements TtsAudioSource {
  PregenServerSource({
    required this.api,
    required this.bookId,
    required this.chapterIndex,
    required this.alignment,
  });

  final TtsApi api;
  final String bookId;
  final int chapterIndex;

  /// Required: maps playback time → sentence index. If the alignment is
  /// missing the session falls back to a different mode rather than using
  /// pregen.
  final ChapterAlignment alignment;

  final _player = AudioPlayer();
  final _sentenceIndexController = StreamController<int>.broadcast();
  StreamSubscription<Duration>? _posSub;
  int _lastEmittedIndex = -1;

  @override
  Future<void> prepare() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/audiobooks/$bookId');
    if (!await dir.exists()) await dir.create(recursive: true);
    final localPath = '${dir.path}/chapter_$chapterIndex.mp3';
    final file = File(localPath);
    if (!await file.exists()) {
      await api.downloadChapter(bookId, chapterIndex, localPath);
    }
    await _player.setSource(DeviceFileSource(localPath));

    _posSub = _player.onPositionChanged.listen((p) {
      final idx = _indexForMs(p.inMilliseconds);
      if (idx != _lastEmittedIndex) {
        _lastEmittedIndex = idx;
        _sentenceIndexController.add(idx);
      }
    });
  }

  @override
  Future<void> play() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> seekToSentence(int sentenceIndex) async {
    if (sentenceIndex < 0 || sentenceIndex >= alignment.sentences.length) return;
    final ms = alignment.sentences[sentenceIndex].startMs;
    await _player.seek(Duration(milliseconds: ms));
  }

  @override
  Future<void> dispose() async {
    await _posSub?.cancel();
    await _player.dispose();
    await _sentenceIndexController.close();
  }

  @override
  Stream<int> get sentenceIndexStream => _sentenceIndexController.stream;

  @override
  Stream<Duration> get positionStream => _player.onPositionChanged;

  @override
  Stream<void> get completionStream => _player.onPlayerComplete;

  int _indexForMs(int ms) {
    final ss = alignment.sentences;
    if (ss.isEmpty) return -1;
    if (ms < ss.first.startMs) return -1;
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
}
