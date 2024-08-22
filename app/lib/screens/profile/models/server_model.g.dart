// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScanStatusModelImpl _$$ScanStatusModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ScanStatusModelImpl(
      total: (json['total'] as num?)?.toInt() ?? 0,
      running: json['running'] as bool? ?? false,
      scanCount: (json['scan_count'] as num?)?.toInt() ?? 0,
      diskUsage: (json['disk_usage'] as num?)?.toInt() ?? 0,
      epubCount: (json['epub_count'] as num?)?.toInt() ?? 0,
      pdfCount: (json['pdf_count'] as num?)?.toInt() ?? 0,
      errs: (json['errs'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$ScanStatusModelImplToJson(
        _$ScanStatusModelImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'running': instance.running,
      'scan_count': instance.scanCount,
      'disk_usage': instance.diskUsage,
      'epub_count': instance.epubCount,
      'pdf_count': instance.pdfCount,
      'errs': instance.errs,
    };
