import 'package:omnigram/providers/auth.provider.dart';
import 'package:omnigram/services/logger.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_life_cycle.provider.g.dart';

enum AppLifeCycleEnum {
  active,
  inactive,
  paused,
  resumed,
  detached,
  hidden,
}


@riverpod
class AppLifeCycle extends _$AppLifeCycle {

  bool _wasPaused = false;

  @override
  AppLifeCycleEnum build() {
    return AppLifeCycleEnum.active;
  }

   AppLifeCycleEnum getAppState() {
    return state;
  }

  void handleAppResume() {
    state = AppLifeCycleEnum.resumed;

    // no need to resume because app was never really paused
    if (!_wasPaused) return;
    _wasPaused = false;

    final isAuthenticated = ref.read(authProvider).isAuthenticated;

    // Needs to be logged in
    if (isAuthenticated) {
      // final permission = _ref.watch(galleryPermissionNotifier);
      // if (permission.isGranted || permission.isLimited) {
      //   _ref.read(backupProvider.notifier).resumeBackup();
      //   _ref.read(backgroundServiceProvider).resumeServiceIfEnabled();
      // }
      // _ref.read(serverInfoProvider.notifier).getServerVersion();
      // switch (_ref.read(tabProvider)) {
      //   case TabEnum.home:
      //     _ref.read(assetProvider.notifier).getAllAsset();
      //   case TabEnum.search:
      //   // nothing to do
      //   case TabEnum.sharing:
      //     _ref.read(assetProvider.notifier).getAllAsset();
      //     _ref.read(sharedAlbumProvider.notifier).getAllSharedAlbums();
      //   case TabEnum.library:
      //     _ref.read(albumProvider.notifier).getAllAlbums();
      // }
    }
  }

 void handleAppInactivity() {
    state = AppLifeCycleEnum.inactive;
    // do not stop/clean up anything on inactivity: issued on every orientation change
  }

  void handleAppPause() {
    state = AppLifeCycleEnum.paused;
    _wasPaused = true;
    // Do not cancel backup if manual upload is in progress
    // if (_ref.read(backupProvider.notifier).backupProgress !=
    //     BackUpProgressEnum.manualInProgress) {
    //   _ref.read(backupProvider.notifier).cancelBackup();
    // }
    // _ref.read(websocketProvider.notifier).disconnect();
    OmnigramLogger.instance.flush();
  }

  void handleAppDetached() {
    state = AppLifeCycleEnum.detached;
    // no guarantee this is called at all
    // _ref.read(manualUploadProvider.notifier).cancelBackup();
  }

  void handleAppHidden() {
    state = AppLifeCycleEnum.hidden;
    // do not stop/clean up anything on inactivity: issued on every orientation change
  }

}





// final appStateProvider =
//     StateNotifierProvider<AppLifeCycleNotifier, AppLifeCycleEnum>((ref) {
//   return AppLifeCycleNotifier(ref);
// });
