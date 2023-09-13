import 'package:objectbox/objectbox.dart';

@Entity()
class Book {
  @Id()
  int id;

  int? size;
  String? path;
  String? ctime;
  String? utime;
  String title;
  String? subTitle;
  String? language;
  String? coverUrl;
  String? uuid;
  String? isbn;
  String? asin;

  @Unique()
  String identifier;
  String author;
  String? authorUrl;
  String? authorSort;
  String? publisher;
  String? description;
  // List<dynamic>? tags;
  String? series;
  String? seriesIndex;
  String? pubdate;
  int? rating;
  String? publisherUrl;
  int? countVisit;
  int? countDownload;

  Book({
    required this.id,
    this.size,
    this.path,
    this.ctime,
    this.utime,
    this.title = '',
    this.subTitle,
    this.language,
    this.coverUrl,
    this.uuid,
    this.isbn,
    this.asin,
    this.identifier = '',
    this.author = '',
    this.authorUrl,
    this.authorSort,
    this.publisher,
    this.description,
    // this.tags,
    this.series,
    this.seriesIndex,
    this.pubdate,
    this.rating,
    this.publisherUrl,
    this.countVisit,
    this.countDownload,
  });

  get isDownloaded => path == null || path!.isEmpty ? false : true;

  String get image => "assets/images/logo-green.png";

  // get image =>
  //     "/book/covers/${this.identifier}/${this.coverUrl ?? 'default_cover_url'}";

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as int,
        size: json['size'] as int?,
        path: json['path'] as String?,
        ctime: json['ctime'] as String?,
        utime: json['utime'] as String?,
        title: json['title'] as String,
        subTitle: json['sub_title'] as String?,
        language: json['language'] as String?,
        coverUrl: json['cover_url'] as String?,
        uuid: json['uuid'] as String?,
        isbn: json['isbn'] as String?,
        asin: json['asin'] as String?,
        identifier: json['identifier'] as String,
        author: json['author'] as String,
        authorUrl: json['author_url'] as String?,
        authorSort: json['author_sort'] as String?,
        publisher: json['publisher'] as String?,
        description: json['description'] as String?,
        // tags: json['tags'] as List<dynamic>?,
        series: json['series'] as String?,
        seriesIndex: json['series_index'] as String?,
        pubdate: json['pubdate'] as String?,
        rating: json['rating'] as int?,
        publisherUrl: json['publisher_url'] as String?,
        countVisit: json['count_visit'] as int?,
        countDownload: json['count_download'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'size': size,
        'path': path,
        'ctime': ctime,
        'utime': utime,
        'title': title,
        'sub_title': subTitle,
        'language': language,
        'cover_url': coverUrl,
        'uuid': uuid,
        'isbn': isbn,
        'asin': asin,
        'identifier': identifier,
        'author': author,
        'author_url': authorUrl,
        'author_sort': authorSort,
        'publisher': publisher,
        'description': description,
        // 'tags': tags,
        'series': series,
        'series_index': seriesIndex,
        'pubdate': pubdate,
        'rating': rating,
        'publisher_url': publisherUrl,
        'count_visit': countVisit,
        'count_download': countDownload,
      };
}
