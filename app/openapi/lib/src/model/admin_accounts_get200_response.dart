//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/user_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_accounts_get200_response.g.dart';

/// AdminAccountsGet200Response
///
/// Properties:
/// * [total] 
/// * [items] 
/// * [pageNum] 
/// * [pageSize] 
@BuiltValue()
abstract class AdminAccountsGet200Response implements Built<AdminAccountsGet200Response, AdminAccountsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'items')
  BuiltList<UserDto> get items;

  @BuiltValueField(wireName: r'page_num')
  int? get pageNum;

  @BuiltValueField(wireName: r'page_size')
  int? get pageSize;

  AdminAccountsGet200Response._();

  factory AdminAccountsGet200Response([void updates(AdminAccountsGet200ResponseBuilder b)]) = _$AdminAccountsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminAccountsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminAccountsGet200Response> get serializer => _$AdminAccountsGet200ResponseSerializer();
}

class _$AdminAccountsGet200ResponseSerializer implements PrimitiveSerializer<AdminAccountsGet200Response> {
  @override
  final Iterable<Type> types = const [AdminAccountsGet200Response, _$AdminAccountsGet200Response];

  @override
  final String wireName = r'AdminAccountsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminAccountsGet200Response object, {
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
      specifiedType: const FullType(BuiltList, [FullType(UserDto)]),
    );
    if (object.pageNum != null) {
      yield r'page_num';
      yield serializers.serialize(
        object.pageNum,
        specifiedType: const FullType(int),
      );
    }
    if (object.pageSize != null) {
      yield r'page_size';
      yield serializers.serialize(
        object.pageSize,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminAccountsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminAccountsGet200ResponseBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(UserDto)]),
          ) as BuiltList<UserDto>;
          result.items.replace(valueDes);
          break;
        case r'page_num':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pageNum = valueDes;
          break;
        case r'page_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pageSize = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminAccountsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminAccountsGet200ResponseBuilder();
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

