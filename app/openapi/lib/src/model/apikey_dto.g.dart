// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apikey_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ApikeyDto extends ApikeyDto {
  @override
  final String name;
  @override
  final String apikey;
  @override
  final int ctime;

  factory _$ApikeyDto([void Function(ApikeyDtoBuilder)? updates]) =>
      (new ApikeyDtoBuilder()..update(updates))._build();

  _$ApikeyDto._({required this.name, required this.apikey, required this.ctime})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, r'ApikeyDto', 'name');
    BuiltValueNullFieldError.checkNotNull(apikey, r'ApikeyDto', 'apikey');
    BuiltValueNullFieldError.checkNotNull(ctime, r'ApikeyDto', 'ctime');
  }

  @override
  ApikeyDto rebuild(void Function(ApikeyDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ApikeyDtoBuilder toBuilder() => new ApikeyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ApikeyDto &&
        name == other.name &&
        apikey == other.apikey &&
        ctime == other.ctime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, apikey.hashCode);
    _$hash = $jc(_$hash, ctime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ApikeyDto')
          ..add('name', name)
          ..add('apikey', apikey)
          ..add('ctime', ctime))
        .toString();
  }
}

class ApikeyDtoBuilder implements Builder<ApikeyDto, ApikeyDtoBuilder> {
  _$ApikeyDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _apikey;
  String? get apikey => _$this._apikey;
  set apikey(String? apikey) => _$this._apikey = apikey;

  int? _ctime;
  int? get ctime => _$this._ctime;
  set ctime(int? ctime) => _$this._ctime = ctime;

  ApikeyDtoBuilder() {
    ApikeyDto._defaults(this);
  }

  ApikeyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _apikey = $v.apikey;
      _ctime = $v.ctime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ApikeyDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ApikeyDto;
  }

  @override
  void update(void Function(ApikeyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ApikeyDto build() => _build();

  _$ApikeyDto _build() {
    final _$result = _$v ??
        new _$ApikeyDto._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ApikeyDto', 'name'),
            apikey: BuiltValueNullFieldError.checkNotNull(
                apikey, r'ApikeyDto', 'apikey'),
            ctime: BuiltValueNullFieldError.checkNotNull(
                ctime, r'ApikeyDto', 'ctime'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
