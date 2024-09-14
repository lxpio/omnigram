//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'speaker_dto.g.dart';

/// SpeakerDto
///
/// Properties:
/// * [id] 
/// * [audioId] 
/// * [demoWav] 
/// * [name] 
/// * [tag] 
/// * [avatarUrl] 
@BuiltValue()
abstract class SpeakerDto implements Built<SpeakerDto, SpeakerDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  int get id;

  @BuiltValueField(wireName: r'audio_id')
  String get audioId;

  @BuiltValueField(wireName: r'demo_wav')
  String get demoWav;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'tag')
  String? get tag;

  @BuiltValueField(wireName: r'avatar_url')
  String? get avatarUrl;

  SpeakerDto._();

  factory SpeakerDto([void updates(SpeakerDtoBuilder b)]) = _$SpeakerDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SpeakerDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SpeakerDto> get serializer => _$SpeakerDtoSerializer();
}

class _$SpeakerDtoSerializer implements PrimitiveSerializer<SpeakerDto> {
  @override
  final Iterable<Type> types = const [SpeakerDto, _$SpeakerDto];

  @override
  final String wireName = r'SpeakerDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SpeakerDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(int),
    );
    yield r'audio_id';
    yield serializers.serialize(
      object.audioId,
      specifiedType: const FullType(String),
    );
    yield r'demo_wav';
    yield serializers.serialize(
      object.demoWav,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.tag != null) {
      yield r'tag';
      yield serializers.serialize(
        object.tag,
        specifiedType: const FullType(String),
      );
    }
    if (object.avatarUrl != null) {
      yield r'avatar_url';
      yield serializers.serialize(
        object.avatarUrl,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SpeakerDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SpeakerDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.id = valueDes;
          break;
        case r'audio_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.audioId = valueDes;
          break;
        case r'demo_wav':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.demoWav = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'tag':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tag = valueDes;
          break;
        case r'avatar_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.avatarUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SpeakerDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SpeakerDtoBuilder();
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

