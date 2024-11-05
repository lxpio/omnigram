// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_token_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefreshTokenDto extends RefreshTokenDto {
  @override
  final String account;
  @override
  final String? deviceId;
  @override
  final String refreshToken;

  factory _$RefreshTokenDto([void Function(RefreshTokenDtoBuilder)? updates]) =>
      (new RefreshTokenDtoBuilder()..update(updates))._build();

  _$RefreshTokenDto._(
      {required this.account, this.deviceId, required this.refreshToken})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        account, r'RefreshTokenDto', 'account');
    BuiltValueNullFieldError.checkNotNull(
        refreshToken, r'RefreshTokenDto', 'refreshToken');
  }

  @override
  RefreshTokenDto rebuild(void Function(RefreshTokenDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefreshTokenDtoBuilder toBuilder() =>
      new RefreshTokenDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefreshTokenDto &&
        account == other.account &&
        deviceId == other.deviceId &&
        refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, account.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RefreshTokenDto')
          ..add('account', account)
          ..add('deviceId', deviceId)
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class RefreshTokenDtoBuilder
    implements Builder<RefreshTokenDto, RefreshTokenDtoBuilder> {
  _$RefreshTokenDto? _$v;

  String? _account;
  String? get account => _$this._account;
  set account(String? account) => _$this._account = account;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  RefreshTokenDtoBuilder() {
    RefreshTokenDto._defaults(this);
  }

  RefreshTokenDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _account = $v.account;
      _deviceId = $v.deviceId;
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefreshTokenDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$RefreshTokenDto;
  }

  @override
  void update(void Function(RefreshTokenDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefreshTokenDto build() => _build();

  _$RefreshTokenDto _build() {
    final _$result = _$v ??
        new _$RefreshTokenDto._(
            account: BuiltValueNullFieldError.checkNotNull(
                account, r'RefreshTokenDto', 'account'),
            deviceId: deviceId,
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'RefreshTokenDto', 'refreshToken'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
