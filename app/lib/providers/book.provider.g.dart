// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookSearchHash() => r'23a9dee5e62ba2de890e836c27406df3e5a74a66';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$BookSearch extends BuildlessNotifier<BookState> {
  late final BookQuery query;

  BookState build(
    BookQuery query,
  );
}

/// See also [BookSearch].
@ProviderFor(BookSearch)
const bookSearchProvider = BookSearchFamily();

/// See also [BookSearch].
class BookSearchFamily extends Family<BookState> {
  /// See also [BookSearch].
  const BookSearchFamily();

  /// See also [BookSearch].
  BookSearchProvider call(
    BookQuery query,
  ) {
    return BookSearchProvider(
      query,
    );
  }

  @override
  BookSearchProvider getProviderOverride(
    covariant BookSearchProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookSearchProvider';
}

/// See also [BookSearch].
class BookSearchProvider extends NotifierProviderImpl<BookSearch, BookState> {
  /// See also [BookSearch].
  BookSearchProvider(
    BookQuery query,
  ) : this._internal(
          () => BookSearch()..query = query,
          from: bookSearchProvider,
          name: r'bookSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookSearchHash,
          dependencies: BookSearchFamily._dependencies,
          allTransitiveDependencies:
              BookSearchFamily._allTransitiveDependencies,
          query: query,
        );

  BookSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final BookQuery query;

  @override
  BookState runNotifierBuild(
    covariant BookSearch notifier,
  ) {
    return notifier.build(
      query,
    );
  }

  @override
  Override overrideWith(BookSearch Function() create) {
    return ProviderOverride(
      origin: this,
      override: BookSearchProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  NotifierProviderElement<BookSearch, BookState> createElement() {
    return _BookSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BookSearchRef on NotifierProviderRef<BookState> {
  /// The parameter `query` of this provider.
  BookQuery get query;
}

class _BookSearchProviderElement
    extends NotifierProviderElement<BookSearch, BookState> with BookSearchRef {
  _BookSearchProviderElement(super.provider);

  @override
  BookQuery get query => (origin as BookSearchProvider).query;
}

String _$booksHash() => r'a5500886c7aaa527761c0af8000c2f0d739f47b4';

abstract class _$Books extends BuildlessAutoDisposeNotifier<BookState> {
  late final BookQuery query;

  BookState build(
    BookQuery query,
  );
}

/// See also [Books].
@ProviderFor(Books)
const booksProvider = BooksFamily();

/// See also [Books].
class BooksFamily extends Family<BookState> {
  /// See also [Books].
  const BooksFamily();

  /// See also [Books].
  BooksProvider call(
    BookQuery query,
  ) {
    return BooksProvider(
      query,
    );
  }

  @override
  BooksProvider getProviderOverride(
    covariant BooksProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'booksProvider';
}

/// See also [Books].
class BooksProvider extends AutoDisposeNotifierProviderImpl<Books, BookState> {
  /// See also [Books].
  BooksProvider(
    BookQuery query,
  ) : this._internal(
          () => Books()..query = query,
          from: booksProvider,
          name: r'booksProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$booksHash,
          dependencies: BooksFamily._dependencies,
          allTransitiveDependencies: BooksFamily._allTransitiveDependencies,
          query: query,
        );

  BooksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final BookQuery query;

  @override
  BookState runNotifierBuild(
    covariant Books notifier,
  ) {
    return notifier.build(
      query,
    );
  }

  @override
  Override overrideWith(Books Function() create) {
    return ProviderOverride(
      origin: this,
      override: BooksProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<Books, BookState> createElement() {
    return _BooksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BooksProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BooksRef on AutoDisposeNotifierProviderRef<BookState> {
  /// The parameter `query` of this provider.
  BookQuery get query;
}

class _BooksProviderElement
    extends AutoDisposeNotifierProviderElement<Books, BookState> with BooksRef {
  _BooksProviderElement(super.provider);

  @override
  BookQuery get query => (origin as BooksProvider).query;
}

String _$bookNotifierHash() => r'87d7cd0e6b41e3be911068e5397916be6f535a96';

/// See also [BookNotifier].
@ProviderFor(BookNotifier)
final bookNotifierProvider = NotifierProvider<BookNotifier, bool>.internal(
  BookNotifier.new,
  name: r'bookNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bookNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookNotifier = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
