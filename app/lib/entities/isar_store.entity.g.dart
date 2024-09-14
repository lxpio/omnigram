// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_store.entity.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetStoreValueCollection on Isar {
  IsarCollection<int, StoreValue> get storeValues => this.collection();
}

const StoreValueSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'StoreValue',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'intValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'strValue',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, StoreValue>(
    serialize: serializeStoreValue,
    deserialize: deserializeStoreValue,
    deserializeProperty: deserializeStoreValueProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeStoreValue(IsarWriter writer, StoreValue object) {
  IsarCore.writeLong(writer, 1, object.intValue ?? -9223372036854775808);
  {
    final value = object.strValue;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  return object.id;
}

@isarProtected
StoreValue deserializeStoreValue(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final int? _intValue;
  {
    final value = IsarCore.readLong(reader, 1);
    if (value == -9223372036854775808) {
      _intValue = null;
    } else {
      _intValue = value;
    }
  }
  final String? _strValue;
  _strValue = IsarCore.readString(reader, 2);
  final object = StoreValue(
    _id,
    intValue: _intValue,
    strValue: _strValue,
  );
  return object;
}

@isarProtected
dynamic deserializeStoreValueProp(IsarReader reader, int property) {
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
      return IsarCore.readString(reader, 2);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _StoreValueUpdate {
  bool call({
    required int id,
    int? intValue,
    String? strValue,
  });
}

class _StoreValueUpdateImpl implements _StoreValueUpdate {
  const _StoreValueUpdateImpl(this.collection);

  final IsarCollection<int, StoreValue> collection;

  @override
  bool call({
    required int id,
    Object? intValue = ignore,
    Object? strValue = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (intValue != ignore) 1: intValue as int?,
          if (strValue != ignore) 2: strValue as String?,
        }) >
        0;
  }
}

sealed class _StoreValueUpdateAll {
  int call({
    required List<int> id,
    int? intValue,
    String? strValue,
  });
}

class _StoreValueUpdateAllImpl implements _StoreValueUpdateAll {
  const _StoreValueUpdateAllImpl(this.collection);

  final IsarCollection<int, StoreValue> collection;

  @override
  int call({
    required List<int> id,
    Object? intValue = ignore,
    Object? strValue = ignore,
  }) {
    return collection.updateProperties(id, {
      if (intValue != ignore) 1: intValue as int?,
      if (strValue != ignore) 2: strValue as String?,
    });
  }
}

extension StoreValueUpdate on IsarCollection<int, StoreValue> {
  _StoreValueUpdate get update => _StoreValueUpdateImpl(this);

  _StoreValueUpdateAll get updateAll => _StoreValueUpdateAllImpl(this);
}

sealed class _StoreValueQueryUpdate {
  int call({
    int? intValue,
    String? strValue,
  });
}

class _StoreValueQueryUpdateImpl implements _StoreValueQueryUpdate {
  const _StoreValueQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<StoreValue> query;
  final int? limit;

  @override
  int call({
    Object? intValue = ignore,
    Object? strValue = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (intValue != ignore) 1: intValue as int?,
      if (strValue != ignore) 2: strValue as String?,
    });
  }
}

extension StoreValueQueryUpdate on IsarQuery<StoreValue> {
  _StoreValueQueryUpdate get updateFirst =>
      _StoreValueQueryUpdateImpl(this, limit: 1);

  _StoreValueQueryUpdate get updateAll => _StoreValueQueryUpdateImpl(this);
}

class _StoreValueQueryBuilderUpdateImpl implements _StoreValueQueryUpdate {
  const _StoreValueQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<StoreValue, StoreValue, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? intValue = ignore,
    Object? strValue = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (intValue != ignore) 1: intValue as int?,
        if (strValue != ignore) 2: strValue as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension StoreValueQueryBuilderUpdate
    on QueryBuilder<StoreValue, StoreValue, QOperations> {
  _StoreValueQueryUpdate get updateFirst =>
      _StoreValueQueryBuilderUpdateImpl(this, limit: 1);

  _StoreValueQueryUpdate get updateAll =>
      _StoreValueQueryBuilderUpdateImpl(this);
}

extension StoreValueQueryFilter
    on QueryBuilder<StoreValue, StoreValue, QFilterCondition> {
  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      idLessThanOrEqualTo(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> idBetween(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> intValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      intValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> intValueEqualTo(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      intValueGreaterThan(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      intValueGreaterThanOrEqualTo(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> intValueLessThan(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      intValueLessThanOrEqualTo(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> intValueBetween(
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

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> strValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      strValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> strValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      strValueGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      strValueGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> strValueLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      strValueLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> strValueBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      strValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> strValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> strValueContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition> strValueMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      strValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterFilterCondition>
      strValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }
}

extension StoreValueQueryObject
    on QueryBuilder<StoreValue, StoreValue, QFilterCondition> {}

extension StoreValueQuerySortBy
    on QueryBuilder<StoreValue, StoreValue, QSortBy> {
  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> sortByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> sortByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> sortByStrValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> sortByStrValueDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension StoreValueQuerySortThenBy
    on QueryBuilder<StoreValue, StoreValue, QSortThenBy> {
  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> thenByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> thenByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> thenByStrValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterSortBy> thenByStrValueDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension StoreValueQueryWhereDistinct
    on QueryBuilder<StoreValue, StoreValue, QDistinct> {
  QueryBuilder<StoreValue, StoreValue, QAfterDistinct> distinctByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<StoreValue, StoreValue, QAfterDistinct> distinctByStrValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }
}

extension StoreValueQueryProperty1
    on QueryBuilder<StoreValue, StoreValue, QProperty> {
  QueryBuilder<StoreValue, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<StoreValue, int?, QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<StoreValue, String?, QAfterProperty> strValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension StoreValueQueryProperty2<R>
    on QueryBuilder<StoreValue, R, QAfterProperty> {
  QueryBuilder<StoreValue, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<StoreValue, (R, int?), QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<StoreValue, (R, String?), QAfterProperty> strValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension StoreValueQueryProperty3<R1, R2>
    on QueryBuilder<StoreValue, (R1, R2), QAfterProperty> {
  QueryBuilder<StoreValue, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<StoreValue, (R1, R2, int?), QOperations> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<StoreValue, (R1, R2, String?), QOperations> strValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}
