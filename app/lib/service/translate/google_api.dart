import 'package:omnigram/enums/lang_list.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/config/config_item.dart';
import 'package:omnigram/service/translate/index.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:omnigram/config/shared_preference_provider.dart';

const _urlGoogleApi =
    'https://translation.googleapis.com/language/translate/v2';

class GoogleApiTranslateProvider extends TranslateServiceProvider {
  @override
  TranslateService get service => TranslateService.googleApi;

  @override
  String getLabel(BuildContext context) =>
      L10n.of(context).translateGoogleCloud;

  @override
  Widget translate(
    String text,
    LangListEnum from,
    LangListEnum to, {
    String? contextText,
    bool isFullText = false,
  }) {
    return convertStreamToWidget(
      translateStream(text, from, to, contextText: contextText),
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
      final config = getConfig();
      final apiKey = config['api_key']?.toString() ?? '';

      if (apiKey.isEmpty) {
        yield* Stream.error(Exception('Please set Google API Key in settings'));
        return;
      }

      yield "...";

      final params = {
        'key': apiKey,
        'q': text,
        'target': mapLanguageCode(to),
        'format': 'text',
      };

      if (from != LangListEnum.auto) {
        params['source'] = mapLanguageCode(from);
      }

      final uri = Uri.parse(_urlGoogleApi).replace(queryParameters: params);

      final response = await Dio().post(uri.toString());

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null &&
            data['data']['translations'] != null &&
            (data['data']['translations'] as List).isNotEmpty) {
          yield data['data']['translations'][0]['translatedText'];
        } else {
          yield* Stream.error(Exception('Google API returned unexpected data'));
        }
      } else {
        yield* Stream.error(Exception('Google API Error: ${response.data}'));
      }
    } catch (e) {
      AnxLog.severe("Translate Google API Error: error=$e");
      yield* Stream.error(Exception(e));
    }
  }

  @override
  List<ConfigItem> getConfigItems(BuildContext context) {
    return [
      ConfigItem(
        key: 'tip',
        label: L10n.of(context).translateTip,
        type: ConfigItemType.tip,
        defaultValue: L10n.of(context).translateGoogleHelpText,
        link: 'https://anx.anxcye.com/docs/translate/google',
      ),
      ConfigItem(
        key: 'api_key',
        label: 'API Key',
        description: L10n.of(context).translateGoogleApiKeyDescription,
        type: ConfigItemType.password,
        defaultValue: '',
      ),
    ];
  }

  @override
  Map<String, dynamic> getConfig() {
    final config = Prefs().getTranslateServiceConfig(service);
    return config ?? {'api_key': ''};
  }

  @override
  void saveConfig(Map<String, dynamic> config) {
    Prefs().saveTranslateServiceConfig(service, config);
  }
}
