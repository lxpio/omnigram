// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etag.entity.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetETagCollection on Isar {
  IsarCollection<int, ETag> get eTags => this.collection();
}

const ETagSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'ETag',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'bookCount',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'utime',
        type: IsarType.long,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, ETag>(
    serialize: serializeETag,
    deserialize: deserializeETag,
    deserializeProperty: deserializeETagProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeETag(IsarWriter writer, ETag object) {
  IsarCore.writeLong(writer, 1, object.bookCount ?? -9223372036854775808);
  IsarCore.writeLong(writer, 2, object.utime);
  return object.id;
}

@isarProtected
ETag deserializeETag(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final int? _bookCount;
  {
    final value = IsarCore.readLong(reader, 1);
    if (value == -9223372036854775808) {
      _bookCount = null;
    } else {
      _bookCount = value;
    }
  }
  final int _utime;
  _utime = IsarCore.readLong(reader, 2);
  final object = ETag(
    id: _id,
    bookCount: _bookCount,
    utime: _utime,
  );
  return object;
}

@isarProtected
dynamic deserializeETagProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      {
        final value = IsarCore.readLong(reader, 1);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 2:
      return IsarCore.readLong(reader, 2);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _ETagUpdate {
  bool call({
    required int id,
    int? bookCount,
    int? utime,
  });
}

class _ETagUpdateImpl implements _ETagUpdate {
  const _ETagUpdateImpl(this.collection);

  final IsarCollection<int, ETag> collection;

  @override
  bool call({
    required int id,
    Object? bookCount = ignore,
    Object? utime = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (bookCount != ignore) 1: bookCount as int?,
          if (utime != ignore) 2: utime as int?,
        }) >
        0;
  }
}

sealed class _ETagUpdateAll {
  int call({
    required List<int> id,
    int? bookCount,
    int? utime,
  });
}

class _ETagUpdateAllImpl implements _ETagUpdateAll {
  const _ETagUpdateAllImpl(this.collection);

  final IsarCollection<int, ETag> collection;

  @override
  int call({
    required List<int> id,
    Object? bookCount = ignore,
    Object? utime = ignore,
  }) {
    return collection.updateProperties(id, {
      if (bookCount != ignore) 1: bookCount as int?,
      if (utime != ignore) 2: utime as int?,
    });
  }
}

extension ETagUpdate on IsarCollection<int, ETag> {
  _ETagUpdate get update => _ETagUpdateImpl(this);

  _ETagUpdateAll get updateAll => _ETagUpdateAllImpl(this);
}

sealed class _ETagQueryUpdate {
  int call({
    int? bookCount,
    int? utime,
  });
}

class _ETagQueryUpdateImpl implements _ETagQueryUpdate {
  const _ETagQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<ETag> query;
  final int? limit;

  @override
  int call({
    Object? bookCount = ignore,
    Object? utime = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (bookCount != ignore) 1: bookCount as int?,
      if (utime != ignore) 2: utime as int?,
    });
  }
}

extension ETagQueryUpdate on IsarQuery<ETag> {
  _ETagQueryUpdate get updateFirst => _ETagQueryUpdateImpl(this, limit: 1);

  _ETagQueryUpdate get updateAll => _ETagQueryUpdateImpl(this);
}

class _ETagQueryBuilderUpdateImpl implements _ETagQueryUpdate {
  const _ETagQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<ETag, ETag, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? bookCount = ignore,
    Object? utime = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (bookCount != ignore) 1: bookCount as int?,
        if (utime != ignore) 2: utime as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension ETagQueryBuilderUpdate on QueryBuilder<ETag, ETag, QOperations> {
  _ETagQueryUpdate get updateFirst =>
      _ETagQueryBuilderUpdateImpl(this, limit: 1);

  _ETagQueryUpdate get updateAll => _ETagQueryBuilderUpdateImpl(this);
}

extension ETagQueryFilter on QueryBuilder<ETag, ETag, QFilterCondition> {
  QueryBuilder<ETag, ETag, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> bookCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> bookCountIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> bookCountEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> bookCountGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> bookCountGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> bookCountLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> bookCountLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> bookCountBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> utimeEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> utimeGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> utimeGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> utimeLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> utimeLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ETag, ETag, QAfterFilterCondition> utimeBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension ETagQueryObject on QueryBuilder<ETag, ETag, QFilterCondition> {}

extension ETagQuerySortBy on QueryBuilder<ETag, ETag, QSortBy> {
  QueryBuilder<ETag, ETag, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> sortByBookCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> sortByBookCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> sortByUtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> sortByUtimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension ETagQuerySortThenBy on QueryBuilder<ETag, ETag, QSortThenBy> {
  QueryBuilder<ETag, ETag, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> thenByBookCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> thenByBookCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> thenByUtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<ETag, ETag, QAfterSortBy> thenByUtimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension ETagQueryWhereDistinct on QueryBuilder<ETag, ETag, QDistinct> {
  QueryBuilder<ETag, ETag, QAfterDistinct> distinctByBookCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<ETag, ETag, QAfterDistinct> distinctByUtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }
}

extension ETagQueryProperty1 on QueryBuilder<ETag, ETag, QProperty> {
  QueryBuilder<ETag, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ETag, int?, QAfterProperty> bookCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ETag, int, QAfterProperty> utimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension ETagQueryProperty2<R> on QueryBuilder<ETag, R, QAfterProperty> {
  QueryBuilder<ETag, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ETag, (R, int?), QAfterProperty> bookCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ETag, (R, int), QAfterProperty> utimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension ETagQueryProperty3<R1, R2>
    on QueryBuilder<ETag, (R1, R2), QAfterProperty> {
  QueryBuilder<ETag, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ETag, (R1, R2, int?), QOperations> bookCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ETag, (R1, R2, int), QOperations> utimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}
