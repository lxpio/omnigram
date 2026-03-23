import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_annotation.freezed.dart';
part 'server_annotation.g.dart';

@freezed
abstract class ServerAnnotation with _$ServerAnnotation {
  const factory ServerAnnotation({
    @Default(0) int id,
    @JsonKey(name: 'user_id') @Default(0) int userId,
    @JsonKey(name: 'book_id') @Default('') String bookId,
    @JsonKey(name: 'device_id') String? deviceId,
    String? chapter,
    @Default('') String content,
    @JsonKey(name: 'selected_text') String? selectedText,
    String? cfi,
    @JsonKey(name: 'page_number') @Default(0) int pageNumber,
    String? position,
    String? color,
    @Default('highlight') String type,
    @Default(0) @JsonKey(name: 'ctime') int cTime,
    @Default(0) @JsonKey(name: 'utime') int uTime,
  }) = _ServerAnnotation;

  factory ServerAnnotation.fromJson(Map<String, dynamic> json) => _$ServerAnnotationFromJson(json);
}
