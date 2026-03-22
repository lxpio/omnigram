import 'package:freezed_annotation/freezed_annotation.dart';

part 'companion_personality.freezed.dart';
part 'companion_personality.g.dart';

@freezed
abstract class CompanionPersonality with _$CompanionPersonality {
  const factory CompanionPersonality({
    @Default('TARS') String name,
    @Default(50) int proactivity,
    @Default(50) int style,
    @Default(50) int depth,
    @Default(50) int warmth,
  }) = _CompanionPersonality;

  factory CompanionPersonality.fromJson(Map<String, dynamic> json) => _$CompanionPersonalityFromJson(json);
}

extension CompanionPresets on CompanionPersonality {
  static CompanionPersonality silent() =>
      const CompanionPersonality(name: 'TARS', proactivity: 20, style: 20, depth: 50, warmth: 30);

  static CompanionPersonality buddy() =>
      const CompanionPersonality(name: 'TARS', proactivity: 50, style: 60, depth: 40, warmth: 80);

  static CompanionPersonality scholar() =>
      const CompanionPersonality(name: 'TARS', proactivity: 80, style: 80, depth: 90, warmth: 30);
}
