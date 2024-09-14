// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateUserDto extends CreateUserDto {
  @override
  final String name;
  @override
  final String email;
  @override
  final String? mobile;
  @override
  final String password;

  factory _$CreateUserDto([void Function(CreateUserDtoBuilder)? updates]) =>
      (new CreateUserDtoBuilder()..update(updates))._build();

  _$CreateUserDto._(
      {required this.name,
      required this.email,
      this.mobile,
      required this.password})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, r'CreateUserDto', 'name');
    BuiltValueNullFieldError.checkNotNull(email, r'CreateUserDto', 'email');
    BuiltValueNullFieldError.checkNotNull(
        password, r'CreateUserDto', 'password');
  }

  @override
  CreateUserDto rebuild(void Function(CreateUserDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateUserDtoBuilder toBuilder() => new CreateUserDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateUserDto &&
        name == other.name &&
        email == other.email &&
        mobile == other.mobile &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, mobile.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateUserDto')
          ..add('name', name)
          ..add('email', email)
          ..add('mobile', mobile)
          ..add('password', password))
        .toString();
  }
}

class CreateUserDtoBuilder
    implements Builder<CreateUserDto, CreateUserDtoBuilder> {
  _$CreateUserDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _mobile;
  String? get mobile => _$this._mobile;
  set mobile(String? mobile) => _$this._mobile = mobile;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  CreateUserDtoBuilder() {
    CreateUserDto._defaults(this);
  }

  CreateUserDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _email = $v.email;
      _mobile = $v.mobile;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateUserDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$CreateUserDto;
  }

  @override
  void update(void Function(CreateUserDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateUserDto build() => _build();

  _$CreateUserDto _build() {
    final _$result = _$v ??
        new _$CreateUserDto._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'CreateUserDto', 'name'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'CreateUserDto', 'email'),
            mobile: mobile,
            password: BuiltValueNullFieldError.checkNotNull(
                password, r'CreateUserDto', 'password'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
