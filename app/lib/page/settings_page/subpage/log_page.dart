import 'dart:io';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/utils/save_file_to_download.dart';
import 'package:omnigram/utils/get_path/log_file.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<String> logs = [];

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData() async {
    File logFile = await getLogFile();
    setState(() {
      logs = logFile.readAsLinesSync().reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppGlassAppBar(
        title: Text(L10n.of(context).settingsAdvancedLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              initData();
            },
          ),
          IconButton(
              onPressed: () => showMoreAction(context),
              icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: ListView(
        children: [for (final log in logs) logItem(log, context)],
      ),
    );
  }

  void showMoreAction(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).padding.top + kToolbarHeight,
        0.0,
        0.0,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.delete),
            title: Text(L10n.of(context).settingsAdvancedLogClearLog),
            onTap: () => clearLog(),
          ),
        ),
        PopupMenuItem(
            child: ListTile(
          leading: const Icon(Icons.file_upload_outlined),
          title: Text(L10n.of(context).settingsAdvancedLogExportLog),
          onTap: () => exportLog(),
        ))
      ],
    );
  }

  Future<void> clearLog() async {
    Navigator.pop(context);
    AnxLog.clear();
    initData();
  }

  Future<void> exportLog() async {
    Navigator.pop(context);
    File logFile = await getLogFile();
    // SaveFileDialogParams params = SaveFileDialogParams(
    //   sourceFilePath: logFile.path,
    // );
    // await FlutterFileDialog.saveFile(params: params);
    String fileName =
        'Omnigram-Log-${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}.txt';
    String? filePath = await saveFileToDownload(
        bytes: await logFile.readAsBytes(),
        fileName: fileName,
        mimeType: 'text/plain');

    AnxToast.show("saved $filePath");
  }
}

Widget logItem(String logStr, BuildContext context) {
  final log = AnxLog.parse(logStr);
  final scheme = Theme.of(context).colorScheme;
  return SelectionArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: log.color,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  log.level.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                log.time.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            log.message,
            // monospace so log alignment / stack frames stay readable
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.4,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: logStr));
              },
              child: Text(L10n.of(context).commonCopy),
            ),
          ),
          Divider(
            height: 8,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ],
      ),
    ),
  );
}
