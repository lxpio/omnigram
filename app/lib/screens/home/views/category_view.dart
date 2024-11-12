import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/utils/constants.dart';

class CategoryData {
  final Icon icon;
  final String title;

  const CategoryData(this.icon, this.title);
}

class CategoryGroup extends HookConsumerWidget {
  CategoryGroup({super.key});

  // final List<CategoryData>? categorys;

  final List<CategoryData> categorys = [
    CategoryData(const Icon(Icons.book), 'category1 one '.tr()),
    CategoryData(const Icon(Icons.book), 'category1  '.tr()),
    CategoryData(const Icon(Icons.book), 'shot'.tr()),
    CategoryData(const Icon(Icons.book), 'loooooooooooooong'.tr()),
    CategoryData(const Icon(Icons.book), 'category1'.tr()),
    CategoryData(const Icon(Icons.book), 'category1'.tr()),
    CategoryData(const Icon(Icons.book), 'category1'.tr()),
    CategoryData(const Icon(Icons.book), 'category1'.tr())
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          // padding: EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 48,
          // child: ListView.builder(itemBuilder: itemBuilder, itemCount: books.length),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categorys.length ?? 0,
            itemBuilder: (context, index) {
              if (index < categorys.length) {
                final book = categorys[index];

                return GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      // width: 150,
                      child: Card(
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            book.icon,
                            Text(book.title),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                    // onTap:(){},
                    // ),
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
                      context.pushNamed(kSummaryPage, extra: book);
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
