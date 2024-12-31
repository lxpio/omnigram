import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/book.provider.dart';
import 'package:omnigram/utils/constants.dart';

import 'book_card_view.dart';

class BookGroup extends HookConsumerWidget {
  const BookGroup(this.title, this.viewmore, this.query, {super.key});

  final String title;
  final String viewmore;
  final BookQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(booksProvider(query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(
            title,
            style: TextStyle(color: Colors.grey[700], fontSize: 18, fontWeight: FontWeight.bold),
          ),
          trailing: InkWell(
            child: Text(viewmore),
            // icon: ,
            onTap: () {
              if (!context.mounted) return;
              context.pushNamed(kReaderSearchPage, extra: query);
            },
          ),
        ),
        Container(
          // padding: EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 200,
          // child: ListView.builder(itemBuilder: itemBuilder, itemCount: books.length),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              if (index < state.items.length) {
                final book = state.items[index];
                return GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: 160,
                      child: BookCard(
                        book: book,
                        width: 160,
                        height: 200,
                      ),
                    ),
                    onTap: () async {
                      if (!context.mounted) return;
                      context.pushNamed(kSummaryPage, extra: book);
                    }
                    //'/reader/books/${book.id}'
                    );
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
