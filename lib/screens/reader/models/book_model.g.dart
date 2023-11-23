// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BookModel _$$_BookModelFromJson(Map<String, dynamic> json) => _$_BookModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String,
      identifier: json['identifier'] as String,
      author: json['author'] as String,
      progress: (json['progress'] as num?)?.toDouble(),
      progressIndex: json['progress_index'] as int?,
      size: json['size'] as int?,
      path: json['path'] as String?,
      ctime: json['ctime'] as String?,
      utime: json['utime'] as String?,
      subTitle: json['sub_title'] as String?,
      language: json['language'] as String?,
      coverUrl: json['cover_url'] as String?,
      uuid: json['uuid'] as String?,
      isbn: json['isbn'] as String?,
      asin: json['asin'] as String?,
      authorUrl: json['author_url'] as String?,
      authorSort: json['author_sort'] as String?,
      publisher: json['publisher'] as String?,
      description: json['description'] as String?,
      series: json['series'] as String?,
      seriesIndex: json['series_index'] as String?,
      pubdate: json['pubdate'] as String?,
      rating: json['rating'] as int?,
      publisherUrl: json['publisher_url'] as String?,
      countVisit: json['count_visit'] as int?,
      countDownload: json['count_download'] as int?,
    );

Map<String, dynamic> _$$_BookModelToJson(_$_BookModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'identifier': instance.identifier,
      'author': instance.author,
      'progress': instance.progress,
      'progress_index': instance.progressIndex,
      'size': instance.size,
      'path': instance.path,
      'ctime': instance.ctime,
      'utime': instance.utime,
      'sub_title': instance.subTitle,
      'language': instance.language,
      'cover_url': instance.coverUrl,
      'uuid': instance.uuid,
      'isbn': instance.isbn,
      'asin': instance.asin,
      'author_url': instance.authorUrl,
      'author_sort': instance.authorSort,
      'publisher': instance.publisher,
      'description': instance.description,
      'series': instance.series,
      'series_index': instance.seriesIndex,
      'pubdate': instance.pubdate,
      'rating': instance.rating,
      'publisher_url': instance.publisherUrl,
      'count_visit': instance.countVisit,
      'count_download': instance.countDownload,
    };
