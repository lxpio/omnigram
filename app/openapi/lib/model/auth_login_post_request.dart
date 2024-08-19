//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AuthLoginPostRequest {
  /// Returns a new [AuthLoginPostRequest] instance.
  AuthLoginPostRequest({
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
    required this.accessToken,
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

  String accessToken;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthLoginPostRequest &&
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
    other.utime == utime &&
    other.accessToken == accessToken;

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
    (utime.hashCode) +
    (accessToken.hashCode);

  @override
  String toString() => 'AuthLoginPostRequest[id=$id, email=$email, mobile=$mobile, name=$name, roleId=$roleId, nickName=$nickName, avatarUrl=$avatarUrl, locked=$locked, mfaSwitch=$mfaSwitch, ctime=$ctime, utime=$utime, accessToken=$accessToken]';

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
      json[r'access_token'] = this.accessToken;
    return json;
  }

  /// Returns a new [AuthLoginPostRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuthLoginPostRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AuthLoginPostRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AuthLoginPostRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AuthLoginPostRequest(
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
        accessToken: mapValueOfType<String>(json, r'access_token')!,
      );
    }
    return null;
  }

  static List<AuthLoginPostRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthLoginPostRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthLoginPostRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuthLoginPostRequest> mapFromJson(dynamic json) {
    final map = <String, AuthLoginPostRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuthLoginPostRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuthLoginPostRequest-objects as value to a dart map
  static Map<String, List<AuthLoginPostRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuthLoginPostRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuthLoginPostRequest.listFromJson(entry.value, growable: growable,);
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
    'access_token',
  };
}

