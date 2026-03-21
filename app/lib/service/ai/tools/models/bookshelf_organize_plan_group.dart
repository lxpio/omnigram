import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:omnigram/service/ai/tools/models/bookshelf_organize_plan_book.dart';

part 'bookshelf_organize_plan_group.freezed.dart';
part 'bookshelf_organize_plan_group.g.dart';

@freezed
abstract class BookshelfOrganizePlanGroup with _$BookshelfOrganizePlanGroup {
  const BookshelfOrganizePlanGroup._();

  const factory BookshelfOrganizePlanGroup({
    required int groupId,
    @Default(<BookshelfOrganizePlanBook>[])
    List<BookshelfOrganizePlanBook> books,
    required bool createNew,
    String? currentName,
    String? proposedName,
  }) = _BookshelfOrganizePlanGroup;

  factory BookshelfOrganizePlanGroup.fromJson(Map<String, dynamic> json) =>
      _$BookshelfOrganizePlanGroupFromJson(json);

  bool get willRename {
    if (proposedName == null) {
      return false;
    }
    if (currentName == null) {
      return true;
    }
    return proposedName!.trim() != currentName!.trim();
  }
}
