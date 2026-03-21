import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_history_input.freezed.dart';
part 'reading_history_input.g.dart';

@freezed
abstract class ReadingHistoryInput with _$ReadingHistoryInput {
  const factory ReadingHistoryInput({
    int? bookId,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) = _ReadingHistoryInput;
  const ReadingHistoryInput._();

  factory ReadingHistoryInput.fromJson(Map<String, dynamic> json) =>
      _$ReadingHistoryInputFromJson(json);

  int resolvedLimit([int fallback = 20]) => (limit ?? fallback).clamp(1, 100);
}
