import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/providers/auth.provider.dart';
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

  Future<void> logout(DefaultApi api) async {
    String? userEmail = IsarStore.tryGet(StoreKey.currentUser)?.email;

    final accessToken = IsarStore.tryGet(StoreKey.accessToken);

    await api
        .authLogoutPost(headers: {'Authorization': 'Bearer $accessToken'})
        .then((_) => log.info("Logout was successful for $userEmail"))
        .onError(
          (error, stackTrace) => log.severe("Logout failed for $userEmail", error, stackTrace),
        );

    await Future.wait([
      // clearAssetsAndAlbums(_db),
      IsarStore.delete(StoreKey.currentUser),
      IsarStore.delete(StoreKey.accessToken),
      IsarStore.delete(StoreKey.refreshToken),
    ]);

    ref.read(authProvider.notifier).logout();
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

  List<Interceptor> bearerAuthInterceptors() {
    return [
      QueuedInterceptorsWrapper(onRequest: (options, handler) {
        final accessToken = IsarStore.tryGet(StoreKey.accessToken);
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      }, onError: (error, handler) async {
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
    final deviceId = IsarStore.tryGet(StoreKey.deviceId);
    final api = _createApi(endpoint);

    final request = RefreshTokenDto((b) => b
      ..account = account
      ..deviceId = deviceId
      ..refreshToken = refreshToken);

    final result = await api.authTokenRefreshPost(refreshTokenDto: request);

    if (result.statusCode == null || result.statusCode! ~/ 100 != 2 || result.data == null) {
      log.severe("Failed to refresh token");
      await logout(api);

      throw DioException(requestOptions: result.requestOptions);
    }

    IsarStore.put(StoreKey.accessToken, result.data!.accessToken);
  }

  static AddHeaderInterceptor setDeviceHeadersInterceptor() {
    final Map<String, String> headers = getDeviceHeaders();
    return AddHeaderInterceptor(headers: headers);
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

    return headers;
  }
}

DefaultApi _createApi(String? endpoint, {List<Interceptor>? interceptors}) {
  final dio = _createDio(endpoint);

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

class AddHeaderInterceptor extends Interceptor {
  final Map<String, String> headers;

  AddHeaderInterceptor({Map<String, String>? headers}) : headers = headers ?? {};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers.addAll(headers);
    super.onRequest(options, handler);
  }
}

Dio _createDio(String? baseUrl, {Map<String, dynamic>? headers}) {
  return Dio(BaseOptions(
    baseUrl: baseUrl ?? r'http://localhost',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
    headers: headers,
  ));
}
