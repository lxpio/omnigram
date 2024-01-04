// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AppConfigModel _$AppConfigModelFromJson(Map<String, dynamic> json) {
  return _AppConfigModel.fromJson(json);
}

/// @nodoc
mixin _$AppConfigModel {
  String get baseUrl => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  String get appName => throw _privateConstructorUsedError;
  String get appVersion => throw _privateConstructorUsedError;
  bool get shouldCollectCrashLog => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppConfigModelCopyWith<AppConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppConfigModelCopyWith<$Res> {
  factory $AppConfigModelCopyWith(
          AppConfigModel value, $Res Function(AppConfigModel) then) =
      _$AppConfigModelCopyWithImpl<$Res, AppConfigModel>;
  @useResult
  $Res call(
      {String baseUrl,
      String token,
      String appName,
      String appVersion,
      bool shouldCollectCrashLog});
}

/// @nodoc
class _$AppConfigModelCopyWithImpl<$Res, $Val extends AppConfigModel>
    implements $AppConfigModelCopyWith<$Res> {
  _$AppConfigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseUrl = null,
    Object? token = null,
    Object? appName = null,
    Object? appVersion = null,
    Object? shouldCollectCrashLog = null,
  }) {
    return _then(_value.copyWith(
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      appName: null == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String,
      appVersion: null == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String,
      shouldCollectCrashLog: null == shouldCollectCrashLog
          ? _value.shouldCollectCrashLog
          : shouldCollectCrashLog // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AppConfigModelCopyWith<$Res>
    implements $AppConfigModelCopyWith<$Res> {
  factory _$$_AppConfigModelCopyWith(
          _$_AppConfigModel value, $Res Function(_$_AppConfigModel) then) =
      __$$_AppConfigModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String baseUrl,
      String token,
      String appName,
      String appVersion,
      bool shouldCollectCrashLog});
}

/// @nodoc
class __$$_AppConfigModelCopyWithImpl<$Res>
    extends _$AppConfigModelCopyWithImpl<$Res, _$_AppConfigModel>
    implements _$$_AppConfigModelCopyWith<$Res> {
  __$$_AppConfigModelCopyWithImpl(
      _$_AppConfigModel _value, $Res Function(_$_AppConfigModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseUrl = null,
    Object? token = null,
    Object? appName = null,
    Object? appVersion = null,
    Object? shouldCollectCrashLog = null,
  }) {
    return _then(_$_AppConfigModel(
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      appName: null == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String,
      appVersion: null == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String,
      shouldCollectCrashLog: null == shouldCollectCrashLog
          ? _value.shouldCollectCrashLog
          : shouldCollectCrashLog // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_AppConfigModel implements _AppConfigModel {
  const _$_AppConfigModel(
      {required this.baseUrl,
      required this.token,
      required this.appName,
      required this.appVersion,
      required this.shouldCollectCrashLog});

  factory _$_AppConfigModel.fromJson(Map<String, dynamic> json) =>
      _$$_AppConfigModelFromJson(json);

  @override
  final String baseUrl;
  @override
  final String token;
  @override
  final String appName;
  @override
  final String appVersion;
  @override
  final bool shouldCollectCrashLog;

  @override
  String toString() {
    return 'AppConfigModel(baseUrl: $baseUrl, token: $token, appName: $appName, appVersion: $appVersion, shouldCollectCrashLog: $shouldCollectCrashLog)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AppConfigModel &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.appName, appName) || other.appName == appName) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.shouldCollectCrashLog, shouldCollectCrashLog) ||
                other.shouldCollectCrashLog == shouldCollectCrashLog));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, baseUrl, token, appName, appVersion, shouldCollectCrashLog);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AppConfigModelCopyWith<_$_AppConfigModel> get copyWith =>
      __$$_AppConfigModelCopyWithImpl<_$_AppConfigModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AppConfigModelToJson(
      this,
    );
  }
}

abstract class _AppConfigModel implements AppConfigModel {
  const factory _AppConfigModel(
      {required final String baseUrl,
      required final String token,
      required final String appName,
      required final String appVersion,
      required final bool shouldCollectCrashLog}) = _$_AppConfigModel;

  factory _AppConfigModel.fromJson(Map<String, dynamic> json) =
      _$_AppConfigModel.fromJson;

  @override
  String get baseUrl;
  @override
  String get token;
  @override
  String get appName;
  @override
  String get appVersion;
  @override
  bool get shouldCollectCrashLog;
  @override
  @JsonKey(ignore: true)
  _$$_AppConfigModelCopyWith<_$_AppConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}
