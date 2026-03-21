import 'package:omnigram/models/book.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_reading_state.freezed.dart';

@freezed
abstract class CurrentReadingState with _$CurrentReadingState {
  const factory CurrentReadingState({
    @Default(false) bool isReading,
    Book? book,
    String? cfi,
    double? percentage,
    String? chapterTitle,
    String? chapterHref,
    int? chapterCurrentPage,
    int? chapterTotalPages,
  }) = _CurrentReadingState;
}
