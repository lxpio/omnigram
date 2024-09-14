import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:omnigram/utils/constants.dart';


import 'book_card_view.dart';

class BookReadingGroup extends HookConsumerWidget {
  const BookReadingGroup(this.title, this.viewmore, this.books, {super.key});

  final String title;
  final String viewmore;
  final List<BookEntity>? books;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(
            title,
            style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          trailing: Text(
            viewmore,
            style: TextStyle(
                color: Colors.blue[700],
                // fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          // padding: EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 230,
          // child: ListView.builder(itemBuilder: itemBuilder, itemCount: books.length),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books?.length ?? 0,
            itemBuilder: (context, index) {
              if (books != null && index < books!.length) {
                final book = books![index];

                return GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: 180,
                      child: BookCard(
                        book: book,
                        width: 180,
                        height: 230,
                      ),
                    ),
                    onTap: () async {
                      // BookModel? b;
                      // //if progress or chapterPos is null , try request backend to get
                      // if (book.progress == null || book.progressIndex == null) {
                      //   final api = ref.read(bookAPIProvider);

                      //   final data = await api.getReadProcess(book.id);

                      //   if (data != null) {
                      //     // await ref.read(selectBookProvider.notifier).refresh(book);
                      //     b = book.copyWith(
                      //         progress: (data["progress"] + 0.0),
                      //         progressIndex: data["progress_index"]);
                      //   }
                      // }
                      if (!context.mounted) return;
                      context.pushNamed(kSummaryPage, extra:  book);
                    }
                    //'/reader/books/${book.id}'
                    );

                // return AspectRatio(
                //   aspectRatio: 2.1 / 3,
                //   child: GestureDetector(
                //     child: Container(
                //       padding: const EdgeInsets.all(8),
                //       child: BookCard(
                //         book: book!,
                //       ),
                //     ),
                //     onTap: () => context.push(kReaderPath, extra: book),
                //     //'/reader/books/${book.id}'
                //   ),
                // );
              } else {
                return const Text("No data available");
              }
            },
            // itemBuilder: (context, index) => makeItem(
            //     image: foods[index]["image"],
            //     isFavorite: foods[index]["isFavorite"],
          ), //     index: index)),
        ),
        const SizedBox(
          height: 30,
        )
      ],
    );
  }
}
