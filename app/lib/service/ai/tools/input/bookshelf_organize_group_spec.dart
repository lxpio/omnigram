import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookshelf_organize_group_spec.freezed.dart';
part 'bookshelf_organize_group_spec.g.dart';

@freezed
abstract class BookshelfOrganizeGroupSpec with _$BookshelfOrganizeGroupSpec {
  const factory BookshelfOrganizeGroupSpec({
    required int groupId,
    required List<int> bookIds,
    String? name,
    bool? createNew,
    String? renameTo,
  }) = _BookshelfOrganizeGroupSpec;

  factory BookshelfOrganizeGroupSpec.fromJson(Map<String, dynamic> json) =>
      _$BookshelfOrganizeGroupSpecFromJson(json);
}
