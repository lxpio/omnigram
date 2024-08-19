//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ScanStatsDto {
  /// Returns a new [ScanStatsDto] instance.
  ScanStatsDto({
    required this.total,
    required this.running,
    required this.scanCount,
    this.errs = const [],
    required this.diskUsage,
    required this.epubCount,
    required this.pdfCount,
  });

  int total;

  bool running;

  int scanCount;

  List<String> errs;

  int diskUsage;

  int epubCount;

  int pdfCount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ScanStatsDto &&
    other.total == total &&
    other.running == running &&
    other.scanCount == scanCount &&
    _deepEquality.equals(other.errs, errs) &&
    other.diskUsage == diskUsage &&
    other.epubCount == epubCount &&
    other.pdfCount == pdfCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (total.hashCode) +
    (running.hashCode) +
    (scanCount.hashCode) +
    (errs.hashCode) +
    (diskUsage.hashCode) +
    (epubCount.hashCode) +
    (pdfCount.hashCode);

  @override
  String toString() => 'ScanStatsDto[total=$total, running=$running, scanCount=$scanCount, errs=$errs, diskUsage=$diskUsage, epubCount=$epubCount, pdfCount=$pdfCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'total'] = this.total;
      json[r'running'] = this.running;
      json[r'scan_count'] = this.scanCount;
      json[r'errs'] = this.errs;
      json[r'disk_usage'] = this.diskUsage;
      json[r'epub_count'] = this.epubCount;
      json[r'pdf_count'] = this.pdfCount;
    return json;
  }

  /// Returns a new [ScanStatsDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ScanStatsDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ScanStatsDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ScanStatsDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ScanStatsDto(
        total: mapValueOfType<int>(json, r'total')!,
        running: mapValueOfType<bool>(json, r'running')!,
        scanCount: mapValueOfType<int>(json, r'scan_count')!,
        errs: json[r'errs'] is Iterable
            ? (json[r'errs'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        diskUsage: mapValueOfType<int>(json, r'disk_usage')!,
        epubCount: mapValueOfType<int>(json, r'epub_count')!,
        pdfCount: mapValueOfType<int>(json, r'pdf_count')!,
      );
    }
    return null;
  }

  static List<ScanStatsDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ScanStatsDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ScanStatsDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ScanStatsDto> mapFromJson(dynamic json) {
    final map = <String, ScanStatsDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ScanStatsDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ScanStatsDto-objects as value to a dart map
  static Map<String, List<ScanStatsDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ScanStatsDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ScanStatsDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'total',
    'running',
    'scan_count',
    'disk_usage',
    'epub_count',
    'pdf_count',
  };
}

