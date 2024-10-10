//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delta_sync_dto.g.dart';

/// DeltaSyncDto
///
/// Properties:
/// * [userId] - 用户ID
/// * [limit] - 数量限制
/// * [utime] - 文件更新的时间
/// * [fileType] - 文件类型
@BuiltValue()
abstract class DeltaSyncDto implements Built<DeltaSyncDto, DeltaSyncDtoBuilder> {
  /// 用户ID
  @BuiltValueField(wireName: r'user_id')
  int? get userId;

  /// 数量限制
  @BuiltValueField(wireName: r'limit')
  int get limit;

  /// 文件更新的时间
  @BuiltValueField(wireName: r'utime')
  int get utime;

  /// 文件类型
  @BuiltValueField(wireName: r'file_type')
  int? get fileType;

  DeltaSyncDto._();

  factory DeltaSyncDto([void updates(DeltaSyncDtoBuilder b)]) = _$DeltaSyncDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeltaSyncDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeltaSyncDto> get serializer => _$DeltaSyncDtoSerializer();
}

class _$DeltaSyncDtoSerializer implements PrimitiveSerializer<DeltaSyncDto> {
  @override
  final Iterable<Type> types = const [DeltaSyncDto, _$DeltaSyncDto];

  @override
  final String wireName = r'DeltaSyncDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeltaSyncDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.userId != null) {
      yield r'user_id';
      yield serializers.serialize(
        object.userId,
        specifiedType: const FullType(int),
      );
    }
    yield r'limit';
    yield serializers.serialize(
      object.limit,
      specifiedType: const FullType(int),
    );
    yield r'utime';
    yield serializers.serialize(
      object.utime,
      specifiedType: const FullType(int),
    );
    if (object.fileType != null) {
      yield r'file_type';
      yield serializers.serialize(
        object.fileType,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeltaSyncDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeltaSyncDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.userId = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.limit = valueDes;
          break;
        case r'utime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.utime = valueDes;
          break;
        case r'file_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.fileType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeltaSyncDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeltaSyncDtoBuilder();
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

