//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'read_progress_dto.g.dart';

/// ReadProgressDto
///
/// Properties:
/// * [id] 
/// * [bookId] 
/// * [userId] 
/// * [startDate] 
/// * [updatedAt] 
/// * [exptEndDate] 
/// * [endDate] 
/// * [progressIndex] 
/// * [progress] 
/// * [paraPosition] 
@BuiltValue()
abstract class ReadProgressDto implements Built<ReadProgressDto, ReadProgressDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  int get id;

  @BuiltValueField(wireName: r'book_id')
  String get bookId;

  @BuiltValueField(wireName: r'user_id')
  int get userId;

  @BuiltValueField(wireName: r'start_date')
  int get startDate;

  @BuiltValueField(wireName: r'updated_at')
  int get updatedAt;

  @BuiltValueField(wireName: r'expt_end_date')
  int get exptEndDate;

  @BuiltValueField(wireName: r'end_date')
  int get endDate;

  @BuiltValueField(wireName: r'progress_index')
  int get progressIndex;

  @BuiltValueField(wireName: r'progress')
  num get progress;

  @BuiltValueField(wireName: r'para_position')
  int get paraPosition;

  ReadProgressDto._();

  factory ReadProgressDto([void updates(ReadProgressDtoBuilder b)]) = _$ReadProgressDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReadProgressDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReadProgressDto> get serializer => _$ReadProgressDtoSerializer();
}

class _$ReadProgressDtoSerializer implements PrimitiveSerializer<ReadProgressDto> {
  @override
  final Iterable<Type> types = const [ReadProgressDto, _$ReadProgressDto];

  @override
  final String wireName = r'ReadProgressDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReadProgressDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(int),
    );
    yield r'book_id';
    yield serializers.serialize(
      object.bookId,
      specifiedType: const FullType(String),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(int),
    );
    yield r'start_date';
    yield serializers.serialize(
      object.startDate,
      specifiedType: const FullType(int),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(int),
    );
    yield r'expt_end_date';
    yield serializers.serialize(
      object.exptEndDate,
      specifiedType: const FullType(int),
    );
    yield r'end_date';
    yield serializers.serialize(
      object.endDate,
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
    ReadProgressDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReadProgressDtoBuilder result,
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
        case r'book_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bookId = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.userId = valueDes;
          break;
        case r'start_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.startDate = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.updatedAt = valueDes;
          break;
        case r'expt_end_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.exptEndDate = valueDes;
          break;
        case r'end_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.endDate = valueDes;
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
  ReadProgressDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReadProgressDtoBuilder();
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

