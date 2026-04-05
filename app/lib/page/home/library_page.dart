import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/providers/book_list.dart';
import 'package:omnigram/providers/empty_state_provider.dart';
import 'package:omnigram/service/book.dart';
import 'package:omnigram/widgets/library/ai_recommendation_card.dart';
import 'package:omnigram/widgets/library/book_grid_item.dart';
import 'package:omnigram/widgets/library/topic_section.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/theme/typography.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookListAsync = ref.watch(bookListProvider);

    return Scaffold(
      body: SafeArea(
        child: bookListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (bookGroups) {
            final allBooks = bookGroups.expand((g) => g).where((b) => !b.isDeleted).toList();

            if (allBooks.isEmpty) {
              final tier = ref.watch(warmthTierProvider);
              final data = emptyStateData(context, tier, EmptyPageType.library);
              return EmptyState.fromData(data, onAction: () => _importBooks(context, ref));
            }

            final recentBooks = List<Book>.from(allBooks)..sort((a, b) => b.createTime.compareTo(a.createTime));
            final recent = recentBooks.take(10).toList();

            return ListView(
              padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
              children: [
                const SizedBox(height: 16),
                Text(L10n.of(context).libraryTitle, style: OmnigramTypography.displayLarge(context)),
                const SizedBox(height: 16),
                SearchBar(
                  hintText: L10n.of(context).librarySearchHint,
                  leading: const Icon(Icons.search),
                  onTap: () {
                    // TODO: navigate to search page
                  },
                ),
                const SizedBox(height: 24),
                AiRecommendationCard(recentBookTitles: allBooks.map((b) => b.title).toList()),
                const SizedBox(height: 16),
                TopicSection(
                  title: L10n.of(context).libraryRecentlyAdded,
                  count: recent.length,
                  books: recent,
                  onBookTap: (book) => _openBook(context, ref, book),
                ),
                const SizedBox(height: 24),
                Text(L10n.of(context).libraryAllBooks(allBooks.length), style: OmnigramTypography.titleMedium(context)),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: allBooks.length,
                  itemBuilder: (_, i) => BookGridItem(book: allBooks[i], onTap: () => _openBook(context, ref, allBooks[i])),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _importBooks(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openBook(BuildContext context, WidgetRef ref, Book book) {
    pushToReadingPage(ref, context, book);
  }

  void _importBooks(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub', 'mobi', 'azw3', 'fb2', 'txt', 'pdf'],
    );
    if (result != null && result.files.isNotEmpty && context.mounted) {
      final files = result.files.where((f) => f.path != null).map((f) => File(f.path!)).toList();
      importBookList(files, context, ref);
    }
  }
}
