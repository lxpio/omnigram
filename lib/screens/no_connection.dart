import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/l10n.dart';

class NoConnectionScreen extends ConsumerWidget {
  const NoConnectionScreen({required this.onRefresh, super.key});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(60),
              child: Lottie.asset(
                "assets/files/Animation-no-connection.json",
              ),
            ),
            Container(
              height: (MediaQuery.of(context).size.height) / 2.4,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.ooops,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.no_internet,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: onRefresh,
                    style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size.fromHeight(45)),
                    child: Text(
                      context.l10n.try_again,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  // MaterialButton(
                  //   onPressed: onRefresh,
                  //   height: 45,
                  //   padding: const EdgeInsets.symmetric(horizontal: 80),
                  //   elevation: 0,
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12)),
                  //   color: Theme.of(context).colorScheme.primary,
                  //   child: Text(
                  //     context.l10n.try_again,
                  //     style: TextStyle(
                  //         color: Theme.of(context).colorScheme.onPrimary),
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          ref.read(userProvider.notifier).logout();
                          context.goNamed(kLoginPage);
                        },
                        child: Text(
                          context.l10n.config_server,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
