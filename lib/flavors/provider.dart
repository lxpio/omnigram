import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_config.dart';
import 'app_store.dart';

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ThemeMode.light;
});

final appConfigProvider =
    NotifierProvider<AppConfigProvider, AppConfig>(AppConfigProvider.new);

class AppConfigProvider extends Notifier<AppConfig> {
  @override
  AppConfig build() {
    if (kDebugMode) {
      print("app config init...");
    }

    try {
      final d = json.decode(AppStore.instance.hive().get('config'));

      if (d != null) {
        return AppConfig.fromJson(d);
      }
    } catch (e) {
      print("app config init error: $e");
    }

    return const AppConfig(
      appName: 'Omnigram',
      bookBaseUrl: '',
      bookToken: '',
      openAIUrl: '',
      shouldCollectCrashLog: false,
    );
  }

  Future<void> updateSever(String apiserver, String apikey) async {
    final updated = state.copyWith(bookBaseUrl: apiserver, bookToken: apikey);

    await AppStore.instance.hive().put('config', json.encode(updated.toJson()));

    state = updated;
  }
}
