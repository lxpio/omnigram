import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/dao/theme.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/page/reading_page.dart';
import 'package:omnigram/providers/desk_provider.dart';
import 'package:omnigram/widgets/desk/greeting_header.dart';
import 'package:omnigram/widgets/desk/hero_book_card.dart';
import 'package:omnigram/widgets/desk/also_reading_shelf.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/theme/typography.dart';

class DeskPage extends ConsumerWidget {
  const DeskPage({super.key});

  void _openReader(BuildContext context, Book book) async {
    final themes = await ThemeDao().selectThemes();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingPage(
          key: readingPageKey,
          book: book,
          initialThemes: themes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deskAsync = ref.watch(deskDataProvider);

    return SafeArea(
      child: deskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (desk) {
          if (desk.currentBook == null) {
            return const EmptyState(
              message: '书桌还是空的，去书架找一本书开始阅读吧。',
              actionLabel: '去书架',
              icon: Icons.auto_stories_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(
                OmnigramTheme.pageHorizontalPadding),
            children: [
              const SizedBox(height: 16),
              const GreetingHeader(),
              const SizedBox(height: 24),
              HeroBookCard(
                book: desk.currentBook!,
                onContinueReading: () =>
                    _openReader(context, desk.currentBook!),
              ),
              const SizedBox(height: 24),
              AlsoReadingShelf(
                books: desk.alsoReading,
                onBookTap: (book) => _openReader(context, book),
              ),
              if (desk.todayReadingMinutes > 0) ...[
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '—— 今日阅读 ${desk.todayReadingMinutes} 分钟 ——',
                    style: OmnigramTypography.caption(context),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
