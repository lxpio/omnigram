import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/scan_status.dart';

class ScanStatusView extends HookConsumerWidget {
  const ScanStatusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(scanStatusProvider);

    return scan.when(
      data: (status) {
        return Container(
          height: 200,
          // padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          // margin: const EdgeInsets.only(bottom: 32.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('服务器使用'),
              ),
              ListTile(
                title: Text(
                  '${status.total}',
                  style: TextStyle(
                    fontSize: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                // subtitle: Text(
                //   "本",
                //   style: TextStyle(
                //     fontSize: 16,
                //     color: Theme.of(context).colorScheme.primary,
                //   ),
                // ),
                trailing: status.running
                    ? IconButton(
                        onPressed: () {
                          ref.read(scanAPIProvider.notifier).stop();
                        },
                        icon: Icon(
                          Icons.stop_circle,
                          size: 48,
                        ),
                        // color: Theme.of(context).colorScheme.primary,
                      )
                    : IconButton(
                        onPressed: () {
                          ref.read(scanAPIProvider.notifier).run();
                        },
                        icon: Icon(
                          Icons.refresh,
                          size: 48,
                        ),
                        // color: Theme.of(context).colorScheme.primary,
                      ),
              ),
              if (status.running)
                LinearProgressIndicator(
                  value: 0.75,
                  semanticsLabel: 'Linear progress indicator',
                )
            ],
          ),
          // color: Theme.of(context).colorScheme.primary.withAlpha(20),
        );

        // )
      },
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Center(child: Text(err.toString())),
    );
  }
}
