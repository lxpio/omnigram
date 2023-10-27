//bookAPIServiceProvider 是全局有效的所以这了不要 autoDispose
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/flavors/provider.dart';
import 'package:omnigram/providers/service/api_service.dart';

import 'interceptors.dart';

final apiServiceProvider = Provider<APIService>((ref) {
  final appConfig = ref.watch(appConfigProvider);

  

  return APIService(
    baseUrl: appConfig.baseUrl,
    serviceHeader: {
      'Authorization': "Bearer ${appConfig.token}",
    },
    interceptor: OauthInterceptorWrapper(ref),
  );
});
