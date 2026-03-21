import 'package:flutter/material.dart';

/// Ensure value is RGB (strips any alpha component).
int sanitizeRgb(int value) => value & 0x00FFFFFF;

/// Convert RGB int to Color with full alpha.
Color colorFromRgb(int rgb) => Color(0xFF000000 | sanitizeRgb(rgb));

/// Extract RGB component from a Color.
int rgbFromColor(Color color) => color.toARGB32() & 0x00FFFFFF;

int? parseRgb(dynamic value) {
  if (value == null) return null;
  if (value is Color) return rgbFromColor(value);
  if (value is num) {
    return sanitizeRgb(value.toInt());
  }
  if (value is String) {
    var v = value.trim();
    if (v.startsWith('0x')) {
      v = v.substring(2);
    } else if (v.startsWith('#')) {
      v = v.substring(1);
    }
    try {
      return sanitizeRgb(int.parse(v, radix: 16));
    } catch (_) {
      return null;
    }
  }
  return null;
}

String rgbString(dynamic value) {
  final rgb = parseRgb(value) ?? 0;
  return '0x${rgb.toRadixString(16).padLeft(6, '0')}';
}
