import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:omnigram/providers/scan_status.provider.dart';

class ScanStatusView extends HookConsumerWidget {
  const ScanStatusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(scanStatusProvider);

    return scan.when(
      data: (status) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // padding: EdgeInsets.only(bottom: 16),
            // margin: const EdgeInsets.only(bottom: 32.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  // dense: true,
                  title: Text('usage'.tr()),
                  trailing: status.running
                      ? IconButton(
                          onPressed: () {
                            ref.read(scanServiceProvider.notifier).stop();
                          },
                          icon: const Icon(Icons.stop_circle),
                          color: Theme.of(context).colorScheme.primary,
                          iconSize: 20,
                        )
                      : null,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxHeight - 16,
                        maxHeight: 128,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          usageCard(context, Icons.auto_stories, '${status.total}', 'scan_book_total_units'.tr()),
                          usageCard(context, Icons.storage, '${status.diskUsage}', 'scan_disk_usage'.tr()),
                        ],
                      ),
                    );
                  }),
                ),
                // const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: status.running
                      ? SizedBox(
                          height: 24,
                          child: Lottie.asset("assets/files/Animation-progress.json"),
                        )
                      : Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Theme.of(context).colorScheme.onTertiary),
                              child: Text(
                                'scan_time'.tr(namedArgs: {"time": DateTime.now().year.toString()}),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Theme.of(context).colorScheme.tertiary),
                              ),
                            ),
                            const Spacer(),
                            IconButton.filledTonal(
                              // hoverColor:
                              //     Theme.of(context).colorScheme.tertiary,
                              color: Theme.of(context).colorScheme.tertiary,
                              onPressed: () {
                                ref.read(scanServiceProvider.notifier).run();
                              },
                              icon: const Icon(Icons.refresh),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.onTertiary,
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () {},
                              color: Theme.of(context).colorScheme.tertiary,
                              icon: const Icon(Icons.more_vert),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.onTertiary,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );

        // )
      },
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Center(child: Text(err.toString())),
    );
  }

  Widget usageCard(BuildContext context, IconData iconData, String title, String subTitle) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 16, 8, 16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              iconData,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            Column(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  subTitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
