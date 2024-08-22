// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'oauth_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OauthModel _$OauthModelFromJson(Map<String, dynamic> json) {
  return _OauthModel.fromJson(json);
}

/// @nodoc
mixin _$OauthModel {
  @JsonKey(name: 'token_type')
  String get tokenType => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh_token')
  String get refreshToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'expired_in')
  int get expiredIn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OauthModelCopyWith<OauthModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OauthModelCopyWith<$Res> {
  factory $OauthModelCopyWith(
          OauthModel value, $Res Function(OauthModel) then) =
      _$OauthModelCopyWithImpl<$Res, OauthModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'refresh_token') String refreshToken,
      @JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'expired_in') int expiredIn});
}

/// @nodoc
class _$OauthModelCopyWithImpl<$Res, $Val extends OauthModel>
    implements $OauthModelCopyWith<$Res> {
  _$OauthModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tokenType = null,
    Object? refreshToken = null,
    Object? accessToken = null,
    Object? expiredIn = null,
  }) {
    return _then(_value.copyWith(
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiredIn: null == expiredIn
          ? _value.expiredIn
          : expiredIn // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OauthModelImplCopyWith<$Res>
    implements $OauthModelCopyWith<$Res> {
  factory _$$OauthModelImplCopyWith(
          _$OauthModelImpl value, $Res Function(_$OauthModelImpl) then) =
      __$$OauthModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'refresh_token') String refreshToken,
      @JsonKey(name: 'access_token') String accessToken,
      @JsonKey(name: 'expired_in') int expiredIn});
}

/// @nodoc
class __$$OauthModelImplCopyWithImpl<$Res>
    extends _$OauthModelCopyWithImpl<$Res, _$OauthModelImpl>
    implements _$$OauthModelImplCopyWith<$Res> {
  __$$OauthModelImplCopyWithImpl(
      _$OauthModelImpl _value, $Res Function(_$OauthModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tokenType = null,
    Object? refreshToken = null,
    Object? accessToken = null,
    Object? expiredIn = null,
  }) {
    return _then(_$OauthModelImpl(
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiredIn: null == expiredIn
          ? _value.expiredIn
          : expiredIn // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OauthModelImpl implements _OauthModel {
  const _$OauthModelImpl(
      {@JsonKey(name: 'token_type') this.tokenType = '',
      @JsonKey(name: 'refresh_token') this.refreshToken = '',
      @JsonKey(name: 'access_token') this.accessToken = '',
      @JsonKey(name: 'expired_in') this.expiredIn = 3600});

  factory _$OauthModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OauthModelImplFromJson(json);

  @override
  @JsonKey(name: 'token_type')
  final String tokenType;
  @override
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @override
  @JsonKey(name: 'access_token')
  final String accessToken;
  @override
  @JsonKey(name: 'expired_in')
  final int expiredIn;

  @override
  String toString() {
    return 'OauthModel(tokenType: $tokenType, refreshToken: $refreshToken, accessToken: $accessToken, expiredIn: $expiredIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OauthModelImpl &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.expiredIn, expiredIn) ||
                other.expiredIn == expiredIn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, tokenType, refreshToken, accessToken, expiredIn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OauthModelImplCopyWith<_$OauthModelImpl> get copyWith =>
      __$$OauthModelImplCopyWithImpl<_$OauthModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OauthModelImplToJson(
      this,
    );
  }
}

abstract class _OauthModel implements OauthModel {
  const factory _OauthModel(
      {@JsonKey(name: 'token_type') final String tokenType,
      @JsonKey(name: 'refresh_token') final String refreshToken,
      @JsonKey(name: 'access_token') final String accessToken,
      @JsonKey(name: 'expired_in') final int expiredIn}) = _$OauthModelImpl;

  factory _OauthModel.fromJson(Map<String, dynamic> json) =
      _$OauthModelImpl.fromJson;

  @override
  @JsonKey(name: 'token_type')
  String get tokenType;
  @override
  @JsonKey(name: 'refresh_token')
  String get refreshToken;
  @override
  @JsonKey(name: 'access_token')
  String get accessToken;
  @override
  @JsonKey(name: 'expired_in')
  int get expiredIn;
  @override
  @JsonKey(ignore: true)
  _$$OauthModelImplCopyWith<_$OauthModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
