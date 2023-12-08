// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tts_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TTSState _$TTSStateFromJson(Map<String, dynamic> json) {
  return _TTSState.fromJson(json);
}

/// @nodoc
mixin _$TTSState {
  bool get showbar => throw _privateConstructorUsedError;
  bool get playing => throw _privateConstructorUsedError;
  Duration? get position => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TTSStateCopyWith<TTSState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TTSStateCopyWith<$Res> {
  factory $TTSStateCopyWith(TTSState value, $Res Function(TTSState) then) =
      _$TTSStateCopyWithImpl<$Res, TTSState>;
  @useResult
  $Res call({bool showbar, bool playing, Duration? position});
}

/// @nodoc
class _$TTSStateCopyWithImpl<$Res, $Val extends TTSState>
    implements $TTSStateCopyWith<$Res> {
  _$TTSStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showbar = null,
    Object? playing = null,
    Object? position = freezed,
  }) {
    return _then(_value.copyWith(
      showbar: null == showbar
          ? _value.showbar
          : showbar // ignore: cast_nullable_to_non_nullable
              as bool,
      playing: null == playing
          ? _value.playing
          : playing // ignore: cast_nullable_to_non_nullable
              as bool,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TTSStateCopyWith<$Res> implements $TTSStateCopyWith<$Res> {
  factory _$$_TTSStateCopyWith(
          _$_TTSState value, $Res Function(_$_TTSState) then) =
      __$$_TTSStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool showbar, bool playing, Duration? position});
}

/// @nodoc
class __$$_TTSStateCopyWithImpl<$Res>
    extends _$TTSStateCopyWithImpl<$Res, _$_TTSState>
    implements _$$_TTSStateCopyWith<$Res> {
  __$$_TTSStateCopyWithImpl(
      _$_TTSState _value, $Res Function(_$_TTSState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showbar = null,
    Object? playing = null,
    Object? position = freezed,
  }) {
    return _then(_$_TTSState(
      showbar: null == showbar
          ? _value.showbar
          : showbar // ignore: cast_nullable_to_non_nullable
              as bool,
      playing: null == playing
          ? _value.playing
          : playing // ignore: cast_nullable_to_non_nullable
              as bool,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TTSState implements _TTSState {
  const _$_TTSState(
      {this.showbar = false, this.playing = false, this.position});

  factory _$_TTSState.fromJson(Map<String, dynamic> json) =>
      _$$_TTSStateFromJson(json);

  @override
  @JsonKey()
  final bool showbar;
  @override
  @JsonKey()
  final bool playing;
  @override
  final Duration? position;

  @override
  String toString() {
    return 'TTSState(showbar: $showbar, playing: $playing, position: $position)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TTSState &&
            (identical(other.showbar, showbar) || other.showbar == showbar) &&
            (identical(other.playing, playing) || other.playing == playing) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, showbar, playing, position);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TTSStateCopyWith<_$_TTSState> get copyWith =>
      __$$_TTSStateCopyWithImpl<_$_TTSState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TTSStateToJson(
      this,
    );
  }
}

abstract class _TTSState implements TTSState {
  const factory _TTSState(
      {final bool showbar,
      final bool playing,
      final Duration? position}) = _$_TTSState;

  factory _TTSState.fromJson(Map<String, dynamic> json) = _$_TTSState.fromJson;

  @override
  bool get showbar;
  @override
  bool get playing;
  @override
  Duration? get position;
  @override
  @JsonKey(ignore: true)
  _$$_TTSStateCopyWith<_$_TTSState> get copyWith =>
      throw _privateConstructorUsedError;
}
