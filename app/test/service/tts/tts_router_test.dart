import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/tts/tts_capability.dart';
import 'package:omnigram/service/tts/tts_router.dart';

void main() {
  group('TtsRouter.decide — auto mode (matrix §6)', () {
    test('GREEN + any → LiveServer', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.green,
          status: ChapterAudioStatus.notGenerated,
          override: TtsDefaultMode.auto,
        ),
        PlaybackMode.liveServer,
      );
    });
    test('YELLOW + Ready → PregenServer', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.yellow,
          status: ChapterAudioStatus.ready,
          override: TtsDefaultMode.auto,
        ),
        PlaybackMode.pregenServer,
      );
    });
    test('YELLOW + Generating → LocalFallback', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.yellow,
          status: ChapterAudioStatus.generating,
          override: TtsDefaultMode.auto,
        ),
        PlaybackMode.localFallback,
      );
    });
    test('YELLOW + NotGenerated → LocalFallback', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.yellow,
          status: ChapterAudioStatus.notGenerated,
          override: TtsDefaultMode.auto,
        ),
        PlaybackMode.localFallback,
      );
    });
    test('RED + Ready → PregenServer', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.red,
          status: ChapterAudioStatus.ready,
          override: TtsDefaultMode.auto,
        ),
        PlaybackMode.pregenServer,
      );
    });
    test('RED + Generating → LocalFallback', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.red,
          status: ChapterAudioStatus.generating,
          override: TtsDefaultMode.auto,
        ),
        PlaybackMode.localFallback,
      );
    });
    test('RED + NotGenerated → LocalFallback', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.red,
          status: ChapterAudioStatus.notGenerated,
          override: TtsDefaultMode.auto,
        ),
        PlaybackMode.localFallback,
      );
    });
    test('NA + Ready → PregenServer', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.na,
          status: ChapterAudioStatus.ready,
          override: TtsDefaultMode.auto,
        ),
        PlaybackMode.pregenServer,
      );
    });
    test('NA + NotGenerated → LocalFallback', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.na,
          status: ChapterAudioStatus.notGenerated,
          override: TtsDefaultMode.auto,
        ),
        PlaybackMode.localFallback,
      );
    });
  });

  group('TtsRouter.decide — overrides', () {
    test('alwaysLive forces live regardless of tier', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.red,
          status: ChapterAudioStatus.notGenerated,
          override: TtsDefaultMode.alwaysLive,
        ),
        PlaybackMode.liveServer,
      );
    });
    test('alwaysPregen + Ready → PregenServer', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.green,
          status: ChapterAudioStatus.ready,
          override: TtsDefaultMode.alwaysPregen,
        ),
        PlaybackMode.pregenServer,
      );
    });
    test('alwaysPregen + NotGenerated → LocalFallback (waiting)', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.green,
          status: ChapterAudioStatus.notGenerated,
          override: TtsDefaultMode.alwaysPregen,
        ),
        PlaybackMode.localFallback,
      );
    });
    test('alwaysLocal forces local always', () {
      expect(
        TtsRouter.decide(
          tier: TtsCapabilityTier.green,
          status: ChapterAudioStatus.ready,
          override: TtsDefaultMode.alwaysLocal,
        ),
        PlaybackMode.localFallback,
      );
    });
  });

  group('TtsRouter.shouldPrefetch', () {
    test('prefetch under YELLOW for not-generated chapter', () {
      expect(
        TtsRouter.shouldPrefetch(
          tier: TtsCapabilityTier.yellow,
          status: ChapterAudioStatus.notGenerated,
        ),
        true,
      );
    });
    test('prefetch under RED for not-generated chapter', () {
      expect(
        TtsRouter.shouldPrefetch(
          tier: TtsCapabilityTier.red,
          status: ChapterAudioStatus.notGenerated,
        ),
        true,
      );
    });
    test('no prefetch under GREEN', () {
      expect(
        TtsRouter.shouldPrefetch(
          tier: TtsCapabilityTier.green,
          status: ChapterAudioStatus.notGenerated,
        ),
        false,
      );
    });
    test('no prefetch under NA', () {
      expect(
        TtsRouter.shouldPrefetch(
          tier: TtsCapabilityTier.na,
          status: ChapterAudioStatus.notGenerated,
        ),
        false,
      );
    });
  });
}
