import 'package:omnigram/enums/bgimg_alignment.dart';
import 'package:omnigram/enums/bgimg_theme_mode.dart';
import 'package:omnigram/enums/bgimg_type.dart';
import 'package:omnigram/service/book_player/book_player_server.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bgimg.freezed.dart';
part 'bgimg.g.dart';

@freezed
abstract class BgimgModel with _$BgimgModel {
  const factory BgimgModel({
    required BgimgType type,
    required String path,
    String? nightPath,
    required BgimgAlignment alignment,
    BgimgThemeMode? selectedMode,
    @Default(0.0) double blur,
    @Default(1.0) double opacity,
  }) = _BgimgModel;

  factory BgimgModel.fromJson(Map<String, dynamic> json) =>
      _$BgimgModelFromJson(json);

  const BgimgModel._();

  String get url => switch (type) {
        BgimgType.none => 'none',
        BgimgType.assets =>
          'http://127.0.0.1:${Server().port}/bgimg/assets/$path',
        BgimgType.localFile =>
          'http://127.0.0.1:${Server().port}/bgimg/local/$path',
      };

  String? get nightUrl => switch (type) {
        BgimgType.none => null,
        BgimgType.assets => nightPath != null
            ? 'http://127.0.0.1:${Server().port}/bgimg/assets/$nightPath'
            : null,
        BgimgType.localFile => nightPath != null
            ? 'http://127.0.0.1:${Server().port}/bgimg/local/$nightPath'
            : null,
      };

  /// Get the effective URL based on user selection and auto-adjust settings
  String getEffectiveUrl({
    required bool isDarkMode,
    required bool autoAdjust,
  }) {
    if (autoAdjust) {
      // Auto mode: use system dark mode to determine
      return isDarkMode && nightUrl != null ? nightUrl! : url;
    } else {
      // Manual mode: use user's selected mode
      if (selectedMode == BgimgThemeMode.night && nightUrl != null) {
        return nightUrl!;
      }
      return url;
    }
  }
}
