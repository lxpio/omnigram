import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:omnigram/providers/service/reader/book_model.dart';

import 'book_card.dart';

class EpubPageBody extends StatefulHookConsumerWidget {
  const EpubPageBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EpubPageBodyState();
}

class _EpubPageBodyState extends ConsumerState<EpubPageBody> {
  @override
  Widget build(BuildContext context) {
    List<Book> books = [
      Book(
        id: 1,
        title: "one",
        identifier: "00001",
        author: 'author_one',
      ),
      Book(
        id: 2,
        title: 'two',
        identifier: "00002",
        author: 'author_two',
      ),
      Book(
        id: 3,
        title: 'three',
        identifier: '00003',
        author: 'author_three',
      )
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.keepreading,
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              AppLocalizations.of(context)!.viewmore,
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
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return AspectRatio(
                  aspectRatio: 2.1 / 3,
                  child: GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: BookCard(
                        book: book,
                      ),
                    ),
                    onTap: () =>
                        context.push('/reader/books/${book.id}', extra: book),
                  ),
                );
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
      ),
    );
  }
}
