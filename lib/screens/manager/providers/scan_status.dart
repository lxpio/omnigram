import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/provider.dart';
import 'package:omnigram/screens/manager/models/server_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scan_status.g.dart';

@riverpod
class ScanStatus extends _$ScanStatus {
  @override
  Future<ScanStatusModel> build() async {
    final api = ref.watch(apiServiceProvider);

    final resp = await api.request<ScanStatusModel>('GET', "/book/scan/status",
        fromJsonT: ScanStatusModel.fromJson);

    if (resp.code == 200) {
      return resp.data!;
    }
    return ScanStatusModel();
    //todo
    // throw Exception(resp.message);
  }

  //run scan
  Future<void> run({
    bool refresh = false,
    int maxThread = 1,
  }) async {
    final api = ref.read(apiServiceProvider);

    final resp = await api.request<ScanStatusModel>(
      'POST',
      "/book/scan/run",
      body: {
        "refresh": refresh,
        "max_thread": maxThread,
      },
    );

    if (resp.code == 200) {
      state = AsyncData(resp.data!);
      return;
    }

    if (kDebugMode) {
      print(resp.message);
    }
  }

  Future<void> stop() async {
    final api = ref.read(apiServiceProvider);

    final resp = await api.request<ScanStatusModel>('POST', "/book/scan/stop");

    if (resp.code == 200) {
      state = AsyncData(resp.data!);
      return;
    }

    if (kDebugMode) {
      print(resp.message);
    }
  }

  Future<void> refresh() async {
    final api = ref.read(apiServiceProvider);
    final resp = await api.request<ScanStatusModel>('GET', "/book/scan/status",
        fromJsonT: ScanStatusModel.fromJson);

    if (resp.code == 200) {
      state = AsyncData(resp.data!);
      return;
    }

    if (kDebugMode) {
      print(resp.message);
    }
  }
}
