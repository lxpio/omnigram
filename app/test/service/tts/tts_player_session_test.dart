import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/service/tts/tts_player_session.dart';
import 'package:omnigram/service/tts/tts_router.dart';

void main() {
  group('TtsPlayerSession.sentenceIndexFor', () {
    final alignment = ChapterAlignment(
      schemaVersion: 1,
      chapterIndex: 0,
      audioDurationMs: 10000,
      sentences: const [
        SentenceAlignment(index: 0, text: 'a', startMs: 0, endMs: 1000, charOffset: 0),
        SentenceAlignment(index: 1, text: 'b', startMs: 1000, endMs: 2500, charOffset: 1),
        SentenceAlignment(index: 2, text: 'c', startMs: 2500, endMs: 5000, charOffset: 2),
      ],
    );

    test('returns -1 before first sentence', () {
      expect(
        TtsPlayerSession.sentenceIndexFor(alignment: alignment, position: const Duration(milliseconds: -10)),
        -1,
      );
    });
    test('returns 0 for position inside first sentence', () {
      expect(
        TtsPlayerSession.sentenceIndexFor(alignment: alignment, position: const Duration(milliseconds: 500)),
        0,
      );
    });
    test('returns 1 at exact start of second sentence', () {
      expect(
        TtsPlayerSession.sentenceIndexFor(alignment: alignment, position: const Duration(milliseconds: 1000)),
        1,
      );
    });
    test('returns last sentence past audio end', () {
      expect(
        TtsPlayerSession.sentenceIndexFor(alignment: alignment, position: const Duration(milliseconds: 10000)),
        2,
      );
    });
    test('returns -1 when alignment is null', () {
      expect(
        TtsPlayerSession.sentenceIndexFor(alignment: null, position: const Duration(milliseconds: 500)),
        -1,
      );
    });
  });

  group('TtsPlayerSession.shouldShowUpgradeToast', () {
    test('upgrades when next-chapter mode differs from current local', () {
      expect(
        TtsPlayerSession.shouldShowUpgradeToast(
          previous: PlaybackMode.localFallback,
          next: PlaybackMode.pregenServer,
        ),
        true,
      );
    });
    test('upgrades from local to live', () {
      expect(
        TtsPlayerSession.shouldShowUpgradeToast(
          previous: PlaybackMode.localFallback,
          next: PlaybackMode.liveServer,
        ),
        true,
      );
    });
    test('no toast when both modes equal', () {
      expect(
        TtsPlayerSession.shouldShowUpgradeToast(
          previous: PlaybackMode.localFallback,
          next: PlaybackMode.localFallback,
        ),
        false,
      );
    });
    test('no toast when not upgrading from local', () {
      expect(
        TtsPlayerSession.shouldShowUpgradeToast(
          previous: PlaybackMode.pregenServer,
          next: PlaybackMode.localFallback,
        ),
        false,
      );
    });
  });
}
