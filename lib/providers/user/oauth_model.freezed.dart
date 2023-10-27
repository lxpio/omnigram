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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

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
  int get expired_in => throw _privateConstructorUsedError;

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
      int expired_in});
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
    Object? expired_in = null,
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
      expired_in: null == expired_in
          ? _value.expired_in
          : expired_in // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_OauthModelCopyWith<$Res>
    implements $OauthModelCopyWith<$Res> {
  factory _$$_OauthModelCopyWith(
          _$_OauthModel value, $Res Function(_$_OauthModel) then) =
      __$$_OauthModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'token_type') String tokenType,
      @JsonKey(name: 'refresh_token') String refreshToken,
      @JsonKey(name: 'access_token') String accessToken,
      int expired_in});
}

/// @nodoc
class __$$_OauthModelCopyWithImpl<$Res>
    extends _$OauthModelCopyWithImpl<$Res, _$_OauthModel>
    implements _$$_OauthModelCopyWith<$Res> {
  __$$_OauthModelCopyWithImpl(
      _$_OauthModel _value, $Res Function(_$_OauthModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tokenType = null,
    Object? refreshToken = null,
    Object? accessToken = null,
    Object? expired_in = null,
  }) {
    return _then(_$_OauthModel(
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
      expired_in: null == expired_in
          ? _value.expired_in
          : expired_in // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_OauthModel implements _OauthModel {
  const _$_OauthModel(
      {@JsonKey(name: 'token_type') this.tokenType = '',
      @JsonKey(name: 'refresh_token') this.refreshToken = '',
      @JsonKey(name: 'access_token') this.accessToken = '',
      this.expired_in = 3600});

  factory _$_OauthModel.fromJson(Map<String, dynamic> json) =>
      _$$_OauthModelFromJson(json);

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
  @JsonKey()
  final int expired_in;

  @override
  String toString() {
    return 'OauthModel(tokenType: $tokenType, refreshToken: $refreshToken, accessToken: $accessToken, expired_in: $expired_in)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_OauthModel &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.expired_in, expired_in) ||
                other.expired_in == expired_in));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, tokenType, refreshToken, accessToken, expired_in);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_OauthModelCopyWith<_$_OauthModel> get copyWith =>
      __$$_OauthModelCopyWithImpl<_$_OauthModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_OauthModelToJson(
      this,
    );
  }
}

abstract class _OauthModel implements OauthModel {
  const factory _OauthModel(
      {@JsonKey(name: 'token_type') final String tokenType,
      @JsonKey(name: 'refresh_token') final String refreshToken,
      @JsonKey(name: 'access_token') final String accessToken,
      final int expired_in}) = _$_OauthModel;

  factory _OauthModel.fromJson(Map<String, dynamic> json) =
      _$_OauthModel.fromJson;

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
  int get expired_in;
  @override
  @JsonKey(ignore: true)
  _$$_OauthModelCopyWith<_$_OauthModel> get copyWith =>
      throw _privateConstructorUsedError;
}
