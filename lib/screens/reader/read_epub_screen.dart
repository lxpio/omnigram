import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/screens/reader/models/epub_document.dart';

import 'views/epub_content_view.dart';

class ReadEpubScreen extends HookConsumerWidget {
  const ReadEpubScreen({super.key, required this.bookFile, this.cfi}) : super();

  final String bookFile;
  final String? cfi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      print('build ReaderContentScreen bookFile');
    }

    final future = useMemoized(() => openDoc());

    final snapshot = useFuture(future);

    if (snapshot.hasData) {
      return EpubContentView(document: snapshot.data!);
    } else if (snapshot.hasError) {
      return Text('${snapshot.error}');
    }
    return const LinearProgressIndicator();
  }

  Future<EpubDocument> openDoc() async {
    if (kDebugMode) {
      print('open EpubDocument, $cfi');
    }

    final document = EpubDocument(path: bookFile, epubCfi: cfi);

    await document.initialize();

    return document;
  }
}
