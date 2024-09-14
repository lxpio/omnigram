// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_token_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AccessTokenDto extends AccessTokenDto {
  @override
  final String tokenType;
  @override
  final int expiredIn;
  @override
  final String refreshToken;
  @override
  final String accessToken;

  factory _$AccessTokenDto([void Function(AccessTokenDtoBuilder)? updates]) =>
      (new AccessTokenDtoBuilder()..update(updates))._build();

  _$AccessTokenDto._(
      {required this.tokenType,
      required this.expiredIn,
      required this.refreshToken,
      required this.accessToken})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        tokenType, r'AccessTokenDto', 'tokenType');
    BuiltValueNullFieldError.checkNotNull(
        expiredIn, r'AccessTokenDto', 'expiredIn');
    BuiltValueNullFieldError.checkNotNull(
        refreshToken, r'AccessTokenDto', 'refreshToken');
    BuiltValueNullFieldError.checkNotNull(
        accessToken, r'AccessTokenDto', 'accessToken');
  }

  @override
  AccessTokenDto rebuild(void Function(AccessTokenDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AccessTokenDtoBuilder toBuilder() =>
      new AccessTokenDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AccessTokenDto &&
        tokenType == other.tokenType &&
        expiredIn == other.expiredIn &&
        refreshToken == other.refreshToken &&
        accessToken == other.accessToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tokenType.hashCode);
    _$hash = $jc(_$hash, expiredIn.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AccessTokenDto')
          ..add('tokenType', tokenType)
          ..add('expiredIn', expiredIn)
          ..add('refreshToken', refreshToken)
          ..add('accessToken', accessToken))
        .toString();
  }
}

class AccessTokenDtoBuilder
    implements Builder<AccessTokenDto, AccessTokenDtoBuilder> {
  _$AccessTokenDto? _$v;

  String? _tokenType;
  String? get tokenType => _$this._tokenType;
  set tokenType(String? tokenType) => _$this._tokenType = tokenType;

  int? _expiredIn;
  int? get expiredIn => _$this._expiredIn;
  set expiredIn(int? expiredIn) => _$this._expiredIn = expiredIn;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  AccessTokenDtoBuilder() {
    AccessTokenDto._defaults(this);
  }

  AccessTokenDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tokenType = $v.tokenType;
      _expiredIn = $v.expiredIn;
      _refreshToken = $v.refreshToken;
      _accessToken = $v.accessToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AccessTokenDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AccessTokenDto;
  }

  @override
  void update(void Function(AccessTokenDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AccessTokenDto build() => _build();

  _$AccessTokenDto _build() {
    final _$result = _$v ??
        new _$AccessTokenDto._(
            tokenType: BuiltValueNullFieldError.checkNotNull(
                tokenType, r'AccessTokenDto', 'tokenType'),
            expiredIn: BuiltValueNullFieldError.checkNotNull(
                expiredIn, r'AccessTokenDto', 'expiredIn'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'AccessTokenDto', 'refreshToken'),
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'AccessTokenDto', 'accessToken'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
