// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'full_sync_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FullSyncDto extends FullSyncDto {
  @override
  final int? userId;
  @override
  final int limit;
  @override
  final int utime;
  @override
  final int? fileType;

  factory _$FullSyncDto([void Function(FullSyncDtoBuilder)? updates]) =>
      (new FullSyncDtoBuilder()..update(updates))._build();

  _$FullSyncDto._(
      {this.userId, required this.limit, required this.utime, this.fileType})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(limit, r'FullSyncDto', 'limit');
    BuiltValueNullFieldError.checkNotNull(utime, r'FullSyncDto', 'utime');
  }

  @override
  FullSyncDto rebuild(void Function(FullSyncDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FullSyncDtoBuilder toBuilder() => new FullSyncDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FullSyncDto &&
        userId == other.userId &&
        limit == other.limit &&
        utime == other.utime &&
        fileType == other.fileType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, utime.hashCode);
    _$hash = $jc(_$hash, fileType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FullSyncDto')
          ..add('userId', userId)
          ..add('limit', limit)
          ..add('utime', utime)
          ..add('fileType', fileType))
        .toString();
  }
}

class FullSyncDtoBuilder implements Builder<FullSyncDto, FullSyncDtoBuilder> {
  _$FullSyncDto? _$v;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  int? _utime;
  int? get utime => _$this._utime;
  set utime(int? utime) => _$this._utime = utime;

  int? _fileType;
  int? get fileType => _$this._fileType;
  set fileType(int? fileType) => _$this._fileType = fileType;

  FullSyncDtoBuilder() {
    FullSyncDto._defaults(this);
  }

  FullSyncDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _limit = $v.limit;
      _utime = $v.utime;
      _fileType = $v.fileType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FullSyncDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$FullSyncDto;
  }

  @override
  void update(void Function(FullSyncDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FullSyncDto build() => _build();

  _$FullSyncDto _build() {
    final _$result = _$v ??
        new _$FullSyncDto._(
            userId: userId,
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'FullSyncDto', 'limit'),
            utime: BuiltValueNullFieldError.checkNotNull(
                utime, r'FullSyncDto', 'utime'),
            fileType: fileType);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
