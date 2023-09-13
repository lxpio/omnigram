// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AppConfig _$$_AppConfigFromJson(Map<String, dynamic> json) => _$_AppConfig(
      bookBaseUrl: json['bookBaseUrl'] as String,
      bookToken: json['bookToken'] as String,
      appName: json['appName'] as String,
      shouldCollectCrashLog: json['shouldCollectCrashLog'] as bool,
      openAIUrl: json['openAIUrl'] as String?,
      openAIApiKey: json['openAIApiKey'] as String?,
    );

Map<String, dynamic> _$$_AppConfigToJson(_$_AppConfig instance) =>
    <String, dynamic>{
      'bookBaseUrl': instance.bookBaseUrl,
      'bookToken': instance.bookToken,
      'appName': instance.appName,
      'shouldCollectCrashLog': instance.shouldCollectCrashLog,
      'openAIUrl': instance.openAIUrl,
      'openAIApiKey': instance.openAIApiKey,
    };
