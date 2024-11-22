import 'dart:io';
import 'package:isar/isar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/book_image.dart';
import 'package:omnigram/entities/book.entity.dart';

import 'package:omnigram/providers/api.provider.dart';
import 'package:omnigram/providers/book.provider.dart';
import 'package:omnigram/providers/db.provider.dart';
import 'package:omnigram/providers/image/remote_image_provider.dart';

import 'package:omnigram/providers/select_book.dart';
import 'package:omnigram/services/book.service.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/show_snackbar.dart';
import 'package:transparent_image/transparent_image.dart';

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
              icon: const Icon(Icons.bookmark, size: 24),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.star,
                size: 24,
                color: liked.value ? Colors.amber : Colors.grey,
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
          ],
        ),
        body: Center(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(height: 32),
            Container(
              // color: Theme.of(context).colorScheme.surface,
              height: MediaQuery.of(context).size.height * .4,
              width: MediaQuery.of(context).size.width * .7,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: bookImage(book),
            ),
            const SizedBox(height: 32),
            Text(book.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${book.author}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width * .7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '4.5',
                        style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '2h',
                        style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
                      )
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Row(
                      children: [
                        Icon(Icons.cloud_download, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          'Watch',
                          style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              // alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text('${book.description}', style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width * .7,
              child: Row(
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
            )
          ]),
        ));
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
