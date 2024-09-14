//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sys_ping_get200_response.g.dart';

/// SysPingGet200Response
///
/// Properties:
/// * [version] - 服务器版本
@BuiltValue()
abstract class SysPingGet200Response implements Built<SysPingGet200Response, SysPingGet200ResponseBuilder> {
  /// 服务器版本
  @BuiltValueField(wireName: r'version')
  String get version;

  SysPingGet200Response._();

  factory SysPingGet200Response([void updates(SysPingGet200ResponseBuilder b)]) = _$SysPingGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SysPingGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SysPingGet200Response> get serializer => _$SysPingGet200ResponseSerializer();
}

class _$SysPingGet200ResponseSerializer implements PrimitiveSerializer<SysPingGet200Response> {
  @override
  final Iterable<Type> types = const [SysPingGet200Response, _$SysPingGet200Response];

  @override
  final String wireName = r'SysPingGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SysPingGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SysPingGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SysPingGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SysPingGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SysPingGet200ResponseBuilder();
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

