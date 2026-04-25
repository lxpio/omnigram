import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  // Keys mirror those in providers/server_connection_provider.dart so we can
  // reuse the logged-in connection without asking the user to retype them.
  static const String _kServerUrlPref = 'omnigram_server_url';
  static const String _kAccessTokenSecure = 'omnigram_access_token';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  TtsService get service => TtsService.server;

  @override
  String getLabel(BuildContext context) => 'Omnigram Server';

  @override
  List<ConfigItem> getConfigItems(BuildContext context) {
    // URL/token come from the logged-in server connection — no manual fields.
    return const [];
  }

  @override
  Map<String, dynamic> getConfig() {
    return {'url': _loggedInUrl() ?? _defaultUrl};
  }

  @override
  void saveConfig(Map<String, dynamic> config) {
    // Nothing to save; config is sourced from the active server connection.
  }

  String? _loggedInUrl() {
    final url = Prefs().prefs.getString(_kServerUrlPref)?.trim();
    if (url == null || url.isEmpty) return null;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  String _baseUrl() => _loggedInUrl() ?? _defaultUrl;

  Future<Map<String, String>> _headers() async {
    final token = await _secureStorage.read(key: _kAccessTokenSecure) ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Uint8List> speak(String text, String? voice, double rate, double pitch) async {
    final baseUrl = _baseUrl();
    final resolvedVoice = resolveVoice(voice);

    final response = await http.post(
      Uri.parse('$baseUrl/tts/synthesize'),
      headers: await _headers(),
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

    final response = await http.get(Uri.parse('$baseUrl/tts/voices'), headers: await _headers());

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
