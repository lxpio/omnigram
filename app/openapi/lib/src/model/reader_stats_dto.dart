//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reader_stats_dto.g.dart';

/// ReaderStatsDto
///
/// Properties:
/// * [total] 
/// * [authors] 
/// * [publisher] 
/// * [tags] 
@BuiltValue()
abstract class ReaderStatsDto implements Built<ReaderStatsDto, ReaderStatsDtoBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'authors')
  int get authors;

  @BuiltValueField(wireName: r'publisher')
  int get publisher;

  @BuiltValueField(wireName: r'tags')
  int get tags;

  ReaderStatsDto._();

  factory ReaderStatsDto([void updates(ReaderStatsDtoBuilder b)]) = _$ReaderStatsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReaderStatsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReaderStatsDto> get serializer => _$ReaderStatsDtoSerializer();
}

class _$ReaderStatsDtoSerializer implements PrimitiveSerializer<ReaderStatsDto> {
  @override
  final Iterable<Type> types = const [ReaderStatsDto, _$ReaderStatsDto];

  @override
  final String wireName = r'ReaderStatsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReaderStatsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'authors';
    yield serializers.serialize(
      object.authors,
      specifiedType: const FullType(int),
    );
    yield r'publisher';
    yield serializers.serialize(
      object.publisher,
      specifiedType: const FullType(int),
    );
    yield r'tags';
    yield serializers.serialize(
      object.tags,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReaderStatsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReaderStatsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        case r'authors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.authors = valueDes;
          break;
        case r'publisher':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.publisher = valueDes;
          break;
        case r'tags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.tags = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReaderStatsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReaderStatsDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

