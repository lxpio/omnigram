import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';

void main() {
  group('GlassQuality.steppedDownForReader', () {
    test('high steps down to medium', () {
      expect(GlassQuality.high.steppedDownForReader(), GlassQuality.medium);
    });
    test('medium steps down to low', () {
      expect(GlassQuality.medium.steppedDownForReader(), GlassQuality.low);
    });
    test('low stays at low', () {
      expect(GlassQuality.low.steppedDownForReader(), GlassQuality.low);
    });
  });

  group('GlassQuality predicates', () {
    test('hasBlur only true for high', () {
      expect(GlassQuality.high.hasBlur, isTrue);
      expect(GlassQuality.medium.hasBlur, isFalse);
      expect(GlassQuality.low.hasBlur, isFalse);
    });
    test('hasMotion true for high+medium, false for low', () {
      expect(GlassQuality.high.hasMotion, isTrue);
      expect(GlassQuality.medium.hasMotion, isTrue);
      expect(GlassQuality.low.hasMotion, isFalse);
    });
  });

  group('resolveAutoQuality (pure)', () {
    test('iOS always high', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.iOS, totalRamMb: 2048, sdkInt: 0),
        GlassQuality.high,
      );
    });
    test('Android 6GB API 31 = high', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.android, totalRamMb: 6 * 1024, sdkInt: 31),
        GlassQuality.high,
      );
    });
    test('Android 4GB API 31 = medium', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.android, totalRamMb: 4 * 1024, sdkInt: 31),
        GlassQuality.medium,
      );
    });
    test('Android 3GB = low', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.android, totalRamMb: 3 * 1024, sdkInt: 31),
        GlassQuality.low,
      );
    });
    test('Android API 30 = low regardless of RAM', () {
      expect(
        resolveAutoQuality(platform: GlassPlatform.android, totalRamMb: 8 * 1024, sdkInt: 30),
        GlassQuality.low,
      );
    });
  });
}
