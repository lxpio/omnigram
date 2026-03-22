import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:omnigram/service/tts/tts_service.dart';
import 'package:omnigram/service/tts/tts_service_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class EdgeTtsProvider extends TtsServiceProvider {
  static final EdgeTtsProvider _instance = EdgeTtsProvider._internal();

  factory EdgeTtsProvider() => _instance;

  EdgeTtsProvider._internal();

  static const String _trustedToken = '6A5AA1D4EAFF4E9FB37E23D68491D6F4';

  static const _uuid = Uuid();

  @override
  TtsService get service => TtsService.edge;

  @override
  String getLabel(BuildContext context) => 'Edge TTS ⚠️ Non-official API';

  @override
  List<ConfigItem> getConfigItems(BuildContext context) => [];

  @override
  Map<String, dynamic> getConfig() => {};

  @override
  void saveConfig(Map<String, dynamic> config) {}

  @override
  Future<Uint8List> speak(String text, String? voice, double rate, double pitch) async {
    final resolvedVoice = resolveVoice(voice);
    final lang = resolvedVoice.contains('-') ? resolvedVoice.split('-').sublist(0, 2).join('-') : 'en-US';
    final rateStr = _rateToString(rate);
    final connectionId = _uuid.v4().replaceAll('-', '');
    final requestId = _uuid.v4().replaceAll('-', '');

    final url =
        'wss://speech.platform.bing.com/consumer/speech/synthesize/'
        'readaloud/edge/v1'
        '?TrustedClientToken=$_trustedToken'
        '&ConnectionId=$connectionId';

    final ws = await WebSocket.connect(url);

    try {
      // Send config message
      ws.add(
        'Content-Type:application/json; charset=utf-8\r\n'
        'Path:speech.config\r\n'
        '\r\n'
        '{"context":{"synthesis":{"audio":{"metadataoptions":'
        '{"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"true"},'
        '"outputFormat":"audio-24khz-48kbitrate-mono-mp3"}}}}',
      );

      // Send SSML message
      final escapedText = _escapeXml(text);
      ws.add(
        'X-RequestId:$requestId\r\n'
        'Content-Type:application/ssml+xml\r\n'
        'Path:ssml\r\n'
        '\r\n'
        "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' "
        "xml:lang='$lang'>"
        "<voice name='$resolvedVoice'>"
        "<prosody pitch='+0Hz' rate='$rateStr' volume='+0%'>"
        '$escapedText'
        '</prosody></voice></speak>',
      );

      // Collect audio data
      final audioChunks = BytesBuilder(copy: false);

      await for (final message in ws) {
        if (message is List<int>) {
          // Binary frame: 2-byte header length (big-endian) + header + audio
          final data = message is Uint8List ? message : Uint8List.fromList(message);
          if (data.length < 2) continue;
          final headerLen = (data[0] << 8) | data[1];
          if (data.length < 2 + headerLen) continue;
          final header = utf8.decode(data.sublist(2, 2 + headerLen));
          if (header.contains('Path:audio')) {
            audioChunks.add(data.sublist(2 + headerLen));
          }
        } else if (message is String) {
          if (message.contains('Path:turn.end')) {
            break;
          }
        }
      }

      await ws.close();
      return audioChunks.toBytes();
    } catch (e) {
      await ws.close().catchError((_) {});
      rethrow;
    }
  }

  /// Converts rate (0.5–2.0) to Edge TTS percentage string.
  /// 1.0 → "+0%", 1.5 → "+50%", 0.5 → "-50%"
  String _rateToString(double rate) {
    final percent = ((rate - 1.0) * 100).round();
    return percent >= 0 ? '+$percent%' : '$percent%';
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  @override
  Future<List<TtsVoice>> getVoices() async {
    return const [
      // zh-CN
      TtsVoice(shortName: 'zh-CN-XiaoxiaoNeural', name: 'Xiaoxiao', locale: 'zh-CN', gender: 'Female'),
      TtsVoice(shortName: 'zh-CN-YunxiNeural', name: 'Yunxi', locale: 'zh-CN', gender: 'Male'),
      TtsVoice(shortName: 'zh-CN-YunjianNeural', name: 'Yunjian', locale: 'zh-CN', gender: 'Male'),
      // en-US
      TtsVoice(shortName: 'en-US-JennyNeural', name: 'Jenny', locale: 'en-US', gender: 'Female'),
      TtsVoice(shortName: 'en-US-GuyNeural', name: 'Guy', locale: 'en-US', gender: 'Male'),
      TtsVoice(shortName: 'en-US-AriaNeural', name: 'Aria', locale: 'en-US', gender: 'Female'),
      // en-GB
      TtsVoice(shortName: 'en-GB-SoniaNeural', name: 'Sonia', locale: 'en-GB', gender: 'Female'),
      TtsVoice(shortName: 'en-GB-RyanNeural', name: 'Ryan', locale: 'en-GB', gender: 'Male'),
      TtsVoice(shortName: 'en-GB-LibbyNeural', name: 'Libby', locale: 'en-GB', gender: 'Female'),
      // ja-JP
      TtsVoice(shortName: 'ja-JP-NanamiNeural', name: 'Nanami', locale: 'ja-JP', gender: 'Female'),
      TtsVoice(shortName: 'ja-JP-KeitaNeural', name: 'Keita', locale: 'ja-JP', gender: 'Male'),
      TtsVoice(shortName: 'ja-JP-AoiNeural', name: 'Aoi', locale: 'ja-JP', gender: 'Female'),
      // ko-KR
      TtsVoice(shortName: 'ko-KR-SunHiNeural', name: 'Sun-Hi', locale: 'ko-KR', gender: 'Female'),
      TtsVoice(shortName: 'ko-KR-InJoonNeural', name: 'InJoon', locale: 'ko-KR', gender: 'Male'),
      TtsVoice(shortName: 'ko-KR-BongJinNeural', name: 'BongJin', locale: 'ko-KR', gender: 'Male'),
      // de-DE
      TtsVoice(shortName: 'de-DE-KatjaNeural', name: 'Katja', locale: 'de-DE', gender: 'Female'),
      TtsVoice(shortName: 'de-DE-ConradNeural', name: 'Conrad', locale: 'de-DE', gender: 'Male'),
      TtsVoice(shortName: 'de-DE-AmalaNeural', name: 'Amala', locale: 'de-DE', gender: 'Female'),
      // fr-FR
      TtsVoice(shortName: 'fr-FR-DeniseNeural', name: 'Denise', locale: 'fr-FR', gender: 'Female'),
      TtsVoice(shortName: 'fr-FR-HenriNeural', name: 'Henri', locale: 'fr-FR', gender: 'Male'),
      TtsVoice(shortName: 'fr-FR-EloiseNeural', name: 'Eloise', locale: 'fr-FR', gender: 'Female'),
      // es-ES
      TtsVoice(shortName: 'es-ES-ElviraNeural', name: 'Elvira', locale: 'es-ES', gender: 'Female'),
      TtsVoice(shortName: 'es-ES-AlvaroNeural', name: 'Alvaro', locale: 'es-ES', gender: 'Male'),
      TtsVoice(shortName: 'es-ES-AbrilNeural', name: 'Abril', locale: 'es-ES', gender: 'Female'),
    ];
  }

  @override
  TtsVoice convertVoiceModel(dynamic voiceData) {
    if (voiceData is TtsVoice) return voiceData;
    if (voiceData is Map<String, dynamic>) {
      return TtsVoice.fromMap(voiceData);
    }
    return const TtsVoice(shortName: '', name: '', locale: '');
  }
}
