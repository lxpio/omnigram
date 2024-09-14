// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enable_scan_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EnableScanDto extends EnableScanDto {
  @override
  final bool refresh;
  @override
  final num maxThread;

  factory _$EnableScanDto([void Function(EnableScanDtoBuilder)? updates]) =>
      (new EnableScanDtoBuilder()..update(updates))._build();

  _$EnableScanDto._({required this.refresh, required this.maxThread})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(refresh, r'EnableScanDto', 'refresh');
    BuiltValueNullFieldError.checkNotNull(
        maxThread, r'EnableScanDto', 'maxThread');
  }

  @override
  EnableScanDto rebuild(void Function(EnableScanDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EnableScanDtoBuilder toBuilder() => new EnableScanDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EnableScanDto &&
        refresh == other.refresh &&
        maxThread == other.maxThread;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, refresh.hashCode);
    _$hash = $jc(_$hash, maxThread.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EnableScanDto')
          ..add('refresh', refresh)
          ..add('maxThread', maxThread))
        .toString();
  }
}

class EnableScanDtoBuilder
    implements Builder<EnableScanDto, EnableScanDtoBuilder> {
  _$EnableScanDto? _$v;

  bool? _refresh;
  bool? get refresh => _$this._refresh;
  set refresh(bool? refresh) => _$this._refresh = refresh;

  num? _maxThread;
  num? get maxThread => _$this._maxThread;
  set maxThread(num? maxThread) => _$this._maxThread = maxThread;

  EnableScanDtoBuilder() {
    EnableScanDto._defaults(this);
  }

  EnableScanDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refresh = $v.refresh;
      _maxThread = $v.maxThread;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EnableScanDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$EnableScanDto;
  }

  @override
  void update(void Function(EnableScanDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EnableScanDto build() => _build();

  _$EnableScanDto _build() {
    final _$result = _$v ??
        new _$EnableScanDto._(
            refresh: BuiltValueNullFieldError.checkNotNull(
                refresh, r'EnableScanDto', 'refresh'),
            maxThread: BuiltValueNullFieldError.checkNotNull(
                maxThread, r'EnableScanDto', 'maxThread'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
