import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/providers/image/remote_image_provider.dart';
import 'package:transparent_image/transparent_image.dart';

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

  return Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        stops: const [.1, .5],
        colors: [
          Colors.black.withOpacity(.15),
          Colors.black.withOpacity(.08),
        ],
      ),
    ),
    child: Center(child: Text(book.title)),
  );
}
