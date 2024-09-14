//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/ebook_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ebook_index_dto.g.dart';

/// EbookIndexDto
///
/// Properties:
/// * [random] 
/// * [recent] 
@BuiltValue()
abstract class EbookIndexDto implements Built<EbookIndexDto, EbookIndexDtoBuilder> {
  @BuiltValueField(wireName: r'random')
  BuiltList<EbookDto> get random;

  @BuiltValueField(wireName: r'recent')
  BuiltList<EbookDto> get recent;

  EbookIndexDto._();

  factory EbookIndexDto([void updates(EbookIndexDtoBuilder b)]) = _$EbookIndexDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EbookIndexDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EbookIndexDto> get serializer => _$EbookIndexDtoSerializer();
}

class _$EbookIndexDtoSerializer implements PrimitiveSerializer<EbookIndexDto> {
  @override
  final Iterable<Type> types = const [EbookIndexDto, _$EbookIndexDto];

  @override
  final String wireName = r'EbookIndexDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EbookIndexDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'random';
    yield serializers.serialize(
      object.random,
      specifiedType: const FullType(BuiltList, [FullType(EbookDto)]),
    );
    yield r'recent';
    yield serializers.serialize(
      object.recent,
      specifiedType: const FullType(BuiltList, [FullType(EbookDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EbookIndexDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EbookIndexDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'random':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(EbookDto)]),
          ) as BuiltList<EbookDto>;
          result.random.replace(valueDes);
          break;
        case r'recent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(EbookDto)]),
          ) as BuiltList<EbookDto>;
          result.recent.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EbookIndexDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EbookIndexDtoBuilder();
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

