import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/service/api/omnigram_api.dart';

part 'audiobook_provider.g.dart';

/// Per-book audiobook task state.
///
/// - `data(null)` — no audiobook generated yet (server returned 404)
/// - `data(task)` — a task exists (pending / running / completed / failed)
/// - `loading` — initial fetch in flight
/// - `error` — network/server error on lookup
///
/// The notifier also manages an SSE subscription while a task is non-terminal,
/// pushing live progress updates into `state`.
@riverpod
class Audiobook extends _$Audiobook {
  StreamSubscription<ServerAudiobookTask>? _sub;

  @override
  Future<ServerAudiobookInfo?> build(String bookId) async {
    ref.onDispose(_cancelSub);
    final api = _tts();
    if (api == null) return null;

    try {
      final info = await api.getAudiobook(bookId);
      _maybeSubscribe(info.task);
      return info;
    } on OmnigramApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Trigger audiobook generation. No-op if a non-failed task already exists.
  Future<void> generate() async {
    final api = _tts();
    if (api == null) return;

    final info = await api.createAudiobook(bookId);
    state = AsyncData(info);
    _maybeSubscribe(info.task);
  }

  /// Delete the audiobook (server removes files + task record).
  Future<void> delete() async {
    final api = _tts();
    if (api == null) return;

    await _cancelSub();
    await api.deleteAudiobook(bookId);
    state = const AsyncData(null);
  }

  /// Manual refresh from server (for pull-to-refresh in UI).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = _tts();
      if (api == null) return null;
      try {
        final info = await api.getAudiobook(bookId);
        _maybeSubscribe(info.task);
        return info;
      } on OmnigramApiException catch (e) {
        if (e.statusCode == 404) return null;
        rethrow;
      }
    });
  }

  // ── Helpers ─────────────────────────────────────────────────────

  dynamic _tts() {
    final conn = ref.read(serverConnectionProvider);
    if (!conn.isConnected) return null;
    return ref.read(serverConnectionProvider.notifier).tts;
  }

  void _maybeSubscribe(ServerAudiobookTask task) {
    if (_isTerminal(task.status)) return;
    _cancelSub();
    final api = _tts();
    if (api == null) return;

    _sub = api.streamTask(task.id).listen(
      (t) {
        final current = state.value;
        state = AsyncData(
          current == null
              ? ServerAudiobookInfo(task: t)
              : current.copyWith(task: t),
        );
        if (_isTerminal(t.status)) _cancelSub();
      },
      onError: (Object e, StackTrace s) {
        debugPrint('[Audiobook] SSE error: $e');
      },
      cancelOnError: true,
    );
  }

  Future<void> _cancelSub() async {
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
  }

  static bool _isTerminal(String status) =>
      status == 'completed' || status == 'failed' || status == 'done';
}
