//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReaderBooksBookIdPutRequest {
  /// Returns a new [ReaderBooksBookIdPutRequest] instance.
  ReaderBooksBookIdPutRequest({
    required this.title,
    required this.subTitle,
    required this.language,
    this.coverUrl,
    this.isbn,
    this.asin,
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
  });

  String title;

  String subTitle;

  String language;

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
  String? isbn;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? asin;

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

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReaderBooksBookIdPutRequest &&
    other.title == title &&
    other.subTitle == subTitle &&
    other.language == language &&
    other.coverUrl == coverUrl &&
    other.isbn == isbn &&
    other.asin == asin &&
    other.category == category &&
    other.author == author &&
    other.authorUrl == authorUrl &&
    other.authorSort == authorSort &&
    other.publisher == publisher &&
    other.description == description &&
    _deepEquality.equals(other.tags, tags) &&
    other.pubdate == pubdate &&
    other.rating == rating &&
    other.publisherUrl == publisherUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (title.hashCode) +
    (subTitle.hashCode) +
    (language.hashCode) +
    (coverUrl == null ? 0 : coverUrl!.hashCode) +
    (isbn == null ? 0 : isbn!.hashCode) +
    (asin == null ? 0 : asin!.hashCode) +
    (category == null ? 0 : category!.hashCode) +
    (author == null ? 0 : author!.hashCode) +
    (authorUrl == null ? 0 : authorUrl!.hashCode) +
    (authorSort == null ? 0 : authorSort!.hashCode) +
    (publisher == null ? 0 : publisher!.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (tags.hashCode) +
    (pubdate == null ? 0 : pubdate!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (publisherUrl == null ? 0 : publisherUrl!.hashCode);

  @override
  String toString() => 'ReaderBooksBookIdPutRequest[title=$title, subTitle=$subTitle, language=$language, coverUrl=$coverUrl, isbn=$isbn, asin=$asin, category=$category, author=$author, authorUrl=$authorUrl, authorSort=$authorSort, publisher=$publisher, description=$description, tags=$tags, pubdate=$pubdate, rating=$rating, publisherUrl=$publisherUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'title'] = this.title;
      json[r'sub_title'] = this.subTitle;
      json[r'language'] = this.language;
    if (this.coverUrl != null) {
      json[r'cover_url'] = this.coverUrl;
    } else {
      json[r'cover_url'] = null;
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
    return json;
  }

  /// Returns a new [ReaderBooksBookIdPutRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReaderBooksBookIdPutRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReaderBooksBookIdPutRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReaderBooksBookIdPutRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReaderBooksBookIdPutRequest(
        title: mapValueOfType<String>(json, r'title')!,
        subTitle: mapValueOfType<String>(json, r'sub_title')!,
        language: mapValueOfType<String>(json, r'language')!,
        coverUrl: mapValueOfType<String>(json, r'cover_url'),
        isbn: mapValueOfType<String>(json, r'isbn'),
        asin: mapValueOfType<String>(json, r'asin'),
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
      );
    }
    return null;
  }

  static List<ReaderBooksBookIdPutRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReaderBooksBookIdPutRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReaderBooksBookIdPutRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReaderBooksBookIdPutRequest> mapFromJson(dynamic json) {
    final map = <String, ReaderBooksBookIdPutRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReaderBooksBookIdPutRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReaderBooksBookIdPutRequest-objects as value to a dart map
  static Map<String, List<ReaderBooksBookIdPutRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReaderBooksBookIdPutRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReaderBooksBookIdPutRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'title',
    'sub_title',
    'language',
  };
}

