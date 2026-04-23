import 'dart:async';
import 'dart:convert';
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
  ///
  /// Server response: `{code, message, data: {task, chapters}}`.
  Future<ServerAudiobookInfo> createAudiobook(String bookId) async {
    return _api.post('/tts/audiobook/$bookId', fromJson: _unwrapInfo);
  }

  /// Create audiobook for a specific chapter.
  Future<ServerAudiobookInfo> createChapterAudio(String bookId, int chapterIndex) async {
    return _api.post('/tts/audiobook/$bookId/chapter/$chapterIndex', fromJson: _unwrapInfo);
  }

  /// Get task status and chapter list.
  Future<ServerAudiobookInfo> getTaskStatus(String taskId) async {
    return _api.get('/tts/tasks/$taskId', fromJson: _unwrapInfo);
  }

  /// Get audiobook info for a book.
  Future<ServerAudiobookInfo> getAudiobook(String bookId) async {
    return _api.get('/tts/audiobook/$bookId', fromJson: _unwrapInfo);
  }

  /// Download audiobook chapter.
  Future<void> downloadChapter(String bookId, int chapter, String savePath) async {
    await _api.downloadFile('/tts/audiobook/$bookId/$chapter', savePath: savePath);
  }

  /// Fetch chapter alignment (sentence timings) — Sprint 7+.
  Future<ChapterAlignment> getChapterAlignment(String bookId, int chapter) async {
    return _api.get(
      '/tts/audiobook/$bookId/$chapter/alignment',
      fromJson: (data) => ChapterAlignment.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Fetch book-level audiobook manifest — Sprint 7+.
  ///
  /// Returns chapter list with durations and sentence counts; use before
  /// pulling individual alignment files so the player can show an accurate
  /// chapter strip / timeline.
  Future<AudiobookIndex> getAudiobookIndex(String bookId) async {
    return _api.get(
      '/tts/audiobook/$bookId/index',
      fromJson: (data) => AudiobookIndex.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Delete audiobook.
  Future<void> deleteAudiobook(String bookId) async {
    await _api.delete('/tts/audiobook/$bookId');
  }

  /// Subscribe to task progress via SSE.
  ///
  /// Server emits `data: {...task json...}\n\n` frames on `/tts/tasks/:id/stream`.
  /// Stream terminates when the task reaches a terminal status or the
  /// connection drops — callers handle resubscription if needed.
  Stream<ServerAudiobookTask> streamTask(String taskId) async* {
    final response = await _api.dio.get<ResponseBody>(
      '/tts/tasks/$taskId/stream',
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
    );
    final body = response.data;
    if (body == null) return;

    final buffer = StringBuffer();
    await for (final chunk in body.stream) {
      buffer.write(utf8.decode(chunk, allowMalformed: true));
      while (true) {
        final s = buffer.toString();
        final sep = s.indexOf('\n\n');
        if (sep < 0) break;
        final event = s.substring(0, sep);
        buffer
          ..clear()
          ..write(s.substring(sep + 2));

        for (final line in event.split('\n')) {
          if (!line.startsWith('data:')) continue;
          final payload = line.substring(5).trim();
          if (payload.isEmpty) continue;
          try {
            final map = jsonDecode(payload) as Map<String, dynamic>;
            yield ServerAudiobookTask.fromJson(map);
          } catch (_) {
            // Ignore malformed frame, keep stream alive.
          }
        }
      }
    }
  }
}

ServerAudiobookInfo _unwrapInfo(dynamic raw) {
  if (raw is! Map<String, dynamic>) {
    throw const FormatException('audiobook payload: expected object');
  }
  // Accept both wrapped ({code,message,data:{task,chapters}}) and bare ({task,chapters}).
  final inner = raw['data'] is Map<String, dynamic> ? raw['data'] as Map<String, dynamic> : raw;
  return ServerAudiobookInfo.fromJson(inner);
}
