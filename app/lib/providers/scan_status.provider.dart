


import 'package:flutter/material.dart';
import 'package:omnigram/providers/api.provider.dart';
import 'package:openapi/openapi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../models/server_model.dart';

part 'scan_status.provider.g.dart';

@riverpod
class ScanService extends _$ScanService {
  @override
  bool build() {
    return false;
  }

  Future<ScanStatsDto?> stop() async {
    final api = ref.read(apiServiceProvider);

    try {
      final resp = await api.sysScanStopPost();

      if (resp.statusCode == 200) {
        //notify to stop
        state = false;
      }

      return resp.data;
    } catch (e) {
      // return ApiResponse(code: 500, message: 'stop scan task failed');
      debugPrint("Error [getDiskInfo] ${e.toString()}");

    }
    return null;
  }

  //run scan
  Future<ScanStatsDto?> run({
    bool refresh = false,
    int maxThread = 1,
  }) async {
    final api = ref.read(apiServiceProvider);

    try {

      final resp = await api.sysScanRunPost(
        enableScanDto:EnableScanDto((b) => b
      ..maxThread = maxThread
      ..refresh = refresh)
        );

      if (resp.statusCode == 200) {
        //notify to fetch status
        state = true;
        ref.notifyListeners();
      }

      return resp.data;
    } catch (e) {
      // return ApiResponse(code: 500, message: 'stop scan task failed');
    }
    return null;
  }

  Stream<ScanStatsDto> scanStatus() async* {
    final api = ref.watch(apiServiceProvider);

    var running = true;

    while (running) {

      ScanStatsDto stats;

      try {

        final resp = await api.sysScanStatusGet();

        stats =
            resp.statusCode == 200 ? resp.data! :  ScanStatsDto( (b) => b..running = false,);

      } catch (e) {
        stats =  ScanStatsDto( (b) => b..running = false,);
      }
      

      running = stats.running;
      // state = running;
      yield stats;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }
}

@riverpod
Stream<ScanStatsDto> scanStatus(ScanStatusRef ref) async* {
  // Connect to an API using sockets, and decode the output
  final api = ref.watch(apiServiceProvider);

    var running = true;

    while (running) {

      ScanStatsDto stats;

      try {

        final resp = await api.sysScanStatusGet();

        stats =
            resp.statusCode == 200 ? resp.data! :  ScanStatsDto( (b) => b..running = false,);

      } catch (e) {
        stats =  ScanStatsDto( (b) => b..running = false,);
      }
      

      running = stats.running;
      // state = running;
      yield stats;
      await Future<void>.delayed(const Duration(seconds: 1));
    }

  

}

