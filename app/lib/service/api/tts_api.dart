import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../models/server/server_tts.dart';
import 'omnigram_api.dart';

/// Text-to-Speech API.
class TtsApi {
  TtsApi(this._api);
  final OmnigramApi _api;

  /// Synthesize text to speech (returns audio bytes).
  Future<Uint8List> synthesize({
    required String text,
    String? voice,
    double? speed,
    String format = 'mp3',
    String? language,
  }) async {
    final response = await _api.dio.post(
      '/tts/synthesize',
      data: {
        'text': text,
        if (voice != null) 'voice': voice,
        if (speed != null) 'speed': speed,
        'format': format,
        if (language != null) 'language': language,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }

  /// List available voices.
  Future<List<ServerVoice>> listVoices() async {
    return _api.getList('/tts/voices', fromJson: ServerVoice.fromJson);
  }

  /// Check TTS service health.
  Future<ServerTtsHealth> checkHealth() async {
    return _api.get('/tts/health', fromJson: (data) => ServerTtsHealth.fromJson(data));
  }

  // ── Audiobook Generation ────────────────────────────────────────

  /// Create audiobook for a book.
  Future<ServerAudiobookTask> createAudiobook(String bookId) async {
    return _api.post('/tts/audiobook/$bookId', fromJson: (data) => ServerAudiobookTask.fromJson(data));
  }

  /// Create audiobook for a specific chapter.
  Future<ServerAudiobookTask> createChapterAudio(String bookId, int chapterIndex) async {
    return _api.post(
      '/tts/audiobook/$bookId/chapter/$chapterIndex',
      fromJson: (data) => ServerAudiobookTask.fromJson(data),
    );
  }

  /// Get task status.
  Future<ServerAudiobookTask> getTaskStatus(String taskId) async {
    return _api.get('/tts/tasks/$taskId', fromJson: (data) => ServerAudiobookTask.fromJson(data));
  }

  /// Get audiobook info.
  Future<ServerAudiobookTask> getAudiobook(String bookId) async {
    return _api.get('/tts/audiobook/$bookId', fromJson: (data) => ServerAudiobookTask.fromJson(data));
  }

  /// Download audiobook chapter.
  Future<void> downloadChapter(String bookId, int chapter, String savePath) async {
    await _api.downloadFile('/tts/audiobook/$bookId/$chapter', savePath: savePath);
  }

  /// Delete audiobook.
  Future<void> deleteAudiobook(String bookId) async {
    await _api.delete('/tts/audiobook/$bookId');
  }
}
