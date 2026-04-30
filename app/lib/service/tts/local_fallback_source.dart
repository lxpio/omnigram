import 'dart:async';
import 'dart:io';

import 'package:omnigram/service/tts/sentence_queue_source.dart';
import 'package:omnigram/service/tts/sentence_splitter.dart';
import 'package:omnigram/service/tts/sherpa_onnx_tts.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:path_provider/path_provider.dart';

/// On-device sherpa-onnx synthesis, sentence by sentence. Caches per-sentence
/// wav under the book's audiobook dir so repeated plays / scrubs are instant.
class LocalFallbackSource implements TtsAudioSource {
  LocalFallbackSource({
    required this.bookId,
    required this.chapterIndex,
    required this.voice,
    required this.sentences,
  }) {
    _inner = SentenceQueueSource(
      sentences: sentences,
      synthesize: _synthesize,
    );
  }

  final String bookId;
  final int chapterIndex;
  final String voice;
  final List<Sentence> sentences;

  late final SentenceQueueSource _inner;

  Future<String> _synthesize(int idx, Sentence sentence) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(
        '${docs.path}/audiobooks/$bookId/local/chapter_$chapterIndex');
    if (!await dir.exists()) await dir.create(recursive: true);
    final path = '${dir.path}/sent_$idx.wav';
    final file = File(path);
    if (!await file.exists()) {
      final wav = await SherpaOnnxProvider().speak(sentence.text, voice, 1.0, 1.0);
      await file.writeAsBytes(wav);
    }
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
