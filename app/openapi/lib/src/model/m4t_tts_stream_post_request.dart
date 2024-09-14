//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'm4t_tts_stream_post_request.g.dart';

/// M4tTtsStreamPostRequest
///
/// Properties:
/// * [text] 
/// * [lang] 
/// * [audioId] 
/// * [format] 
/// * [stream] 
@BuiltValue()
abstract class M4tTtsStreamPostRequest implements Built<M4tTtsStreamPostRequest, M4tTtsStreamPostRequestBuilder> {
  @BuiltValueField(wireName: r'text')
  String get text;

  @BuiltValueField(wireName: r'lang')
  String get lang;

  @BuiltValueField(wireName: r'audio_id')
  String get audioId;

  @BuiltValueField(wireName: r'format')
  String get format;

  @BuiltValueField(wireName: r'stream')
  bool get stream;

  M4tTtsStreamPostRequest._();

  factory M4tTtsStreamPostRequest([void updates(M4tTtsStreamPostRequestBuilder b)]) = _$M4tTtsStreamPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(M4tTtsStreamPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<M4tTtsStreamPostRequest> get serializer => _$M4tTtsStreamPostRequestSerializer();
}

class _$M4tTtsStreamPostRequestSerializer implements PrimitiveSerializer<M4tTtsStreamPostRequest> {
  @override
  final Iterable<Type> types = const [M4tTtsStreamPostRequest, _$M4tTtsStreamPostRequest];

  @override
  final String wireName = r'M4tTtsStreamPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    M4tTtsStreamPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'text';
    yield serializers.serialize(
      object.text,
      specifiedType: const FullType(String),
    );
    yield r'lang';
    yield serializers.serialize(
      object.lang,
      specifiedType: const FullType(String),
    );
    yield r'audio_id';
    yield serializers.serialize(
      object.audioId,
      specifiedType: const FullType(String),
    );
    yield r'format';
    yield serializers.serialize(
      object.format,
      specifiedType: const FullType(String),
    );
    yield r'stream';
    yield serializers.serialize(
      object.stream,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    M4tTtsStreamPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required M4tTtsStreamPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.text = valueDes;
          break;
        case r'lang':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lang = valueDes;
          break;
        case r'audio_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.audioId = valueDes;
          break;
        case r'format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.format = valueDes;
          break;
        case r'stream':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.stream = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  M4tTtsStreamPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = M4tTtsStreamPostRequestBuilder();
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

