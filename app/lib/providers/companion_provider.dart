import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/models/companion_personality.dart';

part 'companion_provider.g.dart';

const _prefsKey = 'companionPersonality';

@Riverpod(keepAlive: true)
class Companion extends _$Companion {
  @override
  CompanionPersonality build() {
    final prefs = Prefs();
    final json = prefs.prefs.getString(_prefsKey);
    if (json != null) {
      try {
        return CompanionPersonality.fromJson(jsonDecode(json));
      } catch (_) {}
    }
    return const CompanionPersonality();
  }

  void update(CompanionPersonality personality) {
    state = personality;
    _save(personality);
  }

  void updateName(String name) => update(state.copyWith(name: name));
  void updateProactivity(int v) => update(state.copyWith(proactivity: v));
  void updateStyle(int v) => update(state.copyWith(style: v));
  void updateDepth(int v) => update(state.copyWith(depth: v));
  void updateWarmth(int v) => update(state.copyWith(warmth: v));

  void applyPreset(CompanionPersonality preset) => update(preset.copyWith(name: state.name));

  void _save(CompanionPersonality p) {
    Prefs().prefs.setString(_prefsKey, jsonEncode(p.toJson()));
  }
}
