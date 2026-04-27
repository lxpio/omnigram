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
  return TtsRouter.decide(tier: tier, status: status, override: override);
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
