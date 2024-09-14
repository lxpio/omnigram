// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_list_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EbookListDto extends EbookListDto {
  @override
  final int total;
  @override
  final BuiltList<EbookDto> items;

  factory _$EbookListDto([void Function(EbookListDtoBuilder)? updates]) =>
      (new EbookListDtoBuilder()..update(updates))._build();

  _$EbookListDto._({required this.total, required this.items}) : super._() {
    BuiltValueNullFieldError.checkNotNull(total, r'EbookListDto', 'total');
    BuiltValueNullFieldError.checkNotNull(items, r'EbookListDto', 'items');
  }

  @override
  EbookListDto rebuild(void Function(EbookListDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EbookListDtoBuilder toBuilder() => new EbookListDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EbookListDto &&
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
    return (newBuiltValueToStringHelper(r'EbookListDto')
          ..add('total', total)
          ..add('items', items))
        .toString();
  }
}

class EbookListDtoBuilder
    implements Builder<EbookListDto, EbookListDtoBuilder> {
  _$EbookListDto? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  ListBuilder<EbookDto>? _items;
  ListBuilder<EbookDto> get items =>
      _$this._items ??= new ListBuilder<EbookDto>();
  set items(ListBuilder<EbookDto>? items) => _$this._items = items;

  EbookListDtoBuilder() {
    EbookListDto._defaults(this);
  }

  EbookListDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EbookListDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$EbookListDto;
  }

  @override
  void update(void Function(EbookListDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EbookListDto build() => _build();

  _$EbookListDto _build() {
    _$EbookListDto _$result;
    try {
      _$result = _$v ??
          new _$EbookListDto._(
              total: BuiltValueNullFieldError.checkNotNull(
                  total, r'EbookListDto', 'total'),
              items: items.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'EbookListDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
