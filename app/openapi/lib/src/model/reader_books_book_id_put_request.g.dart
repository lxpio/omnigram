// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_books_book_id_put_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReaderBooksBookIdPutRequest extends ReaderBooksBookIdPutRequest {
  @override
  final String title;
  @override
  final String subTitle;
  @override
  final String language;
  @override
  final String? coverUrl;
  @override
  final String? isbn;
  @override
  final String? asin;
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
  final BuiltList<String>? tags;
  @override
  final String? pubdate;
  @override
  final num? rating;
  @override
  final String? publisherUrl;

  factory _$ReaderBooksBookIdPutRequest(
          [void Function(ReaderBooksBookIdPutRequestBuilder)? updates]) =>
      (new ReaderBooksBookIdPutRequestBuilder()..update(updates))._build();

  _$ReaderBooksBookIdPutRequest._(
      {required this.title,
      required this.subTitle,
      required this.language,
      this.coverUrl,
      this.isbn,
      this.asin,
      this.category,
      this.author,
      this.authorUrl,
      this.authorSort,
      this.publisher,
      this.description,
      this.tags,
      this.pubdate,
      this.rating,
      this.publisherUrl})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        title, r'ReaderBooksBookIdPutRequest', 'title');
    BuiltValueNullFieldError.checkNotNull(
        subTitle, r'ReaderBooksBookIdPutRequest', 'subTitle');
    BuiltValueNullFieldError.checkNotNull(
        language, r'ReaderBooksBookIdPutRequest', 'language');
  }

  @override
  ReaderBooksBookIdPutRequest rebuild(
          void Function(ReaderBooksBookIdPutRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReaderBooksBookIdPutRequestBuilder toBuilder() =>
      new ReaderBooksBookIdPutRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReaderBooksBookIdPutRequest &&
        title == other.title &&
        subTitle == other.subTitle &&
        language == other.language &&
        coverUrl == other.coverUrl &&
        isbn == other.isbn &&
        asin == other.asin &&
        category == other.category &&
        author == other.author &&
        authorUrl == other.authorUrl &&
        authorSort == other.authorSort &&
        publisher == other.publisher &&
        description == other.description &&
        tags == other.tags &&
        pubdate == other.pubdate &&
        rating == other.rating &&
        publisherUrl == other.publisherUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, subTitle.hashCode);
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, coverUrl.hashCode);
    _$hash = $jc(_$hash, isbn.hashCode);
    _$hash = $jc(_$hash, asin.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, authorUrl.hashCode);
    _$hash = $jc(_$hash, authorSort.hashCode);
    _$hash = $jc(_$hash, publisher.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jc(_$hash, pubdate.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, publisherUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReaderBooksBookIdPutRequest')
          ..add('title', title)
          ..add('subTitle', subTitle)
          ..add('language', language)
          ..add('coverUrl', coverUrl)
          ..add('isbn', isbn)
          ..add('asin', asin)
          ..add('category', category)
          ..add('author', author)
          ..add('authorUrl', authorUrl)
          ..add('authorSort', authorSort)
          ..add('publisher', publisher)
          ..add('description', description)
          ..add('tags', tags)
          ..add('pubdate', pubdate)
          ..add('rating', rating)
          ..add('publisherUrl', publisherUrl))
        .toString();
  }
}

class ReaderBooksBookIdPutRequestBuilder
    implements
        Builder<ReaderBooksBookIdPutRequest,
            ReaderBooksBookIdPutRequestBuilder> {
  _$ReaderBooksBookIdPutRequest? _$v;

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

  String? _isbn;
  String? get isbn => _$this._isbn;
  set isbn(String? isbn) => _$this._isbn = isbn;

  String? _asin;
  String? get asin => _$this._asin;
  set asin(String? asin) => _$this._asin = asin;

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

  ListBuilder<String>? _tags;
  ListBuilder<String> get tags => _$this._tags ??= new ListBuilder<String>();
  set tags(ListBuilder<String>? tags) => _$this._tags = tags;

  String? _pubdate;
  String? get pubdate => _$this._pubdate;
  set pubdate(String? pubdate) => _$this._pubdate = pubdate;

  num? _rating;
  num? get rating => _$this._rating;
  set rating(num? rating) => _$this._rating = rating;

  String? _publisherUrl;
  String? get publisherUrl => _$this._publisherUrl;
  set publisherUrl(String? publisherUrl) => _$this._publisherUrl = publisherUrl;

  ReaderBooksBookIdPutRequestBuilder() {
    ReaderBooksBookIdPutRequest._defaults(this);
  }

  ReaderBooksBookIdPutRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _subTitle = $v.subTitle;
      _language = $v.language;
      _coverUrl = $v.coverUrl;
      _isbn = $v.isbn;
      _asin = $v.asin;
      _category = $v.category;
      _author = $v.author;
      _authorUrl = $v.authorUrl;
      _authorSort = $v.authorSort;
      _publisher = $v.publisher;
      _description = $v.description;
      _tags = $v.tags?.toBuilder();
      _pubdate = $v.pubdate;
      _rating = $v.rating;
      _publisherUrl = $v.publisherUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReaderBooksBookIdPutRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ReaderBooksBookIdPutRequest;
  }

  @override
  void update(void Function(ReaderBooksBookIdPutRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReaderBooksBookIdPutRequest build() => _build();

  _$ReaderBooksBookIdPutRequest _build() {
    _$ReaderBooksBookIdPutRequest _$result;
    try {
      _$result = _$v ??
          new _$ReaderBooksBookIdPutRequest._(
              title: BuiltValueNullFieldError.checkNotNull(
                  title, r'ReaderBooksBookIdPutRequest', 'title'),
              subTitle: BuiltValueNullFieldError.checkNotNull(
                  subTitle, r'ReaderBooksBookIdPutRequest', 'subTitle'),
              language: BuiltValueNullFieldError.checkNotNull(
                  language, r'ReaderBooksBookIdPutRequest', 'language'),
              coverUrl: coverUrl,
              isbn: isbn,
              asin: asin,
              category: category,
              author: author,
              authorUrl: authorUrl,
              authorSort: authorSort,
              publisher: publisher,
              description: description,
              tags: _tags?.build(),
              pubdate: pubdate,
              rating: rating,
              publisherUrl: publisherUrl);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tags';
        _tags?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ReaderBooksBookIdPutRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
