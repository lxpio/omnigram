import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';

void main() {
  group('GlassTokens', () {
    test('blur sigmas are ordered thin < thick < ultra', () {
      expect(GlassTokens.blurSigmaThin, lessThan(GlassTokens.blurSigmaThick));
      expect(GlassTokens.blurSigmaThick, lessThan(GlassTokens.blurSigmaUltra));
    });

    test('tint alpha never exceeds 0.7', () {
      expect(GlassTokens.tintLightAlpha, lessThanOrEqualTo(0.7));
      expect(GlassTokens.tintDarkAlpha, lessThanOrEqualTo(0.7));
    });

    test('radius scale is monotonic button < menu < bar < sheet', () {
      expect(GlassTokens.radiusButton, lessThan(GlassTokens.radiusMenu));
      expect(GlassTokens.radiusMenu, lessThan(GlassTokens.radiusBar));
      expect(GlassTokens.radiusBar, lessThan(GlassTokens.radiusSheet));
    });

    test('springOut curve overshoots above 1.0', () {
      final t = GlassTokens.springOut.transform(0.7);
      expect(t, greaterThan(1.0));
    });
  });
}
