import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/user/user_model.dart';

class OauthInterceptorWrapper extends Interceptor {
  Ref ref;

  OauthInterceptorWrapper(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    return handler.next(options); // super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        'have Error [${err.response?.statusCode}] => Data: ${err.response?.data}');
    if (err.response?.statusCode == 401) {
      ref.read(userProvider.notifier).logout();
      // TODO: 401 处理
    }

    super.onError(err, handler);
  }
}
