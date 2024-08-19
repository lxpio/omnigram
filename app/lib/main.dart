import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import 'package:omnigram/providers/provider.dart';
import "package:omnigram/routes/router.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:universal_platform/universal_platform.dart";
import 'package:desktop_window/desktop_window.dart';

import "models/build_config.dart";
import "models/color_schemes.g.dart";

Future setDesktopWindow() async {
  await DesktopWindow.setMinWindowSize(const Size(600, 400));
  await DesktopWindow.setWindowSize(const Size(1300, 900));
}

Future<void> main() async {
//加载数据前动画效果
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  if (UniversalPlatform.isDesktop) {
    setDesktopWindow();
  }

  await BuildConfig.initialize();

  runApp(const ProviderScope(child: OmniApp()));
}

class OmniApp extends HookConsumerWidget {
  const OmniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Omnigram',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      routerConfig: router,
      // themeMode: AppManager.to.themeMode,
      // locale:
      //     Platform.localeName == 'zh' ? const Locale('zh') : const Locale('en'),

      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'), // Chinese
        Locale('en'), // English
      ],
    );
  }
}
