import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:omnigram/entities/setting.entity.dart';

import 'package:http/http.dart' as http;

import 'tts.service.dart';

class FishTTSService extends TTS {
  final log = Logger('FishTTSService');

  final TTSConfig config;
  final http.Client _httpClient;

  FishTTSService(this.config, {http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  @override
  Future<Stream> gen(String content) async {
    log.finest('Generating TTS for content: $content');

    final req = http.Request('POST', Uri.parse('${config.endpoint}/v1/tts'));

    // final headers = ApiService.getDeviceHeaders();
    final headers = <String, String>{};

    headers['Content-Type'] = 'application/json';

    if (config.accessToken != null) {
      headers['Authorization'] = 'Bearer ${config.accessToken}';
    }
    req.headers.addAll(headers);

    req.body = json.encode(_reqBody(content));
    // req.contentLength = req.body.length;

    final httpResponse = await _httpClient.send(req);

    return httpResponse.stream;
  }

  Object? _reqBody(String text) {
    return {
      'text': text,
      'chunk_length': 200,
      'format': 'mp3',
      'mp3_bitrate': 64,
      'references': [],
      'reference_id': config.voiceId,
      'seed': null,
      // 'use_memory_cache': 'never',
      'normalize': true,
      'opus_bitrate': -1000,
      'latency': 'normal',
      'streaming': false,
      'max_new_tokens': config.maxNewTokens,
      'top_p': config.topP,
      'repetition_penalty': config.repetitionRenalty,
      'temperature': config.temperature,
    };
  }
}
