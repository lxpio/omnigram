// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_credential_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LoginCredentialDto extends LoginCredentialDto {
  @override
  final String account;
  @override
  final String password;
  @override
  final String? deviceId;

  factory _$LoginCredentialDto(
          [void Function(LoginCredentialDtoBuilder)? updates]) =>
      (new LoginCredentialDtoBuilder()..update(updates))._build();

  _$LoginCredentialDto._(
      {required this.account, required this.password, this.deviceId})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        account, r'LoginCredentialDto', 'account');
    BuiltValueNullFieldError.checkNotNull(
        password, r'LoginCredentialDto', 'password');
  }

  @override
  LoginCredentialDto rebuild(
          void Function(LoginCredentialDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoginCredentialDtoBuilder toBuilder() =>
      new LoginCredentialDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoginCredentialDto &&
        account == other.account &&
        password == other.password &&
        deviceId == other.deviceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, account.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LoginCredentialDto')
          ..add('account', account)
          ..add('password', password)
          ..add('deviceId', deviceId))
        .toString();
  }
}

class LoginCredentialDtoBuilder
    implements Builder<LoginCredentialDto, LoginCredentialDtoBuilder> {
  _$LoginCredentialDto? _$v;

  String? _account;
  String? get account => _$this._account;
  set account(String? account) => _$this._account = account;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  LoginCredentialDtoBuilder() {
    LoginCredentialDto._defaults(this);
  }

  LoginCredentialDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _account = $v.account;
      _password = $v.password;
      _deviceId = $v.deviceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LoginCredentialDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$LoginCredentialDto;
  }

  @override
  void update(void Function(LoginCredentialDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LoginCredentialDto build() => _build();

  _$LoginCredentialDto _build() {
    final _$result = _$v ??
        new _$LoginCredentialDto._(
            account: BuiltValueNullFieldError.checkNotNull(
                account, r'LoginCredentialDto', 'account'),
            password: BuiltValueNullFieldError.checkNotNull(
                password, r'LoginCredentialDto', 'password'),
            deviceId: deviceId);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
