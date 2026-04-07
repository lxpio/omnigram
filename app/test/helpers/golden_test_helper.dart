import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/theme/omnigram_theme.dart';

/// Wraps a widget with MaterialApp + L10n + OmnigramTheme for golden tests.
/// Use a fixed size to ensure consistent golden images across environments.
Widget goldenTestApp(Widget child, {Size size = const Size(400, 600)}) {
  return MaterialApp(
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    locale: const Locale('en'),
    theme: OmnigramTheme.light(),
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: child,
      ),
    ),
  );
}
