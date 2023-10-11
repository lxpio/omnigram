// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppConfigImpl _$$AppConfigImplFromJson(Map<String, dynamic> json) =>
    _$AppConfigImpl(
      bookBaseUrl: json['bookBaseUrl'] as String,
      bookToken: json['bookToken'] as String,
      appName: json['appName'] as String,
      shouldCollectCrashLog: json['shouldCollectCrashLog'] as bool,
      openAIUrl: json['openAIUrl'] as String?,
      openAIApiKey: json['openAIApiKey'] as String?,
    );

Map<String, dynamic> _$$AppConfigImplToJson(_$AppConfigImpl instance) =>
    <String, dynamic>{
      'bookBaseUrl': instance.bookBaseUrl,
      'bookToken': instance.bookToken,
      'appName': instance.appName,
      'shouldCollectCrashLog': instance.shouldCollectCrashLog,
      'openAIUrl': instance.openAIUrl,
      'openAIApiKey': instance.openAIApiKey,
    };
