import 'dart:ui';

import 'package:isar/isar.dart';
import 'package:openapi/openapi.dart';


part 'user.entity.g.dart';

@Collection(inheritance: false)
class User {
  User({
    required this.id,
    required this.updatedAt,
    required this.name,
    required this.roleId,
    this.email = '',
    this.mobile = '',
    this.nickName = '',
    this.avatarUrl,
    required this.locked,
    required this.mfaSwitch,
    this.profileImagePath = '',
    this.avatarColor = AvatarColorEnum.primary,

  });


  bool get isAdmin => roleId == 1;


  User.fromUserDto(
    UserDto dto,
    // UserPreferencesResponseDto? preferences,
  )   : id = dto.id,
        updatedAt = DateTime.fromMillisecondsSinceEpoch(dto.utime,isUtc: true),
        email = dto.email ?? '',
        name = dto.name, 
        nickName  = dto.nickName ?? '',
        mobile = dto.mobile ?? '',
        avatarUrl = dto.avatarUrl ?? '',
        locked = dto.locked,
        mfaSwitch = dto.mfaSwitch,
        roleId = dto.roleId,
        profileImagePath = '',
        avatarColor = AvatarColorEnum.primary ; //dto.avatarColor.toAvatarColor()
        

  // User.fromPartnerDto(PartnerResponseDto dto)
  //     : id = dto.id,
  //       updatedAt = DateTime.now(),
  //       email = dto.email,
  //       name = dto.name,
  //       isPartnerSharedBy = false,
  //       isPartnerSharedWith = false,
  //       profileImagePath = dto.profileImagePath,
  //       isAdmin = false,
  //       memoryEnabled = false,
  //       avatarColor = dto.avatarColor.toAvatarColor(),
  //       inTimeline = dto.inTimeline ?? false,
  //       quotaUsageInBytes = 0,
  //       quotaSizeInBytes = 0;

  /// Base user dto used where the complete user object is not required
  // User.fromSimpleUserDto(UserDto dto)
  //     : id = dto.id,
  //       email = dto.email,
  //       name = dto.name,
  //       profileImagePath = dto.profileImagePath,
  //       avatarColor = dto.avatarColor.toAvatarColor(),
  //       // Fill the remaining fields with placeholders
  //       isAdmin = false,
  //       inTimeline = false,
  //       memoryEnabled = false,
  //       isPartnerSharedBy = false,
  //       isPartnerSharedWith = false,
  //       updatedAt = DateTime.now(),
  //       quotaUsageInBytes = 0,
  //       quotaSizeInBytes = 0;

  // @Index(unique: true, replace: false, type: IndexType.hash)
  int id;
  DateTime updatedAt;
  String email;
  String name;
  String nickName;
  String? avatarUrl;
  bool locked;
  int mfaSwitch;
  int roleId;
  String mobile;
  String profileImagePath;
  AvatarColorEnum avatarColor;

  @override
  bool operator ==(other) {
    if (other is! User) return false;
    return id == other.id &&
        updatedAt.isAtSameMomentAs(other.updatedAt) &&
        avatarColor == other.avatarColor &&
        email == other.email &&
        name == other.name &&
        nickName == other.nickName &&
        avatarUrl == other.avatarUrl &&
        locked == other.locked &&
        mfaSwitch == other.mfaSwitch &&
        roleId == other.roleId &&
        mobile == other.mobile &&
        profileImagePath == other.profileImagePath ;
        
  }

  @override
  @ignore
  int get hashCode =>
      id.hashCode ^
      updatedAt.hashCode ^
      email.hashCode ^
      name.hashCode ^
      nickName.hashCode ^
      avatarUrl.hashCode ^
      locked.hashCode ^
      mfaSwitch.hashCode ^
      roleId.hashCode ^
      mobile.hashCode ^
      profileImagePath.hashCode ^
      avatarColor.hashCode ;
}

enum AvatarColorEnum {
  // do not change this order or reuse indices for other purposes, adding is OK
  primary,
  pink,
  red,
  yellow,
  blue,
  green,
  purple,
  orange,
  gray,
  amber,
}

// extension AvatarColorEnumHelper on UserAvatarColor {
//   AvatarColorEnum toAvatarColor() {
//     switch (this) {
//       case UserAvatarColor.primary:
//         return AvatarColorEnum.primary;
//       case UserAvatarColor.pink:
//         return AvatarColorEnum.pink;
//       case UserAvatarColor.red:
//         return AvatarColorEnum.red;
//       case UserAvatarColor.yellow:
//         return AvatarColorEnum.yellow;
//       case UserAvatarColor.blue:
//         return AvatarColorEnum.blue;
//       case UserAvatarColor.green:
//         return AvatarColorEnum.green;
//       case UserAvatarColor.purple:
//         return AvatarColorEnum.purple;
//       case UserAvatarColor.orange:
//         return AvatarColorEnum.orange;
//       case UserAvatarColor.gray:
//         return AvatarColorEnum.gray;
//       case UserAvatarColor.amber:
//         return AvatarColorEnum.amber;
//     }
//     return AvatarColorEnum.primary;
//   }
// }

extension AvatarColorToColorHelper on AvatarColorEnum {
  Color toColor([bool isDarkTheme = false]) {
    switch (this) {
      case AvatarColorEnum.primary:
        return isDarkTheme ? const Color(0xFFABCBFA) : const Color(0xFF4250AF);
      case AvatarColorEnum.pink:
        return const Color.fromARGB(255, 244, 114, 182);
      case AvatarColorEnum.red:
        return const Color.fromARGB(255, 239, 68, 68);
      case AvatarColorEnum.yellow:
        return const Color.fromARGB(255, 234, 179, 8);
      case AvatarColorEnum.blue:
        return const Color.fromARGB(255, 59, 130, 246);
      case AvatarColorEnum.green:
        return const Color.fromARGB(255, 22, 163, 74);
      case AvatarColorEnum.purple:
        return const Color.fromARGB(255, 147, 51, 234);
      case AvatarColorEnum.orange:
        return const Color.fromARGB(255, 234, 88, 12);
      case AvatarColorEnum.gray:
        return const Color.fromARGB(255, 75, 85, 99);
      case AvatarColorEnum.amber:
        return const Color.fromARGB(255, 217, 119, 6);
    }
  }
}
