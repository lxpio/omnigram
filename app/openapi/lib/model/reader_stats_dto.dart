//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReaderStatsDto {
  /// Returns a new [ReaderStatsDto] instance.
  ReaderStatsDto({
    required this.total,
    required this.authors,
    required this.publisher,
    required this.tags,
  });

  int total;

  int authors;

  int publisher;

  int tags;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReaderStatsDto &&
    other.total == total &&
    other.authors == authors &&
    other.publisher == publisher &&
    other.tags == tags;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (total.hashCode) +
    (authors.hashCode) +
    (publisher.hashCode) +
    (tags.hashCode);

  @override
  String toString() => 'ReaderStatsDto[total=$total, authors=$authors, publisher=$publisher, tags=$tags]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'total'] = this.total;
      json[r'authors'] = this.authors;
      json[r'publisher'] = this.publisher;
      json[r'tags'] = this.tags;
    return json;
  }

  /// Returns a new [ReaderStatsDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReaderStatsDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReaderStatsDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReaderStatsDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReaderStatsDto(
        total: mapValueOfType<int>(json, r'total')!,
        authors: mapValueOfType<int>(json, r'authors')!,
        publisher: mapValueOfType<int>(json, r'publisher')!,
        tags: mapValueOfType<int>(json, r'tags')!,
      );
    }
    return null;
  }

  static List<ReaderStatsDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReaderStatsDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReaderStatsDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReaderStatsDto> mapFromJson(dynamic json) {
    final map = <String, ReaderStatsDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReaderStatsDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReaderStatsDto-objects as value to a dart map
  static Map<String, List<ReaderStatsDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReaderStatsDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReaderStatsDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'total',
    'authors',
    'publisher',
    'tags',
  };
}

