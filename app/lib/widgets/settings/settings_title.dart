import 'package:omnigram/main.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget settingsTitle({
  required Icon icon,
  required String title,
  required bool isMobile,
  required int id,
  required int selectedIndex,
  required Function setDetail,
  required Widget subPage,
  required List<String> subtitle,
}) {
  BuildContext context = navigatorKey.currentContext!;
  return ListTile(
    leading: icon,
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    selected: !isMobile && selectedIndex == id,
    subtitle: Text(subtitle.join(' • ')),
    onTap: () {
      if (!isMobile) {
        setDetail(subPage, id);
        return;
      }
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => subPage),
      );
    },
  );
}

Widget settingsSections({
  required List<AbstractSettingsSection> sections,
}) {
  // return SettingsList(sections: sections);
  return ListView.builder(
    itemCount: sections.length,
    itemBuilder: (context, index) {
      return sections[index];
    },
  );
}
