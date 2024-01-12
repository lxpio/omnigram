// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BookModel _$BookModelFromJson(Map<String, dynamic> json) {
  return _BookModel.fromJson(json);
}

/// @nodoc
mixin _$BookModel {
  @Id(assignable: true)
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @Unique()
  String get identifier => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  double? get progress => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_index')
  int? get progressIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'para_position')
  int? get paraPosition => throw _privateConstructorUsedError; //para position
  int? get size => throw _privateConstructorUsedError;
  String? get path => throw _privateConstructorUsedError;
  String? get ctime => throw _privateConstructorUsedError;
  String? get utime => throw _privateConstructorUsedError;
  String? get pubdate => throw _privateConstructorUsedError;
  int? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'sub_title')
  String? get subTitle => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_url')
  String? get coverUrl => throw _privateConstructorUsedError;
  String? get uuid => throw _privateConstructorUsedError;
  String? get isbn => throw _privateConstructorUsedError;
  String? get asin => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_url')
  String? get authorUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_sort')
  String? get authorSort => throw _privateConstructorUsedError;
  String? get publisher => throw _privateConstructorUsedError;
  String? get description =>
      throw _privateConstructorUsedError; // List<dynamic>? tags,
  String? get series => throw _privateConstructorUsedError;
  @JsonKey(name: 'series_index')
  String? get seriesIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'publisher_url')
  String? get publisherUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'count_visit')
  int? get countVisit => throw _privateConstructorUsedError;
  @JsonKey(name: 'count_download')
  int? get countDownload => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookModelCopyWith<BookModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookModelCopyWith<$Res> {
  factory $BookModelCopyWith(BookModel value, $Res Function(BookModel) then) =
      _$BookModelCopyWithImpl<$Res, BookModel>;
  @useResult
  $Res call(
      {@Id(assignable: true) int id,
      String title,
      @Unique() String identifier,
      String author,
      double? progress,
      @JsonKey(name: 'progress_index') int? progressIndex,
      @JsonKey(name: 'para_position') int? paraPosition,
      int? size,
      String? path,
      String? ctime,
      String? utime,
      String? pubdate,
      int? rating,
      @JsonKey(name: 'sub_title') String? subTitle,
      String? language,
      @JsonKey(name: 'cover_url') String? coverUrl,
      String? uuid,
      String? isbn,
      String? asin,
      @JsonKey(name: 'author_url') String? authorUrl,
      @JsonKey(name: 'author_sort') String? authorSort,
      String? publisher,
      String? description,
      String? series,
      @JsonKey(name: 'series_index') String? seriesIndex,
      @JsonKey(name: 'publisher_url') String? publisherUrl,
      @JsonKey(name: 'count_visit') int? countVisit,
      @JsonKey(name: 'count_download') int? countDownload});
}

/// @nodoc
class _$BookModelCopyWithImpl<$Res, $Val extends BookModel>
    implements $BookModelCopyWith<$Res> {
  _$BookModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? identifier = null,
    Object? author = null,
    Object? progress = freezed,
    Object? progressIndex = freezed,
    Object? paraPosition = freezed,
    Object? size = freezed,
    Object? path = freezed,
    Object? ctime = freezed,
    Object? utime = freezed,
    Object? pubdate = freezed,
    Object? rating = freezed,
    Object? subTitle = freezed,
    Object? language = freezed,
    Object? coverUrl = freezed,
    Object? uuid = freezed,
    Object? isbn = freezed,
    Object? asin = freezed,
    Object? authorUrl = freezed,
    Object? authorSort = freezed,
    Object? publisher = freezed,
    Object? description = freezed,
    Object? series = freezed,
    Object? seriesIndex = freezed,
    Object? publisherUrl = freezed,
    Object? countVisit = freezed,
    Object? countDownload = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double?,
      progressIndex: freezed == progressIndex
          ? _value.progressIndex
          : progressIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      paraPosition: freezed == paraPosition
          ? _value.paraPosition
          : paraPosition // ignore: cast_nullable_to_non_nullable
              as int?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      ctime: freezed == ctime
          ? _value.ctime
          : ctime // ignore: cast_nullable_to_non_nullable
              as String?,
      utime: freezed == utime
          ? _value.utime
          : utime // ignore: cast_nullable_to_non_nullable
              as String?,
      pubdate: freezed == pubdate
          ? _value.pubdate
          : pubdate // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      subTitle: freezed == subTitle
          ? _value.subTitle
          : subTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      coverUrl: freezed == coverUrl
          ? _value.coverUrl
          : coverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      uuid: freezed == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String?,
      isbn: freezed == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String?,
      asin: freezed == asin
          ? _value.asin
          : asin // ignore: cast_nullable_to_non_nullable
              as String?,
      authorUrl: freezed == authorUrl
          ? _value.authorUrl
          : authorUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorSort: freezed == authorSort
          ? _value.authorSort
          : authorSort // ignore: cast_nullable_to_non_nullable
              as String?,
      publisher: freezed == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      series: freezed == series
          ? _value.series
          : series // ignore: cast_nullable_to_non_nullable
              as String?,
      seriesIndex: freezed == seriesIndex
          ? _value.seriesIndex
          : seriesIndex // ignore: cast_nullable_to_non_nullable
              as String?,
      publisherUrl: freezed == publisherUrl
          ? _value.publisherUrl
          : publisherUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      countVisit: freezed == countVisit
          ? _value.countVisit
          : countVisit // ignore: cast_nullable_to_non_nullable
              as int?,
      countDownload: freezed == countDownload
          ? _value.countDownload
          : countDownload // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookModelImplCopyWith<$Res>
    implements $BookModelCopyWith<$Res> {
  factory _$$BookModelImplCopyWith(
          _$BookModelImpl value, $Res Function(_$BookModelImpl) then) =
      __$$BookModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@Id(assignable: true) int id,
      String title,
      @Unique() String identifier,
      String author,
      double? progress,
      @JsonKey(name: 'progress_index') int? progressIndex,
      @JsonKey(name: 'para_position') int? paraPosition,
      int? size,
      String? path,
      String? ctime,
      String? utime,
      String? pubdate,
      int? rating,
      @JsonKey(name: 'sub_title') String? subTitle,
      String? language,
      @JsonKey(name: 'cover_url') String? coverUrl,
      String? uuid,
      String? isbn,
      String? asin,
      @JsonKey(name: 'author_url') String? authorUrl,
      @JsonKey(name: 'author_sort') String? authorSort,
      String? publisher,
      String? description,
      String? series,
      @JsonKey(name: 'series_index') String? seriesIndex,
      @JsonKey(name: 'publisher_url') String? publisherUrl,
      @JsonKey(name: 'count_visit') int? countVisit,
      @JsonKey(name: 'count_download') int? countDownload});
}

/// @nodoc
class __$$BookModelImplCopyWithImpl<$Res>
    extends _$BookModelCopyWithImpl<$Res, _$BookModelImpl>
    implements _$$BookModelImplCopyWith<$Res> {
  __$$BookModelImplCopyWithImpl(
      _$BookModelImpl _value, $Res Function(_$BookModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? identifier = null,
    Object? author = null,
    Object? progress = freezed,
    Object? progressIndex = freezed,
    Object? paraPosition = freezed,
    Object? size = freezed,
    Object? path = freezed,
    Object? ctime = freezed,
    Object? utime = freezed,
    Object? pubdate = freezed,
    Object? rating = freezed,
    Object? subTitle = freezed,
    Object? language = freezed,
    Object? coverUrl = freezed,
    Object? uuid = freezed,
    Object? isbn = freezed,
    Object? asin = freezed,
    Object? authorUrl = freezed,
    Object? authorSort = freezed,
    Object? publisher = freezed,
    Object? description = freezed,
    Object? series = freezed,
    Object? seriesIndex = freezed,
    Object? publisherUrl = freezed,
    Object? countVisit = freezed,
    Object? countDownload = freezed,
  }) {
    return _then(_$BookModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      identifier: null == identifier
          ? _value.identifier
          : identifier // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double?,
      progressIndex: freezed == progressIndex
          ? _value.progressIndex
          : progressIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      paraPosition: freezed == paraPosition
          ? _value.paraPosition
          : paraPosition // ignore: cast_nullable_to_non_nullable
              as int?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      ctime: freezed == ctime
          ? _value.ctime
          : ctime // ignore: cast_nullable_to_non_nullable
              as String?,
      utime: freezed == utime
          ? _value.utime
          : utime // ignore: cast_nullable_to_non_nullable
              as String?,
      pubdate: freezed == pubdate
          ? _value.pubdate
          : pubdate // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      subTitle: freezed == subTitle
          ? _value.subTitle
          : subTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      coverUrl: freezed == coverUrl
          ? _value.coverUrl
          : coverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      uuid: freezed == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String?,
      isbn: freezed == isbn
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String?,
      asin: freezed == asin
          ? _value.asin
          : asin // ignore: cast_nullable_to_non_nullable
              as String?,
      authorUrl: freezed == authorUrl
          ? _value.authorUrl
          : authorUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorSort: freezed == authorSort
          ? _value.authorSort
          : authorSort // ignore: cast_nullable_to_non_nullable
              as String?,
      publisher: freezed == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      series: freezed == series
          ? _value.series
          : series // ignore: cast_nullable_to_non_nullable
              as String?,
      seriesIndex: freezed == seriesIndex
          ? _value.seriesIndex
          : seriesIndex // ignore: cast_nullable_to_non_nullable
              as String?,
      publisherUrl: freezed == publisherUrl
          ? _value.publisherUrl
          : publisherUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      countVisit: freezed == countVisit
          ? _value.countVisit
          : countVisit // ignore: cast_nullable_to_non_nullable
              as int?,
      countDownload: freezed == countDownload
          ? _value.countDownload
          : countDownload // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@Entity(realClass: BookModel)
class _$BookModelImpl extends _BookModel {
  const _$BookModelImpl(
      {@Id(assignable: true) this.id = 0,
      required this.title,
      @Unique() required this.identifier,
      required this.author,
      this.progress,
      @JsonKey(name: 'progress_index') this.progressIndex,
      @JsonKey(name: 'para_position') this.paraPosition,
      this.size,
      this.path,
      this.ctime,
      this.utime,
      this.pubdate,
      this.rating,
      @JsonKey(name: 'sub_title') this.subTitle,
      this.language,
      @JsonKey(name: 'cover_url') this.coverUrl,
      this.uuid,
      this.isbn,
      this.asin,
      @JsonKey(name: 'author_url') this.authorUrl,
      @JsonKey(name: 'author_sort') this.authorSort,
      this.publisher,
      this.description,
      this.series,
      @JsonKey(name: 'series_index') this.seriesIndex,
      @JsonKey(name: 'publisher_url') this.publisherUrl,
      @JsonKey(name: 'count_visit') this.countVisit,
      @JsonKey(name: 'count_download') this.countDownload})
      : super._();

  factory _$BookModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookModelImplFromJson(json);

  @override
  @JsonKey()
  @Id(assignable: true)
  final int id;
  @override
  final String title;
  @override
  @Unique()
  final String identifier;
  @override
  final String author;
  @override
  final double? progress;
  @override
  @JsonKey(name: 'progress_index')
  final int? progressIndex;
  @override
  @JsonKey(name: 'para_position')
  final int? paraPosition;
//para position
  @override
  final int? size;
  @override
  final String? path;
  @override
  final String? ctime;
  @override
  final String? utime;
  @override
  final String? pubdate;
  @override
  final int? rating;
  @override
  @JsonKey(name: 'sub_title')
  final String? subTitle;
  @override
  final String? language;
  @override
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @override
  final String? uuid;
  @override
  final String? isbn;
  @override
  final String? asin;
  @override
  @JsonKey(name: 'author_url')
  final String? authorUrl;
  @override
  @JsonKey(name: 'author_sort')
  final String? authorSort;
  @override
  final String? publisher;
  @override
  final String? description;
// List<dynamic>? tags,
  @override
  final String? series;
  @override
  @JsonKey(name: 'series_index')
  final String? seriesIndex;
  @override
  @JsonKey(name: 'publisher_url')
  final String? publisherUrl;
  @override
  @JsonKey(name: 'count_visit')
  final int? countVisit;
  @override
  @JsonKey(name: 'count_download')
  final int? countDownload;

  @override
  String toString() {
    return 'BookModel(id: $id, title: $title, identifier: $identifier, author: $author, progress: $progress, progressIndex: $progressIndex, paraPosition: $paraPosition, size: $size, path: $path, ctime: $ctime, utime: $utime, pubdate: $pubdate, rating: $rating, subTitle: $subTitle, language: $language, coverUrl: $coverUrl, uuid: $uuid, isbn: $isbn, asin: $asin, authorUrl: $authorUrl, authorSort: $authorSort, publisher: $publisher, description: $description, series: $series, seriesIndex: $seriesIndex, publisherUrl: $publisherUrl, countVisit: $countVisit, countDownload: $countDownload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.identifier, identifier) ||
                other.identifier == identifier) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.progressIndex, progressIndex) ||
                other.progressIndex == progressIndex) &&
            (identical(other.paraPosition, paraPosition) ||
                other.paraPosition == paraPosition) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.ctime, ctime) || other.ctime == ctime) &&
            (identical(other.utime, utime) || other.utime == utime) &&
            (identical(other.pubdate, pubdate) || other.pubdate == pubdate) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.subTitle, subTitle) ||
                other.subTitle == subTitle) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.asin, asin) || other.asin == asin) &&
            (identical(other.authorUrl, authorUrl) ||
                other.authorUrl == authorUrl) &&
            (identical(other.authorSort, authorSort) ||
                other.authorSort == authorSort) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.series, series) || other.series == series) &&
            (identical(other.seriesIndex, seriesIndex) ||
                other.seriesIndex == seriesIndex) &&
            (identical(other.publisherUrl, publisherUrl) ||
                other.publisherUrl == publisherUrl) &&
            (identical(other.countVisit, countVisit) ||
                other.countVisit == countVisit) &&
            (identical(other.countDownload, countDownload) ||
                other.countDownload == countDownload));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        identifier,
        author,
        progress,
        progressIndex,
        paraPosition,
        size,
        path,
        ctime,
        utime,
        pubdate,
        rating,
        subTitle,
        language,
        coverUrl,
        uuid,
        isbn,
        asin,
        authorUrl,
        authorSort,
        publisher,
        description,
        series,
        seriesIndex,
        publisherUrl,
        countVisit,
        countDownload
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookModelImplCopyWith<_$BookModelImpl> get copyWith =>
      __$$BookModelImplCopyWithImpl<_$BookModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookModelImplToJson(
      this,
    );
  }
}

abstract class _BookModel extends BookModel {
  const factory _BookModel(
          {@Id(assignable: true) final int id,
          required final String title,
          @Unique() required final String identifier,
          required final String author,
          final double? progress,
          @JsonKey(name: 'progress_index') final int? progressIndex,
          @JsonKey(name: 'para_position') final int? paraPosition,
          final int? size,
          final String? path,
          final String? ctime,
          final String? utime,
          final String? pubdate,
          final int? rating,
          @JsonKey(name: 'sub_title') final String? subTitle,
          final String? language,
          @JsonKey(name: 'cover_url') final String? coverUrl,
          final String? uuid,
          final String? isbn,
          final String? asin,
          @JsonKey(name: 'author_url') final String? authorUrl,
          @JsonKey(name: 'author_sort') final String? authorSort,
          final String? publisher,
          final String? description,
          final String? series,
          @JsonKey(name: 'series_index') final String? seriesIndex,
          @JsonKey(name: 'publisher_url') final String? publisherUrl,
          @JsonKey(name: 'count_visit') final int? countVisit,
          @JsonKey(name: 'count_download') final int? countDownload}) =
      _$BookModelImpl;
  const _BookModel._() : super._();

  factory _BookModel.fromJson(Map<String, dynamic> json) =
      _$BookModelImpl.fromJson;

  @override
  @Id(assignable: true)
  int get id;
  @override
  String get title;
  @override
  @Unique()
  String get identifier;
  @override
  String get author;
  @override
  double? get progress;
  @override
  @JsonKey(name: 'progress_index')
  int? get progressIndex;
  @override
  @JsonKey(name: 'para_position')
  int? get paraPosition;
  @override //para position
  int? get size;
  @override
  String? get path;
  @override
  String? get ctime;
  @override
  String? get utime;
  @override
  String? get pubdate;
  @override
  int? get rating;
  @override
  @JsonKey(name: 'sub_title')
  String? get subTitle;
  @override
  String? get language;
  @override
  @JsonKey(name: 'cover_url')
  String? get coverUrl;
  @override
  String? get uuid;
  @override
  String? get isbn;
  @override
  String? get asin;
  @override
  @JsonKey(name: 'author_url')
  String? get authorUrl;
  @override
  @JsonKey(name: 'author_sort')
  String? get authorSort;
  @override
  String? get publisher;
  @override
  String? get description;
  @override // List<dynamic>? tags,
  String? get series;
  @override
  @JsonKey(name: 'series_index')
  String? get seriesIndex;
  @override
  @JsonKey(name: 'publisher_url')
  String? get publisherUrl;
  @override
  @JsonKey(name: 'count_visit')
  int? get countVisit;
  @override
  @JsonKey(name: 'count_download')
  int? get countDownload;
  @override
  @JsonKey(ignore: true)
  _$$BookModelImplCopyWith<_$BookModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
