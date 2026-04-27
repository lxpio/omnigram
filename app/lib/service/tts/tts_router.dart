import 'package:omnigram/models/tts/tts_capability.dart';

/// Per-chapter audio status (spec §5.2).
enum ChapterAudioStatus { notGenerated, generating, ready, localCached }

/// Runtime playback mode for a session (spec §5.3).
enum PlaybackMode { liveServer, pregenServer, localFallback }

/// User override (spec §8.6 default mode).
enum TtsDefaultMode { auto, alwaysLive, alwaysPregen, alwaysLocal }

extension TtsDefaultModeCodec on TtsDefaultMode {
  String get prefValue => switch (this) {
        TtsDefaultMode.auto => 'auto',
        TtsDefaultMode.alwaysLive => 'always_live',
        TtsDefaultMode.alwaysPregen => 'always_pregen',
        TtsDefaultMode.alwaysLocal => 'always_local',
      };

  static TtsDefaultMode fromPref(String? v) => switch (v) {
        'always_live' => TtsDefaultMode.alwaysLive,
        'always_pregen' => TtsDefaultMode.alwaysPregen,
        'always_local' => TtsDefaultMode.alwaysLocal,
        _ => TtsDefaultMode.auto,
      };
}

class TtsRouter {
  const TtsRouter._();

  /// Pure decision per spec §6.
  static PlaybackMode decide({
    required TtsCapabilityTier tier,
    required ChapterAudioStatus status,
    required TtsDefaultMode override,
  }) {
    switch (override) {
      case TtsDefaultMode.alwaysLive:
        return PlaybackMode.liveServer;
      case TtsDefaultMode.alwaysLocal:
        return PlaybackMode.localFallback;
      case TtsDefaultMode.alwaysPregen:
        return status == ChapterAudioStatus.ready
            ? PlaybackMode.pregenServer
            : PlaybackMode.localFallback;
      case TtsDefaultMode.auto:
        break;
    }

    if (status == ChapterAudioStatus.ready) return PlaybackMode.pregenServer;

    switch (tier) {
      case TtsCapabilityTier.green:
        return PlaybackMode.liveServer;
      case TtsCapabilityTier.yellow:
      case TtsCapabilityTier.red:
      case TtsCapabilityTier.na:
        return PlaybackMode.localFallback;
    }
  }

  /// Whether to enqueue server pre-gen for an as-yet-not-generated chapter.
  static bool shouldPrefetch({
    required TtsCapabilityTier tier,
    required ChapterAudioStatus status,
  }) {
    if (status != ChapterAudioStatus.notGenerated) return false;
    return tier == TtsCapabilityTier.yellow || tier == TtsCapabilityTier.red;
  }
}
