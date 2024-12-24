import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/book.provider.dart';
import 'package:omnigram/utils/constants.dart';

import 'views/book_card_view.dart';

class BookSearchScreen extends HookConsumerWidget {
  const BookSearchScreen(this.query, {super.key});

  final BookQuery query;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      debugPrint('Build Book Small Search Screen');
    }

    final search = useTextEditingController();
    final scrollController = useScrollController();

    final state = ref.watch(bookSearchProvider(query));

    useEffect(() {
      someCallback() {
        debugPrint('Scrolling');
        if (scrollController.position.pixels >= scrollController.position.maxScrollExtent && !state.loading) {
          debugPrint('Scrolling to load more');
          ref.watch(bookSearchProvider(query).notifier).loadMore(search.text);
        }
      }

      scrollController.addListener(someCallback);
      return () => scrollController.removeListener(someCallback);
    }, [scrollController]);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  controller.openView();
                },
              );
            },
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              return List<ListTile>.generate(
                5,
                (int index) {
                  final String item = 'item $index';
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      controller.closeView(item);
                    },
                  );
                },
              );
            },
          ),
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                childAspectRatio: 1.0, // Aspect ratio of each item
              ),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                if (index == state.items.length && state.noMore) {
                  return const Center(child: Text('No More'));

                  // return const Center(child: CircularProgressIndicator());
                }
                final book = state.items[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    child: BookCard(
                      book: book,
                      width: 130,
                      height: 200,
                    ),
                    onTap: () {
                      if (!context.mounted) return;
                      context.pushNamed(kSummaryPage, extra: book);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
