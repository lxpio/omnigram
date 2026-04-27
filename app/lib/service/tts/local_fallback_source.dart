import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:omnigram/service/tts/sherpa_onnx_tts.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:path_provider/path_provider.dart';

/// On-device sherpa-onnx synthesis. Runs in an isolate via the existing
/// SherpaOnnxProvider, caches the resulting wav per (book, chapter) so
/// repeated plays are instant.
class LocalFallbackSource implements TtsAudioSource {
  LocalFallbackSource({
    required this.bookId,
    required this.voice,
    required Future<String> Function(int chapterIndex) fetchChapterText,
  }) : _fetchChapterText = fetchChapterText;

  final String bookId;
  final String voice;
  final Future<String> Function(int) _fetchChapterText;

  final _player = AudioPlayer();

  @override
  Future<void> prepare({required int chapterIndex}) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/audiobooks/$bookId/local');
    if (!await dir.exists()) await dir.create(recursive: true);
    final localPath = '${dir.path}/chapter_$chapterIndex.wav';

    final file = File(localPath);
    if (!await file.exists()) {
      final text = await _fetchChapterText(chapterIndex);
      final wav = await SherpaOnnxProvider().speak(text, voice, 1.0, 1.0);
      await file.writeAsBytes(wav);
    }
    await _player.setSource(DeviceFileSource(localPath));
  }

  @override
  Future<void> play() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();

  @override
  Stream<Duration> get positionStream => _player.onPositionChanged;
  @override
  Stream<void> get completionStream => _player.onPlayerComplete;
}
