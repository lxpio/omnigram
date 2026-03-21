import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_time_input.freezed.dart';
part 'current_time_input.g.dart';

@freezed
abstract class CurrentTimeInput with _$CurrentTimeInput {
  const factory CurrentTimeInput({
    @Default(true) bool includeTimezone,
  }) = _CurrentTimeInput;
  const CurrentTimeInput._();

  factory CurrentTimeInput.fromJson(Map<String, dynamic> json) =>
      _$CurrentTimeInputFromJson(json);
}
