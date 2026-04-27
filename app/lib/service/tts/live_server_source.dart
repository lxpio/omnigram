import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:omnigram/service/api/omnigram_api.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:path_provider/path_provider.dart';

/// Real-time server synthesis. Streams `/tts/synthesize` to a temp file then
/// hands it to audioplayers via DeviceFileSource — the file source path is
/// the most reliable on iOS (see commit dbe33135).
class LiveServerSource implements TtsAudioSource {
  LiveServerSource({
    required this.api,
    required this.bookId,
    required this.voice,
    required this.language,
    required Future<String> Function(int chapterIndex) fetchChapterText,
  }) : _fetchChapterText = fetchChapterText;

  final OmnigramApi api;
  final String bookId;
  final String voice;
  final String? language;
  final Future<String> Function(int) _fetchChapterText;

  final _player = AudioPlayer();
  File? _bufferFile;

  @override
  Future<void> prepare({required int chapterIndex}) async {
    final text = await _fetchChapterText(chapterIndex);
    final tmpDir = await getTemporaryDirectory();
    _bufferFile = File('${tmpDir.path}/live-$bookId-$chapterIndex.mp3');
    final response = await api.dio.post<ResponseBody>(
      '/tts/synthesize',
      data: {
        'text': text,
        'voice': voice,
        'speed': 1.0,
        'format': 'mp3',
        if (language != null) 'language': language,
      },
      options: Options(responseType: ResponseType.stream),
    );
    final body = response.data;
    if (body == null) {
      throw const SocketException('empty TTS response');
    }
    final sink = _bufferFile!.openWrite();
    await for (final chunk in body.stream) {
      sink.add(chunk);
    }
    await sink.close();
    await _player.setSource(DeviceFileSource(_bufferFile!.path));
  }

  @override
  Future<void> play() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() async {
    await _player.dispose();
    final f = _bufferFile;
    if (f != null && await f.exists()) {
      try {
        await f.delete();
      } catch (_) {}
    }
  }

  @override
  Stream<Duration> get positionStream => _player.onPositionChanged;
  @override
  Stream<void> get completionStream => _player.onPlayerComplete;
}
