import 'dart:io';
import 'package:omnigram/config/shared_preference_provider.dart';

/// Get the user's preferred language name for AI reply instructions.
/// Uses app locale setting, falls back to device locale, then English.
String getAiReplyLanguage() {
  final currentLanguageCode =
      Prefs().locale?.languageCode ?? Platform.localeName;

  const languageMap = {
    'zh': '简体中文',
    'zh-CN': '简体中文',
    'zh-Hans': '简体中文',
    'zh-TW': '繁體中文',
    'zh-Hant': '繁體中文',
    'en': 'English',
    'ja': '日本語',
    'ko': '한국어',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'ru': 'Русский',
    'ar': 'العربية',
    'tr': 'Türkçe',
  };

  return languageMap[currentLanguageCode] ??
      languageMap[currentLanguageCode.split('_').first] ??
      'English';
}
