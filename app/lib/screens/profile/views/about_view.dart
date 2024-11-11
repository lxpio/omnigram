import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AboutView extends ConsumerWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("about".tr()),
          const SizedBox(height: 8),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.pageview),
            title: Text("content_policy".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {},
            // ),
          ),
          ListTile(
            leading: const Icon(Icons.pageview),
            title: Text("privacy_policy".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {},
            // ),
          ),
          ListTile(
            leading: const Icon(Icons.pageview),
            title: Text("user_agreement".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {},
            // ),
          ),
          ListTile(
            leading: const Icon(Icons.pageview),
            title: Text("acknowledgements".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {},
            // ),
          ),
          ListTile(
            leading: const Icon(Icons.pageview),
            title: Text("app_versions".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {},
            // ),
          ),
        ],
      ),
    );
  }
}
