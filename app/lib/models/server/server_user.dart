import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_user.freezed.dart';
part 'server_user.g.dart';

@freezed
abstract class ServerUser with _$ServerUser {
  const factory ServerUser({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String email,
    @Default('') String mobile,
    @JsonKey(name: 'role_id') @Default(0) int roleId,
    @JsonKey(name: 'nick_name') @Default('') String nickName,
    @JsonKey(name: 'avatar_url') @Default('') String avatarUrl,
    @Default(false) bool locked,
    @JsonKey(name: 'mfa_switch') @Default(0) int mfaSwitch,
    @Default(0) @JsonKey(name: 'ctime') int cTime,
    @Default(0) @JsonKey(name: 'utime') int uTime,
    @Default(0) @JsonKey(name: 'atime') int aTime,
  }) = _ServerUser;

  factory ServerUser.fromJson(Map<String, dynamic> json) => _$ServerUserFromJson(json);
}
