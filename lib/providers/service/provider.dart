import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/models/app_store.dart';
import 'package:omnigram/providers/provider.dart';
import 'package:omnigram/providers/service/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'interceptors.dart';
import 'server_model.dart';

part 'provider.g.dart';

final apiServiceProvider = Provider<APIService>((ref) {
  final appConfig = ref.watch(appConfigProvider);

  return APIService(
    baseUrl: appConfig.baseUrl,
    serviceHeader: {
      'Authorization': "Bearer ${appConfig.token}",
    },
    interceptor: OauthInterceptorWrapper(ref),
  );
});

@Riverpod(keepAlive: true)
class Server extends _$Server {
  @override
  ServerModel build() {
    if (kDebugMode) {
      print("server model build ");
    }
    try {
      final config = json.decode(AppStore.instance.hive().get('server_config'));

      if (config != null) {
        return ServerModel.fromJson(config);
      }
    } catch (e) {
      print("server_config model init error: $e");
    }

    return const ServerModel();
  }

  Future<int> update() async {
    final service = ref.read(apiServiceProvider);

    final userResp = await service.request('GET', '/sys/info',
        fromJsonT: ServerModel.fromJson);

    if (userResp.code == 200) {
      final updated = userResp.data!;
      await AppStore.instance
          .hive()
          .put('server_config', json.encode(updated.toJson()));

      state = updated;
    }

    return userResp.code;
  }
}
