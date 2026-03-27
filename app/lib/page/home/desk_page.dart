import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/providers/desk_provider.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ambient_tasks.dart';
import 'package:omnigram/service/book.dart';
import 'package:omnigram/widgets/desk/greeting_header.dart';
import 'package:omnigram/widgets/desk/hero_book_card.dart';
import 'package:omnigram/widgets/desk/also_reading_shelf.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/theme/typography.dart';

class DeskPage extends ConsumerStatefulWidget {
  const DeskPage({super.key});

  @override
  ConsumerState<DeskPage> createState() => _DeskPageState();
}

class _DeskPageState extends ConsumerState<DeskPage> {
  String? _memoryText;
  int? _lastHeroBookId;

  void _openReader(BuildContext context, Book book) {
    pushToReadingPage(ref, context, book);
  }

  void _fetchMemoryBridge(Book book) async {
    if (!AiAvailability.isAvailable(ref)) return;

    final text = await AmbientTasks.memoryBridge(
      ref: ref,
      bookId: book.id,
      bookTitle: book.title,
      lastPosition: book.lastReadPosition,
      progress: book.readingPercentage,
    );
    if (text != null && mounted) {
      setState(() => _memoryText = text);
    }
  }

  @override
  Widget build(BuildContext context) {
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

          // Fetch memory bridge when hero book changes
          final heroBook = desk.currentBook!;
          if (heroBook.id != _lastHeroBookId) {
            _lastHeroBookId = heroBook.id;
            _memoryText = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchMemoryBridge(heroBook);
            });
          }

          return ListView(
            padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
            children: [
              const SizedBox(height: 16),
              const GreetingHeader(),
              const SizedBox(height: 24),
              HeroBookCard(
                book: heroBook,
                onContinueReading: () => _openReader(context, heroBook),
                memoryText: _memoryText,
              ),
              const SizedBox(height: 24),
              AlsoReadingShelf(books: desk.alsoReading, onBookTap: (book) => _openReader(context, book)),
              if (desk.todayReadingMinutes > 0) ...[
                const SizedBox(height: 24),
                Center(
                  child: Text('—— 今日阅读 ${desk.todayReadingMinutes} 分钟 ——', style: OmnigramTypography.caption(context)),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
