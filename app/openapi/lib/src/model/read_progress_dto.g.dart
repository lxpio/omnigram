// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read_progress_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReadProgressDto extends ReadProgressDto {
  @override
  final int id;
  @override
  final int bookId;
  @override
  final int userId;
  @override
  final int startDate;
  @override
  final int updatedAt;
  @override
  final int exptEndDate;
  @override
  final int endDate;
  @override
  final int progressIndex;
  @override
  final num progress;
  @override
  final int paraPosition;

  factory _$ReadProgressDto([void Function(ReadProgressDtoBuilder)? updates]) =>
      (new ReadProgressDtoBuilder()..update(updates))._build();

  _$ReadProgressDto._(
      {required this.id,
      required this.bookId,
      required this.userId,
      required this.startDate,
      required this.updatedAt,
      required this.exptEndDate,
      required this.endDate,
      required this.progressIndex,
      required this.progress,
      required this.paraPosition})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'ReadProgressDto', 'id');
    BuiltValueNullFieldError.checkNotNull(bookId, r'ReadProgressDto', 'bookId');
    BuiltValueNullFieldError.checkNotNull(userId, r'ReadProgressDto', 'userId');
    BuiltValueNullFieldError.checkNotNull(
        startDate, r'ReadProgressDto', 'startDate');
    BuiltValueNullFieldError.checkNotNull(
        updatedAt, r'ReadProgressDto', 'updatedAt');
    BuiltValueNullFieldError.checkNotNull(
        exptEndDate, r'ReadProgressDto', 'exptEndDate');
    BuiltValueNullFieldError.checkNotNull(
        endDate, r'ReadProgressDto', 'endDate');
    BuiltValueNullFieldError.checkNotNull(
        progressIndex, r'ReadProgressDto', 'progressIndex');
    BuiltValueNullFieldError.checkNotNull(
        progress, r'ReadProgressDto', 'progress');
    BuiltValueNullFieldError.checkNotNull(
        paraPosition, r'ReadProgressDto', 'paraPosition');
  }

  @override
  ReadProgressDto rebuild(void Function(ReadProgressDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReadProgressDtoBuilder toBuilder() =>
      new ReadProgressDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReadProgressDto &&
        id == other.id &&
        bookId == other.bookId &&
        userId == other.userId &&
        startDate == other.startDate &&
        updatedAt == other.updatedAt &&
        exptEndDate == other.exptEndDate &&
        endDate == other.endDate &&
        progressIndex == other.progressIndex &&
        progress == other.progress &&
        paraPosition == other.paraPosition;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, bookId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, exptEndDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, progressIndex.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, paraPosition.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReadProgressDto')
          ..add('id', id)
          ..add('bookId', bookId)
          ..add('userId', userId)
          ..add('startDate', startDate)
          ..add('updatedAt', updatedAt)
          ..add('exptEndDate', exptEndDate)
          ..add('endDate', endDate)
          ..add('progressIndex', progressIndex)
          ..add('progress', progress)
          ..add('paraPosition', paraPosition))
        .toString();
  }
}

class ReadProgressDtoBuilder
    implements Builder<ReadProgressDto, ReadProgressDtoBuilder> {
  _$ReadProgressDto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _bookId;
  int? get bookId => _$this._bookId;
  set bookId(int? bookId) => _$this._bookId = bookId;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  int? _startDate;
  int? get startDate => _$this._startDate;
  set startDate(int? startDate) => _$this._startDate = startDate;

  int? _updatedAt;
  int? get updatedAt => _$this._updatedAt;
  set updatedAt(int? updatedAt) => _$this._updatedAt = updatedAt;

  int? _exptEndDate;
  int? get exptEndDate => _$this._exptEndDate;
  set exptEndDate(int? exptEndDate) => _$this._exptEndDate = exptEndDate;

  int? _endDate;
  int? get endDate => _$this._endDate;
  set endDate(int? endDate) => _$this._endDate = endDate;

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

  ReadProgressDtoBuilder() {
    ReadProgressDto._defaults(this);
  }

  ReadProgressDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _bookId = $v.bookId;
      _userId = $v.userId;
      _startDate = $v.startDate;
      _updatedAt = $v.updatedAt;
      _exptEndDate = $v.exptEndDate;
      _endDate = $v.endDate;
      _progressIndex = $v.progressIndex;
      _progress = $v.progress;
      _paraPosition = $v.paraPosition;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReadProgressDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ReadProgressDto;
  }

  @override
  void update(void Function(ReadProgressDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReadProgressDto build() => _build();

  _$ReadProgressDto _build() {
    final _$result = _$v ??
        new _$ReadProgressDto._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ReadProgressDto', 'id'),
            bookId: BuiltValueNullFieldError.checkNotNull(
                bookId, r'ReadProgressDto', 'bookId'),
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'ReadProgressDto', 'userId'),
            startDate: BuiltValueNullFieldError.checkNotNull(
                startDate, r'ReadProgressDto', 'startDate'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'ReadProgressDto', 'updatedAt'),
            exptEndDate: BuiltValueNullFieldError.checkNotNull(
                exptEndDate, r'ReadProgressDto', 'exptEndDate'),
            endDate: BuiltValueNullFieldError.checkNotNull(
                endDate, r'ReadProgressDto', 'endDate'),
            progressIndex: BuiltValueNullFieldError.checkNotNull(
                progressIndex, r'ReadProgressDto', 'progressIndex'),
            progress: BuiltValueNullFieldError.checkNotNull(
                progress, r'ReadProgressDto', 'progress'),
            paraPosition:
                BuiltValueNullFieldError.checkNotNull(paraPosition, r'ReadProgressDto', 'paraPosition'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
