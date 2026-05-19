import 'package:flutter/material.dart';

class GlassTokens {
  GlassTokens._();

  // —— Blur sigmas ——
  static const double blurSigmaThin  = 12.0;   // buttons / chips / menu items
  static const double blurSigmaThick = 24.0;   // app bar / tab bar / sheet
  static const double blurSigmaUltra = 40.0;   // full-screen modal scrim

  // —— Tint alphas ——
  // Light mode: white overlay simulates the bright frosted glass face.
  // Dark mode: a thin WHITE overlay (NOT black) — the spec mimics
  // light passing through frosted glass; tinting a dark surface with
  // black just darkens it and makes glass cards disappear into the
  // background. Keep alpha low (~10-14 %) to preserve "still see
  // through" feel.
  // Light mode: high-alpha white tint so the card surface reads as
  // near-pure white over the slightly grey background.
  static const double tintLightAlpha = 0.85;
  static const double tintDarkAlpha  = 0.12;

  static Color tintLight() => Colors.white.withValues(alpha: tintLightAlpha);
  static Color tintDark()  => Colors.white.withValues(alpha: tintDarkAlpha);

  // —— Edge highlight ——
  static const double highlightWidth = 0.8;
  static Color highlightLight = Colors.white.withValues(alpha: 0.6);
  static Color highlightDark  = Colors.white.withValues(alpha: 0.12);
  static Color shadowEdge     = Colors.black.withValues(alpha: 0.08);

  // —— Squircle radii ——
  static const double radiusButton = 14.0;
  static const double radiusMenu   = 18.0;
  static const double radiusBar    = 22.0;
  static const double radiusSheet  = 28.0;
  static const double radiusCapsule = 32.0;

  // —— Press scale ——
  static const double pressedScale  = 0.96;
  static const double overshootScale = 1.02;

  // —— Animation ——
  static const Duration morphPressIn   = Duration(milliseconds: 80);
  static const Duration morphPressOut  = Duration(milliseconds: 220);
  static const Cubic    springOut      = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Duration scrollEdgeFade = Duration(milliseconds: 180);
  static const Duration tabCollapse    = Duration(milliseconds: 320);

  // —— Tab collapse triggers ——
  static const double tabCollapseScrollThreshold = 60.0;
  static const Duration tabCollapseDebounce = Duration(milliseconds: 200);
}
