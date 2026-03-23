import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_shelf.freezed.dart';
part 'server_shelf.g.dart';

@freezed
abstract class ServerShelf with _$ServerShelf {
  const factory ServerShelf({
    @Default(0) int id,
    @JsonKey(name: 'user_id') @Default(0) int userId,
    @Default('') String name,
    String? description,
    @JsonKey(name: 'cover_url') String? coverUrl,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'book_count') @Default(0) int bookCount,
    @Default(0) @JsonKey(name: 'ctime') int cTime,
    @Default(0) @JsonKey(name: 'utime') int uTime,
  }) = _ServerShelf;

  factory ServerShelf.fromJson(Map<String, dynamic> json) => _$ServerShelfFromJson(json);
}
