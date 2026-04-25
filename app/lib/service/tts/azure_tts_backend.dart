import 'dart:convert';
import 'dart:typed_data';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:omnigram/service/tts/tts_service.dart';
import 'package:omnigram/service/tts/tts_service_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AzureTtsProvider extends TtsServiceProvider {
  static final AzureTtsProvider _instance = AzureTtsProvider._internal();

  factory AzureTtsProvider() {
    return _instance;
  }

  AzureTtsProvider._internal();

  @override
  TtsService get service => TtsService.azure;

  @override
  bool get isConfigured {
    final c = getConfig();
    final key = c['key']?.toString() ?? '';
    final region = c['region']?.toString() ?? '';
    return key.isNotEmpty && region.isNotEmpty;
  }

  @override
  String getLabel(BuildContext context) =>
      L10n.of(context).settingsNarrateAzureTts;

  @override
  List<ConfigItem> getConfigItems(BuildContext context) {
    return [
      ConfigItem(
        key: 'tip',
        label: L10n.of(context).translateTip,
        type: ConfigItemType.tip,
        defaultValue: L10n.of(context).settingsNarrateAzureHelpText,
        link: 'https://anx.anxcye.com/docs/tts/azure',
      ),
      ConfigItem(
        key: 'key',
        label: 'API Key',
        description: 'Azure TTS API Key',
        type: ConfigItemType.password,
        defaultValue: '',
      ),
      ConfigItem(
        key: 'region',
        label: 'Region',
        description: 'Azure TTS Region',
        type: ConfigItemType.text,
        defaultValue: 'global',
      ),
    ];
  }

  @override
  Map<String, dynamic> getConfig() {
    final config = Prefs().getOnlineTtsConfig(serviceId);
    // Apply defaults if config is empty
    if (config.isEmpty || (config['key'] == null && config['region'] == null)) {
      return {'key': '', 'region': 'global'};
    }
    return config;
  }

  @override
  void saveConfig(Map<String, dynamic> config) {
    Prefs().saveOnlineTtsConfig(serviceId, config);
  }

  @override
  Future<Uint8List> speak(
      String text, String? voice, double rate, double pitch) async {
    final config = getConfig();
    final String? key = config['key']?.toString();
    final String? region = config['region']?.toString();

    if (key == null || key.isEmpty || region == null || region.isEmpty) {
      throw Exception('Azure TTS config missing (key or region)');
    }

    final String url =
        "https://$region.tts.speech.microsoft.com/cognitiveservices/v1";

    final resolvedVoice = resolveVoice(voice);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Ocp-Apim-Subscription-Key': key,
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'audio-24khz-48kbitrate-mono-mp3',
        'User-Agent': 'Omnigram',
      },
      body: _createSsml(text, resolvedVoice, rate, pitch),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
          'Azure TTS failed: ${response.statusCode} ${response.body}');
    }
  }

  String _createSsml(String text, String voice, double rate, double pitch) {
    // Azure rate: relative value, e.g. +0.00%
    // App rate: 0.5 to 2.0 range, convert to SSML percentage.

    // Convert rate (0.2 ~ 3.0) to percentage string
    // 1.0 = 0%
    // 1.5 = +50%
    // 0.5 = -50%
    int ratePercent = ((rate - 1.0) * 100).toInt();
    String rateStr = ratePercent >= 0 ? "+$ratePercent%" : "$ratePercent%";

    // Convert pitch (0.5 ~ 2.0 typically)
    // Pitch from Prefs().ttsPitch, 1.0 base.
    int pitchPercent = ((pitch - 1.0) * 100).toInt();
    String pitchStr = pitchPercent >= 0 ? "+$pitchPercent%" : "$pitchPercent%";

    return '''
<speak version='1.0' xml:lang='en-US'>
<voice xml:lang='en-US' xml:gender='Female' name='$voice'>
<prosody rate='$rateStr' pitch='$pitchStr'>
$text
</prosody>
</voice>
</speak>
''';
  }

  @override
  Future<List<TtsVoice>> getVoices() async {
    final config = getConfig();
    final String? key = config['key']?.toString();
    final String? region = config['region']?.toString();

    if (key == null || key.isEmpty || region == null || region.isEmpty) {
      return [];
    }

    final String url =
        "https://$region.tts.speech.microsoft.com/cognitiveservices/voices/list";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Ocp-Apim-Subscription-Key': key,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => convertVoiceModel(e)).toList();
      } else {
        throw Exception('Failed to load voices: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty or rethrow?
      rethrow;
    }
  }

  @override
  TtsVoice convertVoiceModel(dynamic voiceData) {
    // Convert Azure voice model to app's standard format
    // Azure format: {"Name": "Microsoft Server Speech Text to Speech Voice (en-US, JennyNeural)", "ShortName": "en-US-JennyNeural", "Gender": "Female", "Locale": "en-US", ...}
    return TtsVoice(
      shortName: voiceData['ShortName'],
      name: voiceData['LocalName'] ?? voiceData['Name'],
      locale: voiceData['Locale'],
      gender: voiceData['Gender'],
      rawData: voiceData,
    );
  }
}
