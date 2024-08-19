//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SpeakerDto {
  /// Returns a new [SpeakerDto] instance.
  SpeakerDto({
    required this.id,
    required this.audioId,
    required this.demoWav,
    required this.name,
    this.tag,
    this.avatarUrl,
  });

  int id;

  String audioId;

  String demoWav;

  String name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? avatarUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SpeakerDto &&
    other.id == id &&
    other.audioId == audioId &&
    other.demoWav == demoWav &&
    other.name == name &&
    other.tag == tag &&
    other.avatarUrl == avatarUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (audioId.hashCode) +
    (demoWav.hashCode) +
    (name.hashCode) +
    (tag == null ? 0 : tag!.hashCode) +
    (avatarUrl == null ? 0 : avatarUrl!.hashCode);

  @override
  String toString() => 'SpeakerDto[id=$id, audioId=$audioId, demoWav=$demoWav, name=$name, tag=$tag, avatarUrl=$avatarUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'audio_id'] = this.audioId;
      json[r'demo_wav'] = this.demoWav;
      json[r'name'] = this.name;
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    if (this.avatarUrl != null) {
      json[r'avatar_url'] = this.avatarUrl;
    } else {
      json[r'avatar_url'] = null;
    }
    return json;
  }

  /// Returns a new [SpeakerDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SpeakerDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SpeakerDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SpeakerDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SpeakerDto(
        id: mapValueOfType<int>(json, r'id')!,
        audioId: mapValueOfType<String>(json, r'audio_id')!,
        demoWav: mapValueOfType<String>(json, r'demo_wav')!,
        name: mapValueOfType<String>(json, r'name')!,
        tag: mapValueOfType<String>(json, r'tag'),
        avatarUrl: mapValueOfType<String>(json, r'avatar_url'),
      );
    }
    return null;
  }

  static List<SpeakerDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SpeakerDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SpeakerDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SpeakerDto> mapFromJson(dynamic json) {
    final map = <String, SpeakerDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SpeakerDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SpeakerDto-objects as value to a dart map
  static Map<String, List<SpeakerDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SpeakerDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SpeakerDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'audio_id',
    'demo_wav',
    'name',
  };
}

