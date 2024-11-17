import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

const omnigramHost = '''https://omnigram.lxpio.com/''';

class AboutView extends HookConsumerWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = useState({});

    getPackageInfo() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      appInfo.value = {
        "version": packageInfo.version,
        "buildNumber": packageInfo.buildNumber,
      };
    }

    useEffect(
      () {
        getPackageInfo();
        return null;
      },
      [],
    );

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
            title: Text("terms_and_conditions".tr()),
            // subtitle: Text("选择深色或者浅色主题"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await launchUrl(Uri.parse('${'omnigram_web_link'.tr()}/terms-conditions'));
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
              await launchUrl(Uri.parse('${'omnigram_web_link'.tr()}/terms-conditions'));
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
            trailing: Text(
              "${appInfo.value["version"]} build.${appInfo.value["buildNumber"]}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () async {},
            // ),
          ),
        ],
      ),
    );
  }
}
