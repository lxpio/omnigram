import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:omnigram/service/tts/tts_factory.dart';
import 'package:omnigram/service/tts/tts_service.dart' as tts_svc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_providers.g.dart';

/// Status of the Omnigram Server's TTS service from the app's perspective.
enum OmnigramServerTtsStatus {
  /// User is not logged in to any Omnigram Server.
  notLoggedIn,

  /// Logged in, but the server isn't running TTS (minimal deployment / sidecar missing).
  serviceUnavailable,

  /// Logged in and TTS is reachable.
  available,
}

@riverpod
Future<OmnigramServerTtsStatus> omnigramServerTtsStatus(Ref ref) async {
  final conn = ref.watch(serverConnectionProvider);
  if (!conn.isConnected) return OmnigramServerTtsStatus.notLoggedIn;
  try {
    final voices = await tts_svc.TtsService.server.provider.getVoices();
    if (voices.isEmpty) return OmnigramServerTtsStatus.serviceUnavailable;
    return OmnigramServerTtsStatus.available;
  } catch (_) {
    return OmnigramServerTtsStatus.serviceUnavailable;
  }
}

/// Voice data tagged with its source service for the unified voice grid.
class TaggedVoice {
  final String source;
  final TtsVoice voice;
  final String sourceLabel;

  const TaggedVoice({required this.source, required this.voice, required this.sourceLabel});

  String get fullId => '$source:${voice.shortName}';
}

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

@riverpod
Future<Map<String, List<TaggedVoice>>> allVoicesGrouped(Ref ref) async {
  final result = <String, List<TaggedVoice>>{};

  // Local offline (sherpa-onnx)
  try {
    final sherpaVoices = await tts_svc.TtsService.sherpaOnnx.provider.getVoices();
    if (sherpaVoices.isNotEmpty) {
      result['local'] = sherpaVoices
          .map((v) => TaggedVoice(source: 'sherpaOnnx', voice: v, sourceLabel: 'Kokoro'))
          .toList();
    }
  } catch (_) {}

  // Per-source online groups. Skip cloud services without credentials so users
  // aren't drowned in voices they can't actually use.
  Future<void> addSource(tts_svc.TtsService svc, String source, String label) async {
    final provider = svc.provider;
    if (!provider.isConfigured) return;
    try {
      final voices = await provider.getVoices();
      if (voices.isEmpty) return;
      result[source] = voices.map((v) => TaggedVoice(source: source, voice: v, sourceLabel: label)).toList();
    } catch (_) {}
  }

  // Order matters — Server first when available, then paid clouds.
  await addSource(tts_svc.TtsService.server, 'server', 'Omnigram Server');
  await addSource(tts_svc.TtsService.azure, 'azure', 'Azure');
  await addSource(tts_svc.TtsService.openai, 'openai', 'OpenAI');
  await addSource(tts_svc.TtsService.aliyun, 'aliyun', 'Aliyun');

  // System
  try {
    final systemVoices = await tts_svc.TtsService.system.provider.getVoices();
    if (systemVoices.isNotEmpty) {
      result['system'] = systemVoices
          .map((v) => TaggedVoice(source: 'system', voice: v, sourceLabel: 'System'))
          .toList();
    }
  } catch (_) {}

  return result;
}
