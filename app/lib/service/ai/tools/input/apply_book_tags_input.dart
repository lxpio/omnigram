import 'package:freezed_annotation/freezed_annotation.dart';

import 'book_tag_request.dart';
import 'create_tag_request.dart';
import 'update_tag_request.dart';

part 'apply_book_tags_input.freezed.dart';
part 'apply_book_tags_input.g.dart';

@freezed
abstract class ApplyBookTagsInput with _$ApplyBookTagsInput {
  const factory ApplyBookTagsInput({
    @Default(<BookTagRequest>[]) List<BookTagRequest> books,
    @Default(<CreateTagRequest>[]) List<CreateTagRequest> createTags,
    @Default(<UpdateTagRequest>[]) List<UpdateTagRequest> updateTags,
  }) = _ApplyBookTagsInput;

  factory ApplyBookTagsInput.fromJson(Map<String, dynamic> json) =>
      _$ApplyBookTagsInputFromJson(json);
}
