import "package:flutter/material.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ThemeMode.light;
});
