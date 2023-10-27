// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AppConfig _$$_AppConfigFromJson(Map<String, dynamic> json) => _$_AppConfig(
      baseUrl: json['baseUrl'] as String,
      token: json['token'] as String,
      appName: json['appName'] as String,
      chatEnabled: json['chatEnabled'] as bool,
      m4tEnabled: json['m4tEnabled'] as bool,
      shouldCollectCrashLog: json['shouldCollectCrashLog'] as bool,
      openAIUrl: json['openAIUrl'] as String?,
      openAIApiKey: json['openAIApiKey'] as String?,
    );

Map<String, dynamic> _$$_AppConfigToJson(_$_AppConfig instance) =>
    <String, dynamic>{
      'baseUrl': instance.baseUrl,
      'token': instance.token,
      'appName': instance.appName,
      'chatEnabled': instance.chatEnabled,
      'm4tEnabled': instance.m4tEnabled,
      'shouldCollectCrashLog': instance.shouldCollectCrashLog,
      'openAIUrl': instance.openAIUrl,
      'openAIApiKey': instance.openAIApiKey,
    };
