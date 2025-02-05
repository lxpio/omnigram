//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/ebook_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ebook_resp_dto.g.dart';

/// EbookRespDto
///
/// Properties:
/// * [total] 
/// * [items] 
@BuiltValue()
abstract class EbookRespDto implements Built<EbookRespDto, EbookRespDtoBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'items')
  BuiltList<EbookDto> get items;

  EbookRespDto._();

  factory EbookRespDto([void updates(EbookRespDtoBuilder b)]) = _$EbookRespDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EbookRespDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EbookRespDto> get serializer => _$EbookRespDtoSerializer();
}

class _$EbookRespDtoSerializer implements PrimitiveSerializer<EbookRespDto> {
  @override
  final Iterable<Type> types = const [EbookRespDto, _$EbookRespDto];

  @override
  final String wireName = r'EbookRespDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EbookRespDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(EbookDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EbookRespDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EbookRespDtoBuilder result,
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
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(EbookDto)]),
          ) as BuiltList<EbookDto>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EbookRespDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EbookRespDtoBuilder();
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

