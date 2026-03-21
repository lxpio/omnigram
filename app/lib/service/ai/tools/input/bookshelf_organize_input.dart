import 'package:omnigram/service/ai/tools/input/bookshelf_organize_group_spec.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookshelf_organize_input.g.dart';
part 'bookshelf_organize_input.freezed.dart';

@freezed
abstract class BookshelfOrganizeInput with _$BookshelfOrganizeInput {
  const factory BookshelfOrganizeInput({
    required List<BookshelfOrganizeGroupSpec> groups,
    @Default(<int>[]) List<int> ungroupedBookIds,
    @Default(<int>[]) List<int> cleanupGroupIds,
    String? summary,
  }) = _BookshelfOrganizeInput;

  const BookshelfOrganizeInput._();
  factory BookshelfOrganizeInput.fromJson(Map<String, dynamic> json) =>
      _$BookshelfOrganizeInputFromJson(json);

  bool get isEmpty => groups.isEmpty && ungroupedBookIds.isEmpty;

  Iterable<int> allBookIds() sync* {
    for (final group in groups) {
      yield* group.bookIds;
    }
    yield* ungroupedBookIds;
  }
}
