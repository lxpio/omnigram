import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:omnigram/flavors/provider.dart';
import 'package:omnigram/screens/reader/models/book_model.dart';

class BookCard extends HookConsumerWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.width,
    required this.height,
  });

  final BookModel book;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.read(appConfigProvider);

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
                  child: book.image.isNotEmpty
                      ? FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          image: NetworkImage(
                            appConfig.baseUrl + book.image,
                            headers: {
                              "Authorization": "Bearer ${appConfig.token}"
                            },
                          ),
                          fit: BoxFit.fill,
                          imageErrorBuilder: (context, error, stackTrace) {
                            if (kDebugMode) {
                              print('get image failed: $error');
                            }
                            return const Icon(Icons.error);
                          },
                        )
                      : Text(book.title),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
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
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 10),
                          if (book.progress != null && book.progress! > 0)
                            LinearProgressIndicator(
                              value: book
                                  .progress, // Change this value to represent the progress
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.grey), // Set to gray
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
