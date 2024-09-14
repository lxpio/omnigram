// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_message.entity.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetLoggerMessageCollection on Isar {
  IsarCollection<int, LoggerMessage> get loggerMessages => this.collection();
}

const LoggerMessageSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'LoggerMessage',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'message',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'details',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'level',
        type: IsarType.byte,
        enumMap: {
          "ALL": 0,
          "FINEST": 1,
          "FINER": 2,
          "FINE": 3,
          "CONFIG": 4,
          "INFO": 5,
          "WARNING": 6,
          "SEVERE": 7,
          "SHOUT": 8,
          "OFF": 9
        },
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'context1',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'context2',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, LoggerMessage>(
    serialize: serializeLoggerMessage,
    deserialize: deserializeLoggerMessage,
    deserializeProperty: deserializeLoggerMessageProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeLoggerMessage(IsarWriter writer, LoggerMessage object) {
  IsarCore.writeString(writer, 1, object.message);
  {
    final value = object.details;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  IsarCore.writeByte(writer, 3, object.level.index);
  IsarCore.writeLong(
      writer, 4, object.createdAt.toUtc().microsecondsSinceEpoch);
  {
    final value = object.context1;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeString(writer, 5, value);
    }
  }
  {
    final value = object.context2;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  return object.id;
}

@isarProtected
LoggerMessage deserializeLoggerMessage(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final String _message;
  _message = IsarCore.readString(reader, 1) ?? '';
  final String? _details;
  _details = IsarCore.readString(reader, 2);
  final LogLevel _level;
  {
    if (IsarCore.readNull(reader, 3)) {
      _level = LogLevel.ALL;
    } else {
      _level =
          _loggerMessageLevel[IsarCore.readByte(reader, 3)] ?? LogLevel.ALL;
    }
  }
  final DateTime _createdAt;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final String? _context1;
  _context1 = IsarCore.readString(reader, 5);
  final String? _context2;
  _context2 = IsarCore.readString(reader, 6);
  final object = LoggerMessage(
    id: _id,
    message: _message,
    details: _details,
    level: _level,
    createdAt: _createdAt,
    context1: _context1,
    context2: _context2,
  );
  return object;
}

@isarProtected
dynamic deserializeLoggerMessageProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2);
    case 3:
      {
        if (IsarCore.readNull(reader, 3)) {
          return LogLevel.ALL;
        } else {
          return _loggerMessageLevel[IsarCore.readByte(reader, 3)] ??
              LogLevel.ALL;
        }
      }
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 5:
      return IsarCore.readString(reader, 5);
    case 6:
      return IsarCore.readString(reader, 6);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _LoggerMessageUpdate {
  bool call({
    required int id,
    String? message,
    String? details,
    LogLevel? level,
    DateTime? createdAt,
    String? context1,
    String? context2,
  });
}

class _LoggerMessageUpdateImpl implements _LoggerMessageUpdate {
  const _LoggerMessageUpdateImpl(this.collection);

  final IsarCollection<int, LoggerMessage> collection;

  @override
  bool call({
    required int id,
    Object? message = ignore,
    Object? details = ignore,
    Object? level = ignore,
    Object? createdAt = ignore,
    Object? context1 = ignore,
    Object? context2 = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (message != ignore) 1: message as String?,
          if (details != ignore) 2: details as String?,
          if (level != ignore) 3: level as LogLevel?,
          if (createdAt != ignore) 4: createdAt as DateTime?,
          if (context1 != ignore) 5: context1 as String?,
          if (context2 != ignore) 6: context2 as String?,
        }) >
        0;
  }
}

sealed class _LoggerMessageUpdateAll {
  int call({
    required List<int> id,
    String? message,
    String? details,
    LogLevel? level,
    DateTime? createdAt,
    String? context1,
    String? context2,
  });
}

class _LoggerMessageUpdateAllImpl implements _LoggerMessageUpdateAll {
  const _LoggerMessageUpdateAllImpl(this.collection);

  final IsarCollection<int, LoggerMessage> collection;

  @override
  int call({
    required List<int> id,
    Object? message = ignore,
    Object? details = ignore,
    Object? level = ignore,
    Object? createdAt = ignore,
    Object? context1 = ignore,
    Object? context2 = ignore,
  }) {
    return collection.updateProperties(id, {
      if (message != ignore) 1: message as String?,
      if (details != ignore) 2: details as String?,
      if (level != ignore) 3: level as LogLevel?,
      if (createdAt != ignore) 4: createdAt as DateTime?,
      if (context1 != ignore) 5: context1 as String?,
      if (context2 != ignore) 6: context2 as String?,
    });
  }
}

extension LoggerMessageUpdate on IsarCollection<int, LoggerMessage> {
  _LoggerMessageUpdate get update => _LoggerMessageUpdateImpl(this);

  _LoggerMessageUpdateAll get updateAll => _LoggerMessageUpdateAllImpl(this);
}

sealed class _LoggerMessageQueryUpdate {
  int call({
    String? message,
    String? details,
    LogLevel? level,
    DateTime? createdAt,
    String? context1,
    String? context2,
  });
}

class _LoggerMessageQueryUpdateImpl implements _LoggerMessageQueryUpdate {
  const _LoggerMessageQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<LoggerMessage> query;
  final int? limit;

  @override
  int call({
    Object? message = ignore,
    Object? details = ignore,
    Object? level = ignore,
    Object? createdAt = ignore,
    Object? context1 = ignore,
    Object? context2 = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (message != ignore) 1: message as String?,
      if (details != ignore) 2: details as String?,
      if (level != ignore) 3: level as LogLevel?,
      if (createdAt != ignore) 4: createdAt as DateTime?,
      if (context1 != ignore) 5: context1 as String?,
      if (context2 != ignore) 6: context2 as String?,
    });
  }
}

extension LoggerMessageQueryUpdate on IsarQuery<LoggerMessage> {
  _LoggerMessageQueryUpdate get updateFirst =>
      _LoggerMessageQueryUpdateImpl(this, limit: 1);

  _LoggerMessageQueryUpdate get updateAll =>
      _LoggerMessageQueryUpdateImpl(this);
}

class _LoggerMessageQueryBuilderUpdateImpl
    implements _LoggerMessageQueryUpdate {
  const _LoggerMessageQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<LoggerMessage, LoggerMessage, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? message = ignore,
    Object? details = ignore,
    Object? level = ignore,
    Object? createdAt = ignore,
    Object? context1 = ignore,
    Object? context2 = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (message != ignore) 1: message as String?,
        if (details != ignore) 2: details as String?,
        if (level != ignore) 3: level as LogLevel?,
        if (createdAt != ignore) 4: createdAt as DateTime?,
        if (context1 != ignore) 5: context1 as String?,
        if (context2 != ignore) 6: context2 as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension LoggerMessageQueryBuilderUpdate
    on QueryBuilder<LoggerMessage, LoggerMessage, QOperations> {
  _LoggerMessageQueryUpdate get updateFirst =>
      _LoggerMessageQueryBuilderUpdateImpl(this, limit: 1);

  _LoggerMessageQueryUpdate get updateAll =>
      _LoggerMessageQueryBuilderUpdateImpl(this);
}

const _loggerMessageLevel = {
  0: LogLevel.ALL,
  1: LogLevel.FINEST,
  2: LogLevel.FINER,
  3: LogLevel.FINE,
  4: LogLevel.CONFIG,
  5: LogLevel.INFO,
  6: LogLevel.WARNING,
  7: LogLevel.SEVERE,
  8: LogLevel.SHOUT,
  9: LogLevel.OFF,
};

extension LoggerMessageQueryFilter
    on QueryBuilder<LoggerMessage, LoggerMessage, QFilterCondition> {
  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageEqualTo(
    String value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageGreaterThan(
    String value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageGreaterThanOrEqualTo(
    String value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageLessThan(
    String value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageLessThanOrEqualTo(
    String value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageBetween(
    String lower,
    String upper, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageStartsWith(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageEndsWith(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsEqualTo(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsGreaterThan(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsGreaterThanOrEqualTo(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsLessThan(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsLessThanOrEqualTo(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsBetween(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsStartsWith(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsEndsWith(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      detailsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      levelEqualTo(
    LogLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      levelGreaterThan(
    LogLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      levelGreaterThanOrEqualTo(
    LogLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      levelLessThan(
    LogLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      levelLessThanOrEqualTo(
    LogLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      levelBetween(
    LogLevel lower,
    LogLevel upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      createdAtEqualTo(
    DateTime value,
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value,
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value,
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1IsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1EqualTo(
    String? value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1GreaterThan(
    String? value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1GreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1LessThan(
    String? value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1LessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1Between(
    String? lower,
    String? upper, {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1StartsWith(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1EndsWith(
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1Contains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1Matches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context1IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2IsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2GreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2GreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2LessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2LessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2Between(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterFilterCondition>
      context2IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }
}

extension LoggerMessageQueryObject
    on QueryBuilder<LoggerMessage, LoggerMessage, QFilterCondition> {}

extension LoggerMessageQuerySortBy
    on QueryBuilder<LoggerMessage, LoggerMessage, QSortBy> {
  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByMessageDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByDetails(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByDetailsDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByContext1(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByContext1Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByContext2(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> sortByContext2Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension LoggerMessageQuerySortThenBy
    on QueryBuilder<LoggerMessage, LoggerMessage, QSortThenBy> {
  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByMessageDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByDetails(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByDetailsDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByContext1(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByContext1Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByContext2(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterSortBy> thenByContext2Desc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension LoggerMessageQueryWhereDistinct
    on QueryBuilder<LoggerMessage, LoggerMessage, QDistinct> {
  QueryBuilder<LoggerMessage, LoggerMessage, QAfterDistinct> distinctByMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterDistinct> distinctByDetails(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterDistinct> distinctByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterDistinct> distinctByContext1(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoggerMessage, LoggerMessage, QAfterDistinct> distinctByContext2(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }
}

extension LoggerMessageQueryProperty1
    on QueryBuilder<LoggerMessage, LoggerMessage, QProperty> {
  QueryBuilder<LoggerMessage, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<LoggerMessage, String, QAfterProperty> messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LoggerMessage, String?, QAfterProperty> detailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LoggerMessage, LogLevel, QAfterProperty> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LoggerMessage, DateTime, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LoggerMessage, String?, QAfterProperty> context1Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LoggerMessage, String?, QAfterProperty> context2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension LoggerMessageQueryProperty2<R>
    on QueryBuilder<LoggerMessage, R, QAfterProperty> {
  QueryBuilder<LoggerMessage, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<LoggerMessage, (R, String), QAfterProperty> messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LoggerMessage, (R, String?), QAfterProperty> detailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LoggerMessage, (R, LogLevel), QAfterProperty> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LoggerMessage, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LoggerMessage, (R, String?), QAfterProperty> context1Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LoggerMessage, (R, String?), QAfterProperty> context2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension LoggerMessageQueryProperty3<R1, R2>
    on QueryBuilder<LoggerMessage, (R1, R2), QAfterProperty> {
  QueryBuilder<LoggerMessage, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<LoggerMessage, (R1, R2, String), QOperations> messageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LoggerMessage, (R1, R2, String?), QOperations>
      detailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LoggerMessage, (R1, R2, LogLevel), QOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LoggerMessage, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LoggerMessage, (R1, R2, String?), QOperations>
      context1Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LoggerMessage, (R1, R2, String?), QOperations>
      context2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}
