import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_book.freezed.dart';
part 'server_book.g.dart';

@freezed
abstract class ServerBook with _$ServerBook {
  const factory ServerBook({
    required String id,
    @Default(0) int size,
    @Default(0) @JsonKey(name: 'ctime') int cTime,
    @Default(0) @JsonKey(name: 'utime') int uTime,
    @Default('') String title,
    @JsonKey(name: 'sub_title') String? subTitle,
    @Default('') String language,
    @JsonKey(name: 'cover_url') @Default('') String coverUrl,
    @Default('') String uuid,
    @Default('') String isbn,
    @Default('') String asin,
    @Default('') String identifier,
    @Default('') String category,
    @Default('') String author,
    @JsonKey(name: 'author_url') @Default('') String authorUrl,
    @JsonKey(name: 'author_sort') @Default('') String authorSort,
    @Default('') String publisher,
    String? description,
    @JsonKey(name: 'file_type') @Default('') String fileType,
    String? series,
    @JsonKey(name: 'series_index') String? seriesIndex,
    @JsonKey(name: 'pubdate') @Default('') String publishDate,
    @Default(0.0) double rating,
    @Default([]) List<String> tags,
    @JsonKey(name: 'publisher_url') @Default('') String publisherUrl,
    @JsonKey(name: 'count_visit') @Default(0) int countVisit,
    @JsonKey(name: 'count_download') @Default(0) int countDownload,
  }) = _ServerBook;

  factory ServerBook.fromJson(Map<String, dynamic> json) => _$ServerBookFromJson(json);
}

@freezed
abstract class ServerBookResp with _$ServerBookResp {
  const factory ServerBookResp({@Default(0) int total, @Default([]) List<ServerBook> books}) = _ServerBookResp;

  factory ServerBookResp.fromJson(Map<String, dynamic> json) => _$ServerBookRespFromJson(json);
}

@freezed
abstract class ServerBookStats with _$ServerBookStats {
  const factory ServerBookStats({
    @Default(0) int total,
    @Default(0) int author,
    @Default(0) int publisher,
    @Default(0) int tag,
  }) = _ServerBookStats;

  factory ServerBookStats.fromJson(Map<String, dynamic> json) => _$ServerBookStatsFromJson(json);
}

@freezed
abstract class ServerProgressBook with _$ServerProgressBook {
  const factory ServerProgressBook({
    required String id,
    @Default('') String title,
    @Default('') String author,
    @JsonKey(name: 'cover_url') @Default('') String coverUrl,
    @Default(0.0) double progress,
    @JsonKey(name: 'progress_index') @Default(0) int progressIndex,
    @JsonKey(name: 'para_position') @Default(0) int paraPosition,
  }) = _ServerProgressBook;

  factory ServerProgressBook.fromJson(Map<String, dynamic> json) => _$ServerProgressBookFromJson(json);
}
