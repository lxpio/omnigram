import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/providers/image/remote_image_provider.dart';
import 'package:transparent_image/transparent_image.dart';

class BookCard extends HookConsumerWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.width,
    required this.height,
  });

  final BookEntity book;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      debugPrint('build book card ${book.title}');
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      // ? SystemMouseCursors.click
      // : SystemMouseCursors.basic,
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          // side: BorderSide(
          //   color: Theme.of(context).colorScheme.outline,
          // ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  height: height * .7,
                  width: width * 1,
                  child: bookImage(book),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      stops: const [.1, .5],
                      colors: [
                        Colors.black.withOpacity(.1),
                        Colors.black.withOpacity(.05),
                      ],
                    ),
                  ),
                  height: height * .7,
                  width: width * 1,
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 10),
                      if (book.progress != null && book.progress! > 0)
                        LinearProgressIndicator(
                          value: book.progress, // Change this value to represent the progress
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey), // Set to gray
                          backgroundColor: Colors.grey[300],
                          // color:,
                          // style: TextStyle(color: Colors.white, fontSize: 14),
                        )
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? bookImage(BookEntity book) {
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image: ImmichRemoteImageProvider(
          coverId: book.identifier + book.coverUrl!,
        ),
        fit: BoxFit.fill,
        imageErrorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('get image failed: $error');
          }
          return Center(child: Text(book.title));
        },
      );
    }

    return Text(book.title);
  }
}
