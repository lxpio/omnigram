// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AppConfigModel _$$_AppConfigModelFromJson(Map<String, dynamic> json) =>
    _$_AppConfigModel(
      baseUrl: json['baseUrl'] as String,
      token: json['token'] as String,
      appName: json['appName'] as String,
      appVersion: json['appVersion'] as String,
      shouldCollectCrashLog: json['shouldCollectCrashLog'] as bool,
    );

Map<String, dynamic> _$$_AppConfigModelToJson(_$_AppConfigModel instance) =>
    <String, dynamic>{
      'baseUrl': instance.baseUrl,
      'token': instance.token,
      'appName': instance.appName,
      'appVersion': instance.appVersion,
      'shouldCollectCrashLog': instance.shouldCollectCrashLog,
    };
