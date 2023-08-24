import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:omnigram/models/model.dart";

import "environment.dart";

class BuildConfig {
  late final Environment environment;

  bool _lock = false;

  static final BuildConfig instance = BuildConfig._internal();

  BuildConfig._internal();

  static Future<void> initialize({
    required Environment envType,
  }) async {
    if (instance._lock) return;

    instance.environment = envType;
    instance._lock = true;

    await AppStore.initialize('gramdb');

    // await AppManager.initialize();
    // await AppProvider.initialize();
    // await ServiceProviderManager.initialize();

    // Remove splash after home page update
    FlutterNativeSplash.remove();
  }
}
