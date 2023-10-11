// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return _AppConfig.fromJson(json);
}

/// @nodoc
mixin _$AppConfig {
  String get bookBaseUrl => throw _privateConstructorUsedError;
  String get bookToken => throw _privateConstructorUsedError;
  String get appName =>
      throw _privateConstructorUsedError; // final String model;
// final String dbName;
  bool get shouldCollectCrashLog => throw _privateConstructorUsedError;
  String? get openAIUrl => throw _privateConstructorUsedError;
  String? get openAIApiKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppConfigCopyWith<AppConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppConfigCopyWith<$Res> {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) then) =
      _$AppConfigCopyWithImpl<$Res, AppConfig>;
  @useResult
  $Res call(
      {String bookBaseUrl,
      String bookToken,
      String appName,
      bool shouldCollectCrashLog,
      String? openAIUrl,
      String? openAIApiKey});
}

/// @nodoc
class _$AppConfigCopyWithImpl<$Res, $Val extends AppConfig>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookBaseUrl = null,
    Object? bookToken = null,
    Object? appName = null,
    Object? shouldCollectCrashLog = null,
    Object? openAIUrl = freezed,
    Object? openAIApiKey = freezed,
  }) {
    return _then(_value.copyWith(
      bookBaseUrl: null == bookBaseUrl
          ? _value.bookBaseUrl
          : bookBaseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bookToken: null == bookToken
          ? _value.bookToken
          : bookToken // ignore: cast_nullable_to_non_nullable
              as String,
      appName: null == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String,
      shouldCollectCrashLog: null == shouldCollectCrashLog
          ? _value.shouldCollectCrashLog
          : shouldCollectCrashLog // ignore: cast_nullable_to_non_nullable
              as bool,
      openAIUrl: freezed == openAIUrl
          ? _value.openAIUrl
          : openAIUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      openAIApiKey: freezed == openAIApiKey
          ? _value.openAIApiKey
          : openAIApiKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppConfigImplCopyWith<$Res>
    implements $AppConfigCopyWith<$Res> {
  factory _$$AppConfigImplCopyWith(
          _$AppConfigImpl value, $Res Function(_$AppConfigImpl) then) =
      __$$AppConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookBaseUrl,
      String bookToken,
      String appName,
      bool shouldCollectCrashLog,
      String? openAIUrl,
      String? openAIApiKey});
}

/// @nodoc
class __$$AppConfigImplCopyWithImpl<$Res>
    extends _$AppConfigCopyWithImpl<$Res, _$AppConfigImpl>
    implements _$$AppConfigImplCopyWith<$Res> {
  __$$AppConfigImplCopyWithImpl(
      _$AppConfigImpl _value, $Res Function(_$AppConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookBaseUrl = null,
    Object? bookToken = null,
    Object? appName = null,
    Object? shouldCollectCrashLog = null,
    Object? openAIUrl = freezed,
    Object? openAIApiKey = freezed,
  }) {
    return _then(_$AppConfigImpl(
      bookBaseUrl: null == bookBaseUrl
          ? _value.bookBaseUrl
          : bookBaseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bookToken: null == bookToken
          ? _value.bookToken
          : bookToken // ignore: cast_nullable_to_non_nullable
              as String,
      appName: null == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String,
      shouldCollectCrashLog: null == shouldCollectCrashLog
          ? _value.shouldCollectCrashLog
          : shouldCollectCrashLog // ignore: cast_nullable_to_non_nullable
              as bool,
      openAIUrl: freezed == openAIUrl
          ? _value.openAIUrl
          : openAIUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      openAIApiKey: freezed == openAIApiKey
          ? _value.openAIApiKey
          : openAIApiKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppConfigImpl implements _AppConfig {
  const _$AppConfigImpl(
      {required this.bookBaseUrl,
      required this.bookToken,
      required this.appName,
      required this.shouldCollectCrashLog,
      this.openAIUrl,
      this.openAIApiKey});

  factory _$AppConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppConfigImplFromJson(json);

  @override
  final String bookBaseUrl;
  @override
  final String bookToken;
  @override
  final String appName;
// final String model;
// final String dbName;
  @override
  final bool shouldCollectCrashLog;
  @override
  final String? openAIUrl;
  @override
  final String? openAIApiKey;

  @override
  String toString() {
    return 'AppConfig(bookBaseUrl: $bookBaseUrl, bookToken: $bookToken, appName: $appName, shouldCollectCrashLog: $shouldCollectCrashLog, openAIUrl: $openAIUrl, openAIApiKey: $openAIApiKey)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppConfigImpl &&
            (identical(other.bookBaseUrl, bookBaseUrl) ||
                other.bookBaseUrl == bookBaseUrl) &&
            (identical(other.bookToken, bookToken) ||
                other.bookToken == bookToken) &&
            (identical(other.appName, appName) || other.appName == appName) &&
            (identical(other.shouldCollectCrashLog, shouldCollectCrashLog) ||
                other.shouldCollectCrashLog == shouldCollectCrashLog) &&
            (identical(other.openAIUrl, openAIUrl) ||
                other.openAIUrl == openAIUrl) &&
            (identical(other.openAIApiKey, openAIApiKey) ||
                other.openAIApiKey == openAIApiKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, bookBaseUrl, bookToken, appName,
      shouldCollectCrashLog, openAIUrl, openAIApiKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      __$$AppConfigImplCopyWithImpl<_$AppConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppConfigImplToJson(
      this,
    );
  }
}

abstract class _AppConfig implements AppConfig {
  const factory _AppConfig(
      {required final String bookBaseUrl,
      required final String bookToken,
      required final String appName,
      required final bool shouldCollectCrashLog,
      final String? openAIUrl,
      final String? openAIApiKey}) = _$AppConfigImpl;

  factory _AppConfig.fromJson(Map<String, dynamic> json) =
      _$AppConfigImpl.fromJson;

  @override
  String get bookBaseUrl;
  @override
  String get bookToken;
  @override
  String get appName;
  @override // final String model;
// final String dbName;
  bool get shouldCollectCrashLog;
  @override
  String? get openAIUrl;
  @override
  String? get openAIApiKey;
  @override
  @JsonKey(ignore: true)
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
