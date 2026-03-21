import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_tag_request.freezed.dart';
part 'update_tag_request.g.dart';

@freezed
abstract class UpdateTagRequest with _$UpdateTagRequest {
  const factory UpdateTagRequest({
    required int id,
    String? name,
    int? rgb,
  }) = _UpdateTagRequest;

  const UpdateTagRequest._();

  factory UpdateTagRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTagRequestFromJson(json);

  bool get isValid => id > 0;
}
