//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'scan_stats_dto.g.dart';

/// ScanStatsDto
///
/// Properties:
/// * [total] 
/// * [running] 
/// * [scanCount] 
/// * [errs] 
/// * [diskUsage] 
@BuiltValue()
abstract class ScanStatsDto implements Built<ScanStatsDto, ScanStatsDtoBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'running')
  bool get running;

  @BuiltValueField(wireName: r'scan_count')
  int get scanCount;

  @BuiltValueField(wireName: r'errs')
  BuiltList<String>? get errs;

  @BuiltValueField(wireName: r'disk_usage')
  int get diskUsage;

  ScanStatsDto._();

  factory ScanStatsDto([void updates(ScanStatsDtoBuilder b)]) = _$ScanStatsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScanStatsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScanStatsDto> get serializer => _$ScanStatsDtoSerializer();
}

class _$ScanStatsDtoSerializer implements PrimitiveSerializer<ScanStatsDto> {
  @override
  final Iterable<Type> types = const [ScanStatsDto, _$ScanStatsDto];

  @override
  final String wireName = r'ScanStatsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScanStatsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'running';
    yield serializers.serialize(
      object.running,
      specifiedType: const FullType(bool),
    );
    yield r'scan_count';
    yield serializers.serialize(
      object.scanCount,
      specifiedType: const FullType(int),
    );
    if (object.errs != null) {
      yield r'errs';
      yield serializers.serialize(
        object.errs,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    yield r'disk_usage';
    yield serializers.serialize(
      object.diskUsage,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ScanStatsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScanStatsDtoBuilder result,
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
        case r'running':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.running = valueDes;
          break;
        case r'scan_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.scanCount = valueDes;
          break;
        case r'errs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.errs.replace(valueDes);
          break;
        case r'disk_usage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.diskUsage = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScanStatsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScanStatsDtoBuilder();
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

