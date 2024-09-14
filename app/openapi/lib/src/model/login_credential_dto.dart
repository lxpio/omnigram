//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'login_credential_dto.g.dart';

/// LoginCredentialDto
///
/// Properties:
/// * [account] - 账号名/邮箱/手机号
/// * [password] - 登陆凭证
@BuiltValue()
abstract class LoginCredentialDto implements Built<LoginCredentialDto, LoginCredentialDtoBuilder> {
  /// 账号名/邮箱/手机号
  @BuiltValueField(wireName: r'account')
  String get account;

  /// 登陆凭证
  @BuiltValueField(wireName: r'password')
  String get password;

  LoginCredentialDto._();

  factory LoginCredentialDto([void updates(LoginCredentialDtoBuilder b)]) = _$LoginCredentialDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LoginCredentialDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LoginCredentialDto> get serializer => _$LoginCredentialDtoSerializer();
}

class _$LoginCredentialDtoSerializer implements PrimitiveSerializer<LoginCredentialDto> {
  @override
  final Iterable<Type> types = const [LoginCredentialDto, _$LoginCredentialDto];

  @override
  final String wireName = r'LoginCredentialDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LoginCredentialDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'account';
    yield serializers.serialize(
      object.account,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LoginCredentialDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LoginCredentialDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'account':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.account = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LoginCredentialDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LoginCredentialDtoBuilder();
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

