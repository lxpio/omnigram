// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_stats_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScanStatsDto extends ScanStatsDto {
  @override
  final int total;
  @override
  final bool running;
  @override
  final int scanCount;
  @override
  final BuiltList<String>? errs;
  @override
  final int diskUsage;
  @override
  final int epubCount;
  @override
  final int pdfCount;

  factory _$ScanStatsDto([void Function(ScanStatsDtoBuilder)? updates]) =>
      (new ScanStatsDtoBuilder()..update(updates))._build();

  _$ScanStatsDto._(
      {required this.total,
      required this.running,
      required this.scanCount,
      this.errs,
      required this.diskUsage,
      required this.epubCount,
      required this.pdfCount})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(total, r'ScanStatsDto', 'total');
    BuiltValueNullFieldError.checkNotNull(running, r'ScanStatsDto', 'running');
    BuiltValueNullFieldError.checkNotNull(
        scanCount, r'ScanStatsDto', 'scanCount');
    BuiltValueNullFieldError.checkNotNull(
        diskUsage, r'ScanStatsDto', 'diskUsage');
    BuiltValueNullFieldError.checkNotNull(
        epubCount, r'ScanStatsDto', 'epubCount');
    BuiltValueNullFieldError.checkNotNull(
        pdfCount, r'ScanStatsDto', 'pdfCount');
  }

  @override
  ScanStatsDto rebuild(void Function(ScanStatsDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScanStatsDtoBuilder toBuilder() => new ScanStatsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScanStatsDto &&
        total == other.total &&
        running == other.running &&
        scanCount == other.scanCount &&
        errs == other.errs &&
        diskUsage == other.diskUsage &&
        epubCount == other.epubCount &&
        pdfCount == other.pdfCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, running.hashCode);
    _$hash = $jc(_$hash, scanCount.hashCode);
    _$hash = $jc(_$hash, errs.hashCode);
    _$hash = $jc(_$hash, diskUsage.hashCode);
    _$hash = $jc(_$hash, epubCount.hashCode);
    _$hash = $jc(_$hash, pdfCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ScanStatsDto')
          ..add('total', total)
          ..add('running', running)
          ..add('scanCount', scanCount)
          ..add('errs', errs)
          ..add('diskUsage', diskUsage)
          ..add('epubCount', epubCount)
          ..add('pdfCount', pdfCount))
        .toString();
  }
}

class ScanStatsDtoBuilder
    implements Builder<ScanStatsDto, ScanStatsDtoBuilder> {
  _$ScanStatsDto? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  bool? _running;
  bool? get running => _$this._running;
  set running(bool? running) => _$this._running = running;

  int? _scanCount;
  int? get scanCount => _$this._scanCount;
  set scanCount(int? scanCount) => _$this._scanCount = scanCount;

  ListBuilder<String>? _errs;
  ListBuilder<String> get errs => _$this._errs ??= new ListBuilder<String>();
  set errs(ListBuilder<String>? errs) => _$this._errs = errs;

  int? _diskUsage;
  int? get diskUsage => _$this._diskUsage;
  set diskUsage(int? diskUsage) => _$this._diskUsage = diskUsage;

  int? _epubCount;
  int? get epubCount => _$this._epubCount;
  set epubCount(int? epubCount) => _$this._epubCount = epubCount;

  int? _pdfCount;
  int? get pdfCount => _$this._pdfCount;
  set pdfCount(int? pdfCount) => _$this._pdfCount = pdfCount;

  ScanStatsDtoBuilder() {
    ScanStatsDto._defaults(this);
  }

  ScanStatsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _running = $v.running;
      _scanCount = $v.scanCount;
      _errs = $v.errs?.toBuilder();
      _diskUsage = $v.diskUsage;
      _epubCount = $v.epubCount;
      _pdfCount = $v.pdfCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScanStatsDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ScanStatsDto;
  }

  @override
  void update(void Function(ScanStatsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScanStatsDto build() => _build();

  _$ScanStatsDto _build() {
    _$ScanStatsDto _$result;
    try {
      _$result = _$v ??
          new _$ScanStatsDto._(
              total: BuiltValueNullFieldError.checkNotNull(
                  total, r'ScanStatsDto', 'total'),
              running: BuiltValueNullFieldError.checkNotNull(
                  running, r'ScanStatsDto', 'running'),
              scanCount: BuiltValueNullFieldError.checkNotNull(
                  scanCount, r'ScanStatsDto', 'scanCount'),
              errs: _errs?.build(),
              diskUsage: BuiltValueNullFieldError.checkNotNull(
                  diskUsage, r'ScanStatsDto', 'diskUsage'),
              epubCount: BuiltValueNullFieldError.checkNotNull(
                  epubCount, r'ScanStatsDto', 'epubCount'),
              pdfCount: BuiltValueNullFieldError.checkNotNull(
                  pdfCount, r'ScanStatsDto', 'pdfCount'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'errs';
        _errs?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ScanStatsDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
