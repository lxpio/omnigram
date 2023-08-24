import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:omnigram/routes/router.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:universal_platform/universal_platform.dart";
import 'package:desktop_window/desktop_window.dart';

import "flavors/app_theme.dart";
import "flavors/build_config.dart";
import "flavors/environment.dart";

Future setDesktopWindow() async {
  await DesktopWindow.setMinWindowSize(const Size(400, 400));
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

  await BuildConfig.initialize(
    envType: Environment.prod,
  );

  runApp(const ProviderScope(child: OmniApp()));
}

class OmniApp extends HookConsumerWidget {
  const OmniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    final _router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Omnigram',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
      // themeMode: AppManager.to.themeMode,
      // locale: const Locale('zh'),

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
