import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/dao/reading_time.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/widgets/insights/ai_narrative_card.dart';
import 'package:omnigram/widgets/insights/knowledge_graph_card.dart';
import 'package:omnigram/widgets/insights/reading_summary_card.dart';
import 'package:omnigram/widgets/insights/notes_list.dart';
import 'package:omnigram/widgets/insights/time_period_selector.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/theme/typography.dart';

class InsightsPage extends ConsumerStatefulWidget {
  const InsightsPage({super.key});

  @override
  ConsumerState<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends ConsumerState<InsightsPage> {
  TimePeriod _period = TimePeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
        children: [
          const SizedBox(height: 16),
          Text('洞察', style: OmnigramTypography.displayLarge(context)),
          const SizedBox(height: 16),
          TimePeriodSelector(
            selected: _period,
            onChanged: (p) => setState(() => _period = p),
          ),
          const SizedBox(height: 24),
          FutureBuilder<_NarrativeData>(
            future: _loadNarrativeData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final data = snapshot.data!;
              return AiNarrativeCard(
                bookTitles: data.bookTitles,
                totalMinutes: data.totalMinutes,
                totalNotes: data.totalNotes,
                timePeriod: _timePeriodLabel(_period),
              );
            },
          ),
          const SizedBox(height: 16),
          const KnowledgeGraphCard(),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, int>>(
            future: _loadStats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final stats = snapshot.data!;
              return ReadingSummaryCard(
                booksRead: stats['books']!,
                totalHours: stats['hours']!,
                totalNotes: stats['notes']!,
              );
            },
          ),
          const SizedBox(height: 24),
          Text('笔记', style: OmnigramTypography.titleLarge(context)),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, List<BookNote>>>(
            future: _loadNotesByBook(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const EmptyState(
                  message: '开始阅读并添加笔记，洞察会随着你的阅读逐渐丰富。',
                  icon: Icons.insights_outlined,
                );
              }
              return NotesByBookList(notesByBook: snapshot.data!);
            },
          ),
        ],
      ),
    );
  }

  static String _timePeriodLabel(TimePeriod p) {
    switch (p) {
      case TimePeriod.thisMonth:
        return 'this month';
      case TimePeriod.lastMonth:
        return 'last month';
      case TimePeriod.thisYear:
        return 'this year';
      case TimePeriod.allTime:
        return 'all time';
    }
  }

  Future<_NarrativeData> _loadNarrativeData() async {
    final readingTimeDao = ReadingTimeDao();
    final bookNoteDao = BookNoteDao();

    List<Map<Book, int>> bookReadingTimes;
    final now = DateTime.now();

    switch (_period) {
      case TimePeriod.thisMonth:
        bookReadingTimes =
            await readingTimeDao.selectBookReadingTimeOfMonth(now);
      case TimePeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        bookReadingTimes =
            await readingTimeDao.selectBookReadingTimeOfMonth(lastMonth);
      case TimePeriod.thisYear:
        bookReadingTimes =
            await readingTimeDao.selectBookReadingTimeOfYear(now);
      case TimePeriod.allTime:
        bookReadingTimes =
            await readingTimeDao.selectBookReadingTimeOfAll();
    }

    final titles =
        bookReadingTimes.map((m) => m.keys.first.title).toList();
    final totalSeconds =
        bookReadingTimes.fold<int>(0, (sum, m) => sum + m.values.first);
    final noteStats = await bookNoteDao.selectNumberOfNotesAndBooks();

    return _NarrativeData(
      bookTitles: titles,
      totalMinutes: totalSeconds ~/ 60,
      totalNotes: noteStats['numberOfNotes'] ?? 0,
    );
  }

  Future<Map<String, int>> _loadStats() async {
    final bookDao = BookDao();
    final readingTimeDao = ReadingTimeDao();
    final bookNoteDao = BookNoteDao();

    final books = await bookDao.selectNotDeleteBooks();
    final finishedCount = books.where((b) => b.readingPercentage >= 1.0).length;
    final totalSeconds = await readingTimeDao.selectTotalReadingTime();
    final noteStats = await bookNoteDao.selectNumberOfNotesAndBooks();

    return {
      'books': finishedCount,
      'hours': totalSeconds ~/ 3600,
      'notes': noteStats['numberOfNotes'] ?? 0,
    };
  }

  Future<Map<String, List<BookNote>>> _loadNotesByBook() async {
    final bookDao = BookDao();
    final bookNoteDao = BookNoteDao();

    final books = await bookDao.selectNotDeleteBooks();
    final grouped = <String, List<BookNote>>{};

    for (final book in books) {
      final notes = await bookNoteDao.selectBookNotesByBookId(book.id);
      if (notes.isNotEmpty) {
        grouped[book.title] = notes;
      }
    }
    return grouped;
  }
}

class _NarrativeData {
  final List<String> bookTitles;
  final int totalMinutes;
  final int totalNotes;

  const _NarrativeData({
    required this.bookTitles,
    required this.totalMinutes,
    required this.totalNotes,
  });
}
