//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reader_books_book_id_progress_put_request.g.dart';

/// ReaderBooksBookIdProgressPutRequest
///
/// Properties:
/// * [userId] 
/// * [updatedAt] 
/// * [progressIndex] 
/// * [progress] 
/// * [paraPosition] 
@BuiltValue()
abstract class ReaderBooksBookIdProgressPutRequest implements Built<ReaderBooksBookIdProgressPutRequest, ReaderBooksBookIdProgressPutRequestBuilder> {
  @BuiltValueField(wireName: r'user_id')
  int get userId;

  @BuiltValueField(wireName: r'updated_at')
  int get updatedAt;

  @BuiltValueField(wireName: r'progress_index')
  int get progressIndex;

  @BuiltValueField(wireName: r'progress')
  num get progress;

  @BuiltValueField(wireName: r'para_position')
  int get paraPosition;

  ReaderBooksBookIdProgressPutRequest._();

  factory ReaderBooksBookIdProgressPutRequest([void updates(ReaderBooksBookIdProgressPutRequestBuilder b)]) = _$ReaderBooksBookIdProgressPutRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReaderBooksBookIdProgressPutRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReaderBooksBookIdProgressPutRequest> get serializer => _$ReaderBooksBookIdProgressPutRequestSerializer();
}

class _$ReaderBooksBookIdProgressPutRequestSerializer implements PrimitiveSerializer<ReaderBooksBookIdProgressPutRequest> {
  @override
  final Iterable<Type> types = const [ReaderBooksBookIdProgressPutRequest, _$ReaderBooksBookIdProgressPutRequest];

  @override
  final String wireName = r'ReaderBooksBookIdProgressPutRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReaderBooksBookIdProgressPutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(int),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(int),
    );
    yield r'progress_index';
    yield serializers.serialize(
      object.progressIndex,
      specifiedType: const FullType(int),
    );
    yield r'progress';
    yield serializers.serialize(
      object.progress,
      specifiedType: const FullType(num),
    );
    yield r'para_position';
    yield serializers.serialize(
      object.paraPosition,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReaderBooksBookIdProgressPutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReaderBooksBookIdProgressPutRequestBuilder result,
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
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.updatedAt = valueDes;
          break;
        case r'progress_index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.progressIndex = valueDes;
          break;
        case r'progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.progress = valueDes;
          break;
        case r'para_position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.paraPosition = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReaderBooksBookIdProgressPutRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReaderBooksBookIdProgressPutRequestBuilder();
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

