import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/models/app_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/app_config_model.dart';

part 'provider.g.dart';

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ThemeMode.system;
});

@Riverpod(keepAlive: true)
class AppConfig extends _$AppConfig {
  @override
  AppConfigModel build() {
    if (kDebugMode) {
      print("app config init...");
    }

    try {
      final d = json.decode(AppStore.instance.hive().get('config_v2'));

      if (d != null) {
        return AppConfigModel.fromJson(d);
      }
    } catch (e) {
      print("app config init error: $e");
    }

    return const AppConfigModel(
      appName: 'Omnigram',
      appVersion: '1.0.1',
      baseUrl: '',
      token: '',
      shouldCollectCrashLog: false,
    );
  }

  Future<void> updateSever({
    String? apiserver,
    String? apikey,
  }) async {
    // final updated = state.copyWith(baseUrl: apiserver, token: apikey);

    final updated = state.copyWith(
      baseUrl: apiserver ?? state.baseUrl,
      token: apikey ?? state.token,
      // serverConfig: serverConfig ?? state.serverConfig,
      // userConfig: userConfig ?? state.userConfig,
    );
    if (kDebugMode) {
      print(
          "app config updated baseUrl: ${updated.baseUrl} token ${updated.token}");
    }

    await AppStore.instance
        .hive()
        .put('config_v2', json.encode(updated.toJson()));

    state = updated;
  }
}
