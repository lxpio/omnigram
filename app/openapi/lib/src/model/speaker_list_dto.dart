//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/speaker_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'speaker_list_dto.g.dart';

/// SpeakerListDto
///
/// Properties:
/// * [total] 
/// * [items] 
@BuiltValue()
abstract class SpeakerListDto implements Built<SpeakerListDto, SpeakerListDtoBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'items')
  BuiltList<SpeakerDto> get items;

  SpeakerListDto._();

  factory SpeakerListDto([void updates(SpeakerListDtoBuilder b)]) = _$SpeakerListDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SpeakerListDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SpeakerListDto> get serializer => _$SpeakerListDtoSerializer();
}

class _$SpeakerListDtoSerializer implements PrimitiveSerializer<SpeakerListDto> {
  @override
  final Iterable<Type> types = const [SpeakerListDto, _$SpeakerListDto];

  @override
  final String wireName = r'SpeakerListDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SpeakerListDto object, {
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
      specifiedType: const FullType(BuiltList, [FullType(SpeakerDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SpeakerListDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SpeakerListDtoBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(SpeakerDto)]),
          ) as BuiltList<SpeakerDto>;
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
  SpeakerListDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SpeakerListDtoBuilder();
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

