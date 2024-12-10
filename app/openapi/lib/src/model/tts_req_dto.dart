//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tts_req_dto.g.dart';

/// TtsReqDto
///
/// Properties:
/// * [text] 
/// * [chunkLength] 
/// * [format] 
/// * [mp3Bitrate] 
/// * [references] 
/// * [referenceId] 
/// * [useMemoryCache] 
/// * [normalize] 
/// * [opusBitrate] 
/// * [latency] 
/// * [streaming] 
/// * [maxNewTokens] 
/// * [topP] 
/// * [repetitionPenalty] 
/// * [temperature] 
@BuiltValue()
abstract class TtsReqDto implements Built<TtsReqDto, TtsReqDtoBuilder> {
  @BuiltValueField(wireName: r'text')
  String get text;

  @BuiltValueField(wireName: r'chunk_length')
  int get chunkLength;

  @BuiltValueField(wireName: r'format')
  String get format;

  @BuiltValueField(wireName: r'mp3_bitrate')
  int get mp3Bitrate;

  @BuiltValueField(wireName: r'references')
  BuiltList<String> get references;

  @BuiltValueField(wireName: r'reference_id')
  String? get referenceId;

  @BuiltValueField(wireName: r'use_memory_cache')
  String? get useMemoryCache;

  @BuiltValueField(wireName: r'normalize')
  bool get normalize;

  @BuiltValueField(wireName: r'opus_bitrate')
  int get opusBitrate;

  @BuiltValueField(wireName: r'latency')
  String? get latency;

  @BuiltValueField(wireName: r'streaming')
  bool get streaming;

  @BuiltValueField(wireName: r'max_new_tokens')
  int get maxNewTokens;

  @BuiltValueField(wireName: r'top_p')
  num? get topP;

  @BuiltValueField(wireName: r'repetition_penalty')
  num? get repetitionPenalty;

  @BuiltValueField(wireName: r'temperature')
  num? get temperature;

  TtsReqDto._();

  factory TtsReqDto([void updates(TtsReqDtoBuilder b)]) = _$TtsReqDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TtsReqDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TtsReqDto> get serializer => _$TtsReqDtoSerializer();
}

class _$TtsReqDtoSerializer implements PrimitiveSerializer<TtsReqDto> {
  @override
  final Iterable<Type> types = const [TtsReqDto, _$TtsReqDto];

  @override
  final String wireName = r'TtsReqDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TtsReqDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'text';
    yield serializers.serialize(
      object.text,
      specifiedType: const FullType(String),
    );
    yield r'chunk_length';
    yield serializers.serialize(
      object.chunkLength,
      specifiedType: const FullType(int),
    );
    yield r'format';
    yield serializers.serialize(
      object.format,
      specifiedType: const FullType(String),
    );
    yield r'mp3_bitrate';
    yield serializers.serialize(
      object.mp3Bitrate,
      specifiedType: const FullType(int),
    );
    yield r'references';
    yield serializers.serialize(
      object.references,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.referenceId != null) {
      yield r'reference_id';
      yield serializers.serialize(
        object.referenceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.useMemoryCache != null) {
      yield r'use_memory_cache';
      yield serializers.serialize(
        object.useMemoryCache,
        specifiedType: const FullType(String),
      );
    }
    yield r'normalize';
    yield serializers.serialize(
      object.normalize,
      specifiedType: const FullType(bool),
    );
    yield r'opus_bitrate';
    yield serializers.serialize(
      object.opusBitrate,
      specifiedType: const FullType(int),
    );
    if (object.latency != null) {
      yield r'latency';
      yield serializers.serialize(
        object.latency,
        specifiedType: const FullType(String),
      );
    }
    yield r'streaming';
    yield serializers.serialize(
      object.streaming,
      specifiedType: const FullType(bool),
    );
    yield r'max_new_tokens';
    yield serializers.serialize(
      object.maxNewTokens,
      specifiedType: const FullType(int),
    );
    if (object.topP != null) {
      yield r'top_p';
      yield serializers.serialize(
        object.topP,
        specifiedType: const FullType(num),
      );
    }
    if (object.repetitionPenalty != null) {
      yield r'repetition_penalty';
      yield serializers.serialize(
        object.repetitionPenalty,
        specifiedType: const FullType(num),
      );
    }
    if (object.temperature != null) {
      yield r'temperature';
      yield serializers.serialize(
        object.temperature,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TtsReqDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TtsReqDtoBuilder result,
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
        case r'chunk_length':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.chunkLength = valueDes;
          break;
        case r'format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.format = valueDes;
          break;
        case r'mp3_bitrate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.mp3Bitrate = valueDes;
          break;
        case r'references':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.references.replace(valueDes);
          break;
        case r'reference_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.referenceId = valueDes;
          break;
        case r'use_memory_cache':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.useMemoryCache = valueDes;
          break;
        case r'normalize':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.normalize = valueDes;
          break;
        case r'opus_bitrate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.opusBitrate = valueDes;
          break;
        case r'latency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.latency = valueDes;
          break;
        case r'streaming':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.streaming = valueDes;
          break;
        case r'max_new_tokens':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.maxNewTokens = valueDes;
          break;
        case r'top_p':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.topP = valueDes;
          break;
        case r'repetition_penalty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.repetitionPenalty = valueDes;
          break;
        case r'temperature':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.temperature = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TtsReqDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TtsReqDtoBuilder();
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

