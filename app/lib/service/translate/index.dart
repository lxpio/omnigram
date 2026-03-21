import 'dart:core';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/enums/lang_list.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/service/config/config_item.dart';
import 'package:omnigram/service/translate/ai.dart';
import 'package:omnigram/service/translate/deepl.dart';
import 'package:omnigram/service/translate/google_api.dart';
import 'package:omnigram/service/translate/microsoft_api.dart';
import 'package:omnigram/service/translate/web_view.dart';
import 'package:omnigram/utils/env_var.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TranslateService {
  bingWeb,
  googleWeb,
  microsoftApi,
  googleApi,
  deepl,
  ai;

  TranslateServiceProvider get provider {
    switch (this) {
      case TranslateService.bingWeb:
        return BingWebTranslateProvider();
      case TranslateService.googleWeb:
        return GoogleWebTranslateProvider();
      case TranslateService.microsoftApi:
        return MicrosoftApiTranslateProvider();
      case TranslateService.googleApi:
        return GoogleApiTranslateProvider();
      case TranslateService.deepl:
        return DeepLTranslateProvider();
      case TranslateService.ai:
        return AiTranslateProvider();
    }
  }

  /// Get the display label from the provider.
  String getLabel(BuildContext context) => provider.getLabel(context);

  /// Check if the service is a WebView provider.
  bool get isWebView => provider is WebViewTranslateProvider;

  static List<TranslateService> get activeValues => values
      .where((e) => e != TranslateService.ai || EnvVar.enableAIFeature)
      .toList();
}

TranslateService getTranslateService(String name) {
  if (name == 'microsoft') {
    return TranslateService.microsoftApi;
  }

  try {
    return TranslateService.values.firstWhere((e) => e.name == name);
  } catch (e) {
    return TranslateService.bingWeb;
  }
}

/// Base class for all translation service providers.
/// Subclasses must implement [service], [label], [translate], and [translateStream].
abstract class TranslateServiceProvider {
  /// The service enum value this provider corresponds to.
  TranslateService get service;

  /// The display label for this service.
  String getLabel(BuildContext context);

  /// Override this method if the service uses a different code format.
  /// Default implementation returns [lang.code].
  String mapLanguageCode(LangListEnum lang) => lang.code;

  /// Get the configuration items for this service.
  List<ConfigItem> getConfigItems(BuildContext context) {
    return [];
  }

  /// Returns the widget for displaying the translation result.
  Widget translate(
    String text,
    LangListEnum from,
    LangListEnum to, {
    String? contextText,
  });

  /// Returns a stream of translation results.
  Stream<String> translateStream(
    String text,
    LangListEnum from,
    LangListEnum to, {
    String? contextText,
    bool isFullText = false,
  });

  /// Translate text only (no widget), with retry logic.
  Future<String> translateTextOnly(
    String text,
    LangListEnum from,
    LangListEnum to, {
    String? contextText,
    bool isFullText = false,
  }) async {
    const int maxRetries = 2;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        String? lastResult;
        await for (String result in translateStream(
          text,
          from,
          to,
          contextText: contextText,
          isFullText: isFullText,
        )) {
          lastResult = result;
        }

        if (lastResult != null &&
            lastResult.trim().isNotEmpty &&
            lastResult != '...') {
          return lastResult;
        }

        throw Exception(
            'Translation returned no valid result: ${lastResult ?? 'No result'}');
      } catch (e) {
        if (attempt < maxRetries) {
          AnxLog.warning(
              'Translation attempt ${attempt + 1} failed with exception: $e. Retrying...');
          await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
          continue;
        } else {
          throw Exception(
              'Translation failed after ${maxRetries + 1} attempts: $e');
        }
      }
    }

    throw Exception('Translation failed after all retry attempts');
  }

  /// Returns the current configuration.
  Map<String, dynamic> getConfig() => {};

  /// Saves the configuration.
  void saveConfig(Map<String, dynamic> config) {}

  /// Helper to convert a stream to a widget with copy button.
  Widget convertStreamToWidget(Stream<String> stream) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        Widget content() {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('...');
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return Text(snapshot.data!);
          } else {
            return const Text('');
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            content(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: snapshot.data!)),
                    child: Text(L10n.of(context).commonCopy))
              ],
            )
          ],
        );
      },
    );
  }
}

// ============================================================================
// Helper functions (use service.provider instead of TranslateFactory)
// ============================================================================

Widget translateText(String text,
    {TranslateService? service, String? contextText}) {
  service ??= Prefs().translateService;
  final from = Prefs().translateFrom;
  final to = Prefs().translateTo;

  return service.provider.translate(
    text,
    from,
    to,
    contextText: contextText,
  );
}

List<ConfigItem> getTranslateServiceConfigItems(
    BuildContext context, TranslateService service) {
  return service.provider.getConfigItems(context);
}

Map<String, dynamic> getTranslateServiceConfig(TranslateService service) {
  return service.provider.getConfig();
}

void saveTranslateServiceConfig(
    TranslateService service, Map<String, dynamic> config) {
  return service.provider.saveConfig(config);
}

Future<String> translateTextOnly(String text,
    {TranslateService? service, String? contextText}) async {
  service ??= Prefs().translateService;
  final from = Prefs().translateFrom;
  final to = Prefs().translateTo;

  return await service.provider.translateTextOnly(
    text,
    from,
    to,
    contextText: contextText,
  );
}
