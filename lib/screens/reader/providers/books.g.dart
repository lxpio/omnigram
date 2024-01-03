// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BookNav _$$_BookNavFromJson(Map<String, dynamic> json) => _$_BookNav(
      recent: (json['recent'] as List<dynamic>?)
          ?.map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      random: (json['random'] as List<dynamic>?)
          ?.map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reading: (json['reading'] as List<dynamic>?)
          ?.map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_BookNavToJson(_$_BookNav instance) =>
    <String, dynamic>{
      'recent': instance.recent,
      'random': instance.random,
      'reading': instance.reading,
    };

_$_PersonBookNav _$$_PersonBookNavFromJson(Map<String, dynamic> json) =>
    _$_PersonBookNav(
      readings: (json['readings'] as List<dynamic>?)
          ?.map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      likes: (json['likes'] as List<dynamic>?)
          ?.map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_PersonBookNavToJson(_$_PersonBookNav instance) =>
    <String, dynamic>{
      'readings': instance.readings,
      'likes': instance.likes,
    };

_$_BookSearch _$$_BookSearchFromJson(Map<String, dynamic> json) =>
    _$_BookSearch(
      search: json['search'] as String?,
      author: json['author'] as String?,
      publisher: json['publisher'] as String?,
      tags: json['tags'] as String?,
    );

Map<String, dynamic> _$$_BookSearchToJson(_$_BookSearch instance) =>
    <String, dynamic>{
      'search': instance.search,
      'author': instance.author,
      'publisher': instance.publisher,
      'tags': instance.tags,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$booksHash() => r'36633dab977224679cfaa8a92a1bbc1e895fdb4f';

/// See also [Books].
@ProviderFor(Books)
final booksProvider = AutoDisposeAsyncNotifierProvider<Books, BookNav>.internal(
  Books.new,
  name: r'booksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$booksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Books = AutoDisposeAsyncNotifier<BookNav>;
String _$personBooksHash() => r'bda89d15c70d06ea5e617ff1a1e2692a49f61a8f';

/// See also [PersonBooks].
@ProviderFor(PersonBooks)
final personBooksProvider =
    AutoDisposeAsyncNotifierProvider<PersonBooks, PersonBookNav>.internal(
  PersonBooks.new,
  name: r'personBooksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$personBooksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PersonBooks = AutoDisposeAsyncNotifier<PersonBookNav>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
