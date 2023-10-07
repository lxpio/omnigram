import "package:flutter_native_splash/flutter_native_splash.dart";
import 'package:omnigram/flavors/app_store.dart';

class BuildConfig {
  bool _lock = false;

  static final BuildConfig instance = BuildConfig._internal();

  BuildConfig._internal();

  static Future<void> initialize() async {
    if (instance._lock) return;

    instance._lock = true;

    await AppStore.initialize('gramdb');

    // await AppManager.initialize();
    // await AppProvider.initialize();
    // await ServiceProviderManager.initialize();

    // Remove splash after home page update
    FlutterNativeSplash.remove();
  }
}
