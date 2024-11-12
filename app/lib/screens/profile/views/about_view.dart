import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

const omnigramHost = '''https://omnigram.lxpio.com/''';

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
            leading: const Icon(Icons.article),
            title: Text("content_policy".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await launchUrl(Uri.parse('${'omnigram_web_link'.tr()}/contentpolicy'));
            },
            // ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text("privacy_policy".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await launchUrl(Uri.parse('${'omnigram_web_link'.tr()}/privacypolicy'));
            },
            // ),
          ),
          ListTile(
            leading: const Icon(Icons.usb_rounded),
            title: Text("user_agreement".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await launchUrl(Uri.parse('${'omnigram_web_link'.tr()}/user_agreement'));
            },
            // ),
          ),
          ListTile(
            leading: const Icon(Icons.thumb_up_alt),
            title: Text("acknowledgements".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await launchUrl(Uri.parse('${'omnigram_web_link'.tr()}/acknowledgements'));
            },
            // ),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
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
