import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/book_image.dart';
import 'package:omnigram/entities/book.entity.dart';

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
}

class BookCardV2 extends HookConsumerWidget {
  const BookCardV2({
    super.key,
    required this.book,
  });

  final BookEntity book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    if (kDebugMode) {
      debugPrint('build book card ${book.title} 4height: $height');
    }

    return Container(
      // padding: const EdgeInsets.fromLTRB(0, 16, 8, 16),
      // margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        // borderRadius: BorderRadius.circular(16),
      ),
      child: Builder(builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                // height: 230,
                // width: double.infinity,
                child: bookImage(book),
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     // borderRadius: const BorderRadius.all(Radius.circular(16)),
              //     gradient: LinearGradient(
              //       begin: Alignment.bottomCenter,
              //       stops: const [.1, .5],
              //       colors: [
              //         Colors.black.withOpacity(.1),
              //         Colors.black.withOpacity(.05),
              //       ],
              //     ),
              //   ),
              // height: height * .7,
              // width: width * 1,
              // ),
            ],
          ),
        );
      }),
    );
  }
}
