import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/provider.dart';
import 'package:omnigram/screens/reader/models/book_local.dart';
import 'package:omnigram/screens/reader/models/book_model.dart';

import 'package:omnigram/screens/reader/providers/books.dart';
import 'package:omnigram/screens/reader/providers/select_book.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/l10n.dart';
import 'package:omnigram/utils/show_snackbar.dart';

class ReaderMobileScreen extends HookConsumerWidget {
  const ReaderMobileScreen({super.key, required this.book}) : super();

  final BookModel book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);

    final localBook = BookLocalBox.instance.get(book.id);
    print('build ReaderMobileScreen cfi: ${book.id}');
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              //back to from
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          // titleSpacing: 0,
          actions: [
            IconButton(
              // onPressed: ,
              icon: const Icon(
                Icons.bookmark,
                size: 24,
              ),
              onPressed: () {
                print("press search");
              },
            ),
            IconButton(
              // onPressed: ,
              icon: const Icon(
                Icons.star,
                size: 24,
              ),
              onPressed: () {
                print("press person");
              },
            ),
            // const SizedBox(width: 16),
          ],
        ),
        body: Center(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(height: 32),
            Container(
              // color: Theme.of(context).colorScheme.surface,
              height: MediaQuery.of(context).size.height * .4,
              width: MediaQuery.of(context).size.width * .7,

              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface,
                  image: DecorationImage(
                    // image: AssetImage(book.image),
                    image: NetworkImage(appConfig.baseUrl + book.image,
                        headers: {
                          "Authorization": "Bearer ${appConfig.token}"
                        }),
                  )),
            ),
            const SizedBox(height: 32),
            Text(book.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(book.author, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width * .7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.yellow, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          '4.5',
                          style: TextStyle(
                              fontSize: 14.0, color: Colors.grey.shade600),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Icon(Icons.access_time,
                            color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          '2h',
                          style: TextStyle(
                              fontSize: 14.0, color: Colors.grey.shade600),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_filled,
                            color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          'Watch',
                          style: TextStyle(
                              fontSize: 14.0, color: Colors.grey.shade600),
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
              child: Text('book.description',
                  style: Theme.of(context).textTheme.bodyMedium),
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
                      final filePath =
                          await getOrDownloadBook(ref, localBook, book.id);
                      if (!context.mounted) return;
                      if (filePath.isEmpty) {
                        showSnackBar(context, "book file not exist!");
                      }
                      //这里需要更新book path,当前selectBookProvider设计是如果path不为空才
                      //加载文件；
                      await ref
                          .read(selectBookProvider.notifier)
                          .refresh(book: book.copyWith(path: filePath));

                      if (!context.mounted) return;
                      context.pushNamed(kReaderDetailPage);
                      // return;
                      //handle error
                      // if (!context.mounted) return;
                      // showSnackBar(context, "book file not exist!");
                    },
                    child: Text(context.l10n.book_start_reading),
                  ),
                  FilledButton.tonal(
                    child: Text(
                      context.l10n.book_start_listening,
                      // style:
                      //     TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    onPressed: () async {
                      final filePath =
                          await getOrDownloadBook(ref, localBook, book.id);
                      if (!context.mounted) return;
                      if (filePath.isEmpty) {
                        showSnackBar(context, "book file not exist!");
                      }

                      if (kDebugMode) {
                        print('on pressed start listen book: ${book.id}');
                      }
                      //这里需要更新book path,当前selectBookProvider设计是如果path不为空才
                      //加载文件；
                      await ref
                          .read(selectBookProvider.notifier)
                          .refresh(book: book.copyWith(path: filePath));
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

  Future<String> getOrDownloadBook(
      WidgetRef ref, BookLocal? localBook, int id) async {
    // Check if the book file already exists and is valid
    final localFilePath = localBook?.localPath;
    if (localFilePath != null && await File(localFilePath).exists()) {
      return localFilePath;
    }

    // If the file doesn't exist, attempt to download it
    try {
      final api = ref.read(bookAPIProvider);

      final bookPath = await api.downloadBook(id, (int count, int total) {
        print('download book: $count/$total');

        // ref.read(bookDownloadProgressProvider).value = count / total;
      });

      BookLocalBox.instance.create(id, bookPath);

      return bookPath;
    } catch (e) {
      // Handle any errors that occur during the download
      print('Error downloading book: $e');
      return '';
    }
  }
}

//int to string
//
