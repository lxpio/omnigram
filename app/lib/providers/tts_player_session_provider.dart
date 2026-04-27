import 'dart:async';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/models/tts/playback_state.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/providers/tts_playback_mode_provider.dart';
import 'package:omnigram/service/tts/live_server_source.dart';
import 'package:omnigram/service/tts/local_fallback_source.dart';
import 'package:omnigram/service/tts/pregen_server_source.dart';
import 'package:omnigram/service/tts/tts_audio_source.dart';
import 'package:omnigram/service/tts/tts_player_session.dart';
import 'package:omnigram/service/tts/tts_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_player_session_provider.g.dart';

class _SessionHolder {
  TtsPlayerSession? session;
  StreamSubscription<PlaybackState>? stateSub;
}

/// App-wide singleton holding at most one active Now-Playing session.
@Riverpod(keepAlive: true)
class TtsPlayerSessionController extends _$TtsPlayerSessionController {
  final _holder = _SessionHolder();
  StreamSubscription<ServerAudiobookTask>? _sseSub;

  @override
  PlaybackState build() {
    ref.onDispose(() async {
      await _sseSub?.cancel();
      await _holder.stateSub?.cancel();
      await _holder.session?.dispose();
    });
    return const PlaybackState();
  }

  Future<void> startSession({
    required Book book,
    required int chapterIndex,
  }) async {
    final conn = ref.read(serverConnectionProvider);
    final api = ref.read(serverConnectionProvider.notifier).tts;
    final omni = ref.read(serverConnectionProvider.notifier).api;
    if (api == null || omni == null || conn.serverUrl == null) {
      state = state.copyWith(errorMessage: 'Not connected to server');
      return;
    }
    final voiceFullId = Prefs().selectedVoiceFullId;
    if (voiceFullId.isEmpty) {
      state = state.copyWith(errorMessage: 'No voice selected');
      return;
    }
    final voiceId = voiceFullId.contains(':')
        ? voiceFullId.split(':').sublist(1).join(':')
        : voiceFullId;

    final bookId = book.id.toString();
    final serverUrl = conn.serverUrl!;

    ServerAudiobookInfo? info;
    try {
      info = await api.getAudiobook(bookId);
    } catch (_) {
      info = null;
    }
    final totalChapters = info?.task.totalChapters ?? info?.chapters.length ?? 1;

    Future<String> fetchChapterText(int idx) async {
      try {
        final align = await api.getChapterAlignment(bookId, idx);
        return align.sentences.map((s) => s.text).join('\n');
      } catch (_) {
        return '';
      }
    }

    Future<String> fetchTitle(int idx) async {
      if (info == null) return '#${idx + 1}';
      for (final c in info.chapters) {
        if (c.chapterIndex == idx) return c.chapterTitle;
      }
      return '#${idx + 1}';
    }

    Future<ChapterAlignment?> fetchAlignment(int idx) async {
      try {
        return await api.getChapterAlignment(bookId, idx);
      } catch (_) {
        return null;
      }
    }

    TtsAudioSource sourceFor(PlaybackMode mode) {
      switch (mode) {
        case PlaybackMode.liveServer:
          return LiveServerSource(
            api: omni,
            bookId: bookId,
            voice: voiceId,
            language: null,
            fetchChapterText: fetchChapterText,
          );
        case PlaybackMode.pregenServer:
          return PregenServerSource(api: api, bookId: bookId);
        case PlaybackMode.localFallback:
          return LocalFallbackSource(
            bookId: bookId,
            voice: voiceId,
            fetchChapterText: fetchChapterText,
          );
      }
    }

    PlaybackMode resolveMode({required int chapterIndex}) {
      return ref.read(ttsPlaybackModeProvider(
        bookId: bookId,
        chapterIndex: chapterIndex,
        serverUrl: serverUrl,
        voiceFullId: voiceFullId,
      ));
    }

    void prefetch(int idx) {
      // Only enqueue server pre-gen if the routing decision says local
      // fallback for this chapter (i.e. server isn't already serving it).
      final mode = resolveMode(chapterIndex: idx);
      if (mode != PlaybackMode.localFallback) return;
      api.createChapterAudio(bookId, idx).then((_) {}).catchError((_) {});
    }

    // Tear down previous session if any.
    await _holder.stateSub?.cancel();
    await _holder.session?.dispose();

    final s = TtsPlayerSession(
      bookId: bookId,
      bookTitle: book.title,
      coverUrl: book.coverFullPath,
      totalChapters: totalChapters,
      fetchChapterTitle: fetchTitle,
      fetchChapterAlignment: fetchAlignment,
      audioSourceFactory: sourceFor,
      modeResolver: resolveMode,
      prefetchHook: prefetch,
      upgradeToast: () {
        // No-op here — UI watches state and surfaces toast when serverReady flips.
      },
    );
    _holder.session = s;
    _holder.stateSub = s.stream.listen((newState) => state = newState);

    // Re-subscribe SSE so the session sees server progress and ready signals.
    await _sseSub?.cancel();
    final task = info?.task;
    if (task != null && task.id.isNotEmpty) {
      _sseSub = api.streamTask(task.id).listen((updated) {
        final pct = updated.totalChapters == 0
            ? 0
            : ((updated.doneChapters / updated.totalChapters) * 100).round();
        s.updateServerProgress(pct);
        api.getAudiobook(bookId).then((fresh) {
          for (final c in fresh.chapters) {
            if (c.chapterIndex == s.state.chapterIndex && c.status == 2) {
              s.markServerReady();
              break;
            }
          }
        }).catchError((_) {
          // best-effort; SSE may continue and we'll get another chance.
        });
      });
    }

    await s.start(chapterIndex: chapterIndex);
  }

  Future<void> play() => _holder.session?.play() ?? Future.value();
  Future<void> pause() => _holder.session?.pause() ?? Future.value();
  Future<void> seek(Duration position) => _holder.session?.seek(position) ?? Future.value();
  Future<void> seekToSentence(int idx) => _holder.session?.seekToSentence(idx) ?? Future.value();
  Future<void> nextChapter() => _holder.session?.nextChapter() ?? Future.value();
  Future<void> prevChapter() => _holder.session?.prevChapter() ?? Future.value();
  Future<void> setSpeed(double s) => _holder.session?.setSpeed(s) ?? Future.value();
  Future<void> upgradeNow() => _holder.session?.upgradeNow() ?? Future.value();

  Future<void> stop() async {
    await _sseSub?.cancel();
    _sseSub = null;
    await _holder.stateSub?.cancel();
    _holder.stateSub = null;
    await _holder.session?.dispose();
    _holder.session = null;
    state = const PlaybackState();
  }
}
