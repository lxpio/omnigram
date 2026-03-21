import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/enums/lang_list.dart';
import 'package:omnigram/main.dart';
import 'package:omnigram/service/ai/prompt_generate.dart';
import 'package:omnigram/service/ai/index.dart';
import 'package:omnigram/service/config/config_item.dart';
import 'package:omnigram/service/translate/index.dart';
import 'package:omnigram/widgets/ai/ai_stream.dart';
import 'package:flutter/material.dart';

class AiTranslateProvider extends TranslateServiceProvider {
  @override
  TranslateService get service => TranslateService.ai;

  @override
  String getLabel(BuildContext context) => L10n.of(context).navBarAI;

  /// AI translation uses native language names (e.g., "简体中文", "English")
  /// instead of ISO codes for better prompt understanding.
  @override
  String mapLanguageCode(LangListEnum lang) => lang.nativeName;

  @override
  Widget translate(
    String text,
    LangListEnum from,
    LangListEnum to, {
    String? contextText,
    bool isFullText = false,
  }) {
    final prompt = isFullText
        ? generatePromptFullTextTranslate(
            text,
            mapLanguageCode(to),
            mapLanguageCode(from),
          )
        : generatePromptTranslate(
            text,
            mapLanguageCode(to),
            mapLanguageCode(from),
            contextText: contextText,
          );

    return AiStream(
      prompt: prompt,
      regenerate: true,
    );
  }

  @override
  Stream<String> translateStream(
    String text,
    LangListEnum from,
    LangListEnum to, {
    String? contextText,
    bool isFullText = false,
  }) async* {
    try {
      final payload = isFullText
          ? generatePromptFullTextTranslate(
              text,
              mapLanguageCode(to),
              mapLanguageCode(from),
            )
          : generatePromptTranslate(
              text,
              mapLanguageCode(to),
              mapLanguageCode(from),
              contextText: contextText,
            );

      final messages = payload.buildMessages();

      await for (final result
          in aiGenerateStream(messages, regenerate: false)) {
        yield result;
      }
    } catch (e) {
      yield L10n.of(navigatorKey.currentContext!).translateError + e.toString();
    }
  }

  @override
  List<ConfigItem> getConfigItems(BuildContext context) {
    return [
      ConfigItem(
        key: 'tip',
        label: 'Tip',
        type: ConfigItemType.tip,
        defaultValue:
            L10n.of(navigatorKey.currentContext!).settingsTranslateAiTip,
      ),
    ];
  }
}
