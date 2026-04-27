import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/tts/tts_capability.dart';

void main() {
  group('TtsCapability.classify', () {
    test('green when both metrics good', () {
      expect(
        TtsCapability.classify(firstByteMs: 800, rtf: 0.4),
        TtsCapabilityTier.green,
      );
    });
    test('yellow when first_byte borderline', () {
      expect(
        TtsCapability.classify(firstByteMs: 2000, rtf: 0.7),
        TtsCapabilityTier.yellow,
      );
    });
    test('red when first_byte exceeds 3s', () {
      expect(
        TtsCapability.classify(firstByteMs: 3500, rtf: 0.5),
        TtsCapabilityTier.red,
      );
    });
    test('red when rtf >= 0.9', () {
      expect(
        TtsCapability.classify(firstByteMs: 1000, rtf: 0.95),
        TtsCapabilityTier.red,
      );
    });
  });

  group('TtsCapability.isExpired', () {
    test('not expired within 7 days', () {
      final cap = TtsCapability(
        serverUrl: 'http://x',
        voiceFullId: 'v',
        tier: TtsCapabilityTier.green,
        firstByteMs: 100,
        rtf: 0.1,
        serverBuild: 'b',
        probedAt: DateTime.now().subtract(const Duration(days: 6)),
      );
      expect(cap.isExpired, false);
    });
    test('expired past 7 days', () {
      final cap = TtsCapability(
        serverUrl: 'http://x',
        voiceFullId: 'v',
        tier: TtsCapabilityTier.green,
        firstByteMs: 100,
        rtf: 0.1,
        serverBuild: 'b',
        probedAt: DateTime.now().subtract(const Duration(days: 8)),
      );
      expect(cap.isExpired, true);
    });
  });
}
