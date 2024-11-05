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
    final endpoint = IsarStore.tryGet(StoreKey.serverEndpoint);
    return _createApi(endpoint, interceptors: bearerAuthInterceptors());
  }

  setEndpoint(String endpoint) {
    state = _createApi(endpoint, interceptors: bearerAuthInterceptors());
  }

  Future<bool> resolveAndSetEndpoint(String serverUrl) async {
    //save server url
    final endpoint = sanitizeUrl(serverUrl);
    final status = await _isEndpointAvailable(endpoint);
    if (status) {
      debugPrint('Endpoint: $endpoint');
      await IsarStore.put(StoreKey.serverEndpoint, endpoint);
      setEndpoint(endpoint);
    }

    return status;
  }

  Future<bool> _isEndpointAvailable(String endpoint) async {
    try {
      final dio = _createDio(endpoint);
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

  static DeviceHeaderInterceptor setDeviceHeadersInterceptor() {
    final Map<String, String> headers = getDeviceHeaders();
    return DeviceHeaderInterceptor(headers: headers);
  }

  static Map<String, String> getDeviceHeaders() {
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

    // final accessToken = IsarStore.tryGet(StoreKey.accessToken);

    // if (accessToken != null) {
    //   headers['Authorization'] = 'Bearer $accessToken';
    // }

    return headers;
  }
}

DefaultApi _createApi(String? endpoint, {List<Interceptor>? interceptors}) {
  final dio = _createDio(endpoint);

  // final Map<String, String> headers = ApiService.getDeviceHeaders();
  // return DeviceHeaderInterceptor(headers: headers);

  List<Interceptor> myInterceptors = [ApiService.setDeviceHeadersInterceptor()];

  if (interceptors != null) {
    myInterceptors.addAll(interceptors);
  }

  if (kDebugMode) {
    myInterceptors.add(LogInterceptor(request: true, responseBody: true));
  }

  final api = Openapi(dio: dio, interceptors: interceptors);

  return api.getDefaultApi();
}

class DeviceHeaderInterceptor extends Interceptor {
  final Map<String, String> headers;

  DeviceHeaderInterceptor({Map<String, String>? headers}) : headers = headers ?? {};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers.addAll(headers);
    super.onRequest(options, handler);
  }
}

List<Interceptor> bearerAuthInterceptors() {
  return [
    QueuedInterceptorsWrapper(onRequest: (options, handler) {
      final accessToken = IsarStore.tryGet(StoreKey.accessToken);
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      handler.next(options);
    },
        // onResponse: (response, handler) {},
        onError: (error, handler) async {
      if (error.response == null) {
        return handler.next(error);
      }

      if (error.response?.statusCode == 401) {
        try {
          final user = IsarStore.tryGet(StoreKey.currentUser);
          if (user == null) {
            return handler.next(error);
          }

          await refreshToken(user.name);

          return handler.next(error);
        } on DioException catch (e) {
          return handler.reject(e);
        }

        // await AuthProvider().logout();
      }
      return handler.next(error);
    }),

    /// Retry the request when 401 occurred
    QueuedInterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response != null && error.response!.statusCode == 401) {
          final retryDio = Dio(
            BaseOptions(baseUrl: error.requestOptions.baseUrl),
          );

          if (error.requestOptions.headers.containsKey('Authorization')) {
            error.requestOptions.headers['Authorization'] = IsarStore.tryGet(StoreKey.accessToken) ?? '';
          }

          /// In real-world scenario,
          /// the request should be requested with [error.requestOptions]
          /// using [fetch] method.
          /// ``` dart
          /// final result = await retryDio.fetch(error.requestOptions);
          /// ```
          final result = await retryDio.fetch(error.requestOptions);

          return handler.resolve(result);
        }
      },
    ),
  ];
}

Future<void> refreshToken(String account) async {
  final endpoint = IsarStore.tryGet(StoreKey.serverEndpoint);
  final refreshToken = IsarStore.tryGet(StoreKey.refreshToken);
  final api = _createApi(endpoint);

  final request = RefreshTokenDto((b) => b
    ..account = account
    ..refreshToken = refreshToken);

  final result = await api.authTokenRefreshPost(refreshTokenDto: request);

  if (result.statusCode == null || result.statusCode! ~/ 100 != 2 || result.data == null) {
    throw DioException(requestOptions: result.requestOptions);
  }

  IsarStore.put(StoreKey.accessToken, result.data!.accessToken);
}

Dio _createDio(String? baseUrl, {Map<String, dynamic>? headers}) {
  return Dio(BaseOptions(
    baseUrl: baseUrl ?? r'http://localhost',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
    headers: headers,
  ));
}
