// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ScanStatusModel _$$_ScanStatusModelFromJson(Map<String, dynamic> json) =>
    _$_ScanStatusModel(
      bookCount: json['book_count'] as int? ?? 0,
      errs: (json['errs'] as List<dynamic>?)?.map((e) => e as String).toList(),
      running: json['running'] as bool? ?? false,
      dataPath: json['data_path'] as String? ?? '',
    );

Map<String, dynamic> _$$_ScanStatusModelToJson(_$_ScanStatusModel instance) =>
    <String, dynamic>{
      'book_count': instance.bookCount,
      'errs': instance.errs,
      'running': instance.running,
      'data_path': instance.dataPath,
    };

_$_ServerModel _$$_ServerModelFromJson(Map<String, dynamic> json) =>
    _$_ServerModel(
      version: json['version'] as String? ?? "v1.0.0",
      system: json['system'] as String?,
      architecture: json['architecture'] as String?,
      scan_stats: json['scan_stats'] == null
          ? const ScanStatusModel()
          : ScanStatusModel.fromJson(
              json['scan_stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_ServerModelToJson(_$_ServerModel instance) =>
    <String, dynamic>{
      'version': instance.version,
      'system': instance.system,
      'architecture': instance.architecture,
      'scan_stats': instance.scan_stats,
    };
