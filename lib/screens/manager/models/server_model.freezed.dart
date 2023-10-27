// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ScanStatusModel _$ScanStatusModelFromJson(Map<String, dynamic> json) {
  return _ScanStatusModel.fromJson(json);
}

/// @nodoc
mixin _$ScanStatusModel {
  @JsonKey(name: 'book_count')
  int get bookCount => throw _privateConstructorUsedError;
  List<String>? get errs => throw _privateConstructorUsedError;
  bool get running => throw _privateConstructorUsedError;
  @JsonKey(name: 'data_path')
  String get dataPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScanStatusModelCopyWith<ScanStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanStatusModelCopyWith<$Res> {
  factory $ScanStatusModelCopyWith(
          ScanStatusModel value, $Res Function(ScanStatusModel) then) =
      _$ScanStatusModelCopyWithImpl<$Res, ScanStatusModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'book_count') int bookCount,
      List<String>? errs,
      bool running,
      @JsonKey(name: 'data_path') String dataPath});
}

/// @nodoc
class _$ScanStatusModelCopyWithImpl<$Res, $Val extends ScanStatusModel>
    implements $ScanStatusModelCopyWith<$Res> {
  _$ScanStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookCount = null,
    Object? errs = freezed,
    Object? running = null,
    Object? dataPath = null,
  }) {
    return _then(_value.copyWith(
      bookCount: null == bookCount
          ? _value.bookCount
          : bookCount // ignore: cast_nullable_to_non_nullable
              as int,
      errs: freezed == errs
          ? _value.errs
          : errs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      running: null == running
          ? _value.running
          : running // ignore: cast_nullable_to_non_nullable
              as bool,
      dataPath: null == dataPath
          ? _value.dataPath
          : dataPath // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ScanStatusModelCopyWith<$Res>
    implements $ScanStatusModelCopyWith<$Res> {
  factory _$$_ScanStatusModelCopyWith(
          _$_ScanStatusModel value, $Res Function(_$_ScanStatusModel) then) =
      __$$_ScanStatusModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'book_count') int bookCount,
      List<String>? errs,
      bool running,
      @JsonKey(name: 'data_path') String dataPath});
}

/// @nodoc
class __$$_ScanStatusModelCopyWithImpl<$Res>
    extends _$ScanStatusModelCopyWithImpl<$Res, _$_ScanStatusModel>
    implements _$$_ScanStatusModelCopyWith<$Res> {
  __$$_ScanStatusModelCopyWithImpl(
      _$_ScanStatusModel _value, $Res Function(_$_ScanStatusModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookCount = null,
    Object? errs = freezed,
    Object? running = null,
    Object? dataPath = null,
  }) {
    return _then(_$_ScanStatusModel(
      bookCount: null == bookCount
          ? _value.bookCount
          : bookCount // ignore: cast_nullable_to_non_nullable
              as int,
      errs: freezed == errs
          ? _value._errs
          : errs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      running: null == running
          ? _value.running
          : running // ignore: cast_nullable_to_non_nullable
              as bool,
      dataPath: null == dataPath
          ? _value.dataPath
          : dataPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ScanStatusModel implements _ScanStatusModel {
  const _$_ScanStatusModel(
      {@JsonKey(name: 'book_count') this.bookCount = 0,
      final List<String>? errs,
      this.running = false,
      @JsonKey(name: 'data_path') this.dataPath = ''})
      : _errs = errs;

  factory _$_ScanStatusModel.fromJson(Map<String, dynamic> json) =>
      _$$_ScanStatusModelFromJson(json);

  @override
  @JsonKey(name: 'book_count')
  final int bookCount;
  final List<String>? _errs;
  @override
  List<String>? get errs {
    final value = _errs;
    if (value == null) return null;
    if (_errs is EqualUnmodifiableListView) return _errs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool running;
  @override
  @JsonKey(name: 'data_path')
  final String dataPath;

  @override
  String toString() {
    return 'ScanStatusModel(bookCount: $bookCount, errs: $errs, running: $running, dataPath: $dataPath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ScanStatusModel &&
            (identical(other.bookCount, bookCount) ||
                other.bookCount == bookCount) &&
            const DeepCollectionEquality().equals(other._errs, _errs) &&
            (identical(other.running, running) || other.running == running) &&
            (identical(other.dataPath, dataPath) ||
                other.dataPath == dataPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, bookCount,
      const DeepCollectionEquality().hash(_errs), running, dataPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ScanStatusModelCopyWith<_$_ScanStatusModel> get copyWith =>
      __$$_ScanStatusModelCopyWithImpl<_$_ScanStatusModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ScanStatusModelToJson(
      this,
    );
  }
}

abstract class _ScanStatusModel implements ScanStatusModel {
  const factory _ScanStatusModel(
      {@JsonKey(name: 'book_count') final int bookCount,
      final List<String>? errs,
      final bool running,
      @JsonKey(name: 'data_path') final String dataPath}) = _$_ScanStatusModel;

  factory _ScanStatusModel.fromJson(Map<String, dynamic> json) =
      _$_ScanStatusModel.fromJson;

  @override
  @JsonKey(name: 'book_count')
  int get bookCount;
  @override
  List<String>? get errs;
  @override
  bool get running;
  @override
  @JsonKey(name: 'data_path')
  String get dataPath;
  @override
  @JsonKey(ignore: true)
  _$$_ScanStatusModelCopyWith<_$_ScanStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

ServerModel _$ServerModelFromJson(Map<String, dynamic> json) {
  return _ServerModel.fromJson(json);
}

/// @nodoc
mixin _$ServerModel {
  String get version => throw _privateConstructorUsedError;
  String? get system => throw _privateConstructorUsedError;
  String? get architecture => throw _privateConstructorUsedError;
  ScanStatusModel get scan_stats => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServerModelCopyWith<ServerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerModelCopyWith<$Res> {
  factory $ServerModelCopyWith(
          ServerModel value, $Res Function(ServerModel) then) =
      _$ServerModelCopyWithImpl<$Res, ServerModel>;
  @useResult
  $Res call(
      {String version,
      String? system,
      String? architecture,
      ScanStatusModel scan_stats});

  $ScanStatusModelCopyWith<$Res> get scan_stats;
}

/// @nodoc
class _$ServerModelCopyWithImpl<$Res, $Val extends ServerModel>
    implements $ServerModelCopyWith<$Res> {
  _$ServerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? system = freezed,
    Object? architecture = freezed,
    Object? scan_stats = null,
  }) {
    return _then(_value.copyWith(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      system: freezed == system
          ? _value.system
          : system // ignore: cast_nullable_to_non_nullable
              as String?,
      architecture: freezed == architecture
          ? _value.architecture
          : architecture // ignore: cast_nullable_to_non_nullable
              as String?,
      scan_stats: null == scan_stats
          ? _value.scan_stats
          : scan_stats // ignore: cast_nullable_to_non_nullable
              as ScanStatusModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ScanStatusModelCopyWith<$Res> get scan_stats {
    return $ScanStatusModelCopyWith<$Res>(_value.scan_stats, (value) {
      return _then(_value.copyWith(scan_stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_ServerModelCopyWith<$Res>
    implements $ServerModelCopyWith<$Res> {
  factory _$$_ServerModelCopyWith(
          _$_ServerModel value, $Res Function(_$_ServerModel) then) =
      __$$_ServerModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String version,
      String? system,
      String? architecture,
      ScanStatusModel scan_stats});

  @override
  $ScanStatusModelCopyWith<$Res> get scan_stats;
}

/// @nodoc
class __$$_ServerModelCopyWithImpl<$Res>
    extends _$ServerModelCopyWithImpl<$Res, _$_ServerModel>
    implements _$$_ServerModelCopyWith<$Res> {
  __$$_ServerModelCopyWithImpl(
      _$_ServerModel _value, $Res Function(_$_ServerModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? system = freezed,
    Object? architecture = freezed,
    Object? scan_stats = null,
  }) {
    return _then(_$_ServerModel(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      system: freezed == system
          ? _value.system
          : system // ignore: cast_nullable_to_non_nullable
              as String?,
      architecture: freezed == architecture
          ? _value.architecture
          : architecture // ignore: cast_nullable_to_non_nullable
              as String?,
      scan_stats: null == scan_stats
          ? _value.scan_stats
          : scan_stats // ignore: cast_nullable_to_non_nullable
              as ScanStatusModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ServerModel implements _ServerModel {
  const _$_ServerModel(
      {this.version = "v1.0.0",
      this.system,
      this.architecture,
      this.scan_stats = const ScanStatusModel()});

  factory _$_ServerModel.fromJson(Map<String, dynamic> json) =>
      _$$_ServerModelFromJson(json);

  @override
  @JsonKey()
  final String version;
  @override
  final String? system;
  @override
  final String? architecture;
  @override
  @JsonKey()
  final ScanStatusModel scan_stats;

  @override
  String toString() {
    return 'ServerModel(version: $version, system: $system, architecture: $architecture, scan_stats: $scan_stats)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ServerModel &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.system, system) || other.system == system) &&
            (identical(other.architecture, architecture) ||
                other.architecture == architecture) &&
            (identical(other.scan_stats, scan_stats) ||
                other.scan_stats == scan_stats));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, version, system, architecture, scan_stats);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ServerModelCopyWith<_$_ServerModel> get copyWith =>
      __$$_ServerModelCopyWithImpl<_$_ServerModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ServerModelToJson(
      this,
    );
  }
}

abstract class _ServerModel implements ServerModel {
  const factory _ServerModel(
      {final String version,
      final String? system,
      final String? architecture,
      final ScanStatusModel scan_stats}) = _$_ServerModel;

  factory _ServerModel.fromJson(Map<String, dynamic> json) =
      _$_ServerModel.fromJson;

  @override
  String get version;
  @override
  String? get system;
  @override
  String? get architecture;
  @override
  ScanStatusModel get scan_stats;
  @override
  @JsonKey(ignore: true)
  _$$_ServerModelCopyWith<_$_ServerModel> get copyWith =>
      throw _privateConstructorUsedError;
}
