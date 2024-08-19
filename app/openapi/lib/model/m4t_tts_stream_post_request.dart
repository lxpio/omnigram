//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class M4tTtsStreamPostRequest {
  /// Returns a new [M4tTtsStreamPostRequest] instance.
  M4tTtsStreamPostRequest({
    required this.text,
    required this.lang,
    required this.audioId,
    required this.format,
    required this.stream,
  });

  String text;

  String lang;

  String audioId;

  String format;

  bool stream;

  @override
  bool operator ==(Object other) => identical(this, other) || other is M4tTtsStreamPostRequest &&
    other.text == text &&
    other.lang == lang &&
    other.audioId == audioId &&
    other.format == format &&
    other.stream == stream;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (text.hashCode) +
    (lang.hashCode) +
    (audioId.hashCode) +
    (format.hashCode) +
    (stream.hashCode);

  @override
  String toString() => 'M4tTtsStreamPostRequest[text=$text, lang=$lang, audioId=$audioId, format=$format, stream=$stream]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'text'] = this.text;
      json[r'lang'] = this.lang;
      json[r'audio_id'] = this.audioId;
      json[r'format'] = this.format;
      json[r'stream'] = this.stream;
    return json;
  }

  /// Returns a new [M4tTtsStreamPostRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static M4tTtsStreamPostRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "M4tTtsStreamPostRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "M4tTtsStreamPostRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return M4tTtsStreamPostRequest(
        text: mapValueOfType<String>(json, r'text')!,
        lang: mapValueOfType<String>(json, r'lang')!,
        audioId: mapValueOfType<String>(json, r'audio_id')!,
        format: mapValueOfType<String>(json, r'format')!,
        stream: mapValueOfType<bool>(json, r'stream')!,
      );
    }
    return null;
  }

  static List<M4tTtsStreamPostRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <M4tTtsStreamPostRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = M4tTtsStreamPostRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, M4tTtsStreamPostRequest> mapFromJson(dynamic json) {
    final map = <String, M4tTtsStreamPostRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = M4tTtsStreamPostRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of M4tTtsStreamPostRequest-objects as value to a dart map
  static Map<String, List<M4tTtsStreamPostRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<M4tTtsStreamPostRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = M4tTtsStreamPostRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'text',
    'lang',
    'audio_id',
    'format',
    'stream',
  };
}

