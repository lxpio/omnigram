// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'm4t_tts_stream_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$M4tTtsStreamPostRequest extends M4tTtsStreamPostRequest {
  @override
  final String text;
  @override
  final String lang;
  @override
  final String audioId;
  @override
  final String format;
  @override
  final bool stream;

  factory _$M4tTtsStreamPostRequest(
          [void Function(M4tTtsStreamPostRequestBuilder)? updates]) =>
      (new M4tTtsStreamPostRequestBuilder()..update(updates))._build();

  _$M4tTtsStreamPostRequest._(
      {required this.text,
      required this.lang,
      required this.audioId,
      required this.format,
      required this.stream})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        text, r'M4tTtsStreamPostRequest', 'text');
    BuiltValueNullFieldError.checkNotNull(
        lang, r'M4tTtsStreamPostRequest', 'lang');
    BuiltValueNullFieldError.checkNotNull(
        audioId, r'M4tTtsStreamPostRequest', 'audioId');
    BuiltValueNullFieldError.checkNotNull(
        format, r'M4tTtsStreamPostRequest', 'format');
    BuiltValueNullFieldError.checkNotNull(
        stream, r'M4tTtsStreamPostRequest', 'stream');
  }

  @override
  M4tTtsStreamPostRequest rebuild(
          void Function(M4tTtsStreamPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  M4tTtsStreamPostRequestBuilder toBuilder() =>
      new M4tTtsStreamPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is M4tTtsStreamPostRequest &&
        text == other.text &&
        lang == other.lang &&
        audioId == other.audioId &&
        format == other.format &&
        stream == other.stream;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jc(_$hash, lang.hashCode);
    _$hash = $jc(_$hash, audioId.hashCode);
    _$hash = $jc(_$hash, format.hashCode);
    _$hash = $jc(_$hash, stream.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'M4tTtsStreamPostRequest')
          ..add('text', text)
          ..add('lang', lang)
          ..add('audioId', audioId)
          ..add('format', format)
          ..add('stream', stream))
        .toString();
  }
}

class M4tTtsStreamPostRequestBuilder
    implements
        Builder<M4tTtsStreamPostRequest, M4tTtsStreamPostRequestBuilder> {
  _$M4tTtsStreamPostRequest? _$v;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  String? _lang;
  String? get lang => _$this._lang;
  set lang(String? lang) => _$this._lang = lang;

  String? _audioId;
  String? get audioId => _$this._audioId;
  set audioId(String? audioId) => _$this._audioId = audioId;

  String? _format;
  String? get format => _$this._format;
  set format(String? format) => _$this._format = format;

  bool? _stream;
  bool? get stream => _$this._stream;
  set stream(bool? stream) => _$this._stream = stream;

  M4tTtsStreamPostRequestBuilder() {
    M4tTtsStreamPostRequest._defaults(this);
  }

  M4tTtsStreamPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _text = $v.text;
      _lang = $v.lang;
      _audioId = $v.audioId;
      _format = $v.format;
      _stream = $v.stream;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(M4tTtsStreamPostRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$M4tTtsStreamPostRequest;
  }

  @override
  void update(void Function(M4tTtsStreamPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  M4tTtsStreamPostRequest build() => _build();

  _$M4tTtsStreamPostRequest _build() {
    final _$result = _$v ??
        new _$M4tTtsStreamPostRequest._(
            text: BuiltValueNullFieldError.checkNotNull(
                text, r'M4tTtsStreamPostRequest', 'text'),
            lang: BuiltValueNullFieldError.checkNotNull(
                lang, r'M4tTtsStreamPostRequest', 'lang'),
            audioId: BuiltValueNullFieldError.checkNotNull(
                audioId, r'M4tTtsStreamPostRequest', 'audioId'),
            format: BuiltValueNullFieldError.checkNotNull(
                format, r'M4tTtsStreamPostRequest', 'format'),
            stream: BuiltValueNullFieldError.checkNotNull(
                stream, r'M4tTtsStreamPostRequest', 'stream'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
