//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sys_info_dto.g.dart';

/// SysInfoDto
///
/// Properties:
/// * [version] 
/// * [system] 
/// * [architecture] 
/// * [docsDataPath] 
/// * [diskUsage] 
/// * [m4tSupport] 
@BuiltValue()
abstract class SysInfoDto implements Built<SysInfoDto, SysInfoDtoBuilder> {
  @BuiltValueField(wireName: r'version')
  String get version;

  @BuiltValueField(wireName: r'system')
  String get system;

  @BuiltValueField(wireName: r'architecture')
  String get architecture;

  @BuiltValueField(wireName: r'docs_data_path')
  String get docsDataPath;

  @BuiltValueField(wireName: r'disk_usage')
  String? get diskUsage;

  @BuiltValueField(wireName: r'm4t_support')
  bool get m4tSupport;

  SysInfoDto._();

  factory SysInfoDto([void updates(SysInfoDtoBuilder b)]) = _$SysInfoDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SysInfoDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SysInfoDto> get serializer => _$SysInfoDtoSerializer();
}

class _$SysInfoDtoSerializer implements PrimitiveSerializer<SysInfoDto> {
  @override
  final Iterable<Type> types = const [SysInfoDto, _$SysInfoDto];

  @override
  final String wireName = r'SysInfoDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SysInfoDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(String),
    );
    yield r'system';
    yield serializers.serialize(
      object.system,
      specifiedType: const FullType(String),
    );
    yield r'architecture';
    yield serializers.serialize(
      object.architecture,
      specifiedType: const FullType(String),
    );
    yield r'docs_data_path';
    yield serializers.serialize(
      object.docsDataPath,
      specifiedType: const FullType(String),
    );
    if (object.diskUsage != null) {
      yield r'disk_usage';
      yield serializers.serialize(
        object.diskUsage,
        specifiedType: const FullType(String),
      );
    }
    yield r'm4t_support';
    yield serializers.serialize(
      object.m4tSupport,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SysInfoDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SysInfoDtoBuilder result,
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
        case r'system':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.system = valueDes;
          break;
        case r'architecture':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.architecture = valueDes;
          break;
        case r'docs_data_path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.docsDataPath = valueDes;
          break;
        case r'disk_usage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.diskUsage = valueDes;
          break;
        case r'm4t_support':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.m4tSupport = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SysInfoDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SysInfoDtoBuilder();
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

