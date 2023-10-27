import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_epub/epub_view.dart';
import 'package:omnigram/models/objectbox.g.dart';
import 'package:omnigram/screens/reader/models/book_model.dart';

import 'providers/books.dart';

// class ReaderContentScreen extends StatefulHookConsumerWidget {
//   const ReaderContentScreen({required this.book, super.key}) : super();

//   final Book book;

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _ReaderContentScreenState();
// }

class ReaderContentScreen extends HookConsumerWidget {
  const ReaderContentScreen({required this.book, super.key}) : super();
  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final appConfig = ref.read(appConfigProvider);

    // late EpubController _epubReaderController;
    final epub = useState(initEpub());
    final cfi = useState(book.chapterPos ?? '');

    useEffect(() {
      final provider = ref.read(bookAPIProvider);
      // final controller = epub.value;

      return () {
        if (kDebugMode) {
          print('exit epub reader');
        }
        // final cfi = controller.generateEpubCfi();
        print('current cfi: ${cfi.value}');
        provider.updateProcess(book.id, 0.5, cfi.value);
        // saveProcess(provider, epub.value);
        epub.value.dispose();
      };
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: EpubViewActualChapter(
          controller: epub.value,
          builder: (chapterValue) => Text(
            chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '',
            textAlign: TextAlign.start,
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.save_alt),
              // color: Colors.white,
              onPressed: () {
                final cfi2 = epub.value.generateEpubCfi();
                cfi.value = cfi2 ?? '';

                _showCurrentEpubCfi(context, epub.value);
              }),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            // color: Colors.white,
            onPressed: () => context.pop(),
          )
        ],
      ),
      drawer: Drawer(
        child: EpubViewTableOfContents(controller: epub.value),
      ),
      body: EpubView(
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          chapterDividerBuilder: (_) => const Divider(),
        ),
        controller: epub.value,
      ),
    );
  }

  void _showCurrentEpubCfi(BuildContext context, EpubController controller) {
    final cfi = controller.generateEpubCfi();

    if (cfi != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cfi),
          action: SnackBarAction(
            label: 'GO',
            onPressed: () {
              controller.gotoEpubCfi(cfi);
            },
          ),
        ),
      );
    }
  }

  EpubController initEpub() {
    print('initState:${book.path!}');
    final file = File(book.path!);

    return EpubController(
      document: EpubDocument.openFile(file),
      epubCfi: book.chapterPos,
      // EpubDocument.openAsset(widget.book.path!),
      // epubCfi:
      //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
      // epubCfi:
      //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
    );
  }

  void saveProcess(BookAPI provider, EpubController controller) {
    final cfi = controller.generateEpubCfi();
    print('current cfi: $cfi');
    provider.updateProcess(book.id, 0.5, cfi);

    // ref.read(provider)
  }
}
