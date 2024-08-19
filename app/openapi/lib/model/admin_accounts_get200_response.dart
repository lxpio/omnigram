//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AdminAccountsGet200Response {
  /// Returns a new [AdminAccountsGet200Response] instance.
  AdminAccountsGet200Response({
    required this.total,
    this.items = const [],
    this.pageNum,
    this.pageSize,
  });

  int total;

  List<UserDto> items;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? pageNum;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? pageSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAccountsGet200Response &&
          other.total == total &&
          _deepEquality.equals(other.items, items) &&
          other.pageNum == pageNum &&
          other.pageSize == pageSize;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (total.hashCode) +
      (items.hashCode) +
      (pageNum == null ? 0 : pageNum!.hashCode) +
      (pageSize == null ? 0 : pageSize!.hashCode);

  @override
  String toString() =>
      'AdminAccountsGet200Response[total=$total, items=$items, pageNum=$pageNum, pageSize=$pageSize]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'total'] = this.total;
    json[r'items'] = this.items;
    if (this.pageNum != null) {
      json[r'page_num'] = this.pageNum;
    } else {
      json[r'page_num'] = null;
    }
    if (this.pageSize != null) {
      json[r'page_size'] = this.pageSize;
    } else {
      json[r'page_size'] = null;
    }
    return json;
  }

  /// Returns a new [AdminAccountsGet200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminAccountsGet200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "AdminAccountsGet200Response[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "AdminAccountsGet200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AdminAccountsGet200Response(
        total: mapValueOfType<int>(json, r'total')!,
        items: UserDto.listFromJson(json[r'items']),
        pageNum: mapValueOfType<int>(json, r'page_num'),
        pageSize: mapValueOfType<int>(json, r'page_size'),
      );
    }
    return null;
  }

  static List<AdminAccountsGet200Response> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <AdminAccountsGet200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminAccountsGet200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminAccountsGet200Response> mapFromJson(dynamic json) {
    final map = <String, AdminAccountsGet200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminAccountsGet200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminAccountsGet200Response-objects as value to a dart map
  static Map<String, List<AdminAccountsGet200Response>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<AdminAccountsGet200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminAccountsGet200Response.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'total',
    'items',
  };
}
