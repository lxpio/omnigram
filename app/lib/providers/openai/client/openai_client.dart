import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'model.dart';
import 'utils.dart';
import 'err.dart';

abstract class OpenAIWrapper {}

class OpenAIClient extends OpenAIWrapper {

  ///[log]
  final Logger _log = Logger("PartnerService");

  OpenAIClient({required Dio dio, bool isLogging = false}) {
    _dio = dio;
    // log = Logger.instance.builder(isLogging: isLogging);
  }

  ///[_dio]
  late Dio _dio;



  Future<T> get<T>(
    String url, {
    required T Function(Map<String, dynamic>) onSuccess,
    required void Function(CancelData cancelData) onCancel,
    bool returnRawData = false,
  }) async {
    try {
      final cancelData = CancelData(cancelToken: CancelToken());
      onCancel(cancelData);

      // _log.info("starting request");
      final rawData = await _dio.get(url, cancelToken: cancelData.cancelToken);

      if (rawData.statusCode == HttpStatus.ok) {
        // _log.info("============= success ==================");

        if (returnRawData) {
          return rawData.data as T;
        }

        return onSuccess(rawData.data);
      } else {
        // _log.info("code: ${rawData.statusCode}, message :${rawData.data}");
        throw handleError(
          code: rawData.statusCode ?? HttpStatus.internalServerError,
          message: "",
          data: rawData.data,
        );
      }
    } on DioException catch (err) {
      // _log.info(
      //   "code: ${err.response?.statusCode}, message :${err.message} + ${err.response?.data}",
      // );
      throw handleError(
        code: err.response?.statusCode ?? HttpStatus.internalServerError,
        message: '${err.message}',
        data: err.response?.data,
      );
    }
  }

  Stream<T> getStream<T>(
    String url, {
    required T Function(Map<String, dynamic>) onSuccess,
    required void Function(CancelData cancelData) onCancel,
  }) {
    final controller = StreamController<T>.broadcast();
    final cancelData = CancelData(cancelToken: CancelToken());

    onCancel(cancelData);

    // _log.info("starting request");
    _dio
        .get(
      url,
      cancelToken: cancelData.cancelToken,
      options: Options(responseType: ResponseType.stream),
    )
        .then(
      (it) {
        (it.data.stream as Stream).listen(
          (it) {
            final rawData = utf8.decode(it);

            final dataList = rawData
                .split("\n")
                .where((element) => element.isNotEmpty)
                .toList();

            for (final line in dataList) {
              if (line.startsWith("data: ")) {
                final data = line.substring(6);
                if (data.startsWith("[DONE]")) {
                  // _log.info("stream response is done");

                  return;
                }

                controller
                  ..sink
                  ..add(onSuccess(json.decode(data)));
              }
            }
          },
          onDone: () {
            controller.close();
          },
          onError: (err, t) {
            _log.severe(err, t);
            controller
              ..sink
              ..addError(err, t);
          },
        );
      },
      onError: (err, t) {
        _log.severe(err, t);
        controller
          ..sink
          ..addError(err, t);
      },
    );

    return controller.stream;
  }

  Future<T> delete<T>(
    String url, {
    required T Function(Map<String, dynamic>) onSuccess,
    required void Function(CancelData cancelData) onCancel,
  }) async {
    try {
      final cancelData = CancelData(cancelToken: CancelToken());
      onCancel(cancelData);

      _log.info("starting request");
      final rawData =
          await _dio.delete(url, cancelToken: cancelData.cancelToken);

      if (rawData.statusCode == HttpStatus.ok) {
        _log.info("============= success ==================");

        return onSuccess(rawData.data);
      } else {
        _log.info("error code: ${rawData.statusCode}, message :${rawData.data}");
        throw handleError(
          code: rawData.statusCode ?? HttpStatus.internalServerError,
          message: "${rawData.statusCode}",
          data: rawData.data,
        );
      }
    } on DioException catch (err) {
      _log.info(
        "code: ${err.response?.statusCode}, message :${err.message} data: ${err.response?.data}",
      );
      throw handleError(
        code: err.response?.statusCode ?? HttpStatus.internalServerError,
        message: "${err.message}",
        data: err.response?.data,
      );
    }
  }

  Future<T> post<T>(
    String url,
    Map<String, dynamic> request, {
    required T Function(Map<String, dynamic>) onSuccess,
    required void Function(CancelData cancelData) onCancel,
  }) async {
    try {
      final cancelData = CancelData(cancelToken: CancelToken());
      onCancel(cancelData);

      _log.info("starting request");
      _log.info("request body :$request");

      final response = await _dio.post(
        url,
        data: json.encode(request),
        cancelToken: cancelData.cancelToken,
      );

      if (response.statusCode == HttpStatus.ok) {
        _log.info("============= success ==================");

        return onSuccess(response.data);
      } else {
        _log.info("code: ${response.statusCode}, message :${response.data}");
        throw handleError(
          code: response.statusCode ?? HttpStatus.internalServerError,
          message: "${response.statusCode}",
          data: response.data,
        );
      }
    } on DioException catch (err) {
      _log.info(
        "error code: ${err.response?.statusCode}, message :${err.message} data:${err.response?.data}",
      );
      throw handleError(
        code: err.response?.statusCode ?? HttpStatus.internalServerError,
        message: "${err.response?.statusCode}",
        data: err.response?.data,
      );
    }
  }

  Stream<Response> postStream(
    String url,
    Map<String, dynamic> request, {
    required void Function(CancelData cancelData) onCancel,
  }) {
    final cancelData = CancelData(cancelToken: CancelToken());
    onCancel(cancelData);

    _log.info("starting request");
    _log.info("request body :$request");
    final response = _dio
        .post(
          url,
          data: json.encode(request),
          cancelToken: cancelData.cancelToken,
        )
        .asStream();

    return response;
  }

  Stream<T> sse<T>(
    String url,
    Map<String, dynamic> request, {
    required T Function(Map<String, dynamic> value) complete,
    required void Function(CancelData cancelData) onCancel,
  }) {
    _log.info("starting request");
    _log.info("request body :$request");
    final controller = StreamController<T>.broadcast();
    final cancelData = CancelData(cancelToken: CancelToken());
    try {
      onCancel(cancelData);
      _dio
          .post(
        url,
        cancelToken: cancelData.cancelToken,
        data: json.encode(request),
        options: Options(responseType: ResponseType.stream),
      )
          .then(
        (it) {
          it.data.stream.listen(
            (it) {
              final raw = utf8.decode(it);
              final dataList = raw
                  .split("\n")
                  .where((element) => element.isNotEmpty)
                  .toList();

              for (final data in dataList) {
                if (data.startsWith("data: ")) {
                  ///remove data:
                  final mData = data.substring(6);
                  if (mData.startsWith("[DONE]")) {
                    _log.info("stream response is done");

                    return;
                  }

                  final jsonMap = mData.decode();
                  if (jsonMap.keys.last) {
                    ///decode data
                    controller
                      ..sink
                      ..add(complete(jsonMap[jsonMap.keys.last]));
                  } else {
                    _log.info("stream response invalid try regenerate");
                    _log.info("last json error :$mData");
                  }
                }
              }
            },
            onDone: () {
              controller.close();
            },
            onError: (err, t) {
              _log.severe(err, t);
              if (err is DioException) {
                controller
                  ..sink
                  ..addError(
                    handleError(
                      code: err.response?.statusCode ??
                          HttpStatus.internalServerError,
                      message: '${err.message}',
                      data: err.response?.extra,
                    ),
                    t,
                  );
              }
            },
          );
        },
        onError: (err, t) {
          _log.severe(err, t);
          if (err is DioException) {
            final error = err;
            controller
              ..sink
              ..addError(
                handleError(
                  code: error.response?.statusCode ??
                      HttpStatus.internalServerError,
                  message: '${error.message}',
                  data: error.response?.extra,
                ),
                t,
              );
          }
        },
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _log.info("cancel request");
      }
    }

    return controller.stream;
  }

  Future<T> postFormData<T>(
    String url,
    FormData request, {
    required T Function(Map<String, dynamic> value) complete,
    required void Function(CancelData cancelData) onCancel,
  }) async {
    try {
      final cancelData = CancelData(cancelToken: CancelToken());
      onCancel(cancelData);

      _log.info("starting request");
      _log.info("request body :$request");
      final response = await _dio.post(
        url,
        data: request,
        cancelToken: cancelData.cancelToken,
      );

      if (response.statusCode == HttpStatus.ok) {
        _log.info("============= success ==================\n");

        return complete(response.data);
      } else {
        _log.info("code: ${response.statusCode}, error: ${response.data}");
        throw handleError(
          code: response.statusCode ?? HttpStatus.internalServerError,
          message: "${response.statusCode}",
          data: response.data,
        );
      }
    } on DioException catch (err) {
      _log.info(
        "code: ${err.response?.statusCode}, error: ${err.message} ${err.response?.data}",
      );
      throw handleError(
        code: err.response?.statusCode ?? HttpStatus.internalServerError,
        message: "${err.response?.statusCode}",
        data: err.response?.data,
      );
    }
  }

  BaseErrorWrapper handleError({
    required int code,
    required String message,
    Map<String, dynamic>? data,
  }) {
    if (code == HttpStatus.unauthorized) {
      return OpenAIAuthError(
        code: code,
        data: OpenAIError.fromJson(data, message),
      );
    } else if (code == HttpStatus.tooManyRequests) {
      return OpenAIRateLimitError(
        code: code,
        data: OpenAIError.fromJson(data, message),
      );
    } else {
      return OpenAIServerError(
        code: code,
        data: OpenAIError.fromJson(data, message),
      );
    }
  }
}

class InterceptorWrapper extends Interceptor {
  final String? _token;
  final String? _orgID;

  InterceptorWrapper({String? token, String? orgID})
      : _token = token,
        _orgID = orgID;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final headers = {'Content-Type': 'application/json'};

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    if (_orgID != null) {
      headers['OpenAI-Organization'] = _orgID!;
    }

    options.headers.addAll(headers);

    return handler.next(options); // super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        'http status code => ${response.statusCode} \nresponse data => ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        'have Error [${err.response?.statusCode}] => Data: ${err.response?.data}');
    super.onError(err, handler);
  }
}

class HttpSetup {
  Duration sendTimeout;
  Duration connectTimeout;
  Duration receiveTimeout;
  String proxy;

  HttpSetup({
    this.sendTimeout = const Duration(seconds: 6),
    this.connectTimeout = const Duration(seconds: 6),
    this.receiveTimeout = const Duration(seconds: 6),
    this.proxy = '',
  });
}
