//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ebook_dto.g.dart';

/// EbookDto
///
/// Properties:
/// * [id] 
/// * [size] 
/// * [ctime] 
/// * [utime] 
/// * [title] 
/// * [subTitle] 
/// * [language] 
/// * [coverUrl] 
/// * [uuid] 
/// * [isbn] 
/// * [asin] 
/// * [identifier] 
/// * [category] 
/// * [author] 
/// * [authorUrl] 
/// * [authorSort] 
/// * [publisher] 
/// * [description] 
/// * [favStatus] 
/// * [pubdate] 
/// * [rating] 
/// * [publisherUrl] 
/// * [countVisit] 
/// * [countDownload] 
/// * [progress] 
/// * [progressIndex] 
/// * [paraPosition] 
/// * [atime] 
@BuiltValue()
abstract class EbookDto implements Built<EbookDto, EbookDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'size')
  int? get size;

  @BuiltValueField(wireName: r'ctime')
  int? get ctime;

  @BuiltValueField(wireName: r'utime')
  int? get utime;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'sub_title')
  String? get subTitle;

  @BuiltValueField(wireName: r'language')
  String? get language;

  @BuiltValueField(wireName: r'cover_url')
  String? get coverUrl;

  @BuiltValueField(wireName: r'uuid')
  String? get uuid;

  @BuiltValueField(wireName: r'isbn')
  String? get isbn;

  @BuiltValueField(wireName: r'asin')
  String? get asin;

  @BuiltValueField(wireName: r'identifier')
  String get identifier;

  @BuiltValueField(wireName: r'category')
  String? get category;

  @BuiltValueField(wireName: r'author')
  String? get author;

  @BuiltValueField(wireName: r'author_url')
  String? get authorUrl;

  @BuiltValueField(wireName: r'author_sort')
  String? get authorSort;

  @BuiltValueField(wireName: r'publisher')
  String? get publisher;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'fav_status')
  bool? get favStatus;

  @BuiltValueField(wireName: r'pubdate')
  String? get pubdate;

  @BuiltValueField(wireName: r'rating')
  num? get rating;

  @BuiltValueField(wireName: r'publisher_url')
  String? get publisherUrl;

  @BuiltValueField(wireName: r'count_visit')
  int? get countVisit;

  @BuiltValueField(wireName: r'count_download')
  int? get countDownload;

  @BuiltValueField(wireName: r'progress')
  num? get progress;

  @BuiltValueField(wireName: r'progress_index')
  int? get progressIndex;

  @BuiltValueField(wireName: r'para_position')
  int? get paraPosition;

  @BuiltValueField(wireName: r'atime')
  int? get atime;

  EbookDto._();

  factory EbookDto([void updates(EbookDtoBuilder b)]) = _$EbookDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EbookDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EbookDto> get serializer => _$EbookDtoSerializer();
}

class _$EbookDtoSerializer implements PrimitiveSerializer<EbookDto> {
  @override
  final Iterable<Type> types = const [EbookDto, _$EbookDto];

  @override
  final String wireName = r'EbookDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EbookDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    if (object.size != null) {
      yield r'size';
      yield serializers.serialize(
        object.size,
        specifiedType: const FullType(int),
      );
    }
    if (object.ctime != null) {
      yield r'ctime';
      yield serializers.serialize(
        object.ctime,
        specifiedType: const FullType(int),
      );
    }
    if (object.utime != null) {
      yield r'utime';
      yield serializers.serialize(
        object.utime,
        specifiedType: const FullType(int),
      );
    }
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.subTitle != null) {
      yield r'sub_title';
      yield serializers.serialize(
        object.subTitle,
        specifiedType: const FullType(String),
      );
    }
    if (object.language != null) {
      yield r'language';
      yield serializers.serialize(
        object.language,
        specifiedType: const FullType(String),
      );
    }
    if (object.coverUrl != null) {
      yield r'cover_url';
      yield serializers.serialize(
        object.coverUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.uuid != null) {
      yield r'uuid';
      yield serializers.serialize(
        object.uuid,
        specifiedType: const FullType(String),
      );
    }
    if (object.isbn != null) {
      yield r'isbn';
      yield serializers.serialize(
        object.isbn,
        specifiedType: const FullType(String),
      );
    }
    if (object.asin != null) {
      yield r'asin';
      yield serializers.serialize(
        object.asin,
        specifiedType: const FullType(String),
      );
    }
    yield r'identifier';
    yield serializers.serialize(
      object.identifier,
      specifiedType: const FullType(String),
    );
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(String),
      );
    }
    if (object.author != null) {
      yield r'author';
      yield serializers.serialize(
        object.author,
        specifiedType: const FullType(String),
      );
    }
    if (object.authorUrl != null) {
      yield r'author_url';
      yield serializers.serialize(
        object.authorUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.authorSort != null) {
      yield r'author_sort';
      yield serializers.serialize(
        object.authorSort,
        specifiedType: const FullType(String),
      );
    }
    if (object.publisher != null) {
      yield r'publisher';
      yield serializers.serialize(
        object.publisher,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.favStatus != null) {
      yield r'fav_status';
      yield serializers.serialize(
        object.favStatus,
        specifiedType: const FullType(bool),
      );
    }
    if (object.pubdate != null) {
      yield r'pubdate';
      yield serializers.serialize(
        object.pubdate,
        specifiedType: const FullType(String),
      );
    }
    if (object.rating != null) {
      yield r'rating';
      yield serializers.serialize(
        object.rating,
        specifiedType: const FullType(num),
      );
    }
    if (object.publisherUrl != null) {
      yield r'publisher_url';
      yield serializers.serialize(
        object.publisherUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.countVisit != null) {
      yield r'count_visit';
      yield serializers.serialize(
        object.countVisit,
        specifiedType: const FullType(int),
      );
    }
    if (object.countDownload != null) {
      yield r'count_download';
      yield serializers.serialize(
        object.countDownload,
        specifiedType: const FullType(int),
      );
    }
    if (object.progress != null) {
      yield r'progress';
      yield serializers.serialize(
        object.progress,
        specifiedType: const FullType(num),
      );
    }
    if (object.progressIndex != null) {
      yield r'progress_index';
      yield serializers.serialize(
        object.progressIndex,
        specifiedType: const FullType(int),
      );
    }
    if (object.paraPosition != null) {
      yield r'para_position';
      yield serializers.serialize(
        object.paraPosition,
        specifiedType: const FullType(int),
      );
    }
    if (object.atime != null) {
      yield r'atime';
      yield serializers.serialize(
        object.atime,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EbookDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EbookDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.size = valueDes;
          break;
        case r'ctime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ctime = valueDes;
          break;
        case r'utime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.utime = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'sub_title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subTitle = valueDes;
          break;
        case r'language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.language = valueDes;
          break;
        case r'cover_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.coverUrl = valueDes;
          break;
        case r'uuid':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.uuid = valueDes;
          break;
        case r'isbn':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.isbn = valueDes;
          break;
        case r'asin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.asin = valueDes;
          break;
        case r'identifier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.identifier = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.author = valueDes;
          break;
        case r'author_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorUrl = valueDes;
          break;
        case r'author_sort':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorSort = valueDes;
          break;
        case r'publisher':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publisher = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'fav_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.favStatus = valueDes;
          break;
        case r'pubdate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pubdate = valueDes;
          break;
        case r'rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.rating = valueDes;
          break;
        case r'publisher_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publisherUrl = valueDes;
          break;
        case r'count_visit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.countVisit = valueDes;
          break;
        case r'count_download':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.countDownload = valueDes;
          break;
        case r'progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.progress = valueDes;
          break;
        case r'progress_index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.progressIndex = valueDes;
          break;
        case r'para_position':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.paraPosition = valueDes;
          break;
        case r'atime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.atime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EbookDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EbookDtoBuilder();
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

