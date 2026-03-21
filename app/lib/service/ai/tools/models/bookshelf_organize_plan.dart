import 'package:omnigram/service/ai/tools/models/bookshelf_organize_plan_book.dart';
import 'package:omnigram/service/ai/tools/models/bookshelf_organize_plan_group.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookshelf_organize_plan.freezed.dart';
part 'bookshelf_organize_plan.g.dart';

@freezed
abstract class BookshelfOrganizePlan with _$BookshelfOrganizePlan {
  const BookshelfOrganizePlan._();

  const factory BookshelfOrganizePlan({
    @Default(<BookshelfOrganizePlanGroup>[])
    List<BookshelfOrganizePlanGroup> groups,
    @Default(<BookshelfOrganizePlanBook>[])
    List<BookshelfOrganizePlanBook> ungroupedBooks,
    @Default(<int>[]) List<int> cleanupGroupIds,
    String? summary,
  }) = _BookshelfOrganizePlan;

  factory BookshelfOrganizePlan.fromJson(Map<String, dynamic> json) =>
      _$BookshelfOrganizePlanFromJson(json);

  Iterable<int> get affectedBookIds sync* {
    for (final group in groups) {
      yield* group.books.map((book) => book.bookId);
    }
    yield* ungroupedBooks.map((book) => book.bookId);
  }
}
