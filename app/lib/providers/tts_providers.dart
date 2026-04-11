import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:omnigram/service/tts/tts_factory.dart';
import 'package:omnigram/service/tts/tts_service.dart' as tts_svc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_providers.g.dart';

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

  // Online
  final online = <TaggedVoice>[];

  // Edge (always available)
  try {
    final edgeVoices = await tts_svc.TtsService.edge.provider.getVoices();
    online.addAll(edgeVoices.map((v) => TaggedVoice(source: 'edge', voice: v, sourceLabel: 'Edge')));
  } catch (_) {}

  // Server (if configured — getVoices returns [] or throws if not configured)
  try {
    final serverVoices = await tts_svc.TtsService.server.provider.getVoices();
    online.addAll(serverVoices.map((v) => TaggedVoice(source: 'server', voice: v, sourceLabel: 'Server')));
  } catch (_) {}

  // Azure
  try {
    final azureVoices = await tts_svc.TtsService.azure.provider.getVoices();
    online.addAll(azureVoices.map((v) => TaggedVoice(source: 'azure', voice: v, sourceLabel: 'Azure')));
  } catch (_) {}

  // OpenAI
  try {
    final openaiVoices = await tts_svc.TtsService.openai.provider.getVoices();
    online.addAll(openaiVoices.map((v) => TaggedVoice(source: 'openai', voice: v, sourceLabel: 'OpenAI')));
  } catch (_) {}

  // Aliyun
  try {
    final aliyunVoices = await tts_svc.TtsService.aliyun.provider.getVoices();
    online.addAll(aliyunVoices.map((v) => TaggedVoice(source: 'aliyun', voice: v, sourceLabel: 'Aliyun')));
  } catch (_) {}

  if (online.isNotEmpty) result['online'] = online;

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
