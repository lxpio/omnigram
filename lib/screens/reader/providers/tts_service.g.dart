// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TTSStateImpl _$$TTSStateImplFromJson(Map<String, dynamic> json) =>
    _$TTSStateImpl(
      showbar: json['showbar'] as bool? ?? false,
      playing: json['playing'] as bool? ?? false,
      position: json['position'] == null
          ? null
          : Duration(microseconds: json['position'] as int),
    );

Map<String, dynamic> _$$TTSStateImplToJson(_$TTSStateImpl instance) =>
    <String, dynamic>{
      'showbar': instance.showbar,
      'playing': instance.playing,
      'position': instance.position?.inMicroseconds,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ttsServiceHash() => r'c38508bd42c2fe06803f756979c0445e4fd1c599';

/// See also [TtsService].
@ProviderFor(TtsService)
final ttsServiceProvider = NotifierProvider<TtsService, TTSState>.internal(
  TtsService.new,
  name: r'ttsServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ttsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TtsService = Notifier<TTSState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
