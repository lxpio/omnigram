import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_tag_request.freezed.dart';
part 'create_tag_request.g.dart';

@freezed
abstract class CreateTagRequest with _$CreateTagRequest {
  const factory CreateTagRequest({
    required String name,
    int? rgb,
  }) = _CreateTagRequest;

  const CreateTagRequest._();

  factory CreateTagRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTagRequestFromJson(json);

  bool get isValid => name.trim().isNotEmpty;
}
