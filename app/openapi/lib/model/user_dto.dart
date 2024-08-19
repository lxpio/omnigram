//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UserDto {
  /// Returns a new [UserDto] instance.
  UserDto({
    required this.id,
    this.email,
    this.mobile,
    required this.name,
    required this.roleId,
    this.nickName,
    this.avatarUrl,
    required this.locked,
    required this.mfaSwitch,
    required this.ctime,
    required this.utime,
  });

  int id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? email;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? mobile;

  String name;

  int roleId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? nickName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? avatarUrl;

  bool locked;

  int mfaSwitch;

  int ctime;

  int utime;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserDto &&
    other.id == id &&
    other.email == email &&
    other.mobile == mobile &&
    other.name == name &&
    other.roleId == roleId &&
    other.nickName == nickName &&
    other.avatarUrl == avatarUrl &&
    other.locked == locked &&
    other.mfaSwitch == mfaSwitch &&
    other.ctime == ctime &&
    other.utime == utime;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (mobile == null ? 0 : mobile!.hashCode) +
    (name.hashCode) +
    (roleId.hashCode) +
    (nickName == null ? 0 : nickName!.hashCode) +
    (avatarUrl == null ? 0 : avatarUrl!.hashCode) +
    (locked.hashCode) +
    (mfaSwitch.hashCode) +
    (ctime.hashCode) +
    (utime.hashCode);

  @override
  String toString() => 'UserDto[id=$id, email=$email, mobile=$mobile, name=$name, roleId=$roleId, nickName=$nickName, avatarUrl=$avatarUrl, locked=$locked, mfaSwitch=$mfaSwitch, ctime=$ctime, utime=$utime]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
    if (this.mobile != null) {
      json[r'mobile'] = this.mobile;
    } else {
      json[r'mobile'] = null;
    }
      json[r'name'] = this.name;
      json[r'role_id'] = this.roleId;
    if (this.nickName != null) {
      json[r'nick_name'] = this.nickName;
    } else {
      json[r'nick_name'] = null;
    }
    if (this.avatarUrl != null) {
      json[r'avatar_url'] = this.avatarUrl;
    } else {
      json[r'avatar_url'] = null;
    }
      json[r'locked'] = this.locked;
      json[r'mfa_switch'] = this.mfaSwitch;
      json[r'ctime'] = this.ctime;
      json[r'utime'] = this.utime;
    return json;
  }

  /// Returns a new [UserDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UserDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UserDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UserDto(
        id: mapValueOfType<int>(json, r'id')!,
        email: mapValueOfType<String>(json, r'email'),
        mobile: mapValueOfType<String>(json, r'mobile'),
        name: mapValueOfType<String>(json, r'name')!,
        roleId: mapValueOfType<int>(json, r'role_id')!,
        nickName: mapValueOfType<String>(json, r'nick_name'),
        avatarUrl: mapValueOfType<String>(json, r'avatar_url'),
        locked: mapValueOfType<bool>(json, r'locked')!,
        mfaSwitch: mapValueOfType<int>(json, r'mfa_switch')!,
        ctime: mapValueOfType<int>(json, r'ctime')!,
        utime: mapValueOfType<int>(json, r'utime')!,
      );
    }
    return null;
  }

  static List<UserDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserDto> mapFromJson(dynamic json) {
    final map = <String, UserDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserDto-objects as value to a dart map
  static Map<String, List<UserDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UserDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UserDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'role_id',
    'locked',
    'mfa_switch',
    'ctime',
    'utime',
  };
}

