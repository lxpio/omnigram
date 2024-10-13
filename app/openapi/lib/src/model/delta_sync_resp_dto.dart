//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/ebook_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delta_sync_resp_dto.g.dart';

/// DeltaSyncRespDto
///
/// Properties:
/// * [needFullSync] 
/// * [deleted] 
/// * [upserted] 
@BuiltValue()
abstract class DeltaSyncRespDto implements Built<DeltaSyncRespDto, DeltaSyncRespDtoBuilder> {
  @BuiltValueField(wireName: r'need_full_sync')
  bool get needFullSync;

  @BuiltValueField(wireName: r'deleted')
  BuiltList<String> get deleted;

  @BuiltValueField(wireName: r'upserted')
  BuiltList<EbookDto> get upserted;

  DeltaSyncRespDto._();

  factory DeltaSyncRespDto([void updates(DeltaSyncRespDtoBuilder b)]) = _$DeltaSyncRespDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeltaSyncRespDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeltaSyncRespDto> get serializer => _$DeltaSyncRespDtoSerializer();
}

class _$DeltaSyncRespDtoSerializer implements PrimitiveSerializer<DeltaSyncRespDto> {
  @override
  final Iterable<Type> types = const [DeltaSyncRespDto, _$DeltaSyncRespDto];

  @override
  final String wireName = r'DeltaSyncRespDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeltaSyncRespDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'need_full_sync';
    yield serializers.serialize(
      object.needFullSync,
      specifiedType: const FullType(bool),
    );
    yield r'deleted';
    yield serializers.serialize(
      object.deleted,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'upserted';
    yield serializers.serialize(
      object.upserted,
      specifiedType: const FullType(BuiltList, [FullType(EbookDto)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeltaSyncRespDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeltaSyncRespDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'need_full_sync':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.needFullSync = valueDes;
          break;
        case r'deleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.deleted.replace(valueDes);
          break;
        case r'upserted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(EbookDto)]),
          ) as BuiltList<EbookDto>;
          result.upserted.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeltaSyncRespDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeltaSyncRespDtoBuilder();
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

