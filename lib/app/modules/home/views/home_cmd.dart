import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommandMenuView extends StatelessWidget {
  final ValueChanged<String> onCommand;

  const CommandMenuView({
    Key? key,
    required this.onCommand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> commands = <Widget>[
      _commandTile(context, '/help', 'command_using_help', Icons.check),
      const Divider(height: 0),
      _commandTile(
          context, '/tanslate', 'command_using_translate', Icons.check),
      const Divider(height: 0),
      _commandTile(context, '/node', 'command_using_note', Icons.check),
    ];

    // Widget divider2 = Divider(color: Colors.grey);

    return ListView(
      // itemCount: _commands.length,
      // itemExtent: 40,
      // separatorBuilder: (BuildContext context, int index) => divider2, // 分隔符
      // itemBuilder: (BuildContext context, int index) {
      //   return _commands[index];
      // },
      shrinkWrap: true,
      children: commands,
    );
  }

  Widget _commandTile(
      BuildContext context, String title, String subtitle, IconData icon) {
    return Container(
        // decoration: BoxDecoration(
        //   //                    <-- BoxDecoration
        //   border: Border(bottom: BorderSide()),
        // ),
        // height: 28,
        color: Theme.of(context).cardColor,
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -4), // to compact
          horizontalTitleGap: 0,
          // contentPadding: const EdgeInsets.all(0),
          // horizontalTitleGap: desiredDoubleValue,
          dense: true,
          title: Row(
            children: [
              Text(
                title,
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
              const SizedBox(width: 10), // 添加一些间隔
              Text(
                subtitle.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 9,
                ),
              ),
            ],
          ),

          leading: const FlutterLogo(
            size: 16,
          ),

          trailing: const Icon(Icons.chevron_left),
          onTap: () {
            // Handle command tap
            // For example, you can call a function to handle the command
            onCommand(title);
          },
        ));
  }
}
