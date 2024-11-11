import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/color_schemes.g.dart';
import 'package:omnigram/providers/app_settings.provider.dart';
import 'package:omnigram/services/app_settings.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeState extends _$ThemeState {
  @override
  ThemeMode build() {
    var themeMode = ref.watch(appSettingsServiceProvider).getSetting(AppSettingsEnum.themeMode);

    if (themeMode == "light") {
      return ThemeMode.light;
    } else if (themeMode == "dark") {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
    // return themeMode;
  }

  void setTheme(ThemeMode themeMode) {
    ref.watch(appSettingsServiceProvider).setSetting(AppSettingsEnum.themeMode, themeMode.toString());
    state = themeMode;
  }
}

String getThemeModeLangTag(ThemeMode themeMode) {
  if (themeMode == ThemeMode.light) {
    return "light_mode";
  } else if (themeMode == ThemeMode.dark) {
    return "dark_mode";
  } else {
    return "follow_system_mode";
  }
}

final ThemeData omnigramDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
);

final ThemeData omnigramLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
);
