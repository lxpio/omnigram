import 'package:easy_localization/easy_localization.dart';
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
      return () {
        scrollController.removeListener(someCallback);
        ref.invalidate(bookSearchProvider(query));
      };
    }, [scrollController]);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
            ref.invalidate(bookSearchProvider(query));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('search'.tr()),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  hintText: 'search'.tr(),
                  onSubmitted: (String value) async {
                    await ref.watch(bookSearchProvider(query).notifier).search(value);
                    debugPrint('Submitted: $value');
                  },
                  leading: const Icon(Icons.search),
                  shadowColor: null,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 8.0)),
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
                      width: 120,
                      height: 180,
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
