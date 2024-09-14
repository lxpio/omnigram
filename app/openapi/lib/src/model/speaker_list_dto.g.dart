// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speaker_list_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SpeakerListDto extends SpeakerListDto {
  @override
  final int total;
  @override
  final BuiltList<SpeakerDto> items;

  factory _$SpeakerListDto([void Function(SpeakerListDtoBuilder)? updates]) =>
      (new SpeakerListDtoBuilder()..update(updates))._build();

  _$SpeakerListDto._({required this.total, required this.items}) : super._() {
    BuiltValueNullFieldError.checkNotNull(total, r'SpeakerListDto', 'total');
    BuiltValueNullFieldError.checkNotNull(items, r'SpeakerListDto', 'items');
  }

  @override
  SpeakerListDto rebuild(void Function(SpeakerListDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SpeakerListDtoBuilder toBuilder() =>
      new SpeakerListDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SpeakerListDto &&
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
    return (newBuiltValueToStringHelper(r'SpeakerListDto')
          ..add('total', total)
          ..add('items', items))
        .toString();
  }
}

class SpeakerListDtoBuilder
    implements Builder<SpeakerListDto, SpeakerListDtoBuilder> {
  _$SpeakerListDto? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  ListBuilder<SpeakerDto>? _items;
  ListBuilder<SpeakerDto> get items =>
      _$this._items ??= new ListBuilder<SpeakerDto>();
  set items(ListBuilder<SpeakerDto>? items) => _$this._items = items;

  SpeakerListDtoBuilder() {
    SpeakerListDto._defaults(this);
  }

  SpeakerListDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SpeakerListDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SpeakerListDto;
  }

  @override
  void update(void Function(SpeakerListDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SpeakerListDto build() => _build();

  _$SpeakerListDto _build() {
    _$SpeakerListDto _$result;
    try {
      _$result = _$v ??
          new _$SpeakerListDto._(
              total: BuiltValueNullFieldError.checkNotNull(
                  total, r'SpeakerListDto', 'total'),
              items: items.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'SpeakerListDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
