import "dart:io";

import "package:easy_localization/easy_localization.dart";
import 'package:device_info_plus/device_info_plus.dart';
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:hooks_riverpod/hooks_riverpod.dart';
import "package:omnigram/consts/locales.dart";
import "package:omnigram/extensions/build_context_extensions.dart";
import "package:omnigram/providers/app_life_cycle.provider.dart";
import "package:omnigram/providers/theme.provider.dart";
import "package:omnigram/routes/router.dart";
import "package:universal_platform/universal_platform.dart";
import 'package:desktop_window/desktop_window.dart';

import "providers/db.provider.dart";
import "utils/build_config.dart";

Future setDesktopWindow() async {
  await DesktopWindow.setMinWindowSize(const Size(600, 400));
  await DesktopWindow.setWindowSize(const Size(1300, 900));
}

Future<void> main() async {
//加载数据前动画效果
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  if (UniversalPlatform.isDesktop) {
    setDesktopWindow();
  }

  // if (kReleaseMode && Platform.isAndroid) {
  //   try {
  //     await FlutterDisplayMode.setHighRefreshRate();
  //     debugPrint("Enabled high refresh mode");
  //   } catch (e) {
  //     debugPrint("Error setting high refresh rate: $e");
  //   }
  // }

  final db = await BuildConfig.initialize();

  //加载proxy配置
  // HttpOverrides.global = HttpProxyOverrides();

  runApp(
    ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: const MainWidget(),
    ),
  );
}

class OmnigramApp extends ConsumerStatefulWidget {
  const OmnigramApp({super.key});

  @override
  ConsumerState<OmnigramApp> createState() => _OmnigramAppState();
}

class _OmnigramAppState extends ConsumerState<OmnigramApp>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: MaterialApp.router(
        title: 'Omnigram',
        debugShowCheckedModeBanner: false,

        themeMode: ref.watch(themeModeProvider),
        darkTheme: omnigramDarkTheme,
        theme: omnigramLightTheme,
        routerConfig: router,
        // routeInformationParser: router.routeInformationParser,
        // routerDelegate: router.routerDelegate,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _initApp().then((_) => debugPrint("App Init Completed"));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // needs to be delayed so that EasyLocalization is working
      //TODO
      // ref.read(backgroundServiceProvider).resumeServiceIfEnabled();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("[APP STATE] resumed");
        ref.read(appLifeCycleProvider.notifier).handleAppResume();
        break;
      case AppLifecycleState.inactive:
        debugPrint("[APP STATE] inactive");
        ref.read(appLifeCycleProvider.notifier).handleAppInactivity();
        break;
      case AppLifecycleState.paused:
        debugPrint("[APP STATE] paused");
        ref.read(appLifeCycleProvider.notifier).handleAppPause();
        break;
      case AppLifecycleState.detached:
        debugPrint("[APP STATE] detached");
        ref.read(appLifeCycleProvider.notifier).handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        debugPrint("[APP STATE] hidden");
        ref.read(appLifeCycleProvider.notifier).handleAppHidden();
        break;
    }
  }

  Future<void> _initApp() async {
    WidgetsBinding.instance.addObserver(this);

    // Draw the app from edge to edge
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Sets the navigation bar color
    SystemUiOverlayStyle overlayStyle = const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    );
    if (Platform.isAndroid) {
      // Android 8 does not support transparent app bars
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt <= 26) {
        overlayStyle = context.isDarkTheme
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light;
      }
    }
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
    //TODO : check if this is needed
    // await ref.read(localNotificationService).setup();
  }
}

// ignore: prefer-single-widget-per-file
class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: locales.values.toList(),
      path: translationsPath,
      useFallbackTranslations: true,
      fallbackLocale: locales.values.first,
      child: const OmnigramApp(),
    );
  }
}
