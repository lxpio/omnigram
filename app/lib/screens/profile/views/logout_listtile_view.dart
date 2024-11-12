import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/auth.provider.dart';

class LogoutListTileView extends ConsumerWidget {
  const LogoutListTileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text("about".tr()),
          const SizedBox(height: 8),
          // const Divider(),
          ListTile(
            leading: const Icon(
              Icons.logout,
              // size: 64,
            ),
            title: Text("logout".tr()),
            onTap: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
