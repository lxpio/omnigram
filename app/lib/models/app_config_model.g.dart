// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppConfigModelImpl _$$AppConfigModelImplFromJson(Map<String, dynamic> json) =>
    _$AppConfigModelImpl(
      baseUrl: json['baseUrl'] as String,
      token: json['token'] as String,
      appName: json['appName'] as String,
      appVersion: json['appVersion'] as String,
      shouldCollectCrashLog: json['shouldCollectCrashLog'] as bool,
    );

Map<String, dynamic> _$$AppConfigModelImplToJson(
        _$AppConfigModelImpl instance) =>
    <String, dynamic>{
      'baseUrl': instance.baseUrl,
      'token': instance.token,
      'appName': instance.appName,
      'appVersion': instance.appVersion,
      'shouldCollectCrashLog': instance.shouldCollectCrashLog,
    };
