// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_index_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EbookIndexDto extends EbookIndexDto {
  @override
  final BuiltList<EbookDto> random;
  @override
  final BuiltList<EbookDto> recent;

  factory _$EbookIndexDto([void Function(EbookIndexDtoBuilder)? updates]) =>
      (new EbookIndexDtoBuilder()..update(updates))._build();

  _$EbookIndexDto._({required this.random, required this.recent}) : super._() {
    BuiltValueNullFieldError.checkNotNull(random, r'EbookIndexDto', 'random');
    BuiltValueNullFieldError.checkNotNull(recent, r'EbookIndexDto', 'recent');
  }

  @override
  EbookIndexDto rebuild(void Function(EbookIndexDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EbookIndexDtoBuilder toBuilder() => new EbookIndexDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EbookIndexDto &&
        random == other.random &&
        recent == other.recent;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, random.hashCode);
    _$hash = $jc(_$hash, recent.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EbookIndexDto')
          ..add('random', random)
          ..add('recent', recent))
        .toString();
  }
}

class EbookIndexDtoBuilder
    implements Builder<EbookIndexDto, EbookIndexDtoBuilder> {
  _$EbookIndexDto? _$v;

  ListBuilder<EbookDto>? _random;
  ListBuilder<EbookDto> get random =>
      _$this._random ??= new ListBuilder<EbookDto>();
  set random(ListBuilder<EbookDto>? random) => _$this._random = random;

  ListBuilder<EbookDto>? _recent;
  ListBuilder<EbookDto> get recent =>
      _$this._recent ??= new ListBuilder<EbookDto>();
  set recent(ListBuilder<EbookDto>? recent) => _$this._recent = recent;

  EbookIndexDtoBuilder() {
    EbookIndexDto._defaults(this);
  }

  EbookIndexDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _random = $v.random.toBuilder();
      _recent = $v.recent.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EbookIndexDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$EbookIndexDto;
  }

  @override
  void update(void Function(EbookIndexDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EbookIndexDto build() => _build();

  _$EbookIndexDto _build() {
    _$EbookIndexDto _$result;
    try {
      _$result = _$v ??
          new _$EbookIndexDto._(random: random.build(), recent: recent.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'random';
        random.build();
        _$failedField = 'recent';
        recent.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'EbookIndexDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
