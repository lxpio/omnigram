import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:omnigram/service/api/tts_api.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:path_provider/path_provider.dart';

/// Plays pre-generated chapter audio files from the server. The first time a
/// chapter is requested we download to app docs dir; subsequent plays are
/// local. Same caching key as `AudiobookPage`.
class PregenServerSource implements TtsAudioSource {
  PregenServerSource({required this.api, required this.bookId});

  final TtsApi api;
  final String bookId;

  final _player = AudioPlayer();

  @override
  Future<void> prepare({required int chapterIndex}) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/audiobooks/$bookId');
    if (!await dir.exists()) await dir.create(recursive: true);
    final localPath = '${dir.path}/chapter_$chapterIndex.mp3';

    final file = File(localPath);
    if (!await file.exists()) {
      await api.downloadChapter(bookId, chapterIndex, localPath);
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
