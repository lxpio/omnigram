import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/tts/aliyun/aliyun_tts_backend.dart';
import 'package:omnigram/service/tts/azure_tts_backend.dart';
import 'package:omnigram/service/tts/edge_tts_backend.dart';
import 'package:omnigram/service/tts/openai_tts_backend.dart';
import 'package:omnigram/service/tts/server_tts_backend.dart';
import 'package:omnigram/service/tts/sherpa_onnx_tts.dart';
import 'package:omnigram/service/tts/tts_service_provider.dart';
import 'package:flutter/material.dart';

/// TTS service enumeration.
/// Defines available TTS services (system TTS and online TTS services).
enum TtsService {
  system,
  edge,
  aliyun,
  azure,
  openai,
  server,
  sherpaOnnx;

  /// Get the provider for this TTS service.
  TtsServiceProvider get provider {
    switch (this) {
      case TtsService.system:
        return SystemTtsProvider();
      case TtsService.edge:
        return EdgeTtsProvider();
      case TtsService.aliyun:
        return AliyunTtsProvider();
      case TtsService.azure:
        return AzureTtsProvider();
      case TtsService.openai:
        return OpenAiTtsProvider();
      case TtsService.server:
        return ServerTtsProvider();
      case TtsService.sherpaOnnx:
        return SherpaOnnxProvider();
    }
  }

  /// Get the display label from the provider.
  String getLabel(BuildContext context) => provider.getLabel(context);

  /// Check if the service is an online TTS provider.
  /// Note: sherpaOnnx is local but uses the OnlineTts playback pipeline.
  bool get isOnline => this != TtsService.system;
}

/// Get TTS service from service ID string.
TtsService getTtsService(String serviceId) {
  try {
    return TtsService.values.firstWhere((e) => e.toString().split('.').last == serviceId);
  } catch (e) {
    return TtsService.system;
  }
}

/// System TTS provider (placeholder for service provider pattern).
/// System TTS doesn't need configuration, so it returns empty config items.
class SystemTtsProvider extends TtsServiceProvider {
  @override
  TtsService get service => TtsService.system;

  @override
  String getLabel(BuildContext context) => L10n.of(context).settingsNarrateSystemTts;
}
