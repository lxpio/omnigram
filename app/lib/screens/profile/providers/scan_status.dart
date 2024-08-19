import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/api_service.dart';
import 'package:omnigram/providers/service/provider.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/server_model.dart';

part 'scan_status.g.dart';

@riverpod
class ScanAPI extends _$ScanAPI {
  @override
  bool build() {
    return true;
  }

  Future<ApiResponse> stop() async {
    final api = ref.read(apiServiceProvider);

    try {
      final resp = await api.request<ScanStatusModel>(
        'POST',
        "/book/scan/stop",
        fromJsonT: ScanStatusModel.fromJson,
      );

      if (resp.code == 200) {
        //notify to stop
        state = false;
      }

      return resp;
    } catch (e) {
      return ApiResponse(code: 500, message: 'stop scan task failed');
    }
  }

  //run scan
  Future<ApiResponse> run({
    bool refresh = false,
    int maxThread = 1,
  }) async {
    final api = ref.read(apiServiceProvider);

    try {
      final resp = await api.request<ScanStatusModel>(
        'POST',
        "/book/scan/run",
        body: {
          "refresh": refresh,
          "max_thread": maxThread,
        },
        fromJsonT: ScanStatusModel.fromJson,
      );

      if (resp.code == 200) {
        //notify to fetch status
        state = true;
        ref.notifyListeners();
      }

      return resp;
    } catch (e) {
      return ApiResponse(code: 500, message: 'stop scan task failed');
    }
  }

  Stream<ScanStatusModel> scanStatus() async* {
    final api = ref.watch(apiServiceProvider);

    var running = true;

    while (running) {
      final resp = await api.request<ScanStatusModel>(
          'GET', "/book/scan/status",
          fromJsonT: ScanStatusModel.fromJson);

      final state =
          resp.code == 200 ? resp.data! : const ScanStatusModel(running: false);

      running = state.running;

      yield state;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }
}

@riverpod
Stream<ScanStatusModel> scanStatus(ScanStatusRef ref) async* {
  // Connect to an API using sockets, and decode the output
  var running = ref.watch(scanAPIProvider);
  print("in scanStatus running");
  final api = ref.watch(apiServiceProvider);

  do {
    final resp = await api.request<ScanStatusModel>('GET', "/book/scan/status",
        fromJsonT: ScanStatusModel.fromJson);

    final state =
        resp.code == 200 ? resp.data! : const ScanStatusModel(running: false);

    running = state.running;

    yield state;
    await Future<void>.delayed(const Duration(seconds: 1));
  } while (running);
}
