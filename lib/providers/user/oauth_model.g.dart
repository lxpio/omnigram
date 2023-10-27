// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_OauthModel _$$_OauthModelFromJson(Map<String, dynamic> json) =>
    _$_OauthModel(
      tokenType: json['token_type'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      accessToken: json['access_token'] as String? ?? '',
      expired_in: json['expired_in'] as int? ?? 3600,
    );

Map<String, dynamic> _$$_OauthModelToJson(_$_OauthModel instance) =>
    <String, dynamic>{
      'token_type': instance.tokenType,
      'refresh_token': instance.refreshToken,
      'access_token': instance.accessToken,
      'expired_in': instance.expired_in,
    };
