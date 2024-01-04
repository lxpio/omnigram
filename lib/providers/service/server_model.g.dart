// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ServerModel _$$_ServerModelFromJson(Map<String, dynamic> json) =>
    _$_ServerModel(
      version: json['version'] as String? ?? "v1.0.0",
      chatEnabled: json['chatEnabled'] as bool? ?? true,
      m4tEnabled: json['m4tEnabled'] as bool? ?? true,
      system: json['system'] as String?,
      architecture: json['architecture'] as String?,
      docsDataPath: json['docs_data_path'] as String? ?? '/docs',
      m4tServerAddr: json['m4t_server_addr'] as String?,
      openAIUrl: json['openai_url'] as String?,
      openAIApiKey: json['openai_apikey'] as String?,
    );

Map<String, dynamic> _$$_ServerModelToJson(_$_ServerModel instance) =>
    <String, dynamic>{
      'version': instance.version,
      'chatEnabled': instance.chatEnabled,
      'm4tEnabled': instance.m4tEnabled,
      'system': instance.system,
      'architecture': instance.architecture,
      'docs_data_path': instance.docsDataPath,
      'm4t_server_addr': instance.m4tServerAddr,
      'openai_url': instance.openAIUrl,
      'openai_apikey': instance.openAIApiKey,
    };
