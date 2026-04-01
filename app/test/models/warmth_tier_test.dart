import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/models/warmth_tier.dart';

void main() {
  group('WarmthTier.fromWarmth', () {
    test('0 → low', () => expect(WarmthTier.fromWarmth(0), WarmthTier.low));
    test('33 → low', () => expect(WarmthTier.fromWarmth(33), WarmthTier.low));
    test('34 → mid', () => expect(WarmthTier.fromWarmth(34), WarmthTier.mid));
    test('50 → mid', () => expect(WarmthTier.fromWarmth(50), WarmthTier.mid));
    test('66 → mid', () => expect(WarmthTier.fromWarmth(66), WarmthTier.mid));
    test('67 → high', () => expect(WarmthTier.fromWarmth(67), WarmthTier.high));
    test('100 → high', () => expect(WarmthTier.fromWarmth(100), WarmthTier.high));
  });
}
