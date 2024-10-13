// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delta_sync_resp_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeltaSyncRespDto extends DeltaSyncRespDto {
  @override
  final bool needFullSync;
  @override
  final BuiltList<String> deleted;
  @override
  final BuiltList<EbookDto> upserted;

  factory _$DeltaSyncRespDto(
          [void Function(DeltaSyncRespDtoBuilder)? updates]) =>
      (new DeltaSyncRespDtoBuilder()..update(updates))._build();

  _$DeltaSyncRespDto._(
      {required this.needFullSync,
      required this.deleted,
      required this.upserted})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        needFullSync, r'DeltaSyncRespDto', 'needFullSync');
    BuiltValueNullFieldError.checkNotNull(
        deleted, r'DeltaSyncRespDto', 'deleted');
    BuiltValueNullFieldError.checkNotNull(
        upserted, r'DeltaSyncRespDto', 'upserted');
  }

  @override
  DeltaSyncRespDto rebuild(void Function(DeltaSyncRespDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeltaSyncRespDtoBuilder toBuilder() =>
      new DeltaSyncRespDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeltaSyncRespDto &&
        needFullSync == other.needFullSync &&
        deleted == other.deleted &&
        upserted == other.upserted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, needFullSync.hashCode);
    _$hash = $jc(_$hash, deleted.hashCode);
    _$hash = $jc(_$hash, upserted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeltaSyncRespDto')
          ..add('needFullSync', needFullSync)
          ..add('deleted', deleted)
          ..add('upserted', upserted))
        .toString();
  }
}

class DeltaSyncRespDtoBuilder
    implements Builder<DeltaSyncRespDto, DeltaSyncRespDtoBuilder> {
  _$DeltaSyncRespDto? _$v;

  bool? _needFullSync;
  bool? get needFullSync => _$this._needFullSync;
  set needFullSync(bool? needFullSync) => _$this._needFullSync = needFullSync;

  ListBuilder<String>? _deleted;
  ListBuilder<String> get deleted =>
      _$this._deleted ??= new ListBuilder<String>();
  set deleted(ListBuilder<String>? deleted) => _$this._deleted = deleted;

  ListBuilder<EbookDto>? _upserted;
  ListBuilder<EbookDto> get upserted =>
      _$this._upserted ??= new ListBuilder<EbookDto>();
  set upserted(ListBuilder<EbookDto>? upserted) => _$this._upserted = upserted;

  DeltaSyncRespDtoBuilder() {
    DeltaSyncRespDto._defaults(this);
  }

  DeltaSyncRespDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _needFullSync = $v.needFullSync;
      _deleted = $v.deleted.toBuilder();
      _upserted = $v.upserted.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeltaSyncRespDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$DeltaSyncRespDto;
  }

  @override
  void update(void Function(DeltaSyncRespDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeltaSyncRespDto build() => _build();

  _$DeltaSyncRespDto _build() {
    _$DeltaSyncRespDto _$result;
    try {
      _$result = _$v ??
          new _$DeltaSyncRespDto._(
              needFullSync: BuiltValueNullFieldError.checkNotNull(
                  needFullSync, r'DeltaSyncRespDto', 'needFullSync'),
              deleted: deleted.build(),
              upserted: upserted.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deleted';
        deleted.build();
        _$failedField = 'upserted';
        upserted.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'DeltaSyncRespDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
