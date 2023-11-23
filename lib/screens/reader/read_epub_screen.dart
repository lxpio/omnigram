import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/select_book.dart';
import 'views/epub_content_view.dart';

class ReadEpubScreen extends HookConsumerWidget {
  const ReadEpubScreen({super.key, this.onClose, this.playtask = false});

  final VoidCallback? onClose;
  final bool playtask;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookFile = ref.watch(epubDocumentProvider);

    if (kDebugMode) {
      print('build ReaderContentScreen bookFile');
    }

    return bookFile.when(
        data: (data) {
          if (data == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    // color: Colors.white,
                    onPressed: () async {
                      if (onClose != null) {
                        onClose!();
                      } else {
                        context.pop();
                      }
                    }),
                // actions: ,
              ),
              body: const Center(child: Text('Book not found')),
            );
          }

          return EpubContentView(
            document: data,
            onClose: onClose,
            runplayTask: playtask,
          );
        },
        error: (err, stack) => Center(child: Text(err.toString())),
        loading: () {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  // color: Colors.white,
                  onPressed: () async {
                    if (onClose != null) {
                      onClose!();
                    } else {
                      context.pop();
                    }
                  }),
              // actions: ,
            ),
            body: const LinearProgressIndicator(),
          );
        });
  }
}
