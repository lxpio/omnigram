//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'change_password_dto.g.dart';

/// ChangePasswordDto
///
/// Properties:
/// * [newPassword] - 新密码
/// * [code] - 重置密码需要额外验证获取操作code
@BuiltValue()
abstract class ChangePasswordDto implements Built<ChangePasswordDto, ChangePasswordDtoBuilder> {
  /// 新密码
  @BuiltValueField(wireName: r'new_password')
  String get newPassword;

  /// 重置密码需要额外验证获取操作code
  @BuiltValueField(wireName: r'code')
  String get code;

  ChangePasswordDto._();

  factory ChangePasswordDto([void updates(ChangePasswordDtoBuilder b)]) = _$ChangePasswordDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChangePasswordDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChangePasswordDto> get serializer => _$ChangePasswordDtoSerializer();
}

class _$ChangePasswordDtoSerializer implements PrimitiveSerializer<ChangePasswordDto> {
  @override
  final Iterable<Type> types = const [ChangePasswordDto, _$ChangePasswordDto];

  @override
  final String wireName = r'ChangePasswordDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChangePasswordDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'new_password';
    yield serializers.serialize(
      object.newPassword,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChangePasswordDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChangePasswordDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'new_password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newPassword = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChangePasswordDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChangePasswordDtoBuilder();
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

