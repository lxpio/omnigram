//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EnableScanDto {
  /// Returns a new [EnableScanDto] instance.
  EnableScanDto({
    required this.refresh,
    required this.maxThread,
  });

  /// 从头开始扫描
  bool refresh;

  /// 扫描线程数量
  num maxThread;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EnableScanDto &&
    other.refresh == refresh &&
    other.maxThread == maxThread;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (refresh.hashCode) +
    (maxThread.hashCode);

  @override
  String toString() => 'EnableScanDto[refresh=$refresh, maxThread=$maxThread]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'refresh'] = this.refresh;
      json[r'max_thread'] = this.maxThread;
    return json;
  }

  /// Returns a new [EnableScanDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EnableScanDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EnableScanDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "EnableScanDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return EnableScanDto(
        refresh: mapValueOfType<bool>(json, r'refresh')!,
        maxThread: num.parse('${json[r'max_thread']}'),
      );
    }
    return null;
  }

  static List<EnableScanDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EnableScanDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EnableScanDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EnableScanDto> mapFromJson(dynamic json) {
    final map = <String, EnableScanDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EnableScanDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EnableScanDto-objects as value to a dart map
  static Map<String, List<EnableScanDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EnableScanDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EnableScanDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'refresh',
    'max_thread',
  };
}

