import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class APIService {
  late final Dio _dio;

  String? proxy;

  Map<String, dynamic>? _headers;
  Map<String, dynamic>? _queries;
  Map<String, dynamic>? _bodies;

  static final singleton = APIService._internal();

  APIService._internal();

  APIService build(
      {String baseUrl = "https://127.0.0.1:8080",
      Map<String, dynamic>? serviceHeader,
      Map<String, dynamic>? serviceQuery,
      Map<String, dynamic>? serviceBody}) {
    _headers = serviceHeader;
    _queries = serviceQuery;
    _bodies = serviceBody;

    final options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json);

    _dio = Dio(options);

    if (proxy != null) {
      _dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) {
          /// "PROXY localhost:7890"
          return proxy!;
        };

        return client;
      });
    }

    // 设置拦截器
    _dio.interceptors.add(LogInterceptor(responseBody: true));

    return singleton;
  }

  Future<ApiResponse<T>> request<T>(String method, String path,
      {Map<String, dynamic>? query,
      Map<String, dynamic>? body,
      Map<String, dynamic>? header,
      T Function(Map<String, dynamic> json)? fromJsonT,
      CancelToken? cancelToken}) async {
    Map<String, dynamic> queryParams = _getQueryParams(query);

    Map<String, dynamic> headerParams = _getHeaderParams(header);

    Map<String, dynamic>? bodyParams = _getBodyParams(body);

    Options options = Options(headers: headerParams, method: method);

    final response = await _dio.request(path,
        data: bodyParams,
        queryParameters: queryParams,
        cancelToken: cancelToken,
        options: options);

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(response.data, fromJsonT);
    } else {
      throw (
        response: response,
        error: 'Request failed with status code ${response.statusCode}',
      );
    }
  }

  Map<String, dynamic> _getHeaderParams(Map<String, dynamic>? header) {
    Map<String, dynamic> headerParams = {};
    if (_headers != null) {
      headerParams.addAll(_headers!);
    }
    if (header != null) {
      headerParams.addAll(header);
    }
    return headerParams;
  }

  Map<String, dynamic> _getQueryParams(Map<String, dynamic>? query) {
    Map<String, dynamic>? queryParams = {};

    if (_queries != null) {
      queryParams.addAll(_queries!);
    }
    if (query != null) {
      queryParams.addAll(query);
    }
    return queryParams;
  }

  Map<String, dynamic> _getBodyParams(Map<String, dynamic>? body) {
    Map<String, dynamic>? bodyParams = {};

    if (_bodies != null) {
      bodyParams.addAll(_bodies!);
    }
    if (body != null) {
      bodyParams.addAll(body);
    }
    return bodyParams;
  }
}

class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json,
      [T Function(Map<String, dynamic> json)? fromJsonT]) {
    return ApiResponse<T>(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}