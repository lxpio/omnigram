import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/models/companion_personality.dart';
import 'package:omnigram/providers/server_connection_provider.dart';

part 'companion_provider.g.dart';

const _prefsKey = 'companionPersonality';

@Riverpod(keepAlive: true)
class Companion extends _$Companion {
  @override
  CompanionPersonality build() {
    // Load from local first, then try server in background
    final prefs = Prefs();
    final json = prefs.prefs.getString(_prefsKey);
    CompanionPersonality local = const CompanionPersonality();
    if (json != null) {
      try {
        local = CompanionPersonality.fromJson(jsonDecode(json));
      } catch (_) {}
    }

    // Try to sync from server in background
    _syncFromServer();

    return local;
  }

  void update(CompanionPersonality personality) {
    state = personality;
    _save(personality);
    _syncToServer(personality);
  }

  void updateName(String name) => update(state.copyWith(name: name));
  void updateProactivity(int v) => update(state.copyWith(proactivity: v));
  void updateStyle(int v) => update(state.copyWith(style: v));
  void updateDepth(int v) => update(state.copyWith(depth: v));
  void updateWarmth(int v) => update(state.copyWith(warmth: v));
  void updateVoice(String v) => update(state.copyWith(voice: v));
  void updateAutoChapterRecap(bool v) => update(state.copyWith(autoChapterRecap: v));
  void updateAnnotateHardWords(bool v) => update(state.copyWith(annotateHardWords: v));
  void updateCrossBookAlerts(bool v) => update(state.copyWith(crossBookAlerts: v));
  void updatePostChapterQuestions(bool v) => update(state.copyWith(postChapterQuestions: v));
  void updateAutoKnowledgeGraph(bool v) => update(state.copyWith(autoKnowledgeGraph: v));

  void applyPreset(CompanionPersonality preset) => update(preset.copyWith(name: state.name));

  void _save(CompanionPersonality p) {
    Prefs().prefs.setString(_prefsKey, jsonEncode(p.toJson()));
  }

  /// Pull companion profile from server if connected.
  Future<void> _syncFromServer() async {
    try {
      final connection = ref.read(serverConnectionProvider);
      if (!connection.isConnected) return;

      final api = ref.read(serverConnectionProvider.notifier).api;
      if (api == null) return;

      final response = await api.get(
        '/user/companion',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      final merged = <String, dynamic>{...state.toJson(), ...response};
      final serverPersonality = CompanionPersonality.fromJson(merged);

      state = serverPersonality;
      _save(serverPersonality);
    } catch (e) {
      debugPrint('[Companion] Server sync failed: $e');
    }
  }

  /// Push companion profile to server if connected.
  Future<void> _syncToServer(CompanionPersonality p) async {
    try {
      final connection = ref.read(serverConnectionProvider);
      if (!connection.isConnected) return;

      final api = ref.read(serverConnectionProvider.notifier).api;
      if (api == null) return;

      await api.putVoid('/user/companion', data: p.toJson());
    } catch (e) {
      debugPrint('[Companion] Server push failed: $e');
    }
  }
}
