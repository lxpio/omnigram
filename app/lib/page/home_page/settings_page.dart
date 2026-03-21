import 'package:omnigram/page/settings_page/more_settings_page.dart';
import 'package:omnigram/widgets/settings/about.dart';
import 'package:omnigram/widgets/settings/theme_mode.dart';
import 'package:omnigram/widgets/settings/webdav_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key, this.controller});

  final ScrollController? controller;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final ScrollController _scrollController = widget.controller ?? ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Text(
                        'Anx',
                        style: TextStyle(
                          fontSize: 130,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(),
              const Padding(padding: EdgeInsets.fromLTRB(20, 8, 10, 8), child: ChangeThemeMode()),
              const Divider(),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: webdavSwitch(context, setState, ref)),
              const Divider(),
              const MoreSettings(),
              const About(),
            ],
          ),
        ),
      ),
    );
  }
}
