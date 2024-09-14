// ignore_for_file: public_member_api_docs, sort_constructors_first
//
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:openapi/openapi.dart';

part 'book.entity.g.dart';

@Collection(inheritance: false)
class BookEntity {
  
  @Id()
  final int id;

  @Index(unique: false)
  final int? remoteId;

  //本地存储文件路径
  final String? localPath;

  //本地存储封面路径
  final String? coverPath;

  final int? size;

  final String? ctime;

  final String? utime;

  final String title;


  final String? subTitle;

 
  final String? language;


  final String? coverUrl;


  final String? uuid;


  final String? isbn;


  final String? asin;

  final String identifier;


  final String? category;

  
  final String? author;

  final String? authorUrl;
 
  final String? authorSort;

  final String? publisher;

  final String? description;

  final String? pubdate;

  final double? rating;

  final String? publisherUrl;

  final bool favStatus;

  final int? countVisit;

  final int? countDownload;

  final double? progress;

  final int? progressIndex;

  final int? paraPosition;

  BookEntity({
    required this.id,
    this.remoteId,
    this.localPath,
    this.coverPath,
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
    this.pubdate,
    this.rating,
    this.publisherUrl,
    required this.favStatus,
    this.countVisit,
    this.countDownload,
    this.progress,
    this.progressIndex,
    this.paraPosition,
  });

  
 

  BookEntity copyWith({
    int? id,
    int? remoteId,
    String? localPath,
    String? coverPath,
    int? size,
    String? ctime,
    String? utime,
    String? title,
    String? subTitle,
    String? language,
    String? coverUrl,
    String? uuid,
    String? isbn,
    String? asin,
    String? identifier,
    String? category,
    String? author,
    String? authorUrl,
    String? authorSort,
    String? publisher,
    String? description,
    String? pubdate,
    double? rating,
    String? publisherUrl,
    bool? favStatus,
    int? countVisit,
    int? countDownload,
    double? progress,
    int? progressIndex,
    int? paraPosition,
  }) {
    return BookEntity(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      localPath: localPath ?? this.localPath,
      coverPath: coverPath ?? this.coverPath,
      size: size ?? this.size,
      ctime: ctime ?? this.ctime,
      utime: utime ?? this.utime,
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      language: language ?? this.language,
      coverUrl: coverUrl ?? this.coverUrl,
      uuid: uuid ?? this.uuid,
      isbn: isbn ?? this.isbn,
      asin: asin ?? this.asin,
      identifier: identifier ?? this.identifier,
      category: category ?? this.category,
      author: author ?? this.author,
      authorUrl: authorUrl ?? this.authorUrl,
      authorSort: authorSort ?? this.authorSort,
      publisher: publisher ?? this.publisher,
      description: description ?? this.description,
      pubdate: pubdate ?? this.pubdate,
      rating: rating ?? this.rating,
      publisherUrl: publisherUrl ?? this.publisherUrl,
      favStatus: favStatus ?? this.favStatus,
      countVisit: countVisit ?? this.countVisit,
      countDownload: countDownload ?? this.countDownload,
      progress: progress ?? this.progress,
      progressIndex: progressIndex ?? this.progressIndex,
      paraPosition: paraPosition ?? this.paraPosition,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'remoteId': remoteId,
      'localPath': localPath,
      'coverPath': coverPath,
      'size': size,
      'ctime': ctime,
      'utime': utime,
      'title': title,
      'subTitle': subTitle,
      'language': language,
      'coverUrl': coverUrl,
      'uuid': uuid,
      'isbn': isbn,
      'asin': asin,
      'identifier': identifier,
      'category': category,
      'author': author,
      'authorUrl': authorUrl,
      'authorSort': authorSort,
      'publisher': publisher,
      'description': description,
      'pubdate': pubdate,
      'rating': rating,
      'publisherUrl': publisherUrl,
      'favStatus': favStatus,
      'countVisit': countVisit,
      'countDownload': countDownload,
      'progress': progress,
      'progressIndex': progressIndex,
      'paraPosition': paraPosition,
    };
  }

  factory BookEntity.fromMap(Map<String, dynamic> map) {
    return BookEntity(
      id: map['id'] as int,
      remoteId: map['remoteId'] != null ? map['remoteId'] as int : null,
      localPath: map['localPath'] != null ? map['localPath'] as String : null,
      coverPath: map['coverPath'] != null ? map['coverPath'] as String : null,
      size: map['size'] != null ? map['size'] as int : null,
      ctime: map['ctime'] != null ? map['ctime'] as String : null,
      utime: map['utime'] != null ? map['utime'] as String : null,
      title: map['title'] as String,
      subTitle: map['subTitle'] != null ? map['subTitle'] as String : null,
      language: map['language'] != null ? map['language'] as String : null,
      coverUrl: map['coverUrl'] != null ? map['coverUrl'] as String : null,
      uuid: map['uuid'] != null ? map['uuid'] as String : null,
      isbn: map['isbn'] != null ? map['isbn'] as String : null,
      asin: map['asin'] != null ? map['asin'] as String : null,
      identifier: map['identifier'] as String,
      category: map['category'] != null ? map['category'] as String : null,
      author: map['author'] != null ? map['author'] as String : null,
      authorUrl: map['authorUrl'] != null ? map['authorUrl'] as String : null,
      authorSort: map['authorSort'] != null ? map['authorSort'] as String : null,
      publisher: map['publisher'] != null ? map['publisher'] as String : null,
      description: map['description'] != null ? map['description'] as String : null,
      pubdate: map['pubdate'] != null ? map['pubdate'] as String : null,
      rating: map['rating'] != null ? map['rating'] as double : null,
      publisherUrl: map['publisherUrl'] != null ? map['publisherUrl'] as String : null,
      favStatus: map['favStatus'] as bool,
      countVisit: map['countVisit'] != null ? map['countVisit'] as int : null,
      countDownload: map['countDownload'] != null ? map['countDownload'] as int : null,
      progress: map['progress'] != null ? map['progress'] as double : null,
      progressIndex: map['progressIndex'] != null ? map['progressIndex'] as int : null,
      paraPosition: map['paraPosition'] != null ? map['paraPosition'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BookEntity.fromJson(String source) => BookEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BookEntity(id: $id, remoteId: $remoteId, localPath: $localPath, coverPath: $coverPath, size: $size, ctime: $ctime, utime: $utime, title: $title, subTitle: $subTitle, language: $language, coverUrl: $coverUrl, uuid: $uuid, isbn: $isbn, asin: $asin, identifier: $identifier, category: $category, author: $author, authorUrl: $authorUrl, authorSort: $authorSort, publisher: $publisher, description: $description, pubdate: $pubdate, rating: $rating, publisherUrl: $publisherUrl, favStatus: $favStatus, countVisit: $countVisit, countDownload: $countDownload, progress: $progress, progressIndex: $progressIndex, paraPosition: $paraPosition)';
  }

  @override
  bool operator ==(covariant BookEntity other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.remoteId == remoteId &&
      other.localPath == localPath &&
      other.coverPath == coverPath &&
      other.size == size &&
      other.ctime == ctime &&
      other.utime == utime &&
      other.title == title &&
      other.subTitle == subTitle &&
      other.language == language &&
      other.coverUrl == coverUrl &&
      other.uuid == uuid &&
      other.isbn == isbn &&
      other.asin == asin &&
      other.identifier == identifier &&
      other.category == category &&
      other.author == author &&
      other.authorUrl == authorUrl &&
      other.authorSort == authorSort &&
      other.publisher == publisher &&
      other.description == description &&
      other.pubdate == pubdate &&
      other.rating == rating &&
      other.publisherUrl == publisherUrl &&
      other.favStatus == favStatus &&
      other.countVisit == countVisit &&
      other.countDownload == countDownload &&
      other.progress == progress &&
      other.progressIndex == progressIndex &&
      other.paraPosition == paraPosition;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      remoteId.hashCode ^
      localPath.hashCode ^
      coverPath.hashCode ^
      size.hashCode ^
      ctime.hashCode ^
      utime.hashCode ^
      title.hashCode ^
      subTitle.hashCode ^
      language.hashCode ^
      coverUrl.hashCode ^
      uuid.hashCode ^
      isbn.hashCode ^
      asin.hashCode ^
      identifier.hashCode ^
      category.hashCode ^
      author.hashCode ^
      authorUrl.hashCode ^
      authorSort.hashCode ^
      publisher.hashCode ^
      description.hashCode ^
      pubdate.hashCode ^
      rating.hashCode ^
      publisherUrl.hashCode ^
      favStatus.hashCode ^
      countVisit.hashCode ^
      countDownload.hashCode ^
      progress.hashCode ^
      progressIndex.hashCode ^
      paraPosition.hashCode;
  }


  @ignore
  bool get isLocal => localPath != null;

  @ignore
  bool get isRemote => remoteId != null;

  @ignore
  BookState get storage {
    if (isRemote && isLocal) {
      return BookState.merged;
    } else if (isRemote) {
      return BookState.remote;
    } else if (isLocal) {
      return BookState.local;
    } else {
      throw Exception("Asset has illegal state: $this");
    }
  }

  BookEntity.remote(EbookDto ebookDto)
      : id = ebookDto.id,
        remoteId = ebookDto.id,
        localPath = null,
        coverPath = null,
        size = ebookDto.size,
        ctime = ebookDto.ctime,
        utime = ebookDto.utime,
        title = ebookDto.title,
        subTitle = ebookDto.subTitle,
        language = ebookDto.language,
        coverUrl = ebookDto.coverUrl,
        uuid = ebookDto.uuid,
        isbn = ebookDto.isbn,
        asin = ebookDto.asin,
        identifier = ebookDto.identifier,
        category = ebookDto.category,
        author = ebookDto.author,
        authorUrl = ebookDto.authorUrl,
        authorSort = ebookDto.authorSort,
        publisher = ebookDto.publisher,
        description = ebookDto.description,
        favStatus = ebookDto.favStatus ?? false,
        pubdate = ebookDto.pubdate,
        rating = ebookDto.rating?.toDouble(),
        publisherUrl = ebookDto.publisherUrl,
        countVisit = ebookDto.countVisit,
        countDownload = ebookDto.countDownload,
        progress = ebookDto.progress?.toDouble(),
        progressIndex = ebookDto.progressIndex,
        paraPosition = ebookDto.paraPosition;

  void put(Isar db)  {
     db.bookEntitys.put(this);
  }

}

/// Describes where the information of this asset came from:
/// only from the local device, only from the remote server or merged from both
enum BookState {
  local,
  remote,
  merged,
}

enum BookType {
  // do not change this order!
  other,
  epub,
  pdf,
  word,
}

class BookNav {
  final List<BookEntity>? recents;
  final List<BookEntity>? randoms;
  final List<BookEntity>? readings;
  final List<BookEntity>? likes;

  const BookNav({
    required this.recents,
    required this.randoms,
    required this.readings,
    required this.likes,
  });
}
