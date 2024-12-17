// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TTSConfig {
  final bool enabled;
  final String endpoint;
  final String? accessToken;
  final String? voiceId;
  final int maxNewTokens;
  final double topP;
  final double temperature;
  final double repetitionRenalty;
  final TTSServiceEnum ttsType;

  TTSConfig({
    required this.enabled,
    required this.endpoint,
    required this.accessToken,
    this.voiceId = '',
    this.maxNewTokens = 1024,
    this.topP = 0.7,
    this.temperature = 0.7,
    this.repetitionRenalty = 1.2,
    this.ttsType = TTSServiceEnum.fishtts,
  });

  TTSConfig copyWith({
    bool? enabled,
    String? endpoint,
    String? accessToken,
    String? voiceId,
    int? maxNewTokens,
    double? topP,
    double? temperature,
    double? repetitionRenalty,
    TTSServiceEnum? ttsType,
  }) {
    return TTSConfig(
      enabled: enabled ?? this.enabled,
      endpoint: endpoint ?? this.endpoint,
      accessToken: accessToken ?? this.accessToken,
      voiceId: voiceId ?? this.voiceId,
      maxNewTokens: maxNewTokens ?? this.maxNewTokens,
      topP: topP ?? this.topP,
      temperature: temperature ?? this.temperature,
      repetitionRenalty: repetitionRenalty ?? this.repetitionRenalty,
      ttsType: ttsType ?? this.ttsType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enabled': enabled,
      'endpoint': endpoint,
      'accessToken': accessToken,
      'voiceId': voiceId,
      'maxNewTokens': maxNewTokens,
      'topP': topP,
      'temperature': temperature,
      'repetitionRenalty': repetitionRenalty,
      'ttsType': ttsType.name,
    };
  }

  factory TTSConfig.fromMap(Map<String, dynamic> map) {
    return TTSConfig(
      enabled: map['enabled'] as bool,
      endpoint: map['endpoint'] as String,
      accessToken: map['accessToken'] as String,
      voiceId: map['voiceId'] as String,
      maxNewTokens: map['maxNewTokens'] as int,
      topP: map['topP'] as double,
      temperature: map['temperature'] as double,
      repetitionRenalty: map['repetitionRenalty'] as double,
      ttsType: TTSServiceEnum.values.byName(map['ttsType'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory TTSConfig.fromJson(String source) => TTSConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TTSConfig(enabled: $enabled, endpoint: $endpoint, accessToken: $accessToken, voiceId: $voiceId, maxNewTokens: $maxNewTokens, topP: $topP, temperature: $temperature, repetitionRenalty: $repetitionRenalty, ttsType: $ttsType)';
  }

  @override
  bool operator ==(covariant TTSConfig other) {
    if (identical(this, other)) return true;

    return other.enabled == enabled &&
        other.endpoint == endpoint &&
        other.accessToken == accessToken &&
        other.voiceId == voiceId &&
        other.maxNewTokens == maxNewTokens &&
        other.topP == topP &&
        other.temperature == temperature &&
        other.repetitionRenalty == repetitionRenalty &&
        other.ttsType == ttsType;
  }

  @override
  int get hashCode {
    return enabled.hashCode ^
        endpoint.hashCode ^
        accessToken.hashCode ^
        voiceId.hashCode ^
        maxNewTokens.hashCode ^
        topP.hashCode ^
        temperature.hashCode ^
        repetitionRenalty.hashCode ^
        ttsType.hashCode;
  }
}

enum TTSServiceEnum {
  // do not change this order or reuse indices for other purposes, adding is OK
  fishtts,
  device,
  xttsv2;

  String get i18nName {
    return 'tts_service_$name';
  }
}
