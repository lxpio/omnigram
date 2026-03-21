import 'dart:typed_data';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/service/config/service_provider.dart';
import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:flutter/widgets.dart';

// Re-export ConfigItem for convenience
export 'package:omnigram/service/config/config_item.dart';

// Forward declaration to avoid circular dependency
// The actual TtsService enum is defined in tts_service.dart
// ignore: unused_element
abstract class _TtsService {}

/// Base class for all TTS service providers.
///
/// Subclasses must implement:
/// - [service]: The TTS service enum value.
/// - [getLabel]: The display label.
/// - For online TTS services:
///   - [speak]: Generate speech audio from text.
///   - [getVoices]: Get available voices.
///   - [getConfigItems]: Configuration items.
///   - [getConfig] / [saveConfig]: Configuration management.
abstract class TtsServiceProvider extends ServiceProvider<dynamic> {
  String get serviceId => service.toString().split('.').last;

  /// The display label for this service.
  @override
  String getLabel(BuildContext context);

  /// Generate speech audio from text.
  /// Only required for online TTS services.
  /// System TTS doesn't use this method.
  Future<Uint8List> speak(
      String text, String? voice, double rate, double pitch) async {
    throw UnimplementedError('speak() not implemented for $service');
  }

  /// Get available voices for this TTS service.
  /// Returns empty list for system TTS (handled separately).
  Future<List<TtsVoice>> getVoices() async {
    return [];
  }

  /// Convert voice data from API response to TtsVoice model.
  /// Only needed for online TTS services.
  TtsVoice convertVoiceModel(dynamic voiceData) {
    throw UnimplementedError(
        'convertVoiceModel() not implemented for $service');
  }

  /// Get the currently selected voice for this service.
  String getSelectedVoice() {
    return Prefs().getTtsVoiceModel(serviceId);
  }

  /// Persist the selected voice for this service.
  void setSelectedVoice(String voice) {
    Prefs().setTtsVoiceModel(serviceId, voice);
  }

  /// Resolve the voice to use, optionally overriding the saved selection.
  String resolveVoice(String? voiceOverride) {
    if (voiceOverride != null && voiceOverride.isNotEmpty) {
      return voiceOverride;
    }
    final selected = getSelectedVoice();
    if (selected.isEmpty) {
      throw Exception('No voice selected for $service');
    }
    return selected;
  }
}
