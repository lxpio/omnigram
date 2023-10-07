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
    final config = AppStore.instance.hive().get('config');

    if (config != null) {
      return AppConfig.fromJson(config);
    }

    return const AppConfig(
        appName: 'Omnigram',
        bookBaseUrl: '',
        bookToken: '',
        openAIUrl: '',
        shouldCollectCrashLog: false);
  }

  void update(AppConfig config) {
    AppStore.instance.hive().put('config', config.toJson());
    state = config;
  }
}
