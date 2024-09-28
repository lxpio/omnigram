import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/utils/url_helper.dart';
import 'package:openapi/openapi.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logging/logging.dart';

part 'api.provider.g.dart';

@Riverpod(keepAlive: true)
class ApiService extends _$ApiService {
  // late ApiClient _apiClient;

  final log = Logger("ApiService");

  @override
  DefaultApi build() {
    log.info("ApiService build");

    return _createApi();
  }

  setEndpoint() {
    state = _createApi();
    // ref.notifyListeners();
  }

  Future<bool> resolveAndSetEndpoint(String endpoint) async {
    final status = await _isEndpointAvailable(endpoint);
    if (status) {
      debugPrint("Endpoint is available");
      setEndpoint();
    }

    return status;
  }

  Future<bool> _isEndpointAvailable(String endpoint) async {
    final dio = _createDio(endpoint);

    try {
      final response = await dio.get("/sys/ping");

      log.info("Pinging server with response code ${response.statusCode}");
      if (response.statusCode != 200) {
        log.severe(
          "Server Gateway Error: ${response.data} - Cannot communicate to the server",
        );
        return false;
      }
    } on TimeoutException catch (_) {
      return false;
    } on SocketException catch (_) {
      return false;
    } catch (error, stackTrace) {
      log.severe(
        "Error while checking server availability",
        error,
        stackTrace,
      );
      return false;
    }
    return true;
  }

  Dio _createDio(String? baseUrl) {
    return Dio(BaseOptions(
      baseUrl: baseUrl ?? r'http://localhost',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  DefaultApi _createApi() {
    final endpoint = IsarStore.tryGet(StoreKey.serverEndpoint);
    final accessToken = IsarStore.get(StoreKey.accessToken, "");
    // final customHeadersStr = IsarStore.get(StoreKey.customHeaders, "");

    final dio = _createDio(endpoint);

    final interceptors = [
      setDeviceHeadersInterceptor(),
      BearerAuthInterceptor()
    ];

    if (kDebugMode) {
      interceptors.add(LogInterceptor(request: true, responseBody: true));
    }

    final api = Openapi(dio: dio, interceptors: interceptors);

    api.setBearerAuth('bearer', accessToken);
    return api.getDefaultApi();
  }

  DeviceHeaderInterceptor setDeviceHeadersInterceptor() {
    // Make sign-in request
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    final Map<String, String> headers = {};

    try {
      if (Platform.isIOS) {
        deviceInfoPlugin.iosInfo.then((iosInfo) {
          headers['x-device-model'] = iosInfo.utsname.machine;
          headers['x-device-type'] = 'iOS';
        });
      } else {
        deviceInfoPlugin.androidInfo.then((androidInfo) {
          headers['x-device-model'] = androidInfo.model;
          headers['x-device-type'] = 'Android';
        });
      }
    } catch (e) {
      // log.warning("Failed to set device headers: $e");
    }

    return DeviceHeaderInterceptor(headers: headers);
  }

  static Map<String, String> getRequestHeaders() {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final Map<String, String> headers = {};
    try {
      if (Platform.isIOS) {
        deviceInfoPlugin.iosInfo.then((iosInfo) {
          headers['x-device-model'] = iosInfo.utsname.machine;
          headers['x-device-type'] = 'iOS';
        });
      } else {
        deviceInfoPlugin.androidInfo.then((androidInfo) {
          headers['x-device-model'] = androidInfo.model;
          headers['x-device-type'] = 'Android';
        });
      }
    } catch (e) {
      // log.warning("Failed to set device headers: $e");
    }

    final accessToken = IsarStore.get(StoreKey.accessToken, "");
    headers['Authorization'] = 'Bearer $accessToken';

    return headers;
  }
}

class DeviceHeaderInterceptor extends Interceptor {
  final Map<String, String> headers;

  DeviceHeaderInterceptor({Map<String, String>? headers})
      : headers = headers ?? {};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers.addAll(headers);
    super.onRequest(options, handler);
  }
}
