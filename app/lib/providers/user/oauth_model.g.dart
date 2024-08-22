// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OauthModelImpl _$$OauthModelImplFromJson(Map<String, dynamic> json) =>
    _$OauthModelImpl(
      tokenType: json['token_type'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      accessToken: json['access_token'] as String? ?? '',
      expiredIn: (json['expired_in'] as num?)?.toInt() ?? 3600,
    );

Map<String, dynamic> _$$OauthModelImplToJson(_$OauthModelImpl instance) =>
    <String, dynamic>{
      'token_type': instance.tokenType,
      'refresh_token': instance.refreshToken,
      'access_token': instance.accessToken,
      'expired_in': instance.expiredIn,
    };
