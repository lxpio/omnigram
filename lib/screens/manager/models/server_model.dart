import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_model.freezed.dart';
part 'server_model.g.dart';

@freezed
class ScanStatusModel with _$ScanStatusModel {
  const factory ScanStatusModel({
    @Default(0) @JsonKey(name: 'book_count') int bookCount,
    List<String>? errs,
    @Default(false) bool running,
    @Default('') @JsonKey(name: 'data_path') String dataPath,
  }) = _ScanStatusModel;

  factory ScanStatusModel.fromJson(Map<String, Object?> json) =>
      _$ScanStatusModelFromJson(json);
}

@freezed
class ServerModel with _$ServerModel {
  const factory ServerModel({
    @Default("v1.0.0") String version,
    String? system,
    String? architecture,
    @Default(ScanStatusModel()) ScanStatusModel scan_stats,
  }) = _ServerModel;

  factory ServerModel.fromJson(Map<String, Object?> json) =>
      _$ServerModelFromJson(json);
}
