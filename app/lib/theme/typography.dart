import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Platform-aware system font (iOS 26 alignment).
/// - iOS / macOS: SF Pro Text
/// - Android: Roboto Flex (Flutter 3.16+ built-in)
/// - Windows: Segoe UI Variable
/// Returns null on web/other → Flutter default.
String? systemFontFamily() {
  if (kIsWeb) return null;
  if (Platform.isIOS || Platform.isMacOS) return '.SF Pro Text';
  if (Platform.isAndroid) return 'Roboto Flex';
  if (Platform.isWindows) return 'Segoe UI Variable';
  return null;
}

/// Omnigram typography hierarchy
/// Bold headings, warm body text, clear visual hierarchy
class OmnigramTypography {
  OmnigramTypography._();

  static String? get _ff => systemFontFamily();

  static TextStyle displayLarge(BuildContext context) => TextStyle(
        fontFamily: _ff,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle displayMedium(BuildContext context) => TextStyle(
        fontFamily: _ff,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle titleLarge(BuildContext context) => TextStyle(
        fontFamily: _ff,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
        fontFamily: _ff,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontFamily: _ff,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontFamily: _ff,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontFamily: _ff,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle label(BuildContext context) => TextStyle(
        fontFamily: _ff,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
}
