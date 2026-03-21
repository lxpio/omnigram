import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:omnigram/service/tts/tts_factory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_providers.g.dart';

@riverpod
class TtsService extends _$TtsService {
  @override
  String build() {
    return Prefs().ttsService;
  }

  void setService(String serviceId) {
    Prefs().ttsService = serviceId;
    state = serviceId;
  }
}

@riverpod
Future<List<TtsVoice>> ttsVoices(Ref ref) async {
  // Watch service change to trigger refresh
  ref.watch(ttsServiceProvider);

  // Also watch system tts toggle if we want to support switching between system/online here?
  // Current design in SettingsPage separates System vs Online via a switch.
  // The voice list usually depends on what is currently active or selected.

  // Use TtsFactory to get the right instance.
  // Note: TtsFactory.current depends on Prefs().isSystemTts which is not watched here directly.
  // But NarrateSettings usually toggles isSystemTts.

  final tts = TtsFactory().current;
  return await tts.getVoices();
}

@riverpod
class OnlineTtsConfig extends _$OnlineTtsConfig {
  @override
  Map<String, dynamic> build(String serviceId) {
    return Prefs().getOnlineTtsConfig(serviceId);
  }

  void updateConfig(String key, dynamic value) {
    final current = Map<String, dynamic>.from(state);
    current[key] = value;
    Prefs().saveOnlineTtsConfig(serviceId, current);
    state = current;
  }
}
