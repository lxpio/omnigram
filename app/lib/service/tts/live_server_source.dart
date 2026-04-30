import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:omnigram/service/api/omnigram_api.dart';
import 'package:omnigram/service/tts/sentence_queue_source.dart';
import 'package:omnigram/service/tts/sentence_splitter.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:path_provider/path_provider.dart';

/// Real-time server synthesis, sentence by sentence. Each sentence is POSTed
/// to `/tts/synthesize` and streamed to a temp mp3 file.
class LiveServerSource implements TtsAudioSource {
  LiveServerSource({
    required this.api,
    required this.bookId,
    required this.chapterIndex,
    required this.voice,
    required this.language,
    required this.sentences,
  }) {
    _inner = SentenceQueueSource(
      sentences: sentences,
      synthesize: _synthesize,
    );
  }

  final OmnigramApi api;
  final String bookId;
  final int chapterIndex;
  final String voice;
  final String? language;
  final List<Sentence> sentences;

  late final SentenceQueueSource _inner;

  Future<String> _synthesize(int idx, Sentence sentence) async {
    final tmpDir = await getTemporaryDirectory();
    final dir = Directory('${tmpDir.path}/live-tts/$bookId/$chapterIndex');
    if (!await dir.exists()) await dir.create(recursive: true);
    final path = '${dir.path}/sent_$idx.mp3';
    final file = File(path);
    if (await file.exists()) return path;

    final response = await api.dio.post<ResponseBody>(
      '/tts/synthesize',
      data: {
        'text': sentence.text,
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
    final sink = file.openWrite();
    await for (final chunk in body.stream) {
      sink.add(chunk);
    }
    await sink.close();
    return path;
  }

  @override
  Future<void> prepare() => _inner.prepare();
  @override
  Future<void> play() => _inner.play();
  @override
  Future<void> pause() => _inner.pause();
  @override
  Future<void> seek(Duration position) => _inner.seek(position);
  @override
  Future<void> seekToSentence(int sentenceIndex) => _inner.seekToSentence(sentenceIndex);
  @override
  Future<void> dispose() => _inner.dispose();
  @override
  Stream<int> get sentenceIndexStream => _inner.sentenceIndexStream;
  @override
  Stream<Duration> get positionStream => _inner.positionStream;
  @override
  Stream<void> get completionStream => _inner.completionStream;
}
