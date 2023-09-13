import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    required String bookBaseUrl,
    required String bookToken,
    required String appName,
    // final String model;
    // final String dbName;
    required bool shouldCollectCrashLog,
    String? openAIUrl,
    String? openAIApiKey,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, Object?> json) =>
      _$AppConfigFromJson(json);
}

// @riverpod
// AppConfig appConfig(AppConfigRef ref) {
//   return const AppConfig(
//       appName: 'Omnigram',
//       bookBaseUrl: 'http://127.0.0.1:8889',
//       bookToken: 'empty token',
//       shouldCollectCrashLog: false);
// }

final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(
      appName: 'Omnigram',
      bookBaseUrl: 'http://127.0.0.1:8889',
      bookToken: 'empty token',
      shouldCollectCrashLog: false);
});
