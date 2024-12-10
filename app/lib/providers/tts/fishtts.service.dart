import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:omnigram/entities/setting.entity.dart';

import 'package:http/http.dart' as http;
import 'package:omnigram/providers/api.provider.dart';

import 'tts.service.dart';

class FishTTSService implements TTS {
  final log = Logger('FishTTSService');

  final TTSConfig config;
  final http.Client _httpClient;
  bool _downloading;

  FishTTSService(this.config, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client(),
        _downloading = false;

  Future<void> clearCache() async {
    if (_downloading) {
      throw Exception("Cannot clear cache while download is in progress");
    }
    // _response = null;
    // final cacheFile = await this.cacheFile;
    // if (await cacheFile.exists()) {
    //   await cacheFile.delete();
    // }
    // final mimeFile = await _mimeFile;
    // if (await mimeFile.exists()) {
    //   await mimeFile.delete();
  }

  @override
  Future<Stream> gen(String content) async {
    _downloading = true;
    log.finest('Generating TTS for content: $content');

    final req = http.Request('POST', Uri.parse('${config.endpoint}/api/v1/tts'));

    final headers = ApiService.getDeviceHeaders();

    if (config.accessToken != null) {
      headers['Authorization'] = 'Bearer ${config.accessToken}';
    }
    req.headers.addAll(headers);

    req.body = json.encode(_reqBody(content));

    final httpResponse = await _httpClient.send(req);
    _downloading = false;
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
