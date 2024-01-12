// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'books.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BookNav _$BookNavFromJson(Map<String, dynamic> json) {
  return _BookNav.fromJson(json);
}

/// @nodoc
mixin _$BookNav {
  List<BookModel>? get recent => throw _privateConstructorUsedError;
  List<BookModel>? get random => throw _privateConstructorUsedError;
  List<BookModel>? get reading => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookNavCopyWith<BookNav> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookNavCopyWith<$Res> {
  factory $BookNavCopyWith(BookNav value, $Res Function(BookNav) then) =
      _$BookNavCopyWithImpl<$Res, BookNav>;
  @useResult
  $Res call(
      {List<BookModel>? recent,
      List<BookModel>? random,
      List<BookModel>? reading});
}

/// @nodoc
class _$BookNavCopyWithImpl<$Res, $Val extends BookNav>
    implements $BookNavCopyWith<$Res> {
  _$BookNavCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recent = freezed,
    Object? random = freezed,
    Object? reading = freezed,
  }) {
    return _then(_value.copyWith(
      recent: freezed == recent
          ? _value.recent
          : recent // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
      random: freezed == random
          ? _value.random
          : random // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
      reading: freezed == reading
          ? _value.reading
          : reading // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookNavImplCopyWith<$Res> implements $BookNavCopyWith<$Res> {
  factory _$$BookNavImplCopyWith(
          _$BookNavImpl value, $Res Function(_$BookNavImpl) then) =
      __$$BookNavImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<BookModel>? recent,
      List<BookModel>? random,
      List<BookModel>? reading});
}

/// @nodoc
class __$$BookNavImplCopyWithImpl<$Res>
    extends _$BookNavCopyWithImpl<$Res, _$BookNavImpl>
    implements _$$BookNavImplCopyWith<$Res> {
  __$$BookNavImplCopyWithImpl(
      _$BookNavImpl _value, $Res Function(_$BookNavImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recent = freezed,
    Object? random = freezed,
    Object? reading = freezed,
  }) {
    return _then(_$BookNavImpl(
      recent: freezed == recent
          ? _value._recent
          : recent // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
      random: freezed == random
          ? _value._random
          : random // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
      reading: freezed == reading
          ? _value._reading
          : reading // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookNavImpl implements _BookNav {
  const _$BookNavImpl(
      {final List<BookModel>? recent,
      final List<BookModel>? random,
      final List<BookModel>? reading})
      : _recent = recent,
        _random = random,
        _reading = reading;

  factory _$BookNavImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookNavImplFromJson(json);

  final List<BookModel>? _recent;
  @override
  List<BookModel>? get recent {
    final value = _recent;
    if (value == null) return null;
    if (_recent is EqualUnmodifiableListView) return _recent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<BookModel>? _random;
  @override
  List<BookModel>? get random {
    final value = _random;
    if (value == null) return null;
    if (_random is EqualUnmodifiableListView) return _random;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<BookModel>? _reading;
  @override
  List<BookModel>? get reading {
    final value = _reading;
    if (value == null) return null;
    if (_reading is EqualUnmodifiableListView) return _reading;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'BookNav(recent: $recent, random: $random, reading: $reading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookNavImpl &&
            const DeepCollectionEquality().equals(other._recent, _recent) &&
            const DeepCollectionEquality().equals(other._random, _random) &&
            const DeepCollectionEquality().equals(other._reading, _reading));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_recent),
      const DeepCollectionEquality().hash(_random),
      const DeepCollectionEquality().hash(_reading));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookNavImplCopyWith<_$BookNavImpl> get copyWith =>
      __$$BookNavImplCopyWithImpl<_$BookNavImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookNavImplToJson(
      this,
    );
  }
}

abstract class _BookNav implements BookNav {
  const factory _BookNav(
      {final List<BookModel>? recent,
      final List<BookModel>? random,
      final List<BookModel>? reading}) = _$BookNavImpl;

  factory _BookNav.fromJson(Map<String, dynamic> json) = _$BookNavImpl.fromJson;

  @override
  List<BookModel>? get recent;
  @override
  List<BookModel>? get random;
  @override
  List<BookModel>? get reading;
  @override
  @JsonKey(ignore: true)
  _$$BookNavImplCopyWith<_$BookNavImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PersonBookNav _$PersonBookNavFromJson(Map<String, dynamic> json) {
  return _PersonBookNav.fromJson(json);
}

/// @nodoc
mixin _$PersonBookNav {
  List<BookModel>? get readings => throw _privateConstructorUsedError;
  List<BookModel>? get likes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PersonBookNavCopyWith<PersonBookNav> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonBookNavCopyWith<$Res> {
  factory $PersonBookNavCopyWith(
          PersonBookNav value, $Res Function(PersonBookNav) then) =
      _$PersonBookNavCopyWithImpl<$Res, PersonBookNav>;
  @useResult
  $Res call({List<BookModel>? readings, List<BookModel>? likes});
}

/// @nodoc
class _$PersonBookNavCopyWithImpl<$Res, $Val extends PersonBookNav>
    implements $PersonBookNavCopyWith<$Res> {
  _$PersonBookNavCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? readings = freezed,
    Object? likes = freezed,
  }) {
    return _then(_value.copyWith(
      readings: freezed == readings
          ? _value.readings
          : readings // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
      likes: freezed == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PersonBookNavImplCopyWith<$Res>
    implements $PersonBookNavCopyWith<$Res> {
  factory _$$PersonBookNavImplCopyWith(
          _$PersonBookNavImpl value, $Res Function(_$PersonBookNavImpl) then) =
      __$$PersonBookNavImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<BookModel>? readings, List<BookModel>? likes});
}

/// @nodoc
class __$$PersonBookNavImplCopyWithImpl<$Res>
    extends _$PersonBookNavCopyWithImpl<$Res, _$PersonBookNavImpl>
    implements _$$PersonBookNavImplCopyWith<$Res> {
  __$$PersonBookNavImplCopyWithImpl(
      _$PersonBookNavImpl _value, $Res Function(_$PersonBookNavImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? readings = freezed,
    Object? likes = freezed,
  }) {
    return _then(_$PersonBookNavImpl(
      readings: freezed == readings
          ? _value._readings
          : readings // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
      likes: freezed == likes
          ? _value._likes
          : likes // ignore: cast_nullable_to_non_nullable
              as List<BookModel>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonBookNavImpl implements _PersonBookNav {
  const _$PersonBookNavImpl(
      {final List<BookModel>? readings, final List<BookModel>? likes})
      : _readings = readings,
        _likes = likes;

  factory _$PersonBookNavImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonBookNavImplFromJson(json);

  final List<BookModel>? _readings;
  @override
  List<BookModel>? get readings {
    final value = _readings;
    if (value == null) return null;
    if (_readings is EqualUnmodifiableListView) return _readings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<BookModel>? _likes;
  @override
  List<BookModel>? get likes {
    final value = _likes;
    if (value == null) return null;
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PersonBookNav(readings: $readings, likes: $likes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonBookNavImpl &&
            const DeepCollectionEquality().equals(other._readings, _readings) &&
            const DeepCollectionEquality().equals(other._likes, _likes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_readings),
      const DeepCollectionEquality().hash(_likes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonBookNavImplCopyWith<_$PersonBookNavImpl> get copyWith =>
      __$$PersonBookNavImplCopyWithImpl<_$PersonBookNavImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonBookNavImplToJson(
      this,
    );
  }
}

abstract class _PersonBookNav implements PersonBookNav {
  const factory _PersonBookNav(
      {final List<BookModel>? readings,
      final List<BookModel>? likes}) = _$PersonBookNavImpl;

  factory _PersonBookNav.fromJson(Map<String, dynamic> json) =
      _$PersonBookNavImpl.fromJson;

  @override
  List<BookModel>? get readings;
  @override
  List<BookModel>? get likes;
  @override
  @JsonKey(ignore: true)
  _$$PersonBookNavImplCopyWith<_$PersonBookNavImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookSearch _$BookSearchFromJson(Map<String, dynamic> json) {
  return _BookSearch.fromJson(json);
}

/// @nodoc
mixin _$BookSearch {
  String? get search => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  String? get publisher => throw _privateConstructorUsedError;
  String? get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookSearchCopyWith<BookSearch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookSearchCopyWith<$Res> {
  factory $BookSearchCopyWith(
          BookSearch value, $Res Function(BookSearch) then) =
      _$BookSearchCopyWithImpl<$Res, BookSearch>;
  @useResult
  $Res call({String? search, String? author, String? publisher, String? tags});
}

/// @nodoc
class _$BookSearchCopyWithImpl<$Res, $Val extends BookSearch>
    implements $BookSearchCopyWith<$Res> {
  _$BookSearchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = freezed,
    Object? author = freezed,
    Object? publisher = freezed,
    Object? tags = freezed,
  }) {
    return _then(_value.copyWith(
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String?,
      publisher: freezed == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookSearchImplCopyWith<$Res>
    implements $BookSearchCopyWith<$Res> {
  factory _$$BookSearchImplCopyWith(
          _$BookSearchImpl value, $Res Function(_$BookSearchImpl) then) =
      __$$BookSearchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? search, String? author, String? publisher, String? tags});
}

/// @nodoc
class __$$BookSearchImplCopyWithImpl<$Res>
    extends _$BookSearchCopyWithImpl<$Res, _$BookSearchImpl>
    implements _$$BookSearchImplCopyWith<$Res> {
  __$$BookSearchImplCopyWithImpl(
      _$BookSearchImpl _value, $Res Function(_$BookSearchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = freezed,
    Object? author = freezed,
    Object? publisher = freezed,
    Object? tags = freezed,
  }) {
    return _then(_$BookSearchImpl(
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String?,
      publisher: freezed == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookSearchImpl implements _BookSearch {
  const _$BookSearchImpl({this.search, this.author, this.publisher, this.tags});

  factory _$BookSearchImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookSearchImplFromJson(json);

  @override
  final String? search;
  @override
  final String? author;
  @override
  final String? publisher;
  @override
  final String? tags;

  @override
  String toString() {
    return 'BookSearch(search: $search, author: $author, publisher: $publisher, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookSearchImpl &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.tags, tags) || other.tags == tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, search, author, publisher, tags);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookSearchImplCopyWith<_$BookSearchImpl> get copyWith =>
      __$$BookSearchImplCopyWithImpl<_$BookSearchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookSearchImplToJson(
      this,
    );
  }
}

abstract class _BookSearch implements BookSearch {
  const factory _BookSearch(
      {final String? search,
      final String? author,
      final String? publisher,
      final String? tags}) = _$BookSearchImpl;

  factory _BookSearch.fromJson(Map<String, dynamic> json) =
      _$BookSearchImpl.fromJson;

  @override
  String? get search;
  @override
  String? get author;
  @override
  String? get publisher;
  @override
  String? get tags;
  @override
  @JsonKey(ignore: true)
  _$$BookSearchImplCopyWith<_$BookSearchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
