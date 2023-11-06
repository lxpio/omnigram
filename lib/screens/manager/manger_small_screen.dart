import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:omnigram/utils/l10n.dart';

import 'views/scan_status_view.dart';

class ManagerSmallScreen extends HookConsumerWidget {
  const ManagerSmallScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final scan = ref.watch(scanAPIProvider);

    // scan.stats().

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          // body: Stack(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    // width: 300,
                    height: 80,
                    child: ListTile(
                      leading: Icon(
                        Icons.support_agent,
                        size: 64,
                      ),
                      title: Text("Need help?"),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ScanStatusView(),
                  const SizedBox(height: 32),
                  Text("Server config"),
                  const SizedBox(height: 8),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.color_lens_outlined,
                      // size: 64,
                    ),
                    title: Text("主题"),
                    subtitle: Text("选择深色或者浅色主题"),
                    trailing: Switch(
                      value: true,
                      onChanged: (bool value) {},
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      // size: 64,
                    ),
                    title: Text("语言"),
                    // subtitle: Text("您首选语言"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(20)),
                          child: Text(
                            '中文',
                            style: TextStyle(
                              fontSize: 14,
                              // color: Color(
                              //     int.parse("0xff${job.experienceLevelColor}")),
                            ),
                          ),
                        ),
                        // Text("中文", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios),
                        // IconButton(
                        //   onPressed: () {},
                        //   icon: Icon(Icons.arrow_forward_ios),
                        //   // color: Theme.of(context).colorScheme.primary,
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text("Chat config"),
                  const SizedBox(height: 8),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.support_agent,
                      // size: 64,
                    ),
                    title: Text("Need help?"),
                    trailing: SizedBox(
                      width: 200,
                      child: TextField(
                        autocorrect: false,
                        decoration: InputDecoration.collapsed(
                          hintText: 'type_your_tokens',
                        ),
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
