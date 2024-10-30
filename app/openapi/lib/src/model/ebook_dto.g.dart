// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EbookDto extends EbookDto {
  @override
  final String id;
  @override
  final int? size;
  @override
  final int? ctime;
  @override
  final int? utime;
  @override
  final String title;
  @override
  final String? subTitle;
  @override
  final String? language;
  @override
  final String? coverUrl;
  @override
  final String? uuid;
  @override
  final String? isbn;
  @override
  final String? asin;
  @override
  final String identifier;
  @override
  final String? category;
  @override
  final String? author;
  @override
  final String? authorUrl;
  @override
  final String? authorSort;
  @override
  final String? publisher;
  @override
  final String? description;
  @override
  final bool? favStatus;
  @override
  final String? pubdate;
  @override
  final num? rating;
  @override
  final String? publisherUrl;
  @override
  final int? countVisit;
  @override
  final int? countDownload;
  @override
  final num? progress;
  @override
  final int? progressIndex;
  @override
  final int? paraPosition;
  @override
  final int? atime;

  factory _$EbookDto([void Function(EbookDtoBuilder)? updates]) =>
      (new EbookDtoBuilder()..update(updates))._build();

  _$EbookDto._(
      {required this.id,
      this.size,
      this.ctime,
      this.utime,
      required this.title,
      this.subTitle,
      this.language,
      this.coverUrl,
      this.uuid,
      this.isbn,
      this.asin,
      required this.identifier,
      this.category,
      this.author,
      this.authorUrl,
      this.authorSort,
      this.publisher,
      this.description,
      this.favStatus,
      this.pubdate,
      this.rating,
      this.publisherUrl,
      this.countVisit,
      this.countDownload,
      this.progress,
      this.progressIndex,
      this.paraPosition,
      this.atime})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'EbookDto', 'id');
    BuiltValueNullFieldError.checkNotNull(title, r'EbookDto', 'title');
    BuiltValueNullFieldError.checkNotNull(
        identifier, r'EbookDto', 'identifier');
  }

  @override
  EbookDto rebuild(void Function(EbookDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EbookDtoBuilder toBuilder() => new EbookDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EbookDto &&
        id == other.id &&
        size == other.size &&
        ctime == other.ctime &&
        utime == other.utime &&
        title == other.title &&
        subTitle == other.subTitle &&
        language == other.language &&
        coverUrl == other.coverUrl &&
        uuid == other.uuid &&
        isbn == other.isbn &&
        asin == other.asin &&
        identifier == other.identifier &&
        category == other.category &&
        author == other.author &&
        authorUrl == other.authorUrl &&
        authorSort == other.authorSort &&
        publisher == other.publisher &&
        description == other.description &&
        favStatus == other.favStatus &&
        pubdate == other.pubdate &&
        rating == other.rating &&
        publisherUrl == other.publisherUrl &&
        countVisit == other.countVisit &&
        countDownload == other.countDownload &&
        progress == other.progress &&
        progressIndex == other.progressIndex &&
        paraPosition == other.paraPosition &&
        atime == other.atime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, ctime.hashCode);
    _$hash = $jc(_$hash, utime.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, subTitle.hashCode);
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, coverUrl.hashCode);
    _$hash = $jc(_$hash, uuid.hashCode);
    _$hash = $jc(_$hash, isbn.hashCode);
    _$hash = $jc(_$hash, asin.hashCode);
    _$hash = $jc(_$hash, identifier.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, authorUrl.hashCode);
    _$hash = $jc(_$hash, authorSort.hashCode);
    _$hash = $jc(_$hash, publisher.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, favStatus.hashCode);
    _$hash = $jc(_$hash, pubdate.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, publisherUrl.hashCode);
    _$hash = $jc(_$hash, countVisit.hashCode);
    _$hash = $jc(_$hash, countDownload.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, progressIndex.hashCode);
    _$hash = $jc(_$hash, paraPosition.hashCode);
    _$hash = $jc(_$hash, atime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EbookDto')
          ..add('id', id)
          ..add('size', size)
          ..add('ctime', ctime)
          ..add('utime', utime)
          ..add('title', title)
          ..add('subTitle', subTitle)
          ..add('language', language)
          ..add('coverUrl', coverUrl)
          ..add('uuid', uuid)
          ..add('isbn', isbn)
          ..add('asin', asin)
          ..add('identifier', identifier)
          ..add('category', category)
          ..add('author', author)
          ..add('authorUrl', authorUrl)
          ..add('authorSort', authorSort)
          ..add('publisher', publisher)
          ..add('description', description)
          ..add('favStatus', favStatus)
          ..add('pubdate', pubdate)
          ..add('rating', rating)
          ..add('publisherUrl', publisherUrl)
          ..add('countVisit', countVisit)
          ..add('countDownload', countDownload)
          ..add('progress', progress)
          ..add('progressIndex', progressIndex)
          ..add('paraPosition', paraPosition)
          ..add('atime', atime))
        .toString();
  }
}

class EbookDtoBuilder implements Builder<EbookDto, EbookDtoBuilder> {
  _$EbookDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _size;
  int? get size => _$this._size;
  set size(int? size) => _$this._size = size;

  int? _ctime;
  int? get ctime => _$this._ctime;
  set ctime(int? ctime) => _$this._ctime = ctime;

  int? _utime;
  int? get utime => _$this._utime;
  set utime(int? utime) => _$this._utime = utime;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _subTitle;
  String? get subTitle => _$this._subTitle;
  set subTitle(String? subTitle) => _$this._subTitle = subTitle;

  String? _language;
  String? get language => _$this._language;
  set language(String? language) => _$this._language = language;

  String? _coverUrl;
  String? get coverUrl => _$this._coverUrl;
  set coverUrl(String? coverUrl) => _$this._coverUrl = coverUrl;

  String? _uuid;
  String? get uuid => _$this._uuid;
  set uuid(String? uuid) => _$this._uuid = uuid;

  String? _isbn;
  String? get isbn => _$this._isbn;
  set isbn(String? isbn) => _$this._isbn = isbn;

  String? _asin;
  String? get asin => _$this._asin;
  set asin(String? asin) => _$this._asin = asin;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  String? _author;
  String? get author => _$this._author;
  set author(String? author) => _$this._author = author;

  String? _authorUrl;
  String? get authorUrl => _$this._authorUrl;
  set authorUrl(String? authorUrl) => _$this._authorUrl = authorUrl;

  String? _authorSort;
  String? get authorSort => _$this._authorSort;
  set authorSort(String? authorSort) => _$this._authorSort = authorSort;

  String? _publisher;
  String? get publisher => _$this._publisher;
  set publisher(String? publisher) => _$this._publisher = publisher;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  bool? _favStatus;
  bool? get favStatus => _$this._favStatus;
  set favStatus(bool? favStatus) => _$this._favStatus = favStatus;

  String? _pubdate;
  String? get pubdate => _$this._pubdate;
  set pubdate(String? pubdate) => _$this._pubdate = pubdate;

  num? _rating;
  num? get rating => _$this._rating;
  set rating(num? rating) => _$this._rating = rating;

  String? _publisherUrl;
  String? get publisherUrl => _$this._publisherUrl;
  set publisherUrl(String? publisherUrl) => _$this._publisherUrl = publisherUrl;

  int? _countVisit;
  int? get countVisit => _$this._countVisit;
  set countVisit(int? countVisit) => _$this._countVisit = countVisit;

  int? _countDownload;
  int? get countDownload => _$this._countDownload;
  set countDownload(int? countDownload) =>
      _$this._countDownload = countDownload;

  num? _progress;
  num? get progress => _$this._progress;
  set progress(num? progress) => _$this._progress = progress;

  int? _progressIndex;
  int? get progressIndex => _$this._progressIndex;
  set progressIndex(int? progressIndex) =>
      _$this._progressIndex = progressIndex;

  int? _paraPosition;
  int? get paraPosition => _$this._paraPosition;
  set paraPosition(int? paraPosition) => _$this._paraPosition = paraPosition;

  int? _atime;
  int? get atime => _$this._atime;
  set atime(int? atime) => _$this._atime = atime;

  EbookDtoBuilder() {
    EbookDto._defaults(this);
  }

  EbookDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _size = $v.size;
      _ctime = $v.ctime;
      _utime = $v.utime;
      _title = $v.title;
      _subTitle = $v.subTitle;
      _language = $v.language;
      _coverUrl = $v.coverUrl;
      _uuid = $v.uuid;
      _isbn = $v.isbn;
      _asin = $v.asin;
      _identifier = $v.identifier;
      _category = $v.category;
      _author = $v.author;
      _authorUrl = $v.authorUrl;
      _authorSort = $v.authorSort;
      _publisher = $v.publisher;
      _description = $v.description;
      _favStatus = $v.favStatus;
      _pubdate = $v.pubdate;
      _rating = $v.rating;
      _publisherUrl = $v.publisherUrl;
      _countVisit = $v.countVisit;
      _countDownload = $v.countDownload;
      _progress = $v.progress;
      _progressIndex = $v.progressIndex;
      _paraPosition = $v.paraPosition;
      _atime = $v.atime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EbookDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$EbookDto;
  }

  @override
  void update(void Function(EbookDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EbookDto build() => _build();

  _$EbookDto _build() {
    final _$result = _$v ??
        new _$EbookDto._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'EbookDto', 'id'),
            size: size,
            ctime: ctime,
            utime: utime,
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'EbookDto', 'title'),
            subTitle: subTitle,
            language: language,
            coverUrl: coverUrl,
            uuid: uuid,
            isbn: isbn,
            asin: asin,
            identifier: BuiltValueNullFieldError.checkNotNull(
                identifier, r'EbookDto', 'identifier'),
            category: category,
            author: author,
            authorUrl: authorUrl,
            authorSort: authorSort,
            publisher: publisher,
            description: description,
            favStatus: favStatus,
            pubdate: pubdate,
            rating: rating,
            publisherUrl: publisherUrl,
            countVisit: countVisit,
            countDownload: countDownload,
            progress: progress,
            progressIndex: progressIndex,
            paraPosition: paraPosition,
            atime: atime);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
