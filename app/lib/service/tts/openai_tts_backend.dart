import 'dart:convert';
import 'dart:typed_data';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:omnigram/service/tts/tts_service.dart';
import 'package:omnigram/service/tts/tts_service_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class OpenAiTtsProvider extends TtsServiceProvider {
  static final OpenAiTtsProvider _instance = OpenAiTtsProvider._internal();

  factory OpenAiTtsProvider() {
    return _instance;
  }

  OpenAiTtsProvider._internal();

  static const String _defaultUrl = 'https://api.openai.com/v1/audio/speech';
  static const String _defaultModel = 'gpt-4o-mini-tts';
  static const String _defaultVoice = 'alloy';

  @override
  TtsService get service => TtsService.openai;

  @override
  bool get isConfigured {
    final key = getConfig()['key']?.toString() ?? '';
    return key.isNotEmpty;
  }

  @override
  String getLabel(BuildContext context) =>
      L10n.of(context).settingsNarrateOpenAiTts;

  @override
  List<ConfigItem> getConfigItems(BuildContext context) {
    return [
      ConfigItem(
        key: 'tip',
        label: L10n.of(context).translateTip,
        type: ConfigItemType.tip,
        defaultValue: L10n.of(context).settingsNarrateOpenAiHelpText,
        link: 'https://anx.anxcye.com/docs/tts/openai',
      ),
      ConfigItem(
        key: 'url',
        label: 'URL',
        description: L10n.of(context).settingsNarrateOpenAiUrlDescription,
        type: ConfigItemType.text,
        defaultValue: _defaultUrl,
      ),
      ConfigItem(
        key: 'key',
        label: 'API Key',
        description: L10n.of(context).settingsNarrateOpenAiKeyDescription,
        type: ConfigItemType.password,
        defaultValue: '',
      ),
      ConfigItem(
        key: 'model',
        label: 'Model',
        description: L10n.of(context).settingsNarrateOpenAiModelDescription,
        type: ConfigItemType.text,
        defaultValue: _defaultModel,
      ),
      ConfigItem(
        key: 'voice',
        label: 'Voice',
        description: L10n.of(context).settingsNarrateOpenAiVoiceDescription,
        type: ConfigItemType.text,
        defaultValue: _defaultVoice,
      ),
      ConfigItem(
        key: 'instructions',
        label: 'Instructions',
        description:
            L10n.of(context).settingsNarrateOpenAiInstructionsDescription,
        type: ConfigItemType.text,
        defaultValue: '',
      ),
    ];
  }

  @override
  Map<String, dynamic> getConfig() {
    final config = Prefs().getOnlineTtsConfig(serviceId);
    if (config.isEmpty) {
      return {
        'url': _defaultUrl,
        'key': '',
        'model': _defaultModel,
        'voice': _defaultVoice,
        'instructions': '',
      };
    }
    return {
      'url': config['url'] ?? _defaultUrl,
      'key': config['key'] ?? '',
      'model': config['model'] ?? _defaultModel,
      'voice': config['voice'] ?? _defaultVoice,
      'instructions': config['instructions'] ?? '',
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
    final String url = config['url']?.toString().trim() ?? _defaultUrl;
    final String? key = config['key']?.toString();
    final String model = config['model']?.toString().trim() ?? _defaultModel;
    final String resolvedVoice = resolveVoice(voice);

    if (key == null || key.isEmpty) {
      throw Exception('OpenAI TTS config missing (key)');
    }

    final instructions = _buildInstructions(
      config['instructions']?.toString(),
      rate,
      pitch,
    );

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'voice': resolvedVoice,
        'input': text,
        if (instructions.isNotEmpty) 'instructions': instructions,
        'response_format': 'mp3',
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    throw Exception(
        'OpenAI TTS failed: ${response.statusCode} ${response.body}');
  }

  String _buildInstructions(String? base, double rate, double pitch) {
    final buffer = StringBuffer();
    if (base != null && base.trim().isNotEmpty) {
      buffer.writeln(base.trim());
    }
    buffer.writeln('Please speak at a speed of ${rate.toStringAsFixed(2)}x.');
    buffer.writeln('Please use a pitch of ${pitch.toStringAsFixed(2)}x.');
    return buffer.toString().trim();
  }

  @override
  Future<List<TtsVoice>> getVoices() async {
    return const [
      TtsVoice(shortName: 'alloy', name: 'Alloy', locale: 'en-US'),
      TtsVoice(shortName: 'ash', name: 'Ash', locale: 'en-US'),
      TtsVoice(shortName: 'coral', name: 'Coral', locale: 'en-US'),
      TtsVoice(shortName: 'echo', name: 'Echo', locale: 'en-US'),
      TtsVoice(shortName: 'fable', name: 'Fable', locale: 'en-US'),
      TtsVoice(shortName: 'nova', name: 'Nova', locale: 'en-US'),
      TtsVoice(shortName: 'onyx', name: 'Onyx', locale: 'en-US'),
      TtsVoice(shortName: 'sage', name: 'Sage', locale: 'en-US'),
      TtsVoice(shortName: 'shimmer', name: 'Shimmer', locale: 'en-US'),
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
