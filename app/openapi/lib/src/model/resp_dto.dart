//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resp_dto.g.dart';

/// RespDto
///
/// Properties:
/// * [code] - 错误码/响应码
/// * [message] - 一般信息/错误信息
@BuiltValue()
abstract class RespDto implements Built<RespDto, RespDtoBuilder> {
  /// 错误码/响应码
  @BuiltValueField(wireName: r'code')
  int get code;

  /// 一般信息/错误信息
  @BuiltValueField(wireName: r'message')
  String get message;

  RespDto._();

  factory RespDto([void updates(RespDtoBuilder b)]) = _$RespDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RespDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RespDto> get serializer => _$RespDtoSerializer();
}

class _$RespDtoSerializer implements PrimitiveSerializer<RespDto> {
  @override
  final Iterable<Type> types = const [RespDto, _$RespDto];

  @override
  final String wireName = r'RespDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RespDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(int),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RespDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RespDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RespDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RespDtoBuilder();
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

