import 'dart:async';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/main.dart';
import 'package:omnigram/page/settings_page/developer/developer_options_page.dart';
import 'package:omnigram/utils/env_var.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/widgets/settings/link_icon.dart';
import 'package:omnigram/utils/check_update.dart';
import 'package:omnigram/widgets/settings/show_donate_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({
    super.key,
    this.leadingColor = false,
  });
  final bool leadingColor;

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  String version = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {}

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(L10n.of(context).appAbout),
      leading: Icon(Icons.info_outline,
          color: widget.leadingColor
              ? Theme.of(context).colorScheme.primary
              : null),
      onTap: () => openAboutDialog(),
    );
  }
}

const int _developerUnlockTapThreshold = 7;
int _developerUnlockTapCount = 0;
Timer? _developerUnlockResetTimer;

void _handleDeveloperUnlockTap(BuildContext context) {
  _developerUnlockTapCount++;
  _developerUnlockResetTimer?.cancel();
  _developerUnlockResetTimer =
      Timer(const Duration(seconds: 2), () => _developerUnlockTapCount = 0);

  final alreadyEnabled = Prefs().developerOptionsEnabled;
  if (_developerUnlockTapCount < _developerUnlockTapThreshold) {
    return;
  }

  _developerUnlockTapCount = 0;
  if (!alreadyEnabled) {
    Prefs().developerOptionsEnabled = true;
    AnxToast.show('Developer options enabled');
  }

  final navigator = Navigator.of(context, rootNavigator: true);
  if (navigator.canPop()) {
    navigator.pop();
  }
  Future.microtask(_openDeveloperOptionsPage);
}

void _openDeveloperOptionsPage() {
  final BuildContext? navContext = navigatorKey.currentContext;
  if (navContext == null) return;
  Navigator.of(navContext).push(
    CupertinoPageRoute(
      fullscreenDialog: false,
      builder: (context) => const DeveloperOptionsPage(),
    ),
  );
}

Future<void> openAboutDialog() async {
  final pubspecContent = await rootBundle.loadString('pubspec.yaml');
  final pubspec = Pubspec.parse(pubspecContent);
  final version = pubspec.version.toString();

  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
          content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          minWidth: 300,
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Center(
                    child: Text(
                      'Omnigram',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(L10n.of(context).appVersion),
                  subtitle: Text(version + (kDebugMode ? ' (debug)' : '')),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: version));
                    AnxToast.show(L10n.of(context).notesPageCopied);
                    _handleDeveloperUnlockTap(context);
                  },
                ),
                if (EnvVar.enableCheckUpdate)
                  ListTile(
                      title: Text(L10n.of(context).aboutCheckForUpdates),
                      onTap: () => checkUpdate(true)),
                if (EnvVar.enableDonation)
                  ListTile(
                    title: Text(L10n.of(context).appDonate),
                    onTap: () {
                      showDonateDialog(context);
                    },
                  ),
                ListTile(
                  title: Text(L10n.of(context).appLicense),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'Omnigram',
                      applicationVersion: version,
                    );
                  },
                ),
                ListTile(
                  title: Text(L10n.of(context).appAuthor),
                  onTap: () {
                    launchUrl(
                      Uri.parse(
                          'https://github.com/lxpio/omnigram/graphs/contributors'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                ListTile(
                  title: const Text('Based on Anx Reader'),
                  subtitle: const Text('MIT Licensed · github.com/Anxcye/anx-reader'),
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://github.com/Anxcye/anx-reader'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                ListTile(
                  title: Text(L10n.of(context).aboutPrivacyPolicy),
                  onTap: () async {
                    launchUrl(
                      Uri.parse('https://omnigram.lxpio.com/privacy'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                ListTile(
                  title: Text(L10n.of(context).aboutTermsOfUse),
                  onTap: () async {
                    launchUrl(
                      Uri.parse('https://omnigram.lxpio.com/terms'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                ListTile(
                  title: Text(L10n.of(context).aboutHelp),
                  onTap: () async {
                    launchUrl(
                      Uri.parse('https://omnigram.lxpio.com/docs'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const Divider(),
                if (EnvVar.showBeian) ...[
                  GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse('https://beian.miit.gov.cn/'),
                          mode: LaunchMode.externalApplication);
                    },
                    child: const Text('闽ICP备2025091402号-1A'),
                  ),
                  const Divider(),
                ],
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      linkIcon(
                          icon: Icon(
                            IonIcons.earth,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          url: 'https://omnigram.lxpio.com',
                          mode: LaunchMode.externalApplication),
                      linkIcon(
                          icon: Icon(
                            IonIcons.logo_github,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          url: 'https://github.com/lxpio/omnigram',
                          mode: LaunchMode.externalApplication),
                      if (EnvVar.showTelegramLink)
                        linkIcon(
                            icon: Icon(
                              Icons.telegram,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            url: 'https://t.me/omnigram',
                            mode: LaunchMode.externalApplication),
                      linkIcon(
                          icon: Image.asset(
                            'assets/images/xiaohongshu.png',
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          url:
                              'https://www.xiaohongshu.com/user/profile/5d403f3e00000000100151ff',
                          mode: LaunchMode.externalApplication),
                      linkIcon(
                          icon: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              'assets/images/qq.png',
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          // qq group url is so crazy
                          url:
                              'http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=8BYItJOMz4RCQJoHAAei7FV-nGB0iT8O&authKey=MD6a7gI%2FENiMr32rQRTLx2BpzTaa1wO9Qfmhx9ETcaLS%2FdcOFeptvVH9FWfvUpL2&noverify=0&group_code=1042905699',
                          mode: LaunchMode.externalApplication),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    },
  );
}
