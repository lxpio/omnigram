// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_stats_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReaderStatsDto extends ReaderStatsDto {
  @override
  final int total;
  @override
  final int authors;
  @override
  final int publisher;
  @override
  final int categorys;

  factory _$ReaderStatsDto([void Function(ReaderStatsDtoBuilder)? updates]) =>
      (new ReaderStatsDtoBuilder()..update(updates))._build();

  _$ReaderStatsDto._(
      {required this.total,
      required this.authors,
      required this.publisher,
      required this.categorys})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(total, r'ReaderStatsDto', 'total');
    BuiltValueNullFieldError.checkNotNull(
        authors, r'ReaderStatsDto', 'authors');
    BuiltValueNullFieldError.checkNotNull(
        publisher, r'ReaderStatsDto', 'publisher');
    BuiltValueNullFieldError.checkNotNull(
        categorys, r'ReaderStatsDto', 'categorys');
  }

  @override
  ReaderStatsDto rebuild(void Function(ReaderStatsDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReaderStatsDtoBuilder toBuilder() =>
      new ReaderStatsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReaderStatsDto &&
        total == other.total &&
        authors == other.authors &&
        publisher == other.publisher &&
        categorys == other.categorys;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, authors.hashCode);
    _$hash = $jc(_$hash, publisher.hashCode);
    _$hash = $jc(_$hash, categorys.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReaderStatsDto')
          ..add('total', total)
          ..add('authors', authors)
          ..add('publisher', publisher)
          ..add('categorys', categorys))
        .toString();
  }
}

class ReaderStatsDtoBuilder
    implements Builder<ReaderStatsDto, ReaderStatsDtoBuilder> {
  _$ReaderStatsDto? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _authors;
  int? get authors => _$this._authors;
  set authors(int? authors) => _$this._authors = authors;

  int? _publisher;
  int? get publisher => _$this._publisher;
  set publisher(int? publisher) => _$this._publisher = publisher;

  int? _categorys;
  int? get categorys => _$this._categorys;
  set categorys(int? categorys) => _$this._categorys = categorys;

  ReaderStatsDtoBuilder() {
    ReaderStatsDto._defaults(this);
  }

  ReaderStatsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _authors = $v.authors;
      _publisher = $v.publisher;
      _categorys = $v.categorys;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReaderStatsDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ReaderStatsDto;
  }

  @override
  void update(void Function(ReaderStatsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReaderStatsDto build() => _build();

  _$ReaderStatsDto _build() {
    final _$result = _$v ??
        new _$ReaderStatsDto._(
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'ReaderStatsDto', 'total'),
            authors: BuiltValueNullFieldError.checkNotNull(
                authors, r'ReaderStatsDto', 'authors'),
            publisher: BuiltValueNullFieldError.checkNotNull(
                publisher, r'ReaderStatsDto', 'publisher'),
            categorys: BuiltValueNullFieldError.checkNotNull(
                categorys, r'ReaderStatsDto', 'categorys'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
