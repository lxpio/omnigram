// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_resp_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EbookRespDto extends EbookRespDto {
  @override
  final int total;
  @override
  final BuiltList<EbookDto> items;

  factory _$EbookRespDto([void Function(EbookRespDtoBuilder)? updates]) =>
      (new EbookRespDtoBuilder()..update(updates))._build();

  _$EbookRespDto._({required this.total, required this.items}) : super._() {
    BuiltValueNullFieldError.checkNotNull(total, r'EbookRespDto', 'total');
    BuiltValueNullFieldError.checkNotNull(items, r'EbookRespDto', 'items');
  }

  @override
  EbookRespDto rebuild(void Function(EbookRespDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EbookRespDtoBuilder toBuilder() => new EbookRespDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EbookRespDto &&
        total == other.total &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EbookRespDto')
          ..add('total', total)
          ..add('items', items))
        .toString();
  }
}

class EbookRespDtoBuilder
    implements Builder<EbookRespDto, EbookRespDtoBuilder> {
  _$EbookRespDto? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  ListBuilder<EbookDto>? _items;
  ListBuilder<EbookDto> get items =>
      _$this._items ??= new ListBuilder<EbookDto>();
  set items(ListBuilder<EbookDto>? items) => _$this._items = items;

  EbookRespDtoBuilder() {
    EbookRespDto._defaults(this);
  }

  EbookRespDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EbookRespDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$EbookRespDto;
  }

  @override
  void update(void Function(EbookRespDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EbookRespDto build() => _build();

  _$EbookRespDto _build() {
    _$EbookRespDto _$result;
    try {
      _$result = _$v ??
          new _$EbookRespDto._(
              total: BuiltValueNullFieldError.checkNotNull(
                  total, r'EbookRespDto', 'total'),
              items: items.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'EbookRespDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
