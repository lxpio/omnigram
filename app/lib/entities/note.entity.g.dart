// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.entity.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetNoteEntityCollection on Isar {
  IsarCollection<int, NoteEntity> get noteEntitys => this.collection();
}

const NoteEntitySchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'NoteEntity',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'remoteId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'title',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'localPath',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'parentId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'levelPath',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'priority',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'shouldRenderChildren',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'isHoverEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'ctime',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'utime',
        type: IsarType.long,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'remoteId',
        properties: [
          "remoteId",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, NoteEntity>(
    serialize: serializeNoteEntity,
    deserialize: deserializeNoteEntity,
    deserializeProperty: deserializeNoteEntityProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeNoteEntity(IsarWriter writer, NoteEntity object) {
  {
    final value = object.remoteId;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  IsarCore.writeString(writer, 2, object.title);
  {
    final value = object.localPath;
    if (value == null) {
      IsarCore.writeNull(writer, 3);
    } else {
      IsarCore.writeString(writer, 3, value);
    }
  }
  IsarCore.writeLong(writer, 4, object.parentId ?? -9223372036854775808);
  IsarCore.writeString(writer, 5, object.levelPath);
  IsarCore.writeLong(writer, 6, object.priority);
  IsarCore.writeBool(writer, 7, object.shouldRenderChildren);
  IsarCore.writeBool(writer, 8, object.isHoverEnabled);
  IsarCore.writeLong(writer, 9, object.ctime ?? -9223372036854775808);
  IsarCore.writeLong(writer, 10, object.utime ?? -9223372036854775808);
  return object.id;
}

@isarProtected
NoteEntity deserializeNoteEntity(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final String? _remoteId;
  _remoteId = IsarCore.readString(reader, 1);
  final String _title;
  _title = IsarCore.readString(reader, 2) ?? '';
  final String? _localPath;
  _localPath = IsarCore.readString(reader, 3);
  final int? _parentId;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _parentId = null;
    } else {
      _parentId = value;
    }
  }
  final String _levelPath;
  _levelPath = IsarCore.readString(reader, 5) ?? '';
  final int _priority;
  _priority = IsarCore.readLong(reader, 6);
  final bool _shouldRenderChildren;
  _shouldRenderChildren = IsarCore.readBool(reader, 7);
  final bool _isHoverEnabled;
  _isHoverEnabled = IsarCore.readBool(reader, 8);
  final int? _ctime;
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      _ctime = null;
    } else {
      _ctime = value;
    }
  }
  final int? _utime;
  {
    final value = IsarCore.readLong(reader, 10);
    if (value == -9223372036854775808) {
      _utime = null;
    } else {
      _utime = value;
    }
  }
  final object = NoteEntity(
    id: _id,
    remoteId: _remoteId,
    title: _title,
    localPath: _localPath,
    parentId: _parentId,
    levelPath: _levelPath,
    priority: _priority,
    shouldRenderChildren: _shouldRenderChildren,
    isHoverEnabled: _isHoverEnabled,
    ctime: _ctime,
    utime: _utime,
  );
  return object;
}

@isarProtected
dynamic deserializeNoteEntityProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3);
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    case 6:
      return IsarCore.readLong(reader, 6);
    case 7:
      return IsarCore.readBool(reader, 7);
    case 8:
      return IsarCore.readBool(reader, 8);
    case 9:
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 10:
      {
        final value = IsarCore.readLong(reader, 10);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _NoteEntityUpdate {
  bool call({
    required int id,
    String? remoteId,
    String? title,
    String? localPath,
    int? parentId,
    String? levelPath,
    int? priority,
    bool? shouldRenderChildren,
    bool? isHoverEnabled,
    int? ctime,
    int? utime,
  });
}

class _NoteEntityUpdateImpl implements _NoteEntityUpdate {
  const _NoteEntityUpdateImpl(this.collection);

  final IsarCollection<int, NoteEntity> collection;

  @override
  bool call({
    required int id,
    Object? remoteId = ignore,
    Object? title = ignore,
    Object? localPath = ignore,
    Object? parentId = ignore,
    Object? levelPath = ignore,
    Object? priority = ignore,
    Object? shouldRenderChildren = ignore,
    Object? isHoverEnabled = ignore,
    Object? ctime = ignore,
    Object? utime = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (remoteId != ignore) 1: remoteId as String?,
          if (title != ignore) 2: title as String?,
          if (localPath != ignore) 3: localPath as String?,
          if (parentId != ignore) 4: parentId as int?,
          if (levelPath != ignore) 5: levelPath as String?,
          if (priority != ignore) 6: priority as int?,
          if (shouldRenderChildren != ignore) 7: shouldRenderChildren as bool?,
          if (isHoverEnabled != ignore) 8: isHoverEnabled as bool?,
          if (ctime != ignore) 9: ctime as int?,
          if (utime != ignore) 10: utime as int?,
        }) >
        0;
  }
}

sealed class _NoteEntityUpdateAll {
  int call({
    required List<int> id,
    String? remoteId,
    String? title,
    String? localPath,
    int? parentId,
    String? levelPath,
    int? priority,
    bool? shouldRenderChildren,
    bool? isHoverEnabled,
    int? ctime,
    int? utime,
  });
}

class _NoteEntityUpdateAllImpl implements _NoteEntityUpdateAll {
  const _NoteEntityUpdateAllImpl(this.collection);

  final IsarCollection<int, NoteEntity> collection;

  @override
  int call({
    required List<int> id,
    Object? remoteId = ignore,
    Object? title = ignore,
    Object? localPath = ignore,
    Object? parentId = ignore,
    Object? levelPath = ignore,
    Object? priority = ignore,
    Object? shouldRenderChildren = ignore,
    Object? isHoverEnabled = ignore,
    Object? ctime = ignore,
    Object? utime = ignore,
  }) {
    return collection.updateProperties(id, {
      if (remoteId != ignore) 1: remoteId as String?,
      if (title != ignore) 2: title as String?,
      if (localPath != ignore) 3: localPath as String?,
      if (parentId != ignore) 4: parentId as int?,
      if (levelPath != ignore) 5: levelPath as String?,
      if (priority != ignore) 6: priority as int?,
      if (shouldRenderChildren != ignore) 7: shouldRenderChildren as bool?,
      if (isHoverEnabled != ignore) 8: isHoverEnabled as bool?,
      if (ctime != ignore) 9: ctime as int?,
      if (utime != ignore) 10: utime as int?,
    });
  }
}

extension NoteEntityUpdate on IsarCollection<int, NoteEntity> {
  _NoteEntityUpdate get update => _NoteEntityUpdateImpl(this);

  _NoteEntityUpdateAll get updateAll => _NoteEntityUpdateAllImpl(this);
}

sealed class _NoteEntityQueryUpdate {
  int call({
    String? remoteId,
    String? title,
    String? localPath,
    int? parentId,
    String? levelPath,
    int? priority,
    bool? shouldRenderChildren,
    bool? isHoverEnabled,
    int? ctime,
    int? utime,
  });
}

class _NoteEntityQueryUpdateImpl implements _NoteEntityQueryUpdate {
  const _NoteEntityQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<NoteEntity> query;
  final int? limit;

  @override
  int call({
    Object? remoteId = ignore,
    Object? title = ignore,
    Object? localPath = ignore,
    Object? parentId = ignore,
    Object? levelPath = ignore,
    Object? priority = ignore,
    Object? shouldRenderChildren = ignore,
    Object? isHoverEnabled = ignore,
    Object? ctime = ignore,
    Object? utime = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (remoteId != ignore) 1: remoteId as String?,
      if (title != ignore) 2: title as String?,
      if (localPath != ignore) 3: localPath as String?,
      if (parentId != ignore) 4: parentId as int?,
      if (levelPath != ignore) 5: levelPath as String?,
      if (priority != ignore) 6: priority as int?,
      if (shouldRenderChildren != ignore) 7: shouldRenderChildren as bool?,
      if (isHoverEnabled != ignore) 8: isHoverEnabled as bool?,
      if (ctime != ignore) 9: ctime as int?,
      if (utime != ignore) 10: utime as int?,
    });
  }
}

extension NoteEntityQueryUpdate on IsarQuery<NoteEntity> {
  _NoteEntityQueryUpdate get updateFirst =>
      _NoteEntityQueryUpdateImpl(this, limit: 1);

  _NoteEntityQueryUpdate get updateAll => _NoteEntityQueryUpdateImpl(this);
}

class _NoteEntityQueryBuilderUpdateImpl implements _NoteEntityQueryUpdate {
  const _NoteEntityQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<NoteEntity, NoteEntity, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? remoteId = ignore,
    Object? title = ignore,
    Object? localPath = ignore,
    Object? parentId = ignore,
    Object? levelPath = ignore,
    Object? priority = ignore,
    Object? shouldRenderChildren = ignore,
    Object? isHoverEnabled = ignore,
    Object? ctime = ignore,
    Object? utime = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (remoteId != ignore) 1: remoteId as String?,
        if (title != ignore) 2: title as String?,
        if (localPath != ignore) 3: localPath as String?,
        if (parentId != ignore) 4: parentId as int?,
        if (levelPath != ignore) 5: levelPath as String?,
        if (priority != ignore) 6: priority as int?,
        if (shouldRenderChildren != ignore) 7: shouldRenderChildren as bool?,
        if (isHoverEnabled != ignore) 8: isHoverEnabled as bool?,
        if (ctime != ignore) 9: ctime as int?,
        if (utime != ignore) 10: utime as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension NoteEntityQueryBuilderUpdate
    on QueryBuilder<NoteEntity, NoteEntity, QOperations> {
  _NoteEntityQueryUpdate get updateFirst =>
      _NoteEntityQueryBuilderUpdateImpl(this, limit: 1);

  _NoteEntityQueryUpdate get updateAll =>
      _NoteEntityQueryBuilderUpdateImpl(this);
}

extension NoteEntityQueryFilter
    on QueryBuilder<NoteEntity, NoteEntity, QFilterCondition> {
  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> remoteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      remoteIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> remoteIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      remoteIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      remoteIdGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> remoteIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      remoteIdLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> remoteIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      remoteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> remoteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> remoteIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> remoteIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleEqualTo(
    String value, {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleGreaterThan(
    String value, {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      titleGreaterThanOrEqualTo(
    String value, {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleLessThan(
    String value, {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      titleLessThanOrEqualTo(
    String value, {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleContains(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      localPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      localPathIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> localPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      localPathGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      localPathGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> localPathLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      localPathLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> localPathBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      localPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> localPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> localPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> localPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      localPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      localPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> parentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      parentIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> parentIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      parentIdGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      parentIdGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> parentIdLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      parentIdLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> parentIdBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> levelPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      levelPathGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      levelPathGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> levelPathLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      levelPathLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> levelPathBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      levelPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> levelPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> levelPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> levelPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      levelPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      levelPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> priorityEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      priorityGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      priorityGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> priorityLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      priorityLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> priorityBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      shouldRenderChildrenEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      isHoverEnabledEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> ctimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> ctimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> ctimeEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> ctimeGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      ctimeGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> ctimeLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      ctimeLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> ctimeBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> utimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> utimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> utimeEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> utimeGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      utimeGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> utimeLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
      utimeLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> utimeBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension NoteEntityQueryObject
    on QueryBuilder<NoteEntity, NoteEntity, QFilterCondition> {}

extension NoteEntityQuerySortBy
    on QueryBuilder<NoteEntity, NoteEntity, QSortBy> {
  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByRemoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByRemoteIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByTitleDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByLocalPathDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByLevelPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByLevelPathDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy>
      sortByShouldRenderChildren() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy>
      sortByShouldRenderChildrenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByIsHoverEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy>
      sortByIsHoverEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByCtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByCtimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByUtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByUtimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension NoteEntityQuerySortThenBy
    on QueryBuilder<NoteEntity, NoteEntity, QSortThenBy> {
  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByRemoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByRemoteIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByTitleDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByLocalPathDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByLevelPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByLevelPathDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy>
      thenByShouldRenderChildren() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy>
      thenByShouldRenderChildrenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByIsHoverEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy>
      thenByIsHoverEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByCtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByCtimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByUtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByUtimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension NoteEntityQueryWhereDistinct
    on QueryBuilder<NoteEntity, NoteEntity, QDistinct> {
  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct> distinctByRemoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct> distinctByLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct> distinctByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct> distinctByLevelPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct> distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct>
      distinctByShouldRenderChildren() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct>
      distinctByIsHoverEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct> distinctByCtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterDistinct> distinctByUtime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }
}

extension NoteEntityQueryProperty1
    on QueryBuilder<NoteEntity, NoteEntity, QProperty> {
  QueryBuilder<NoteEntity, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteEntity, String?, QAfterProperty> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteEntity, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteEntity, String?, QAfterProperty> localPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NoteEntity, int?, QAfterProperty> parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NoteEntity, String, QAfterProperty> levelPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NoteEntity, int, QAfterProperty> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<NoteEntity, bool, QAfterProperty>
      shouldRenderChildrenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<NoteEntity, bool, QAfterProperty> isHoverEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<NoteEntity, int?, QAfterProperty> ctimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<NoteEntity, int?, QAfterProperty> utimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension NoteEntityQueryProperty2<R>
    on QueryBuilder<NoteEntity, R, QAfterProperty> {
  QueryBuilder<NoteEntity, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteEntity, (R, String?), QAfterProperty> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteEntity, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteEntity, (R, String?), QAfterProperty> localPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NoteEntity, (R, int?), QAfterProperty> parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NoteEntity, (R, String), QAfterProperty> levelPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NoteEntity, (R, int), QAfterProperty> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<NoteEntity, (R, bool), QAfterProperty>
      shouldRenderChildrenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<NoteEntity, (R, bool), QAfterProperty> isHoverEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<NoteEntity, (R, int?), QAfterProperty> ctimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<NoteEntity, (R, int?), QAfterProperty> utimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension NoteEntityQueryProperty3<R1, R2>
    on QueryBuilder<NoteEntity, (R1, R2), QAfterProperty> {
  QueryBuilder<NoteEntity, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, String?), QOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, String), QOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, String?), QOperations> localPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, int?), QOperations> parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, String), QOperations> levelPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, int), QOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, bool), QOperations>
      shouldRenderChildrenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, bool), QOperations>
      isHoverEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, int?), QOperations> ctimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<NoteEntity, (R1, R2, int?), QOperations> utimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}
