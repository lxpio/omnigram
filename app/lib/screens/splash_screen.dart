import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:logging/logging.dart';
import 'package:omnigram/providers/api.provider.dart';
import 'package:omnigram/providers/auth.provider.dart';
import 'package:omnigram/utils/constants.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = Logger("SplashScreenPage");

    final endpoint = IsarStore.tryGet(StoreKey.serverEndpoint);
    final accessToken = IsarStore.tryGet(StoreKey.accessToken);

    void performLoggingIn() async {
      log.info('Starting login process');
      bool isAuthSuccess = false;

      if (accessToken != null && endpoint != null) {
        ref.read(apiServiceProvider.notifier).setEndpoint(endpoint);
        try {
          isAuthSuccess = await ref.read(authProvider.notifier).setSuccessLoginInfo();
        } catch (error, stackTrace) {
          log.severe(
            'Cannot set success login info',
            error,
            stackTrace,
          );
        }
      } else {
        log.severe(
          'Missing authentication, server, or endpoint info from the local store',
        );
      }

      if (!isAuthSuccess) {
        log.severe(
          'Unable to login using offline or online methods - Logging out completely',
        );
        // ref.read(authProvider.notifier).logout();
      }

      // final hasPermission =
      //     await ref.read(galleryPermissionNotifier.notifier).hasPermission;
      // if (hasPermission) {
      //   // Resume backup (if enable) then navigate
      //   ref.watch(backupProvider.notifier).resumeBackup();
      // }
    }

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          performLoggingIn();
          debugPrint('Performing login');
          context.goNamed(kHomePage);
        });

        return null;
      },
      [],
    );

    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/images/logo-white-s.png'),
          width: 80,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
