//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_accounts_account_id_apikeys_post_request.g.dart';

/// AuthAccountsAccountIdApikeysPostRequest
///
/// Properties:
/// * [name] - 用于标记用途
@BuiltValue()
abstract class AuthAccountsAccountIdApikeysPostRequest implements Built<AuthAccountsAccountIdApikeysPostRequest, AuthAccountsAccountIdApikeysPostRequestBuilder> {
  /// 用于标记用途
  @BuiltValueField(wireName: r'name')
  String get name;

  AuthAccountsAccountIdApikeysPostRequest._();

  factory AuthAccountsAccountIdApikeysPostRequest([void updates(AuthAccountsAccountIdApikeysPostRequestBuilder b)]) = _$AuthAccountsAccountIdApikeysPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthAccountsAccountIdApikeysPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthAccountsAccountIdApikeysPostRequest> get serializer => _$AuthAccountsAccountIdApikeysPostRequestSerializer();
}

class _$AuthAccountsAccountIdApikeysPostRequestSerializer implements PrimitiveSerializer<AuthAccountsAccountIdApikeysPostRequest> {
  @override
  final Iterable<Type> types = const [AuthAccountsAccountIdApikeysPostRequest, _$AuthAccountsAccountIdApikeysPostRequest];

  @override
  final String wireName = r'AuthAccountsAccountIdApikeysPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthAccountsAccountIdApikeysPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthAccountsAccountIdApikeysPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthAccountsAccountIdApikeysPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthAccountsAccountIdApikeysPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthAccountsAccountIdApikeysPostRequestBuilder();
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

