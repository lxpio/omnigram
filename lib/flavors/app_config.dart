import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig({
    required String baseUrl,
    required String token,
    required String appName,
    required bool chatEnabled,
    required bool m4tEnabled,
    required bool shouldCollectCrashLog,
    String? openAIUrl,
    String? openAIApiKey,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, Object?> json) =>
      _$AppConfigFromJson(json);
}
