// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:omnigram/services/app_settings.service.dart';

part 'app_settings.provider.g.dart';

class APPConfigs {
  final String themeMode;
  // final bool followSystemSetting;
  final int logLevel;
  final String language;
  APPConfigs({
    required this.themeMode,
    required this.logLevel,
    required this.language,
  });

  APPConfigs copyWith({
    String? themeMode,
    int? logLevel,
    String? language,
  }) {
    return APPConfigs(
      themeMode: themeMode ?? this.themeMode,
      logLevel: logLevel ?? this.logLevel,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'themeMode': themeMode,
      'logLevel': logLevel,
      'language': language,
    };
  }

  factory APPConfigs.fromMap(Map<String, dynamic> map) {
    return APPConfigs(
      themeMode: map['themeMode'] as String,
      logLevel: map['logLevel'] as int,
      language: map['language'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory APPConfigs.fromJson(String source) => APPConfigs.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'APPConfigs(themeMode: $themeMode, logLevel: $logLevel, language: $language)';

  @override
  bool operator ==(covariant APPConfigs other) {
    if (identical(this, other)) return true;

    return other.themeMode == themeMode && other.logLevel == logLevel && other.language == language;
  }

  @override
  int get hashCode => themeMode.hashCode ^ logLevel.hashCode ^ language.hashCode;
}

@Riverpod(keepAlive: true)
AppSettingsService appSettingsService(AppSettingsServiceRef ref) => AppSettingsService();
