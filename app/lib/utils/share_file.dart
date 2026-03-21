import 'dart:io';

import 'package:omnigram/main.dart';
import 'package:omnigram/widgets/show_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareFile({
  File? file,
  String? filePath,
  String? title,
}) async {
  if (filePath == null && file == null) {
    return;
  }
  filePath ??= file?.path;

  showLoading();
  final box = navigatorKey.currentContext!.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(ShareParams(
    title: title ?? filePath?.split('/').last ?? 'file',
    files: [XFile(filePath ?? '')],
    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  ));
  SmartDialog.dismiss();
}
