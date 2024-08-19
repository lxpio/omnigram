//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApikeyDto {
  /// Returns a new [ApikeyDto] instance.
  ApikeyDto({
    required this.name,
    required this.apikey,
    required this.ctime,
  });

  String name;

  String apikey;

  int ctime;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApikeyDto &&
    other.name == name &&
    other.apikey == apikey &&
    other.ctime == ctime;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (apikey.hashCode) +
    (ctime.hashCode);

  @override
  String toString() => 'ApikeyDto[name=$name, apikey=$apikey, ctime=$ctime]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'apikey'] = this.apikey;
      json[r'ctime'] = this.ctime;
    return json;
  }

  /// Returns a new [ApikeyDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApikeyDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApikeyDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApikeyDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApikeyDto(
        name: mapValueOfType<String>(json, r'name')!,
        apikey: mapValueOfType<String>(json, r'apikey')!,
        ctime: mapValueOfType<int>(json, r'ctime')!,
      );
    }
    return null;
  }

  static List<ApikeyDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApikeyDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApikeyDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApikeyDto> mapFromJson(dynamic json) {
    final map = <String, ApikeyDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApikeyDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApikeyDto-objects as value to a dart map
  static Map<String, List<ApikeyDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApikeyDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApikeyDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'apikey',
    'ctime',
  };
}

