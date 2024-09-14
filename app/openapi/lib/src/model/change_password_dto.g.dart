// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChangePasswordDto extends ChangePasswordDto {
  @override
  final String newPassword;
  @override
  final String code;

  factory _$ChangePasswordDto(
          [void Function(ChangePasswordDtoBuilder)? updates]) =>
      (new ChangePasswordDtoBuilder()..update(updates))._build();

  _$ChangePasswordDto._({required this.newPassword, required this.code})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        newPassword, r'ChangePasswordDto', 'newPassword');
    BuiltValueNullFieldError.checkNotNull(code, r'ChangePasswordDto', 'code');
  }

  @override
  ChangePasswordDto rebuild(void Function(ChangePasswordDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChangePasswordDtoBuilder toBuilder() =>
      new ChangePasswordDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChangePasswordDto &&
        newPassword == other.newPassword &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, newPassword.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChangePasswordDto')
          ..add('newPassword', newPassword)
          ..add('code', code))
        .toString();
  }
}

class ChangePasswordDtoBuilder
    implements Builder<ChangePasswordDto, ChangePasswordDtoBuilder> {
  _$ChangePasswordDto? _$v;

  String? _newPassword;
  String? get newPassword => _$this._newPassword;
  set newPassword(String? newPassword) => _$this._newPassword = newPassword;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  ChangePasswordDtoBuilder() {
    ChangePasswordDto._defaults(this);
  }

  ChangePasswordDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _newPassword = $v.newPassword;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChangePasswordDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ChangePasswordDto;
  }

  @override
  void update(void Function(ChangePasswordDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChangePasswordDto build() => _build();

  _$ChangePasswordDto _build() {
    final _$result = _$v ??
        new _$ChangePasswordDto._(
            newPassword: BuiltValueNullFieldError.checkNotNull(
                newPassword, r'ChangePasswordDto', 'newPassword'),
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'ChangePasswordDto', 'code'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
