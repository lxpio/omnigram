import 'dart:convert';
import 'dart:typed_data';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:omnigram/service/tts/tts_service.dart';
import 'package:omnigram/service/tts/tts_service_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class ServerTtsProvider extends TtsServiceProvider {
  static final ServerTtsProvider _instance = ServerTtsProvider._internal();

  factory ServerTtsProvider() {
    return _instance;
  }

  ServerTtsProvider._internal();

  static const String _defaultUrl = 'http://localhost:8080';

  @override
  TtsService get service => TtsService.server;

  @override
  String getLabel(BuildContext context) => 'Omnigram Server';

  @override
  List<ConfigItem> getConfigItems(BuildContext context) {
    return [
      ConfigItem(
        key: 'url',
        label: 'Server URL',
        description: 'Omnigram Server address (e.g. http://192.168.1.100:8080)',
        type: ConfigItemType.text,
        defaultValue: _defaultUrl,
      ),
      ConfigItem(
        key: 'token',
        label: 'Auth Token',
        description: 'OAuth Bearer token (optional)',
        type: ConfigItemType.password,
        defaultValue: '',
      ),
    ];
  }

  @override
  Map<String, dynamic> getConfig() {
    final config = Prefs().getOnlineTtsConfig(serviceId);
    if (config.isEmpty) {
      return {'url': _defaultUrl, 'token': ''};
    }
    return {'url': config['url'] ?? _defaultUrl, 'token': config['token'] ?? ''};
  }

  @override
  void saveConfig(Map<String, dynamic> config) {
    Prefs().saveOnlineTtsConfig(serviceId, config);
  }

  String _baseUrl() {
    final config = getConfig();
    final url = config['url']?.toString().trim() ?? _defaultUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> _headers() {
    final config = getConfig();
    final token = config['token']?.toString() ?? '';
    return {'Content-Type': 'application/json', if (token.isNotEmpty) 'Authorization': 'Bearer $token'};
  }

  @override
  Future<Uint8List> speak(String text, String? voice, double rate, double pitch) async {
    final baseUrl = _baseUrl();
    final resolvedVoice = resolveVoice(voice);

    final response = await http.post(
      Uri.parse('$baseUrl/tts/synthesize'),
      headers: _headers(),
      body: jsonEncode({'text': text, 'voice': resolvedVoice, 'speed': rate, 'format': 'mp3'}),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    throw Exception('Server TTS failed: ${response.statusCode} ${response.body}');
  }

  @override
  Future<List<TtsVoice>> getVoices() async {
    final baseUrl = _baseUrl();

    final response = await http.get(Uri.parse('$baseUrl/tts/voices'), headers: _headers());

    if (response.statusCode != 200) {
      throw Exception('Server TTS voices failed: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>? ?? [];

    return data.map((v) {
      final map = v as Map<String, dynamic>;
      return TtsVoice(
        shortName: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        locale: map['language']?.toString() ?? '',
        gender: map['gender']?.toString() ?? '',
      );
    }).toList();
  }

  @override
  TtsVoice convertVoiceModel(dynamic voiceData) {
    if (voiceData is TtsVoice) return voiceData;
    if (voiceData is Map<String, dynamic>) {
      return TtsVoice(
        shortName: voiceData['id']?.toString() ?? '',
        name: voiceData['name']?.toString() ?? '',
        locale: voiceData['language']?.toString() ?? '',
        gender: voiceData['gender']?.toString() ?? '',
      );
    }
    return const TtsVoice(shortName: '', name: '', locale: '');
  }
}
