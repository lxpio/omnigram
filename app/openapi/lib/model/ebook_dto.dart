//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EbookDto {
  /// Returns a new [EbookDto] instance.
  EbookDto({
    required this.id,
    this.size,
    this.ctime,
    this.utime,
    required this.title,
    this.subTitle,
    this.language,
    this.coverUrl,
    this.uuid,
    this.isbn,
    this.asin,
    required this.identifier,
    this.category,
    this.author,
    this.authorUrl,
    this.authorSort,
    this.publisher,
    this.description,
    this.tags = const [],
    this.pubdate,
    this.rating,
    this.publisherUrl,
    this.countVisit,
    this.countDownload,
    this.progress,
    this.progressIndex,
    this.paraPosition,
  });

  int id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? size;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? ctime;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? utime;

  String title;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? subTitle;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? language;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? coverUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? uuid;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? isbn;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? asin;

  String identifier;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? category;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? author;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? authorUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? authorSort;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? publisher;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  List<String> tags;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? pubdate;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? rating;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? publisherUrl;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? countVisit;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? countDownload;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  num? progress;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? progressIndex;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? paraPosition;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EbookDto &&
    other.id == id &&
    other.size == size &&
    other.ctime == ctime &&
    other.utime == utime &&
    other.title == title &&
    other.subTitle == subTitle &&
    other.language == language &&
    other.coverUrl == coverUrl &&
    other.uuid == uuid &&
    other.isbn == isbn &&
    other.asin == asin &&
    other.identifier == identifier &&
    other.category == category &&
    other.author == author &&
    other.authorUrl == authorUrl &&
    other.authorSort == authorSort &&
    other.publisher == publisher &&
    other.description == description &&
    _deepEquality.equals(other.tags, tags) &&
    other.pubdate == pubdate &&
    other.rating == rating &&
    other.publisherUrl == publisherUrl &&
    other.countVisit == countVisit &&
    other.countDownload == countDownload &&
    other.progress == progress &&
    other.progressIndex == progressIndex &&
    other.paraPosition == paraPosition;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (size == null ? 0 : size!.hashCode) +
    (ctime == null ? 0 : ctime!.hashCode) +
    (utime == null ? 0 : utime!.hashCode) +
    (title.hashCode) +
    (subTitle == null ? 0 : subTitle!.hashCode) +
    (language == null ? 0 : language!.hashCode) +
    (coverUrl == null ? 0 : coverUrl!.hashCode) +
    (uuid == null ? 0 : uuid!.hashCode) +
    (isbn == null ? 0 : isbn!.hashCode) +
    (asin == null ? 0 : asin!.hashCode) +
    (identifier.hashCode) +
    (category == null ? 0 : category!.hashCode) +
    (author == null ? 0 : author!.hashCode) +
    (authorUrl == null ? 0 : authorUrl!.hashCode) +
    (authorSort == null ? 0 : authorSort!.hashCode) +
    (publisher == null ? 0 : publisher!.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (tags.hashCode) +
    (pubdate == null ? 0 : pubdate!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (publisherUrl == null ? 0 : publisherUrl!.hashCode) +
    (countVisit == null ? 0 : countVisit!.hashCode) +
    (countDownload == null ? 0 : countDownload!.hashCode) +
    (progress == null ? 0 : progress!.hashCode) +
    (progressIndex == null ? 0 : progressIndex!.hashCode) +
    (paraPosition == null ? 0 : paraPosition!.hashCode);

  @override
  String toString() => 'EbookDto[id=$id, size=$size, ctime=$ctime, utime=$utime, title=$title, subTitle=$subTitle, language=$language, coverUrl=$coverUrl, uuid=$uuid, isbn=$isbn, asin=$asin, identifier=$identifier, category=$category, author=$author, authorUrl=$authorUrl, authorSort=$authorSort, publisher=$publisher, description=$description, tags=$tags, pubdate=$pubdate, rating=$rating, publisherUrl=$publisherUrl, countVisit=$countVisit, countDownload=$countDownload, progress=$progress, progressIndex=$progressIndex, paraPosition=$paraPosition]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.size != null) {
      json[r'size'] = this.size;
    } else {
      json[r'size'] = null;
    }
    if (this.ctime != null) {
      json[r'ctime'] = this.ctime;
    } else {
      json[r'ctime'] = null;
    }
    if (this.utime != null) {
      json[r'utime'] = this.utime;
    } else {
      json[r'utime'] = null;
    }
      json[r'title'] = this.title;
    if (this.subTitle != null) {
      json[r'sub_title'] = this.subTitle;
    } else {
      json[r'sub_title'] = null;
    }
    if (this.language != null) {
      json[r'language'] = this.language;
    } else {
      json[r'language'] = null;
    }
    if (this.coverUrl != null) {
      json[r'cover_url'] = this.coverUrl;
    } else {
      json[r'cover_url'] = null;
    }
    if (this.uuid != null) {
      json[r'uuid'] = this.uuid;
    } else {
      json[r'uuid'] = null;
    }
    if (this.isbn != null) {
      json[r'isbn'] = this.isbn;
    } else {
      json[r'isbn'] = null;
    }
    if (this.asin != null) {
      json[r'asin'] = this.asin;
    } else {
      json[r'asin'] = null;
    }
      json[r'identifier'] = this.identifier;
    if (this.category != null) {
      json[r'category'] = this.category;
    } else {
      json[r'category'] = null;
    }
    if (this.author != null) {
      json[r'author'] = this.author;
    } else {
      json[r'author'] = null;
    }
    if (this.authorUrl != null) {
      json[r'author_url'] = this.authorUrl;
    } else {
      json[r'author_url'] = null;
    }
    if (this.authorSort != null) {
      json[r'author_sort'] = this.authorSort;
    } else {
      json[r'author_sort'] = null;
    }
    if (this.publisher != null) {
      json[r'publisher'] = this.publisher;
    } else {
      json[r'publisher'] = null;
    }
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
      json[r'tags'] = this.tags;
    if (this.pubdate != null) {
      json[r'pubdate'] = this.pubdate;
    } else {
      json[r'pubdate'] = null;
    }
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
    if (this.publisherUrl != null) {
      json[r'publisher_url'] = this.publisherUrl;
    } else {
      json[r'publisher_url'] = null;
    }
    if (this.countVisit != null) {
      json[r'count_visit'] = this.countVisit;
    } else {
      json[r'count_visit'] = null;
    }
    if (this.countDownload != null) {
      json[r'count_download'] = this.countDownload;
    } else {
      json[r'count_download'] = null;
    }
    if (this.progress != null) {
      json[r'progress'] = this.progress;
    } else {
      json[r'progress'] = null;
    }
    if (this.progressIndex != null) {
      json[r'progress_index'] = this.progressIndex;
    } else {
      json[r'progress_index'] = null;
    }
    if (this.paraPosition != null) {
      json[r'para_position'] = this.paraPosition;
    } else {
      json[r'para_position'] = null;
    }
    return json;
  }

  /// Returns a new [EbookDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EbookDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EbookDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "EbookDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return EbookDto(
        id: mapValueOfType<int>(json, r'id')!,
        size: mapValueOfType<int>(json, r'size'),
        ctime: mapValueOfType<String>(json, r'ctime'),
        utime: mapValueOfType<String>(json, r'utime'),
        title: mapValueOfType<String>(json, r'title')!,
        subTitle: mapValueOfType<String>(json, r'sub_title'),
        language: mapValueOfType<String>(json, r'language'),
        coverUrl: mapValueOfType<String>(json, r'cover_url'),
        uuid: mapValueOfType<String>(json, r'uuid'),
        isbn: mapValueOfType<String>(json, r'isbn'),
        asin: mapValueOfType<String>(json, r'asin'),
        identifier: mapValueOfType<String>(json, r'identifier')!,
        category: mapValueOfType<String>(json, r'category'),
        author: mapValueOfType<String>(json, r'author'),
        authorUrl: mapValueOfType<String>(json, r'author_url'),
        authorSort: mapValueOfType<String>(json, r'author_sort'),
        publisher: mapValueOfType<String>(json, r'publisher'),
        description: mapValueOfType<String>(json, r'description'),
        tags: json[r'tags'] is Iterable
            ? (json[r'tags'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        pubdate: mapValueOfType<String>(json, r'pubdate'),
        rating: num.parse('${json[r'rating']}'),
        publisherUrl: mapValueOfType<String>(json, r'publisher_url'),
        countVisit: mapValueOfType<int>(json, r'count_visit'),
        countDownload: mapValueOfType<int>(json, r'count_download'),
        progress: num.parse('${json[r'progress']}'),
        progressIndex: mapValueOfType<int>(json, r'progress_index'),
        paraPosition: mapValueOfType<int>(json, r'para_position'),
      );
    }
    return null;
  }

  static List<EbookDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EbookDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EbookDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EbookDto> mapFromJson(dynamic json) {
    final map = <String, EbookDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EbookDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EbookDto-objects as value to a dart map
  static Map<String, List<EbookDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EbookDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EbookDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'title',
    'identifier',
  };
}

