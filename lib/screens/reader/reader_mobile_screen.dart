import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/service/reader/book_model.dart';
import 'package:omnigram/providers/service/reader/books.dart';
import 'package:omnigram/screens/home/book_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReaderMobileScreen extends HookConsumerWidget {
  const ReaderMobileScreen({required this.book, super.key}) : super();

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                //back to from
                context.pop();
              },
              icon: const Icon(Icons.arrow_back),
            );
          }),
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
                    image: AssetImage(book.image),
                  )),
              // child: BookCard(book: book)
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
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 20,
                        ),
                        SizedBox(width: 5),
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
                        Icon(
                          Icons.access_time,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '2h',
                          style: TextStyle(
                              fontSize: 14.0, color: Colors.grey.shade600),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        SizedBox(width: 5),
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
            Container(
              // alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text('book.description',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width * .7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      context.push('/reader/books/${book.id}/details',
                          extra: book);
                      // onPress();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.book_start_reading,
                      // style:
                      //     TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  FilledButton.tonal(
                    child: Text(
                      AppLocalizations.of(context)!.book_start_listening,
                      // style:
                      //     TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            )
          ]),
        ));
  }
}

//int to string
//
