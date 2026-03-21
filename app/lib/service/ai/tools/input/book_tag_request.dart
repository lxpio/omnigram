import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_tag_request.freezed.dart';
part 'book_tag_request.g.dart';

@freezed
abstract class BookTagRequest with _$BookTagRequest {
  const factory BookTagRequest({
    required String bookTitle,
    required int bookId,
    @Default(<String>[]) List<String> tags,
  }) = _BookTagRequest;

  const BookTagRequest._();

  factory BookTagRequest.fromJson(Map<String, dynamic> json) =>
      _$BookTagRequestFromJson(json);

  bool get isValid => bookId > 0 && bookTitle.trim().isNotEmpty;
}
