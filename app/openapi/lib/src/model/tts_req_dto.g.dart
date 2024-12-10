// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_req_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TtsReqDto extends TtsReqDto {
  @override
  final String text;
  @override
  final int chunkLength;
  @override
  final String format;
  @override
  final int mp3Bitrate;
  @override
  final BuiltList<String> references;
  @override
  final String? referenceId;
  @override
  final String? useMemoryCache;
  @override
  final bool normalize;
  @override
  final int opusBitrate;
  @override
  final String? latency;
  @override
  final bool streaming;
  @override
  final int maxNewTokens;
  @override
  final num? topP;
  @override
  final num? repetitionPenalty;
  @override
  final num? temperature;

  factory _$TtsReqDto([void Function(TtsReqDtoBuilder)? updates]) =>
      (new TtsReqDtoBuilder()..update(updates))._build();

  _$TtsReqDto._(
      {required this.text,
      required this.chunkLength,
      required this.format,
      required this.mp3Bitrate,
      required this.references,
      this.referenceId,
      this.useMemoryCache,
      required this.normalize,
      required this.opusBitrate,
      this.latency,
      required this.streaming,
      required this.maxNewTokens,
      this.topP,
      this.repetitionPenalty,
      this.temperature})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(text, r'TtsReqDto', 'text');
    BuiltValueNullFieldError.checkNotNull(
        chunkLength, r'TtsReqDto', 'chunkLength');
    BuiltValueNullFieldError.checkNotNull(format, r'TtsReqDto', 'format');
    BuiltValueNullFieldError.checkNotNull(
        mp3Bitrate, r'TtsReqDto', 'mp3Bitrate');
    BuiltValueNullFieldError.checkNotNull(
        references, r'TtsReqDto', 'references');
    BuiltValueNullFieldError.checkNotNull(normalize, r'TtsReqDto', 'normalize');
    BuiltValueNullFieldError.checkNotNull(
        opusBitrate, r'TtsReqDto', 'opusBitrate');
    BuiltValueNullFieldError.checkNotNull(streaming, r'TtsReqDto', 'streaming');
    BuiltValueNullFieldError.checkNotNull(
        maxNewTokens, r'TtsReqDto', 'maxNewTokens');
  }

  @override
  TtsReqDto rebuild(void Function(TtsReqDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TtsReqDtoBuilder toBuilder() => new TtsReqDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TtsReqDto &&
        text == other.text &&
        chunkLength == other.chunkLength &&
        format == other.format &&
        mp3Bitrate == other.mp3Bitrate &&
        references == other.references &&
        referenceId == other.referenceId &&
        useMemoryCache == other.useMemoryCache &&
        normalize == other.normalize &&
        opusBitrate == other.opusBitrate &&
        latency == other.latency &&
        streaming == other.streaming &&
        maxNewTokens == other.maxNewTokens &&
        topP == other.topP &&
        repetitionPenalty == other.repetitionPenalty &&
        temperature == other.temperature;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, chunkLength.hashCode);
    _$hash = $jc(_$hash, format.hashCode);
    _$hash = $jc(_$hash, mp3Bitrate.hashCode);
    _$hash = $jc(_$hash, references.hashCode);
    _$hash = $jc(_$hash, referenceId.hashCode);
    _$hash = $jc(_$hash, useMemoryCache.hashCode);
    _$hash = $jc(_$hash, normalize.hashCode);
    _$hash = $jc(_$hash, opusBitrate.hashCode);
    _$hash = $jc(_$hash, latency.hashCode);
    _$hash = $jc(_$hash, streaming.hashCode);
    _$hash = $jc(_$hash, maxNewTokens.hashCode);
    _$hash = $jc(_$hash, topP.hashCode);
    _$hash = $jc(_$hash, repetitionPenalty.hashCode);
    _$hash = $jc(_$hash, temperature.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TtsReqDto')
          ..add('text', text)
          ..add('chunkLength', chunkLength)
          ..add('format', format)
          ..add('mp3Bitrate', mp3Bitrate)
          ..add('references', references)
          ..add('referenceId', referenceId)
          ..add('useMemoryCache', useMemoryCache)
          ..add('normalize', normalize)
          ..add('opusBitrate', opusBitrate)
          ..add('latency', latency)
          ..add('streaming', streaming)
          ..add('maxNewTokens', maxNewTokens)
          ..add('topP', topP)
          ..add('repetitionPenalty', repetitionPenalty)
          ..add('temperature', temperature))
        .toString();
  }
}

class TtsReqDtoBuilder implements Builder<TtsReqDto, TtsReqDtoBuilder> {
  _$TtsReqDto? _$v;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  int? _chunkLength;
  int? get chunkLength => _$this._chunkLength;
  set chunkLength(int? chunkLength) => _$this._chunkLength = chunkLength;

  String? _format;
  String? get format => _$this._format;
  set format(String? format) => _$this._format = format;

  int? _mp3Bitrate;
  int? get mp3Bitrate => _$this._mp3Bitrate;
  set mp3Bitrate(int? mp3Bitrate) => _$this._mp3Bitrate = mp3Bitrate;

  ListBuilder<String>? _references;
  ListBuilder<String> get references =>
      _$this._references ??= new ListBuilder<String>();
  set references(ListBuilder<String>? references) =>
      _$this._references = references;

  String? _referenceId;
  String? get referenceId => _$this._referenceId;
  set referenceId(String? referenceId) => _$this._referenceId = referenceId;

  String? _useMemoryCache;
  String? get useMemoryCache => _$this._useMemoryCache;
  set useMemoryCache(String? useMemoryCache) =>
      _$this._useMemoryCache = useMemoryCache;

  bool? _normalize;
  bool? get normalize => _$this._normalize;
  set normalize(bool? normalize) => _$this._normalize = normalize;

  int? _opusBitrate;
  int? get opusBitrate => _$this._opusBitrate;
  set opusBitrate(int? opusBitrate) => _$this._opusBitrate = opusBitrate;

  String? _latency;
  String? get latency => _$this._latency;
  set latency(String? latency) => _$this._latency = latency;

  bool? _streaming;
  bool? get streaming => _$this._streaming;
  set streaming(bool? streaming) => _$this._streaming = streaming;

  int? _maxNewTokens;
  int? get maxNewTokens => _$this._maxNewTokens;
  set maxNewTokens(int? maxNewTokens) => _$this._maxNewTokens = maxNewTokens;

  num? _topP;
  num? get topP => _$this._topP;
  set topP(num? topP) => _$this._topP = topP;

  num? _repetitionPenalty;
  num? get repetitionPenalty => _$this._repetitionPenalty;
  set repetitionPenalty(num? repetitionPenalty) =>
      _$this._repetitionPenalty = repetitionPenalty;

  num? _temperature;
  num? get temperature => _$this._temperature;
  set temperature(num? temperature) => _$this._temperature = temperature;

  TtsReqDtoBuilder() {
    TtsReqDto._defaults(this);
  }

  TtsReqDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _text = $v.text;
      _chunkLength = $v.chunkLength;
      _format = $v.format;
      _mp3Bitrate = $v.mp3Bitrate;
      _references = $v.references.toBuilder();
      _referenceId = $v.referenceId;
      _useMemoryCache = $v.useMemoryCache;
      _normalize = $v.normalize;
      _opusBitrate = $v.opusBitrate;
      _latency = $v.latency;
      _streaming = $v.streaming;
      _maxNewTokens = $v.maxNewTokens;
      _topP = $v.topP;
      _repetitionPenalty = $v.repetitionPenalty;
      _temperature = $v.temperature;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TtsReqDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$TtsReqDto;
  }

  @override
  void update(void Function(TtsReqDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TtsReqDto build() => _build();

  _$TtsReqDto _build() {
    _$TtsReqDto _$result;
    try {
      _$result = _$v ??
          new _$TtsReqDto._(
              text: BuiltValueNullFieldError.checkNotNull(
                  text, r'TtsReqDto', 'text'),
              chunkLength: BuiltValueNullFieldError.checkNotNull(
                  chunkLength, r'TtsReqDto', 'chunkLength'),
              format: BuiltValueNullFieldError.checkNotNull(
                  format, r'TtsReqDto', 'format'),
              mp3Bitrate: BuiltValueNullFieldError.checkNotNull(
                  mp3Bitrate, r'TtsReqDto', 'mp3Bitrate'),
              references: references.build(),
              referenceId: referenceId,
              useMemoryCache: useMemoryCache,
              normalize: BuiltValueNullFieldError.checkNotNull(
                  normalize, r'TtsReqDto', 'normalize'),
              opusBitrate: BuiltValueNullFieldError.checkNotNull(
                  opusBitrate, r'TtsReqDto', 'opusBitrate'),
              latency: latency,
              streaming: BuiltValueNullFieldError.checkNotNull(
                  streaming, r'TtsReqDto', 'streaming'),
              maxNewTokens: BuiltValueNullFieldError.checkNotNull(
                  maxNewTokens, r'TtsReqDto', 'maxNewTokens'),
              topP: topP,
              repetitionPenalty: repetitionPenalty,
              temperature: temperature);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'references';
        references.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'TtsReqDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
