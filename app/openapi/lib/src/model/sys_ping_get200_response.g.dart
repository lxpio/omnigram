// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sys_ping_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SysPingGet200Response extends SysPingGet200Response {
  @override
  final String version;

  factory _$SysPingGet200Response(
          [void Function(SysPingGet200ResponseBuilder)? updates]) =>
      (new SysPingGet200ResponseBuilder()..update(updates))._build();

  _$SysPingGet200Response._({required this.version}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        version, r'SysPingGet200Response', 'version');
  }

  @override
  SysPingGet200Response rebuild(
          void Function(SysPingGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SysPingGet200ResponseBuilder toBuilder() =>
      new SysPingGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SysPingGet200Response && version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SysPingGet200Response')
          ..add('version', version))
        .toString();
  }
}

class SysPingGet200ResponseBuilder
    implements Builder<SysPingGet200Response, SysPingGet200ResponseBuilder> {
  _$SysPingGet200Response? _$v;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  SysPingGet200ResponseBuilder() {
    SysPingGet200Response._defaults(this);
  }

  SysPingGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SysPingGet200Response other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SysPingGet200Response;
  }

  @override
  void update(void Function(SysPingGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SysPingGet200Response build() => _build();

  _$SysPingGet200Response _build() {
    final _$result = _$v ??
        new _$SysPingGet200Response._(
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'SysPingGet200Response', 'version'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
