import 'package:freezed_annotation/freezed_annotation.dart';

part 'notes_search_input.freezed.dart';
part 'notes_search_input.g.dart';

@freezed
abstract class NotesSearchInput with _$NotesSearchInput {
  const factory NotesSearchInput({
    String? keyword,
    int? bookId,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) = _NotesSearchInput;
  const NotesSearchInput._();

  factory NotesSearchInput.fromJson(Map<String, dynamic> json) =>
      _$NotesSearchInputFromJson(json);

  int resolvedLimit([int fallback = 10]) {
    final value = limit ?? fallback;
    return value.clamp(1, 50);
  }
}
