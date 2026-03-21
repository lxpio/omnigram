import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_content_search_input.freezed.dart';
part 'book_content_search_input.g.dart';

@freezed
abstract class BookContentSearchInput with _$BookContentSearchInput {
  const factory BookContentSearchInput({
    required int bookId,
    required String keyword,
    int? maxResults,
    int? maxSnippets,
    int? maxCharacters,
  }) = _BookContentSearchInput;

  const BookContentSearchInput._();

  factory BookContentSearchInput.fromJson(Map<String, dynamic> json) =>
      _$BookContentSearchInputFromJson(json);

  int resolvedMaxResults([int fallback = 5]) {
    final value = maxResults ?? fallback;
    return value.clamp(1, 10);
  }

  int resolvedMaxSnippets([int fallback = 3]) {
    final value = maxSnippets ?? fallback;
    return value.clamp(1, 10);
  }

  int? resolvedMaxCharacters({int min = 100, int max = 2000}) {
    final value = maxCharacters;
    if (value == null) {
      return null;
    }
    if (value <= 0) {
      return null;
    }
    return value.clamp(min, max);
  }
}
