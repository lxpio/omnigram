// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TTSState _$$_TTSStateFromJson(Map<String, dynamic> json) => _$_TTSState(
      showbar: json['showbar'] as bool? ?? false,
      playing: json['playing'] as bool? ?? false,
    );

Map<String, dynamic> _$$_TTSStateToJson(_$_TTSState instance) =>
    <String, dynamic>{
      'showbar': instance.showbar,
      'playing': instance.playing,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ttsServiceHash() => r'90092a717c131b00f7be95f22a79875080992a9f';

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
