//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'enable_scan_dto.g.dart';

/// EnableScanDto
///
/// Properties:
/// * [refresh] - 从头开始扫描
/// * [maxThread] - 扫描线程数量
@BuiltValue()
abstract class EnableScanDto implements Built<EnableScanDto, EnableScanDtoBuilder> {
  /// 从头开始扫描
  @BuiltValueField(wireName: r'refresh')
  bool get refresh;

  /// 扫描线程数量
  @BuiltValueField(wireName: r'max_thread')
  num get maxThread;

  EnableScanDto._();

  factory EnableScanDto([void updates(EnableScanDtoBuilder b)]) = _$EnableScanDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EnableScanDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EnableScanDto> get serializer => _$EnableScanDtoSerializer();
}

class _$EnableScanDtoSerializer implements PrimitiveSerializer<EnableScanDto> {
  @override
  final Iterable<Type> types = const [EnableScanDto, _$EnableScanDto];

  @override
  final String wireName = r'EnableScanDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EnableScanDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'refresh';
    yield serializers.serialize(
      object.refresh,
      specifiedType: const FullType(bool),
    );
    yield r'max_thread';
    yield serializers.serialize(
      object.maxThread,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EnableScanDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EnableScanDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'refresh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.refresh = valueDes;
          break;
        case r'max_thread':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.maxThread = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EnableScanDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EnableScanDtoBuilder();
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

