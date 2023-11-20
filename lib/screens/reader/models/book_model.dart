import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:objectbox/objectbox.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

@freezed
class BookModel with _$BookModel {
  @Entity(realClass: BookModel)
  const factory BookModel({
    @Id(assignable: true) @Default(0) int id,
    required String title,
    @Unique() required String identifier,
    required String author,
    double? progress,
    @JsonKey(name: 'chapter_pos') String? chapterPos,
    int? size,
    String? path,
    String? ctime,
    String? utime,
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
    // List<dynamic>? tags,
    String? series,
    @JsonKey(name: 'series_index') String? seriesIndex,
    String? pubdate,
    int? rating,
    @JsonKey(name: 'publisher_url') String? publisherUrl,
    @JsonKey(name: 'count_visit') int? countVisit,
    @JsonKey(name: 'count_download') int? countDownload,
  }) = _BookModel;

  factory BookModel.fromJson(Map<String, Object?> json) =>
      _$BookModelFromJson(json);

  const BookModel._();

  String get image => (coverUrl?.isNotEmpty ?? false)
      ? "/book/covers/$identifier$coverUrl"
      : "";
}
