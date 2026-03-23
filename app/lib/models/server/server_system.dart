import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_system.freezed.dart';
part 'server_system.g.dart';

@freezed
abstract class ServerSystemInfo with _$ServerSystemInfo {
  const factory ServerSystemInfo({
    String? version,
    String? system,
    String? architecture,
    @JsonKey(name: 'tts_support') @Default(false) bool ttsSupport,
    @JsonKey(name: 'tts_provider') String? ttsProvider,
    @JsonKey(name: 'disk_usage') Map<String, dynamic>? diskUsage,
  }) = _ServerSystemInfo;

  factory ServerSystemInfo.fromJson(Map<String, dynamic> json) => _$ServerSystemInfoFromJson(json);
}

@freezed
abstract class ServerAiConfig with _$ServerAiConfig {
  const factory ServerAiConfig({
    @Default(false) bool enabled,
    @Default('') String provider,
    @JsonKey(name: 'base_url') @Default('') String baseUrl,
    @JsonKey(name: 'api_key') @Default('') String apiKey,
    @Default('') String model,
    @JsonKey(name: 'auto_metadata') @Default(false) bool autoMetadata,
    @JsonKey(name: 'auto_summary') @Default(false) bool autoSummary,
  }) = _ServerAiConfig;

  factory ServerAiConfig.fromJson(Map<String, dynamic> json) => _$ServerAiConfigFromJson(json);
}

@freezed
abstract class ServerApiToken with _$ServerApiToken {
  const factory ServerApiToken({
    @Default(0) int id,
    @Default('') String name,
    @JsonKey(name: 'api_key') @Default('') String apiKey,
    @JsonKey(name: 'user_id') @Default(0) int userId,
    @Default(0) @JsonKey(name: 'ctime') int ctime,
  }) = _ServerApiToken;

  factory ServerApiToken.fromJson(Map<String, dynamic> json) => _$ServerApiTokenFromJson(json);
}

@freezed
abstract class PagedResponse with _$PagedResponse {
  const factory PagedResponse({
    dynamic data,
    @Default(1) int page,
    @JsonKey(name: 'page_size') @Default(20) int pageSize,
    @JsonKey(name: 'total_count') @Default(0) int totalCount,
    @JsonKey(name: 'total_pages') @Default(0) int totalPages,
  }) = _PagedResponse;

  factory PagedResponse.fromJson(Map<String, dynamic> json) => _$PagedResponseFromJson(json);
}

@freezed
abstract class ServerScanStatus with _$ServerScanStatus {
  const factory ServerScanStatus({@Default(false) bool scanning, @Default(0.0) double progress}) = _ServerScanStatus;

  factory ServerScanStatus.fromJson(Map<String, dynamic> json) => _$ServerScanStatusFromJson(json);
}
