//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AccessTokenDto {
  /// Returns a new [AccessTokenDto] instance.
  AccessTokenDto({
    required this.tokenType,
    required this.expiredIn,
    required this.refreshToken,
    required this.accessToken,
  });

  String tokenType;

  int expiredIn;

  String refreshToken;

  String accessToken;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AccessTokenDto &&
    other.tokenType == tokenType &&
    other.expiredIn == expiredIn &&
    other.refreshToken == refreshToken &&
    other.accessToken == accessToken;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (tokenType.hashCode) +
    (expiredIn.hashCode) +
    (refreshToken.hashCode) +
    (accessToken.hashCode);

  @override
  String toString() => 'AccessTokenDto[tokenType=$tokenType, expiredIn=$expiredIn, refreshToken=$refreshToken, accessToken=$accessToken]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'token_type'] = this.tokenType;
      json[r'expired_in'] = this.expiredIn;
      json[r'refresh_token'] = this.refreshToken;
      json[r'access_token'] = this.accessToken;
    return json;
  }

  /// Returns a new [AccessTokenDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AccessTokenDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AccessTokenDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AccessTokenDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AccessTokenDto(
        tokenType: mapValueOfType<String>(json, r'token_type')!,
        expiredIn: mapValueOfType<int>(json, r'expired_in')!,
        refreshToken: mapValueOfType<String>(json, r'refresh_token')!,
        accessToken: mapValueOfType<String>(json, r'access_token')!,
      );
    }
    return null;
  }

  static List<AccessTokenDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AccessTokenDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AccessTokenDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AccessTokenDto> mapFromJson(dynamic json) {
    final map = <String, AccessTokenDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AccessTokenDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AccessTokenDto-objects as value to a dart map
  static Map<String, List<AccessTokenDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AccessTokenDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AccessTokenDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'token_type',
    'expired_in',
    'refresh_token',
    'access_token',
  };
}

