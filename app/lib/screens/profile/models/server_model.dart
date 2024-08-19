// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_model.freezed.dart';
part 'server_model.g.dart';

@freezed
class ScanStatusModel with _$ScanStatusModel {
  const factory ScanStatusModel({
    @Default(0) int total,
    @Default(false) bool running,
    @Default(0) @JsonKey(name: 'scan_count') int scanCount,
    @Default(0) @JsonKey(name: 'disk_usage') int diskUsage,
    @Default(0) @JsonKey(name: 'epub_count') int epubCount,
    @Default(0) @JsonKey(name: 'pdf_count') int pdfCount,
    List<String>? errs,
  }) = _ScanStatusModel;

  factory ScanStatusModel.fromJson(Map<String, Object?> json) =>
      _$ScanStatusModelFromJson(json);
}
