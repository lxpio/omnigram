import 'package:flutter/material.dart';

/// Omnigram pastel color palette
/// Reference: docs/discussions/ui1.png, ui2.png
class OmnigramColors {
  OmnigramColors._();

  // Seed color for Material 3 dynamic scheme
  static const Color seed = Color(0xFF4A7C59); // Warm green

  // Pastel card backgrounds
  static const Color cardPink = Color(0xFFFCE4EC);
  static const Color cardGreen = Color(0xFFE8F5E9);
  static const Color cardLavender = Color(0xFFEDE7F6);
  static const Color cardPeach = Color(0xFFFFF3E0);
  static const Color cardBlue = Color(0xFFE3F2FD);

  // Surface colors
  static const Color surfaceLight = Color(0xFFF7F6F3);
  static const Color surfaceDark = Color(0xFF1A1A1A);

  // Reading-specific
  static const Color readerBgLight = Color(0xFFFBFBF3);
  static const Color readerBgDark = Color(0xFF1C1C1E);

  // Accent for interactive elements
  static const Color accent = Color(0xFF2E7D32);
  static const Color accentLight = Color(0xFF66BB6A);

  // AI accent
  static const Color accentLavender = Color(0xFF7E57C2);

  /// Returns a pastel color for a given index (cycles through palette)
  static Color pastelAt(int index) {
    const pastels = [cardPink, cardGreen, cardLavender, cardPeach, cardBlue];
    return pastels[index % pastels.length];
  }
}
