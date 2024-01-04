// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ScanStatusModel _$$_ScanStatusModelFromJson(Map<String, dynamic> json) =>
    _$_ScanStatusModel(
      total: json['total'] as int? ?? 0,
      running: json['running'] as bool? ?? false,
      scanCount: json['scan_count'] as int? ?? 0,
      diskUsage: json['disk_usage'] as int? ?? 0,
      epubCount: json['epub_count'] as int? ?? 0,
      pdfCount: json['pdf_count'] as int? ?? 0,
      errs: (json['errs'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$_ScanStatusModelToJson(_$_ScanStatusModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'running': instance.running,
      'scan_count': instance.scanCount,
      'disk_usage': instance.diskUsage,
      'epub_count': instance.epubCount,
      'pdf_count': instance.pdfCount,
      'errs': instance.errs,
    };
