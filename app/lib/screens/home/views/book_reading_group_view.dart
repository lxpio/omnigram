import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/book.provider.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'book_card_view.dart';

class BookReadingGroup extends HookConsumerWidget {
  const BookReadingGroup(this.title, this.viewmore, this.query, {super.key});

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
        CarouselSlider(
          options: CarouselOptions(
            // scrollDirection: Axis.horizontal,
            // autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            // scrollPhysics: ScrollPhysics(),
            height: 360.0,
            aspectRatio: 16 / 9,
          ),
          items: state.items.map((book) {
            return Builder(
              builder: (BuildContext context) {
                final h = MediaQuery.of(context).size.height;
                debugPrint('build items  4height: $h');
                return Container(
                  // width: MediaQuery.of(context).size.width,
                  // height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  // child: MouseRegion(
                  //   cursor: SystemMouseCursors.click,
                  //   child: BookCardV2(book: book),
                  // ),
                  child: GestureDetector(
                    child: BookCardV2(book: book),
                    onTap: () {
                      if (!context.mounted) return;
                      context.pushNamed(kSummaryPage, extra: book);
                    },
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(
          height: 30,
        )
      ],
    );
  }
}
