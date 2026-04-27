import 'dart:async';
import 'dart:convert';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/models/tts/tts_capability.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_capability_provider.g.dart';

String _capabilityKey(String serverUrl, String voiceFullId) => '$serverUrl::$voiceFullId';

/// Capability cache keyed by `(serverUrl, voiceFullId)`.
///
/// - Probe is triggered automatically on every transition to "connected".
/// - Results are persisted to `SharedPreferences` and survive app restarts.
/// - Entries expire after 7 days; expired entries are treated as a cache miss.
@Riverpod(keepAlive: true)
class TtsCapabilityCache extends _$TtsCapabilityCache {
  @override
  Map<String, TtsCapability> build() {
    ref.listen<ServerConnectionState>(serverConnectionProvider, (previous, next) {
      final wasConnected = previous?.isConnected ?? false;
      if (!wasConnected && next.isConnected && next.serverUrl != null) {
        unawaited(_probeOnLogin(next.serverUrl!));
      }
    });
    return _readFromPrefs();
  }

  Map<String, TtsCapability> _readFromPrefs() {
    final raw = Prefs().ttsCapabilityCacheJson;
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in decoded.entries) e.key: TtsCapability.fromJson(e.value as Map<String, dynamic>),
      };
    } catch (_) {
      return {};
    }
  }

  void _persist() {
    Prefs().ttsCapabilityCacheJson = jsonEncode({
      for (final e in state.entries) e.key: e.value.toJson(),
    });
  }

  /// Returns a fresh capability or null when missing/expired.
  TtsCapability? get(String serverUrl, String voiceFullId) {
    final cap = state[_capabilityKey(serverUrl, voiceFullId)];
    if (cap == null || cap.isExpired) return null;
    return cap;
  }

  Future<TtsCapability> probe({
    required String serverUrl,
    required String voiceFullId,
    String? language,
  }) async {
    final voiceId = voiceFullId.contains(':')
        ? voiceFullId.split(':').sublist(1).join(':')
        : voiceFullId;
    try {
      final api = ref.read(serverConnectionProvider.notifier).tts;
      if (api == null) throw StateError('not connected');
      final result = await api.probe(voice: voiceId, language: language);
      final tier = TtsCapability.classify(firstByteMs: result.firstByteMs, rtf: result.rtf);
      final cap = TtsCapability(
        serverUrl: serverUrl,
        voiceFullId: voiceFullId,
        tier: tier,
        firstByteMs: result.firstByteMs,
        rtf: result.rtf,
        serverBuild: result.serverBuild,
        probedAt: DateTime.now(),
      );
      state = {...state, _capabilityKey(serverUrl, voiceFullId): cap};
      _persist();
      return cap;
    } catch (_) {
      final cap = TtsCapability(
        serverUrl: serverUrl,
        voiceFullId: voiceFullId,
        tier: TtsCapabilityTier.na,
        firstByteMs: -1,
        rtf: -1,
        serverBuild: '',
        probedAt: DateTime.now(),
      );
      state = {...state, _capabilityKey(serverUrl, voiceFullId): cap};
      _persist();
      return cap;
    }
  }

  void invalidate(String serverUrl, String voiceFullId) {
    final key = _capabilityKey(serverUrl, voiceFullId);
    if (!state.containsKey(key)) return;
    final next = Map<String, TtsCapability>.from(state)..remove(key);
    state = next;
    _persist();
  }

  Future<void> _probeOnLogin(String serverUrl) async {
    final voiceFullId = Prefs().selectedVoiceFullId;
    if (voiceFullId.isEmpty || !voiceFullId.startsWith('server:')) return;
    if (get(serverUrl, voiceFullId) != null) return;
    await probe(serverUrl: serverUrl, voiceFullId: voiceFullId);
  }
}
