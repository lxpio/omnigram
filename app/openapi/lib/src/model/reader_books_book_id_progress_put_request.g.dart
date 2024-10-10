// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_books_book_id_progress_put_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReaderBooksBookIdProgressPutRequest
    extends ReaderBooksBookIdProgressPutRequest {
  @override
  final int userId;
  @override
  final int updatedAt;
  @override
  final int progressIndex;
  @override
  final num progress;
  @override
  final int paraPosition;

  factory _$ReaderBooksBookIdProgressPutRequest(
          [void Function(ReaderBooksBookIdProgressPutRequestBuilder)?
              updates]) =>
      (new ReaderBooksBookIdProgressPutRequestBuilder()..update(updates))
          ._build();

  _$ReaderBooksBookIdProgressPutRequest._(
      {required this.userId,
      required this.updatedAt,
      required this.progressIndex,
      required this.progress,
      required this.paraPosition})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        userId, r'ReaderBooksBookIdProgressPutRequest', 'userId');
    BuiltValueNullFieldError.checkNotNull(
        updatedAt, r'ReaderBooksBookIdProgressPutRequest', 'updatedAt');
    BuiltValueNullFieldError.checkNotNull(
        progressIndex, r'ReaderBooksBookIdProgressPutRequest', 'progressIndex');
    BuiltValueNullFieldError.checkNotNull(
        progress, r'ReaderBooksBookIdProgressPutRequest', 'progress');
    BuiltValueNullFieldError.checkNotNull(
        paraPosition, r'ReaderBooksBookIdProgressPutRequest', 'paraPosition');
  }

  @override
  ReaderBooksBookIdProgressPutRequest rebuild(
          void Function(ReaderBooksBookIdProgressPutRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReaderBooksBookIdProgressPutRequestBuilder toBuilder() =>
      new ReaderBooksBookIdProgressPutRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReaderBooksBookIdProgressPutRequest &&
        userId == other.userId &&
        updatedAt == other.updatedAt &&
        progressIndex == other.progressIndex &&
        progress == other.progress &&
        paraPosition == other.paraPosition;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, progressIndex.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, paraPosition.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReaderBooksBookIdProgressPutRequest')
          ..add('userId', userId)
          ..add('updatedAt', updatedAt)
          ..add('progressIndex', progressIndex)
          ..add('progress', progress)
          ..add('paraPosition', paraPosition))
        .toString();
  }
}

class ReaderBooksBookIdProgressPutRequestBuilder
    implements
        Builder<ReaderBooksBookIdProgressPutRequest,
            ReaderBooksBookIdProgressPutRequestBuilder> {
  _$ReaderBooksBookIdProgressPutRequest? _$v;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  int? _updatedAt;
  int? get updatedAt => _$this._updatedAt;
  set updatedAt(int? updatedAt) => _$this._updatedAt = updatedAt;

  int? _progressIndex;
  int? get progressIndex => _$this._progressIndex;
  set progressIndex(int? progressIndex) =>
      _$this._progressIndex = progressIndex;

  num? _progress;
  num? get progress => _$this._progress;
  set progress(num? progress) => _$this._progress = progress;

  int? _paraPosition;
  int? get paraPosition => _$this._paraPosition;
  set paraPosition(int? paraPosition) => _$this._paraPosition = paraPosition;

  ReaderBooksBookIdProgressPutRequestBuilder() {
    ReaderBooksBookIdProgressPutRequest._defaults(this);
  }

  ReaderBooksBookIdProgressPutRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _updatedAt = $v.updatedAt;
      _progressIndex = $v.progressIndex;
      _progress = $v.progress;
      _paraPosition = $v.paraPosition;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReaderBooksBookIdProgressPutRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ReaderBooksBookIdProgressPutRequest;
  }

  @override
  void update(
      void Function(ReaderBooksBookIdProgressPutRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReaderBooksBookIdProgressPutRequest build() => _build();

  _$ReaderBooksBookIdProgressPutRequest _build() {
    final _$result = _$v ??
        new _$ReaderBooksBookIdProgressPutRequest._(
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'ReaderBooksBookIdProgressPutRequest', 'userId'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'ReaderBooksBookIdProgressPutRequest', 'updatedAt'),
            progressIndex: BuiltValueNullFieldError.checkNotNull(progressIndex,
                r'ReaderBooksBookIdProgressPutRequest', 'progressIndex'),
            progress: BuiltValueNullFieldError.checkNotNull(
                progress, r'ReaderBooksBookIdProgressPutRequest', 'progress'),
            paraPosition: BuiltValueNullFieldError.checkNotNull(paraPosition,
                r'ReaderBooksBookIdProgressPutRequest', 'paraPosition'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
