//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'access_token_dto.g.dart';

/// AccessTokenDto
///
/// Properties:
/// * [tokenType] 
/// * [expiredIn] 
/// * [refreshToken] 
/// * [accessToken] 
@BuiltValue()
abstract class AccessTokenDto implements Built<AccessTokenDto, AccessTokenDtoBuilder> {
  @BuiltValueField(wireName: r'token_type')
  String get tokenType;

  @BuiltValueField(wireName: r'expired_in')
  int get expiredIn;

  @BuiltValueField(wireName: r'refresh_token')
  String get refreshToken;

  @BuiltValueField(wireName: r'access_token')
  String get accessToken;

  AccessTokenDto._();

  factory AccessTokenDto([void updates(AccessTokenDtoBuilder b)]) = _$AccessTokenDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccessTokenDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AccessTokenDto> get serializer => _$AccessTokenDtoSerializer();
}

class _$AccessTokenDtoSerializer implements PrimitiveSerializer<AccessTokenDto> {
  @override
  final Iterable<Type> types = const [AccessTokenDto, _$AccessTokenDto];

  @override
  final String wireName = r'AccessTokenDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AccessTokenDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token_type';
    yield serializers.serialize(
      object.tokenType,
      specifiedType: const FullType(String),
    );
    yield r'expired_in';
    yield serializers.serialize(
      object.expiredIn,
      specifiedType: const FullType(int),
    );
    yield r'refresh_token';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
    yield r'access_token';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AccessTokenDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AccessTokenDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tokenType = valueDes;
          break;
        case r'expired_in':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiredIn = valueDes;
          break;
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        case r'access_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AccessTokenDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccessTokenDtoBuilder();
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

