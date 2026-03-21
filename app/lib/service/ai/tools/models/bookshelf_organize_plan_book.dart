import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookshelf_organize_plan_book.freezed.dart';
part 'bookshelf_organize_plan_book.g.dart';

@freezed
abstract class BookshelfOrganizePlanBook with _$BookshelfOrganizePlanBook {
  const BookshelfOrganizePlanBook._();

  const factory BookshelfOrganizePlanBook({
    required int bookId,
    required String title,
    String? author,
    int? previousGroupId,
  }) = _BookshelfOrganizePlanBook;

  factory BookshelfOrganizePlanBook.fromJson(Map<String, dynamic> json) =>
      _$BookshelfOrganizePlanBookFromJson(json);
}
