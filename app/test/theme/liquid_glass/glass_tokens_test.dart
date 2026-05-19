import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';

void main() {
  group('GlassTokens', () {
    test('blur sigmas are ordered thin < thick < ultra', () {
      expect(GlassTokens.blurSigmaThin, lessThan(GlassTokens.blurSigmaThick));
      expect(GlassTokens.blurSigmaThick, lessThan(GlassTokens.blurSigmaUltra));
    });

    test('tint alphas stay within visual budget', () {
      // Light mode uses a high-alpha white tint so cards lift clearly
      // above the warm-grey surface (iOS systemGroupedBackground feel).
      // Dark mode uses a thin white overlay so cards lift over the dark
      // surface without "blacking out" the page.
      expect(GlassTokens.tintLightAlpha, inInclusiveRange(0.5, 0.95));
      expect(GlassTokens.tintDarkAlpha, inInclusiveRange(0.05, 0.25));
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
