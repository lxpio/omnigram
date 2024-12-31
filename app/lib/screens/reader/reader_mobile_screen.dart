import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/book_image.dart';
import 'package:omnigram/entities/book.entity.dart';

import 'package:omnigram/providers/book.provider.dart';
import 'package:omnigram/providers/db.provider.dart';

import 'package:omnigram/providers/select_book.dart';

import 'package:omnigram/services/book.service.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/show_snackbar.dart';

import 'views/description_text_view.dart';

class ReaderMobileScreen extends HookConsumerWidget {
  const ReaderMobileScreen({super.key, required this.book}) : super();

  final BookEntity book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = useState(book.favStatus);

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.favorite,
                size: 24,
                color: liked.value ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                liked.value = !liked.value;
                final isar = ref.read(dbProvider);
                isar.write((db) => db.bookEntitys.put(book.copyWith(favStatus: liked.value)));

                ref.invalidate(booksProvider(BookQuery.likes));
                ref.invalidate(booksProvider(BookQuery.recents));
                ref.invalidate(booksProvider(BookQuery.readings));
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, size: 24),
              onPressed: () {},
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 10.0),
            _BookDescSection(book: book),
            const SizedBox(height: 30.0),
            ListTile(
              title: Text(
                'reader_book_description'.tr(),
                style: TextStyle(color: Colors.grey[700], fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            DescriptionTextView(text: book.description),
            const SizedBox(height: 30.0),
            ListTile(
              title: Text(
                'reader_more_from_author'.tr(),
                style: TextStyle(color: Colors.grey[700], fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // const _Divider(),
          ],
        ));
  }
}

class _BookDescSection extends ConsumerWidget {
  const _BookDescSection({super.key, required this.book});

  final BookEntity book;
//
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Hero(
          tag: book.identifier,
          child: SizedBox(
            width: 130,
            height: 200,
            child: bookImage(book),
          ),
        ),
        const SizedBox(width: 20.0),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 5.0),
              Hero(
                tag: book.title,
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    book.title.replaceAll(r'\', ''),
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              Hero(
                tag: '${book.author} -',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    '${book.author}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              // _CategoryChips(entry: entry),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonal(
                    onPressed: () async {
                      final filePath = await getOrDownloadBook(ref, book);
                      if (!context.mounted) return;
                      if (filePath.isEmpty) {
                        showSnackBar(context, "book file not exist!");
                      }
                      //这里需要更新book path,当前selectBookProvider设计是如果path不为空才
                      //加载文件；
                      await ref.read(selectBookProvider.notifier).refresh(book: book.copyWith(localPath: filePath));

                      if (!context.mounted) return;
                      context.pushNamed(kReaderDetailPage);
                      // return;
                      //handle error
                      // if (!context.mounted) return;
                      // showSnackBar(context, "book file not exist!");
                    },
                    child: Text('book_start_reading'.tr()),
                  ),
                  FilledButton.tonal(
                    child: Text(
                      'book_start_listening'.tr(),
                      // style:
                      //     TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    onPressed: () async {
                      final filePath = await getOrDownloadBook(ref, book);
                      if (!context.mounted) return;
                      if (filePath.isEmpty) {
                        showSnackBar(context, "book file not exist!");
                      }

                      if (kDebugMode) {
                        print('on pressed start listen book: ${book.id}');
                      }
                      //这里需要更新book path,当前selectBookProvider设计是如果path不为空才
                      //加载文件；
                      await ref.read(selectBookProvider.notifier).refresh(book: book.copyWith(localPath: filePath));
                      // ref.read(selectBookProvider.notifier).play();
                      if (!context.mounted) return;
                      context.pushNamed(kReaderDetailPage, extra: true);
                      // return;
                      //handle error
                      // if (!context.mounted) return;
                      // showSnackBar(context, "book file not exist!");
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String> getOrDownloadBook(WidgetRef ref, BookEntity book) async {
    // Check if the book file already exists and is valid
    final localFilePath = book.localPath;
    if (localFilePath != null && await File(localFilePath).exists()) {
      return localFilePath;
    }

    // If the file doesn't exist, attempt to download it
    try {
      final service = ref.watch(bookServiceProvider);

      final bookPath = await service.downloadBook(book);

      // Check if the download was successful
      if (bookPath != null) {
        final isar = ref.read(dbProvider);
        isar.write((db) => db.bookEntitys.put(book.copyWith(localPath: bookPath)));
        return bookPath;
      }

      return '';
    } catch (e) {
      // Handle any errors that occur during the download
      print('Error downloading book: $e');
      return '';
    }
  }
}
