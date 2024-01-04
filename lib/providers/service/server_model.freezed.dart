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

ServerModel _$ServerModelFromJson(Map<String, dynamic> json) {
  return _ServerModel.fromJson(json);
}

/// @nodoc
mixin _$ServerModel {
  String get version => throw _privateConstructorUsedError;
  bool get chatEnabled => throw _privateConstructorUsedError;
  bool get m4tEnabled => throw _privateConstructorUsedError;
  String? get system => throw _privateConstructorUsedError;
  String? get architecture => throw _privateConstructorUsedError;
  @JsonKey(name: 'docs_data_path')
  String get docsDataPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'm4t_server_addr')
  String? get m4tServerAddr => throw _privateConstructorUsedError;
  @JsonKey(name: 'openai_url')
  String? get openAIUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'openai_apikey')
  String? get openAIApiKey => throw _privateConstructorUsedError;

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
      bool chatEnabled,
      bool m4tEnabled,
      String? system,
      String? architecture,
      @JsonKey(name: 'docs_data_path') String docsDataPath,
      @JsonKey(name: 'm4t_server_addr') String? m4tServerAddr,
      @JsonKey(name: 'openai_url') String? openAIUrl,
      @JsonKey(name: 'openai_apikey') String? openAIApiKey});
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
    Object? chatEnabled = null,
    Object? m4tEnabled = null,
    Object? system = freezed,
    Object? architecture = freezed,
    Object? docsDataPath = null,
    Object? m4tServerAddr = freezed,
    Object? openAIUrl = freezed,
    Object? openAIApiKey = freezed,
  }) {
    return _then(_value.copyWith(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      chatEnabled: null == chatEnabled
          ? _value.chatEnabled
          : chatEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      m4tEnabled: null == m4tEnabled
          ? _value.m4tEnabled
          : m4tEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      system: freezed == system
          ? _value.system
          : system // ignore: cast_nullable_to_non_nullable
              as String?,
      architecture: freezed == architecture
          ? _value.architecture
          : architecture // ignore: cast_nullable_to_non_nullable
              as String?,
      docsDataPath: null == docsDataPath
          ? _value.docsDataPath
          : docsDataPath // ignore: cast_nullable_to_non_nullable
              as String,
      m4tServerAddr: freezed == m4tServerAddr
          ? _value.m4tServerAddr
          : m4tServerAddr // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$_ServerModelCopyWith<$Res>
    implements $ServerModelCopyWith<$Res> {
  factory _$$_ServerModelCopyWith(
          _$_ServerModel value, $Res Function(_$_ServerModel) then) =
      __$$_ServerModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String version,
      bool chatEnabled,
      bool m4tEnabled,
      String? system,
      String? architecture,
      @JsonKey(name: 'docs_data_path') String docsDataPath,
      @JsonKey(name: 'm4t_server_addr') String? m4tServerAddr,
      @JsonKey(name: 'openai_url') String? openAIUrl,
      @JsonKey(name: 'openai_apikey') String? openAIApiKey});
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
    Object? chatEnabled = null,
    Object? m4tEnabled = null,
    Object? system = freezed,
    Object? architecture = freezed,
    Object? docsDataPath = null,
    Object? m4tServerAddr = freezed,
    Object? openAIUrl = freezed,
    Object? openAIApiKey = freezed,
  }) {
    return _then(_$_ServerModel(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      chatEnabled: null == chatEnabled
          ? _value.chatEnabled
          : chatEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      m4tEnabled: null == m4tEnabled
          ? _value.m4tEnabled
          : m4tEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      system: freezed == system
          ? _value.system
          : system // ignore: cast_nullable_to_non_nullable
              as String?,
      architecture: freezed == architecture
          ? _value.architecture
          : architecture // ignore: cast_nullable_to_non_nullable
              as String?,
      docsDataPath: null == docsDataPath
          ? _value.docsDataPath
          : docsDataPath // ignore: cast_nullable_to_non_nullable
              as String,
      m4tServerAddr: freezed == m4tServerAddr
          ? _value.m4tServerAddr
          : m4tServerAddr // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$_ServerModel implements _ServerModel {
  const _$_ServerModel(
      {this.version = "v1.0.0",
      this.chatEnabled = true,
      this.m4tEnabled = true,
      this.system,
      this.architecture,
      @JsonKey(name: 'docs_data_path') this.docsDataPath = '/docs',
      @JsonKey(name: 'm4t_server_addr') this.m4tServerAddr,
      @JsonKey(name: 'openai_url') this.openAIUrl,
      @JsonKey(name: 'openai_apikey') this.openAIApiKey});

  factory _$_ServerModel.fromJson(Map<String, dynamic> json) =>
      _$$_ServerModelFromJson(json);

  @override
  @JsonKey()
  final String version;
  @override
  @JsonKey()
  final bool chatEnabled;
  @override
  @JsonKey()
  final bool m4tEnabled;
  @override
  final String? system;
  @override
  final String? architecture;
  @override
  @JsonKey(name: 'docs_data_path')
  final String docsDataPath;
  @override
  @JsonKey(name: 'm4t_server_addr')
  final String? m4tServerAddr;
  @override
  @JsonKey(name: 'openai_url')
  final String? openAIUrl;
  @override
  @JsonKey(name: 'openai_apikey')
  final String? openAIApiKey;

  @override
  String toString() {
    return 'ServerModel(version: $version, chatEnabled: $chatEnabled, m4tEnabled: $m4tEnabled, system: $system, architecture: $architecture, docsDataPath: $docsDataPath, m4tServerAddr: $m4tServerAddr, openAIUrl: $openAIUrl, openAIApiKey: $openAIApiKey)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ServerModel &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.chatEnabled, chatEnabled) ||
                other.chatEnabled == chatEnabled) &&
            (identical(other.m4tEnabled, m4tEnabled) ||
                other.m4tEnabled == m4tEnabled) &&
            (identical(other.system, system) || other.system == system) &&
            (identical(other.architecture, architecture) ||
                other.architecture == architecture) &&
            (identical(other.docsDataPath, docsDataPath) ||
                other.docsDataPath == docsDataPath) &&
            (identical(other.m4tServerAddr, m4tServerAddr) ||
                other.m4tServerAddr == m4tServerAddr) &&
            (identical(other.openAIUrl, openAIUrl) ||
                other.openAIUrl == openAIUrl) &&
            (identical(other.openAIApiKey, openAIApiKey) ||
                other.openAIApiKey == openAIApiKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      version,
      chatEnabled,
      m4tEnabled,
      system,
      architecture,
      docsDataPath,
      m4tServerAddr,
      openAIUrl,
      openAIApiKey);

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
          final bool chatEnabled,
          final bool m4tEnabled,
          final String? system,
          final String? architecture,
          @JsonKey(name: 'docs_data_path') final String docsDataPath,
          @JsonKey(name: 'm4t_server_addr') final String? m4tServerAddr,
          @JsonKey(name: 'openai_url') final String? openAIUrl,
          @JsonKey(name: 'openai_apikey') final String? openAIApiKey}) =
      _$_ServerModel;

  factory _ServerModel.fromJson(Map<String, dynamic> json) =
      _$_ServerModel.fromJson;

  @override
  String get version;
  @override
  bool get chatEnabled;
  @override
  bool get m4tEnabled;
  @override
  String? get system;
  @override
  String? get architecture;
  @override
  @JsonKey(name: 'docs_data_path')
  String get docsDataPath;
  @override
  @JsonKey(name: 'm4t_server_addr')
  String? get m4tServerAddr;
  @override
  @JsonKey(name: 'openai_url')
  String? get openAIUrl;
  @override
  @JsonKey(name: 'openai_apikey')
  String? get openAIApiKey;
  @override
  @JsonKey(ignore: true)
  _$$_ServerModelCopyWith<_$_ServerModel> get copyWith =>
      throw _privateConstructorUsedError;
}
