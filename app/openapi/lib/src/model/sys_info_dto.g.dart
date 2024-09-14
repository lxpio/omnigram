// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sys_info_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SysInfoDto extends SysInfoDto {
  @override
  final String version;
  @override
  final String system;
  @override
  final String architecture;
  @override
  final String docsDataPath;
  @override
  final String? diskUsage;
  @override
  final bool m4tSupport;

  factory _$SysInfoDto([void Function(SysInfoDtoBuilder)? updates]) =>
      (new SysInfoDtoBuilder()..update(updates))._build();

  _$SysInfoDto._(
      {required this.version,
      required this.system,
      required this.architecture,
      required this.docsDataPath,
      this.diskUsage,
      required this.m4tSupport})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(version, r'SysInfoDto', 'version');
    BuiltValueNullFieldError.checkNotNull(system, r'SysInfoDto', 'system');
    BuiltValueNullFieldError.checkNotNull(
        architecture, r'SysInfoDto', 'architecture');
    BuiltValueNullFieldError.checkNotNull(
        docsDataPath, r'SysInfoDto', 'docsDataPath');
    BuiltValueNullFieldError.checkNotNull(
        m4tSupport, r'SysInfoDto', 'm4tSupport');
  }

  @override
  SysInfoDto rebuild(void Function(SysInfoDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SysInfoDtoBuilder toBuilder() => new SysInfoDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SysInfoDto &&
        version == other.version &&
        system == other.system &&
        architecture == other.architecture &&
        docsDataPath == other.docsDataPath &&
        diskUsage == other.diskUsage &&
        m4tSupport == other.m4tSupport;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, system.hashCode);
    _$hash = $jc(_$hash, architecture.hashCode);
    _$hash = $jc(_$hash, docsDataPath.hashCode);
    _$hash = $jc(_$hash, diskUsage.hashCode);
    _$hash = $jc(_$hash, m4tSupport.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SysInfoDto')
          ..add('version', version)
          ..add('system', system)
          ..add('architecture', architecture)
          ..add('docsDataPath', docsDataPath)
          ..add('diskUsage', diskUsage)
          ..add('m4tSupport', m4tSupport))
        .toString();
  }
}

class SysInfoDtoBuilder implements Builder<SysInfoDto, SysInfoDtoBuilder> {
  _$SysInfoDto? _$v;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  String? _system;
  String? get system => _$this._system;
  set system(String? system) => _$this._system = system;

  String? _architecture;
  String? get architecture => _$this._architecture;
  set architecture(String? architecture) => _$this._architecture = architecture;

  String? _docsDataPath;
  String? get docsDataPath => _$this._docsDataPath;
  set docsDataPath(String? docsDataPath) => _$this._docsDataPath = docsDataPath;

  String? _diskUsage;
  String? get diskUsage => _$this._diskUsage;
  set diskUsage(String? diskUsage) => _$this._diskUsage = diskUsage;

  bool? _m4tSupport;
  bool? get m4tSupport => _$this._m4tSupport;
  set m4tSupport(bool? m4tSupport) => _$this._m4tSupport = m4tSupport;

  SysInfoDtoBuilder() {
    SysInfoDto._defaults(this);
  }

  SysInfoDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _system = $v.system;
      _architecture = $v.architecture;
      _docsDataPath = $v.docsDataPath;
      _diskUsage = $v.diskUsage;
      _m4tSupport = $v.m4tSupport;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SysInfoDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SysInfoDto;
  }

  @override
  void update(void Function(SysInfoDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SysInfoDto build() => _build();

  _$SysInfoDto _build() {
    final _$result = _$v ??
        new _$SysInfoDto._(
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'SysInfoDto', 'version'),
            system: BuiltValueNullFieldError.checkNotNull(
                system, r'SysInfoDto', 'system'),
            architecture: BuiltValueNullFieldError.checkNotNull(
                architecture, r'SysInfoDto', 'architecture'),
            docsDataPath: BuiltValueNullFieldError.checkNotNull(
                docsDataPath, r'SysInfoDto', 'docsDataPath'),
            diskUsage: diskUsage,
            m4tSupport: BuiltValueNullFieldError.checkNotNull(
                m4tSupport, r'SysInfoDto', 'm4tSupport'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
