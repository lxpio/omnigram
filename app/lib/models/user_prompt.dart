import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_prompt.freezed.dart';
part 'user_prompt.g.dart';

@freezed
abstract class UserPrompt with _$UserPrompt {
  const UserPrompt._();

  const factory UserPrompt({
    required String id, // ID generated from millisecondsSinceEpoch
    required String name, // Prompt name
    required String content, // Prompt content
    @Default(true) bool enabled, // Whether the prompt is enabled
    required int order, // Display order
    required DateTime createdAt, // Creation time
    required DateTime updatedAt, // Last update time
  }) = _UserPrompt;

  factory UserPrompt.fromJson(Map<String, dynamic> json) =>
      _$UserPromptFromJson(json);
}
