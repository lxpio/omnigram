import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter_content_by_href_input.freezed.dart';
part 'chapter_content_by_href_input.g.dart';

@freezed
abstract class ChapterContentByHrefInput with _$ChapterContentByHrefInput {
  factory ChapterContentByHrefInput({
    required String href,
    int? maxCharacters,
  }) = _ChapterContentByHrefInput;

  factory ChapterContentByHrefInput.fromJson(Map<String, dynamic> json) =>
      _$ChapterContentByHrefInputFromJson(json);
}
