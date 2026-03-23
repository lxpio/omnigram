import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/service/book.dart';
import 'package:omnigram/widgets/bookshelf/book_bottom_sheet.dart';
import 'package:omnigram/widgets/bookshelf/book_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookItem extends ConsumerWidget {
  const BookItem({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> handleLongPress(BuildContext context) async {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return BookBottomSheet(book: book);
        },
      );
    }

    return GestureDetector(
      onTap: () {
        pushToReadingPage(ref, context, book);
      },
      onLongPress: () {
        handleLongPress(context);
      },
      onSecondaryTap: () {
        handleLongPress(context);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: book.coverFullPath,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (!Prefs().eInkMode)
                      BoxShadow(
                        color: Colors.grey.withAlpha(100),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [Expanded(child: BookCover(book: book))],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 55,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 9,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      '${(book.readingPercentage * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 9, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
