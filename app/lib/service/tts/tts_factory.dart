import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/service/tts/base_tts.dart';
import 'package:omnigram/service/tts/online_tts.dart';
import 'package:omnigram/service/tts/system_tts.dart';
import 'package:omnigram/service/tts/tts_service.dart';
import 'package:flutter/material.dart';

class TtsFactory {
  static final TtsFactory _instance = TtsFactory._internal();

  factory TtsFactory() {
    return _instance;
  }

  TtsFactory._internal();

  BaseTts? _currentTts;

  BaseTts get current {
    _currentTts ??= createTts();
    return _currentTts!;
  }

  BaseTts createTts() {
    TtsService service = getTtsService(Prefs().ttsService);
    return service == TtsService.system ? SystemTts() : OnlineTts();
  }

  Future<void> switchTtsType(String serviceId) async {
    if (Prefs().ttsService == serviceId) return;

    if (_currentTts != null) {
      await _currentTts!.stop();
      await _currentTts!.dispose();
      _currentTts = null;
    }

    Prefs().ttsService = serviceId;
    _currentTts = createTts();
  }

  /// Switch to the engine matching a VoiceFullId source.
  Future<void> switchToVoiceSource(String source) async {
    if (Prefs().ttsService == source) return;
    await switchTtsType(source);
  }

  Future<void> dispose() async {
    if (_currentTts != null) {
      await _currentTts!.stop();
      await _currentTts!.dispose();
      _currentTts = null;
    }
  }

  ValueNotifier<TtsStateEnum> get ttsStateNotifier {
    return current.ttsStateNotifier;
  }
}
