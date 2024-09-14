// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resp_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RespDto extends RespDto {
  @override
  final int code;
  @override
  final String message;

  factory _$RespDto([void Function(RespDtoBuilder)? updates]) =>
      (new RespDtoBuilder()..update(updates))._build();

  _$RespDto._({required this.code, required this.message}) : super._() {
    BuiltValueNullFieldError.checkNotNull(code, r'RespDto', 'code');
    BuiltValueNullFieldError.checkNotNull(message, r'RespDto', 'message');
  }

  @override
  RespDto rebuild(void Function(RespDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RespDtoBuilder toBuilder() => new RespDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RespDto && code == other.code && message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RespDto')
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class RespDtoBuilder implements Builder<RespDto, RespDtoBuilder> {
  _$RespDto? _$v;

  int? _code;
  int? get code => _$this._code;
  set code(int? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  RespDtoBuilder() {
    RespDto._defaults(this);
  }

  RespDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RespDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$RespDto;
  }

  @override
  void update(void Function(RespDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RespDto build() => _build();

  _$RespDto _build() {
    final _$result = _$v ??
        new _$RespDto._(
            code:
                BuiltValueNullFieldError.checkNotNull(code, r'RespDto', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'RespDto', 'message'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
