import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/models/tts/tts_capability.dart';
import 'package:omnigram/providers/audiobook_provider.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/providers/tts_capability_provider.dart';
import 'package:omnigram/service/tts/tts_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_playback_mode_provider.g.dart';

/// Resolves PlaybackMode for `(book, chapter)` from current capability,
/// per-chapter audio status, and the user's default-mode override. Re-evaluates
/// whenever any input changes.
///
/// Server's `ChapterTask.Status` enum: 0 pending, 1 running, 2 completed, 3 failed,
/// 4 paused, 5 cancelled. Only 1 ↦ generating, 2 ↦ ready; everything else is
/// notGenerated for routing purposes.
@riverpod
PlaybackMode ttsPlaybackMode(
  Ref ref, {
  required String bookId,
  required int chapterIndex,
  required String serverUrl,
  required String voiceFullId,
}) {
  if (!(Prefs().experimentalTtsAdaptiveRouting ?? false)) {
    return PlaybackMode.liveServer;
  }

  final capCache = ref.watch(ttsCapabilityCacheProvider);
  final cap = capCache['$serverUrl::$voiceFullId'];
  final tier = (cap == null || cap.isExpired) ? TtsCapabilityTier.na : cap.tier;

  final asyncInfo = ref.watch(audiobookProvider(bookId));
  final status = asyncInfo.maybeWhen(
    data: (info) => _statusFor(info, chapterIndex),
    orElse: () => ChapterAudioStatus.notGenerated,
  );

  final override = TtsDefaultModeCodec.fromPref(Prefs().ttsDefaultMode);

  // Router's NA → localFallback rule is right when "we don't know" means
  // no signal at all. But once the user has logged in and selected a
  // server voice, NA in practice usually means "probe hasn't finished
  // yet" — defaulting against the user's explicit server choice is a
  // worse UX than trying the server and surfacing failure if it actually
  // breaks. Treat (NA + auto + server voice) as if probe were GREEN so
  // we route to liveServer; the live source will report errors loud and
  // clear if the server isn't reachable after all.
  final effectiveTier = (tier == TtsCapabilityTier.na &&
          override == TtsDefaultMode.auto &&
          voiceFullId.startsWith('server:'))
      ? TtsCapabilityTier.green
      : tier;
  return TtsRouter.decide(
      tier: effectiveTier, status: status, override: override);
}

ChapterAudioStatus _statusFor(ServerAudiobookInfo? info, int chapterIndex) {
  if (info == null) return ChapterAudioStatus.notGenerated;
  ServerAudiobookChapter? ch;
  for (final c in info.chapters) {
    if (c.chapterIndex == chapterIndex) {
      ch = c;
      break;
    }
  }
  if (ch == null) return ChapterAudioStatus.notGenerated;
  return switch (ch.status) {
    2 => ChapterAudioStatus.ready,
    1 => ChapterAudioStatus.generating,
    _ => ChapterAudioStatus.notGenerated,
  };
}

/// Prefetch helper — call when entering a chapter that should be queued for
/// server pre-gen. Best-effort; failures are swallowed.
@riverpod
Future<void> ttsPrefetchChapter(
  Ref ref, {
  required String bookId,
  required int chapterIndex,
}) async {
  final api = ref.read(serverConnectionProvider.notifier).tts;
  if (api == null) return;
  try {
    await api.createChapterAudio(bookId, chapterIndex);
  } catch (_) {
    // best-effort prefetch
  }
}
