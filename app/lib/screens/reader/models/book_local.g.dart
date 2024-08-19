// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_local.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookLocalImpl _$$BookLocalImplFromJson(Map<String, dynamic> json) =>
    _$BookLocalImpl(
      id: json['id'] as int,
      localPath: json['local_path'] as String,
      md5: json['md5'] as String?,
    );

Map<String, dynamic> _$$BookLocalImplToJson(_$BookLocalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'local_path': instance.localPath,
      'md5': instance.md5,
    };
