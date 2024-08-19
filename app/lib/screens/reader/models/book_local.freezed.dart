// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_local.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BookLocal _$BookLocalFromJson(Map<String, dynamic> json) {
  return _BookLocal.fromJson(json);
}

/// @nodoc
mixin _$BookLocal {
  @Id(assignable: true)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'local_path')
  String get localPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'md5')
  String? get md5 => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookLocalCopyWith<BookLocal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookLocalCopyWith<$Res> {
  factory $BookLocalCopyWith(BookLocal value, $Res Function(BookLocal) then) =
      _$BookLocalCopyWithImpl<$Res, BookLocal>;
  @useResult
  $Res call(
      {@Id(assignable: true) int id,
      @JsonKey(name: 'local_path') String localPath,
      @JsonKey(name: 'md5') String? md5});
}

/// @nodoc
class _$BookLocalCopyWithImpl<$Res, $Val extends BookLocal>
    implements $BookLocalCopyWith<$Res> {
  _$BookLocalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? localPath = null,
    Object? md5 = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      localPath: null == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String,
      md5: freezed == md5
          ? _value.md5
          : md5 // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookLocalImplCopyWith<$Res>
    implements $BookLocalCopyWith<$Res> {
  factory _$$BookLocalImplCopyWith(
          _$BookLocalImpl value, $Res Function(_$BookLocalImpl) then) =
      __$$BookLocalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@Id(assignable: true) int id,
      @JsonKey(name: 'local_path') String localPath,
      @JsonKey(name: 'md5') String? md5});
}

/// @nodoc
class __$$BookLocalImplCopyWithImpl<$Res>
    extends _$BookLocalCopyWithImpl<$Res, _$BookLocalImpl>
    implements _$$BookLocalImplCopyWith<$Res> {
  __$$BookLocalImplCopyWithImpl(
      _$BookLocalImpl _value, $Res Function(_$BookLocalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? localPath = null,
    Object? md5 = freezed,
  }) {
    return _then(_$BookLocalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      localPath: null == localPath
          ? _value.localPath
          : localPath // ignore: cast_nullable_to_non_nullable
              as String,
      md5: freezed == md5
          ? _value.md5
          : md5 // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@Entity(realClass: BookLocal)
class _$BookLocalImpl implements _BookLocal {
  _$BookLocalImpl(
      {@Id(assignable: true) required this.id,
      @JsonKey(name: 'local_path') required this.localPath,
      @JsonKey(name: 'md5') this.md5});

  factory _$BookLocalImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookLocalImplFromJson(json);

  @override
  @Id(assignable: true)
  final int id;
  @override
  @JsonKey(name: 'local_path')
  final String localPath;
  @override
  @JsonKey(name: 'md5')
  final String? md5;

  @override
  String toString() {
    return 'BookLocal(id: $id, localPath: $localPath, md5: $md5)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookLocalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.localPath, localPath) ||
                other.localPath == localPath) &&
            (identical(other.md5, md5) || other.md5 == md5));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, localPath, md5);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookLocalImplCopyWith<_$BookLocalImpl> get copyWith =>
      __$$BookLocalImplCopyWithImpl<_$BookLocalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookLocalImplToJson(
      this,
    );
  }
}

abstract class _BookLocal implements BookLocal {
  factory _BookLocal(
      {@Id(assignable: true) required final int id,
      @JsonKey(name: 'local_path') required final String localPath,
      @JsonKey(name: 'md5') final String? md5}) = _$BookLocalImpl;

  factory _BookLocal.fromJson(Map<String, dynamic> json) =
      _$BookLocalImpl.fromJson;

  @override
  @Id(assignable: true)
  int get id;
  @override
  @JsonKey(name: 'local_path')
  String get localPath;
  @override
  @JsonKey(name: 'md5')
  String? get md5;
  @override
  @JsonKey(ignore: true)
  _$$BookLocalImplCopyWith<_$BookLocalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
