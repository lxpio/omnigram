// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speaker_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SpeakerDto extends SpeakerDto {
  @override
  final int id;
  @override
  final String audioId;
  @override
  final String demoWav;
  @override
  final String name;
  @override
  final String? tag;
  @override
  final String? avatarUrl;

  factory _$SpeakerDto([void Function(SpeakerDtoBuilder)? updates]) =>
      (new SpeakerDtoBuilder()..update(updates))._build();

  _$SpeakerDto._(
      {required this.id,
      required this.audioId,
      required this.demoWav,
      required this.name,
      this.tag,
      this.avatarUrl})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'SpeakerDto', 'id');
    BuiltValueNullFieldError.checkNotNull(audioId, r'SpeakerDto', 'audioId');
    BuiltValueNullFieldError.checkNotNull(demoWav, r'SpeakerDto', 'demoWav');
    BuiltValueNullFieldError.checkNotNull(name, r'SpeakerDto', 'name');
  }

  @override
  SpeakerDto rebuild(void Function(SpeakerDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SpeakerDtoBuilder toBuilder() => new SpeakerDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SpeakerDto &&
        id == other.id &&
        audioId == other.audioId &&
        demoWav == other.demoWav &&
        name == other.name &&
        tag == other.tag &&
        avatarUrl == other.avatarUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, audioId.hashCode);
    _$hash = $jc(_$hash, demoWav.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, tag.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SpeakerDto')
          ..add('id', id)
          ..add('audioId', audioId)
          ..add('demoWav', demoWav)
          ..add('name', name)
          ..add('tag', tag)
          ..add('avatarUrl', avatarUrl))
        .toString();
  }
}

class SpeakerDtoBuilder implements Builder<SpeakerDto, SpeakerDtoBuilder> {
  _$SpeakerDto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _audioId;
  String? get audioId => _$this._audioId;
  set audioId(String? audioId) => _$this._audioId = audioId;

  String? _demoWav;
  String? get demoWav => _$this._demoWav;
  set demoWav(String? demoWav) => _$this._demoWav = demoWav;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _tag;
  String? get tag => _$this._tag;
  set tag(String? tag) => _$this._tag = tag;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  SpeakerDtoBuilder() {
    SpeakerDto._defaults(this);
  }

  SpeakerDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _audioId = $v.audioId;
      _demoWav = $v.demoWav;
      _name = $v.name;
      _tag = $v.tag;
      _avatarUrl = $v.avatarUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SpeakerDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SpeakerDto;
  }

  @override
  void update(void Function(SpeakerDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SpeakerDto build() => _build();

  _$SpeakerDto _build() {
    final _$result = _$v ??
        new _$SpeakerDto._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'SpeakerDto', 'id'),
            audioId: BuiltValueNullFieldError.checkNotNull(
                audioId, r'SpeakerDto', 'audioId'),
            demoWav: BuiltValueNullFieldError.checkNotNull(
                demoWav, r'SpeakerDto', 'demoWav'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'SpeakerDto', 'name'),
            tag: tag,
            avatarUrl: avatarUrl);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
