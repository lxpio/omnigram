import 'package:flutter/material.dart';

/// Deterministic RGB color from a string. Alpha is always 0xFF.
Color hashColor(String input) {
  int hash = 0;
  for (int i = 0; i < input.length; i++) {
    hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    hash = hash & 0xFFFFFFFF;
  }
  final r = (hash & 0xFF0000) >> 16;
  final g = (hash & 0x00FF00) >> 8;
  final b = (hash & 0x0000FF);
  return Color.fromARGB(0xFF, r, g, b);
}
