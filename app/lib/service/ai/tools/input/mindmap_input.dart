import 'package:freezed_annotation/freezed_annotation.dart';

part 'mindmap_input.freezed.dart';
part 'mindmap_input.g.dart';

@freezed
abstract class MindmapInput with _$MindmapInput {
  const factory MindmapInput({
    required String title,
    required String hierarchicalList,
  }) = _MindmapInput;

  const MindmapInput._();

  factory MindmapInput.fromJson(Map<String, dynamic> json) =>
      _$MindmapInputFromJson(json);
}
