import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../models/server/auth_response.dart';

/// Base HTTP client for Omnigram Server REST API.
///
/// Handles authentication, token refresh, and error normalization.
class OmnigramApi {
  OmnigramApi({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(requestHeader: false, requestBody: true, responseBody: true, compact: true),
      );
    }

    _dio.interceptors.add(InterceptorsWrapper(onRequest: _onRequest, onError: _onError));
  }

  final String baseUrl;
  late final Dio _dio;

  String? _accessToken;
  String? _refreshToken;
  String? _account;
  String? _deviceId;

  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;

  /// Set authentication credentials from a successful login.
  void setAuth({required String accessToken, required String refreshToken, String? account, String? deviceId}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _account = account;
    _deviceId = deviceId;
  }

  /// Clear authentication state.
  void clearAuth() {
    _accessToken = null;
    _refreshToken = null;
    _account = null;
    _deviceId = null;
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_accessToken != null) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    handler.next(options);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 401 && _refreshToken != null) {
      try {
        final newToken = await _tryRefreshToken();
        if (newToken != null) {
          _accessToken = newToken.accessToken;
          _refreshToken = newToken.refreshToken;

          // Retry original request with new token
          final options = error.requestOptions;
          options.headers['Authorization'] = 'Bearer $_accessToken';
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        }
      } catch (_) {
        // Refresh failed — fall through to original error
      }
    }
    handler.next(error);
  }

  Future<AuthTokenResponse?> _tryRefreshToken() async {
    if (_account == null || _refreshToken == null) return null;
    try {
      final response = await _dio.post(
        '/auth/token/refresh',
        data: {'account': _account, 'device_id': _deviceId ?? '', 'refresh_token': _refreshToken},
        options: Options(headers: {}), // No auth header for refresh
      );
      return AuthTokenResponse.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  // ── HTTP Convenience Methods ─────────────────────────────────────

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return fromJson(response.data);
  }

  Future<List<T>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    final list = response.data as List;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<T> post<T>(String path, {dynamic data, required T Function(dynamic) fromJson}) async {
    final response = await _dio.post(path, data: data);
    return fromJson(response.data);
  }

  Future<void> postVoid(String path, {dynamic data}) async {
    await _dio.post(path, data: data);
  }

  Future<T> put<T>(String path, {dynamic data, required T Function(dynamic) fromJson}) async {
    final response = await _dio.put(path, data: data);
    return fromJson(response.data);
  }

  Future<void> putVoid(String path, {dynamic data}) async {
    await _dio.put(path, data: data);
  }

  Future<void> delete(String path, {dynamic data}) async {
    await _dio.delete(path, data: data);
  }

  Future<Response> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? extraFields,
  }) async {
    final formData = FormData.fromMap({fieldName: await MultipartFile.fromFile(filePath), ...?extraFields});
    return _dio.post(path, data: formData);
  }

  Future<Response> downloadFile(
    String path, {
    required String savePath,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _dio.download(path, savePath, onReceiveProgress: onReceiveProgress);
  }

  /// Raw Dio access for streaming or special cases.
  Dio get dio => _dio;
}

/// Exception wrapper for Omnigram API errors.
class OmnigramApiException implements Exception {
  OmnigramApiException({required this.statusCode, this.code, this.message, this.details});

  factory OmnigramApiException.fromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final err = ErrorResponse.fromJson(data);
      return OmnigramApiException(
        statusCode: e.response?.statusCode ?? 0,
        code: err.code,
        message: err.message,
        details: err.details,
      );
    }
    return OmnigramApiException(statusCode: e.response?.statusCode ?? 0, message: e.message);
  }

  final int statusCode;
  final String? code;
  final String? message;
  final dynamic details;

  @override
  String toString() => 'OmnigramApiException($statusCode): $message';
}
