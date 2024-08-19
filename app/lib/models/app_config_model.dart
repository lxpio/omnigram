import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config_model.freezed.dart';
part 'app_config_model.g.dart';

@freezed
class AppConfigModel with _$AppConfigModel {
  const factory AppConfigModel({
    required String baseUrl,
    required String token,
    required String appName,
    required String appVersion,
    required bool shouldCollectCrashLog,
  }) = _AppConfigModel;

  factory AppConfigModel.fromJson(Map<String, Object?> json) =>
      _$AppConfigModelFromJson(json);
}
