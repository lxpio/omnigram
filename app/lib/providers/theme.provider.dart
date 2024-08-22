


import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/color_schemes.g.dart';
import 'package:omnigram/providers/app_settings.provider.dart';
import 'package:omnigram/services/app_settings.service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  
  var themeMode = ref
      .watch(appSettingsServiceProvider)
      .getSetting(AppSettingsEnum.themeMode);

  debugPrint("Current themeMode $themeMode");

  if (themeMode == "light") {
    return ThemeMode.light;
  } else if (themeMode == "dark") {
    return ThemeMode.dark;
  } else {
    return ThemeMode.system;
  }
});



final ThemeData omnigramDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
);


final ThemeData omnigramLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
);
