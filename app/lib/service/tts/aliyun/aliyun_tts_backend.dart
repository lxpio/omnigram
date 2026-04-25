import 'dart:convert';
import 'dart:typed_data';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/tts/aliyun/aliyun_voices.dart';
import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:omnigram/service/tts/tts_service.dart';
import 'package:omnigram/service/tts/tts_service_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AliyunTtsProvider extends TtsServiceProvider {
  static final AliyunTtsProvider _instance = AliyunTtsProvider._internal();

  factory AliyunTtsProvider() {
    return _instance;
  }

  AliyunTtsProvider._internal();

  static const String _defaultUrl =
      'https://nls-gateway.aliyuncs.com/stream/v1/tts';
  static const String _defaultVoice = 'xiaoyun';
  static const String _tokenHost = 'nls-meta.cn-shanghai.aliyuncs.com';
  static const String _tokenRegionId = 'cn-shanghai';
  static const int _tokenRefreshBufferSeconds = 300;
  static const _uuid = Uuid();

  String? _cachedToken;
  int? _tokenExpireTimeSec;
  Future<void>? _refreshingToken;

  @override
  TtsService get service => TtsService.aliyun;

  @override
  bool get isConfigured {
    final c = getConfig();
    final appkey = c['appkey']?.toString() ?? '';
    final id = c['accessKeyId']?.toString() ?? '';
    final secret = c['accessKeySecret']?.toString() ?? '';
    return appkey.isNotEmpty && id.isNotEmpty && secret.isNotEmpty;
  }

  @override
  String getLabel(BuildContext context) =>
      L10n.of(context).settingsNarrateAliyunTts;

  @override
  List<ConfigItem> getConfigItems(BuildContext context) {
    return [
      ConfigItem(
        key: 'tip',
        label: L10n.of(context).translateTip,
        type: ConfigItemType.tip,
        defaultValue: L10n.of(context).settingsNarrateAliyunHelpText,
        link: 'https://anx.anxcye.com/docs/tts/aliyun',
      ),
      ConfigItem(
        key: 'appkey',
        label: 'App Key',
        type: ConfigItemType.text,
        defaultValue: '',
      ),
      ConfigItem(
        key: 'accessKeyId',
        label: 'Access Key ID',
        type: ConfigItemType.text,
        defaultValue: '',
      ),
      ConfigItem(
        key: 'accessKeySecret',
        label: 'Access Key Secret',
        type: ConfigItemType.password,
        defaultValue: '',
      ),
      ConfigItem(
        key: 'url',
        label: 'Endpoint',
        description: L10n.of(context).settingsNarrateAliyunEndpointTip,
        type: ConfigItemType.select,
        defaultValue: _defaultUrl,
        options: [
          {
            'label': L10n.of(context).settingsNarrateAliyunEndpointAutoLabel,
            'value': 'https://nls-gateway.aliyuncs.com/stream/v1/tts',
          },
          {
            'label': 'Shanghai',
            'value':
                'https://nls-gateway-cn-shanghai.aliyuncs.com/stream/v1/tts',
          },
          {
            'label': 'Beijing',
            'value':
                'https://nls-gateway-cn-beijing.aliyuncs.com/stream/v1/tts',
          },
          {
            'label': 'Shenzhen',
            'value':
                'https://nls-gateway-cn-shenzhen.aliyuncs.com/stream/v1/tts',
          },
        ],
      ),
    ];
  }

  @override
  Map<String, dynamic> getConfig() {
    final config = Prefs().getOnlineTtsConfig(serviceId);
    if (config.isEmpty) {
      return {
        'appkey': '',
        'accessKeyId': '',
        'accessKeySecret': '',
        'url': _defaultUrl,
        'voice': _defaultVoice,
      };
    }
    return {
      'appkey': config['appkey'] ?? '',
      'accessKeyId': config['accessKeyId'] ?? '',
      'accessKeySecret': config['accessKeySecret'] ?? '',
      'url': config['url'] ?? _defaultUrl,
      'voice': config['voice'] ?? _defaultVoice,
    };
  }

  @override
  void saveConfig(Map<String, dynamic> config) {
    Prefs().saveOnlineTtsConfig(serviceId, config);
  }

  @override
  Future<Uint8List> speak(
      String text, String? voice, double rate, double pitch) async {
    final config = getConfig();
    final String? appkey = config['appkey']?.toString().trim();
    final String? accessKeyId = config['accessKeyId']?.toString().trim();
    final String? accessKeySecret =
        config['accessKeySecret']?.toString().trim();
    final String url = config['url']?.toString().trim() ?? _defaultUrl;

    if (appkey == null || appkey.isEmpty) {
      throw Exception('Aliyun TTS config missing (appkey)');
    }
    if (accessKeyId == null || accessKeyId.isEmpty) {
      throw Exception('Aliyun TTS config missing (accessKeyId)');
    }
    if (accessKeySecret == null || accessKeySecret.isEmpty) {
      throw Exception('Aliyun TTS config missing (accessKeySecret)');
    }

    final token = await _ensureToken(accessKeyId, accessKeySecret);
    final resolvedVoice = resolveVoice(voice);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'appkey': appkey,
        'token': token,
        'text': text,
        'format': 'mp3',
        'sample_rate': 16000,
        'voice': resolvedVoice,
        'speech_rate': _toAliyunRate(rate),
        'pitch_rate': _toAliyunRate(pitch),
      }),
    );

    final contentType = response.headers['content-type'];
    if (contentType != null && contentType.toLowerCase().startsWith('audio/')) {
      return response.bodyBytes;
    }

    final errorBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    throw Exception('Aliyun TTS failed: ${response.statusCode} $errorBody');
  }

  int _toAliyunRate(double value) {
    final scaled = ((value - 1.0) * 500).round();
    if (scaled > 500) return 500;
    if (scaled < -500) return -500;
    return scaled;
  }

  Future<String> _ensureToken(
      String accessKeyId, String accessKeySecret) async {
    final nowSec = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final expireTime = _tokenExpireTimeSec ?? 0;
    if (_cachedToken != null &&
        nowSec + _tokenRefreshBufferSeconds < expireTime) {
      return _cachedToken!;
    }

    if (_refreshingToken != null) {
      await _refreshingToken;
      if (_cachedToken != null) return _cachedToken!;
    }

    _refreshingToken = _requestToken(accessKeyId, accessKeySecret);
    try {
      await _refreshingToken;
    } finally {
      _refreshingToken = null;
    }
    if (_cachedToken == null) {
      throw Exception('Aliyun TTS token request failed');
    }
    return _cachedToken!;
  }

  Future<void> _requestToken(String accessKeyId, String accessKeySecret) async {
    final timestamp = _iso8601Time();
    final nonce = _uuid.v4();
    final params = <String, String>{
      'AccessKeyId': accessKeyId,
      'Action': 'CreateToken',
      'Version': '2019-02-28',
      'Format': 'JSON',
      'RegionId': _tokenRegionId,
      'SignatureMethod': 'HMAC-SHA1',
      'SignatureVersion': '1.0',
      'SignatureNonce': nonce,
      'Timestamp': timestamp,
    };

    final queryString = _canonicalizedQuery(params);
    final stringToSign = _createStringToSign('GET', '/', queryString);
    final signature = _sign(stringToSign, '${accessKeySecret}&');
    final signedQuery = 'Signature=$signature&$queryString';
    final url = Uri.parse('https://$_tokenHost/?$signedQuery');

    final response = await http.get(url, headers: {
      'Accept': 'application/json',
    });

    final responseBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (response.statusCode != 200) {
      throw Exception(
          'Aliyun token request failed: ${response.statusCode} $responseBody');
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final tokenObj = data['Token'];
    if (tokenObj is Map<String, dynamic>) {
      final token = tokenObj['Id']?.toString();
      final expire = tokenObj['ExpireTime'];
      final expireTime =
          expire is int ? expire : int.tryParse(expire?.toString() ?? '');
      if (token != null && token.isNotEmpty && expireTime != null) {
        _cachedToken = token;
        _tokenExpireTimeSec = expireTime;
        return;
      }
    }
    throw Exception('Aliyun token response invalid: $responseBody');
  }

  String _iso8601Time() {
    final now = DateTime.now().toUtc();
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${now.year}-${two(now.month)}-${two(now.day)}'
        'T${two(now.hour)}:${two(now.minute)}:${two(now.second)}Z';
  }

  String _percentEncode(String value) {
    return Uri.encodeQueryComponent(value)
        .replaceAll('+', '%20')
        .replaceAll('*', '%2A')
        .replaceAll('%7E', '~');
  }

  String _canonicalizedQuery(Map<String, String> params) {
    final keys = params.keys.toList()..sort();
    final parts = <String>[];
    for (final key in keys) {
      parts.add('${_percentEncode(key)}=${_percentEncode(params[key]!)}');
    }
    return parts.join('&');
  }

  String _createStringToSign(String method, String path, String queryString) {
    return '$method&${_percentEncode(path)}&${_percentEncode(queryString)}';
  }

  String _sign(String stringToSign, String secret) {
    final key = utf8.encode(secret);
    final message = utf8.encode(stringToSign);
    final digest = Hmac(sha1, key).convert(message);
    final signature = base64.encode(digest.bytes);
    return _percentEncode(signature);
  }

  @override
  Future<List<TtsVoice>> getVoices() async {
    return aliyunVoices;
  }

  @override
  TtsVoice convertVoiceModel(dynamic voiceData) {
    if (voiceData is TtsVoice) return voiceData;
    if (voiceData is Map<String, dynamic>) {
      return TtsVoice.fromMap(voiceData);
    }
    return const TtsVoice(shortName: '', name: '', locale: '');
  }

  @override
  String getSelectedVoice() {
    final config = getConfig();
    final voice = config['voice']?.toString() ?? '';
    if (voice.isNotEmpty) return voice;
    return _defaultVoice;
  }

  @override
  void setSelectedVoice(String voice) {
    final config = getConfig();
    config['voice'] = voice;
    saveConfig(config);
  }
}
