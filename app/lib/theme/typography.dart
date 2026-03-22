import 'package:flutter/material.dart';

/// Omnigram typography hierarchy
/// Bold headings, warm body text, clear visual hierarchy
class OmnigramTypography {
  OmnigramTypography._();

  static TextStyle displayLarge(BuildContext context) =>
      TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.3, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle displayMedium(BuildContext context) =>
      TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle titleLarge(BuildContext context) =>
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle titleMedium(BuildContext context) =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle bodyLarge(BuildContext context) =>
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: Theme.of(context).colorScheme.onSurface);

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static TextStyle label(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}
