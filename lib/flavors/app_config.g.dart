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

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appConfigHash() => r'932a135bedaa35b767c8a28ec32a585843187865';

/// See also [appConfig].
@ProviderFor(appConfig)
final appConfigProvider = AutoDisposeProvider<AppConfig>.internal(
  appConfig,
  name: r'appConfigProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppConfigRef = AutoDisposeProviderRef<AppConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member
