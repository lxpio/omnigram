import 'package:omnigram/utils/platform_utils.dart';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/dao/database.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/window_info.dart';
import 'package:omnigram/page/home_page.dart';
import 'package:omnigram/page/omnigram_home.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/page/migration_page.dart';
import 'package:omnigram/service/book_player/book_player_server.dart';
import 'package:omnigram/service/tts/tts_handler.dart';
import 'package:omnigram/utils/get_path/macos_migration.dart';
import 'package:omnigram/utils/color_scheme.dart';
import 'package:omnigram/utils/error/common.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:omnigram/utils/window_position_validator.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/service/sync/sync_manager.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:heroine/heroine.dart';
import 'package:provider/provider.dart' as provider;
import 'package:window_manager/window_manager.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late AudioHandler audioHandler;
final heroineController = HeroineController();

/// Whether macOS data migration is needed (checked at startup)
bool _needsMigration = false;
MigrationCheckResult? _migrationCheckResult;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs().initPrefs();

  // Initialize desktop window with validated position
  if (AnxPlatform.isWindows || AnxPlatform.isMacOS) {
    await initializeDesktopWindow();
  }

  // Check if migration is needed before initializing paths
  if (AnxPlatform.isMacOS) {
    _migrationCheckResult = await checkMigrationNeeded();
    _needsMigration = _migrationCheckResult?.needsMigration ?? false;
  }

  // If no migration needed, initialize paths normally
  if (!_needsMigration) {
    initBasePath();
    AnxLog.init();
    AnxError.init();
    await DBHelper().initDB();
  }

  Server().start();

  audioHandler = await AudioService.init(
    builder: () => TtsHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.anx.reader.tts.channel.audio',
      androidNotificationChannelName: 'ANX Reader TTS',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  SmartDialog.config.custom = SmartConfigCustom(
    maskColor: Colors.black.withAlpha(35),
    useAnimation: true,
    animationType: SmartAnimationType.centerFade_otherSlide,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver, WindowListener {
  static const Locale _englishFallbackLocale = Locale('en');

  bool _syncStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> onWindowClose() async {
    await Server().stop();
    await webViewEnvironment?.dispose();
    webViewEnvironment = null;
    await DBHelper.close();
    await windowManager.destroy();
  }

  @override
  Future<void> onWindowMoved() async {
    await _updateWindowInfo();
  }

  @override
  Future<void> onWindowMaximize() async {
    await _updateWindowInfo();
  }

  @override
  Future<void> onWindowUnmaximize() async {
    await _updateWindowInfo();
  }

  @override
  Future<void> onWindowResized() async {
    await _updateWindowInfo();
  }

  Future<void> _updateWindowInfo() async {
    if (!AnxPlatform.isWindows && !AnxPlatform.isMacOS) {
      return;
    }
    final windowOffset = await windowManager.getPosition();
    final windowSize = await windowManager.getSize();
    final isMaximized = await windowManager.isMaximized();

    Prefs().windowInfo = WindowInfo(
      x: windowOffset.dx,
      y: windowOffset.dy,
      width: windowSize.width,
      height: windowSize.height,
      isMaximized: isMaximized,
    );
    AnxLog.info('onWindowClose: Offset: $windowOffset, Size: $windowSize');
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (AnxPlatform.isIOS) {
        Server().start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch server connection — trigger sync when connection is restored
    ref.listen<ServerConnectionState>(serverConnectionProvider, (prev, next) {
      debugPrint('[Main] Connection state changed: ${prev?.status} → ${next.status}, syncStarted=$_syncStarted');
      if (!_syncStarted && next.isConnected) {
        _syncStarted = true;
        debugPrint('[Main] Starting sync...');
        ref.read(syncManagerProvider.notifier).sync();
        ref.read(syncManagerProvider.notifier).startAutoSync();
      }
    });

    return provider.MultiProvider(
      providers: [provider.ChangeNotifierProvider(create: (_) => Prefs())],
      child: provider.Consumer<Prefs>(
        builder: (context, prefsNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            scrollBehavior: ScrollConfiguration.of(context).copyWith(
              physics: const BouncingScrollPhysics(),
              // dragDevices: {
              //   PointerDeviceKind.touch,
              //   PointerDeviceKind.mouse,
              // },
            ),
            navigatorObservers: [FlutterSmartDialog.observer, heroineController],
            builder: FlutterSmartDialog.init(),
            navigatorKey: navigatorKey,
            locale: prefsNotifier.locale,
            localeListResolutionCallback: _resolveLocale,
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            title: 'Omnigram',
            themeMode: prefsNotifier.themeMode,
            theme: OmnigramTheme.light(),
            darkTheme: OmnigramTheme.dark(),
            home: _needsMigration
                ? _MigrationWrapper(migrationCheckResult: _migrationCheckResult!)
                : const OmnigramHome(),
          );
        },
      ),
    );
  }

  Locale _resolveLocale(List<Locale>? preferredLocales, Iterable<Locale> supportedLocales) {
    if (preferredLocales == null || preferredLocales.isEmpty) {
      return _englishFallbackLocale;
    }

    final Locale resolvedLocale = basicLocaleListResolution(preferredLocales, supportedLocales);

    final bool hasMatch = preferredLocales.any((Locale preferredLocale) {
      return supportedLocales.any((Locale supportedLocale) {
        if (preferredLocale.languageCode != supportedLocale.languageCode) {
          return false;
        }

        final String? preferredCountryCode = preferredLocale.countryCode;
        final String? supportedCountryCode = supportedLocale.countryCode;

        return preferredCountryCode == null ||
            supportedCountryCode == null ||
            preferredCountryCode == supportedCountryCode;
      });
    });

    return hasMatch ? resolvedLocale : _englishFallbackLocale;
  }
}

/// Widget that wraps the migration flow on macOS.
/// Shows MigrationPage during migration, then navigates to HomePage.
class _MigrationWrapper extends StatefulWidget {
  final MigrationCheckResult migrationCheckResult;

  const _MigrationWrapper({required this.migrationCheckResult});

  @override
  State<_MigrationWrapper> createState() => _MigrationWrapperState();
}

class _MigrationWrapperState extends State<_MigrationWrapper> {
  bool _migrationComplete = false;

  Future<void> _onMigrationComplete() async {
    // Initialize paths and DB after migration
    initBasePath();
    AnxLog.init();
    AnxError.init();
    await DBHelper().initDB();

    if (mounted) {
      setState(() {
        _migrationComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_migrationComplete) {
      return const HomePage();
    }
    return MigrationPage(onMigrationComplete: _onMigrationComplete);
  }
}
