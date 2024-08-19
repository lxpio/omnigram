// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_model.freezed.dart';
part 'server_model.g.dart';

@freezed
class ServerModel with _$ServerModel {
  const factory ServerModel({
    @Default("v1.0.0") String version,
    @Default(true) bool chatEnabled,
    @Default(true) bool m4tEnabled,
    String? system,
    String? architecture,
    @Default('/docs') @JsonKey(name: 'docs_data_path') String docsDataPath,
    @JsonKey(name: 'm4t_server_addr') String? m4tServerAddr,
    @JsonKey(name: 'openai_url') String? openAIUrl,
    @JsonKey(name: 'openai_apikey') String? openAIApiKey,

    // @Default(ScanStatusModel()) ScanStatusModel scan_stats,
  }) = _ServerModel;

  factory ServerModel.fromJson(Map<String, Object?> json) =>
      _$ServerModelFromJson(json);
}
