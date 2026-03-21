import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/reading_time.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/reading_time.dart';
import 'package:omnigram/utils/date/convert_seconds.dart';

class ReadingHistoryRecord {
  ReadingHistoryRecord({
    required this.book,
    required this.entry,
  });

  final Book book;
  final ReadingTime entry;

  Map<String, dynamic> toMap() {
    return {
      'bookId': book.id,
      'bookTitle': book.title,
      'author': book.author,
      'date': entry.date,
      'readingDuration': convertSeconds(entry.readingTime),
      'groupId': book.groupId,
    };
  }
}

class ReadingHistoryRepository {
  const ReadingHistoryRepository();

  Future<List<ReadingHistoryRecord>> fetchHistory({
    int? bookId,
    DateTime? from,
    DateTime? to,
    int limit = 20,
  }) async {
    final entries = await readingTimeDao.queryReadingHistory(
      bookId: bookId,
      from: from,
      to: to,
      limit: limit,
    );

    if (entries.isEmpty) {
      return const [];
    }

    final bookIds = entries.map((entry) => entry.bookId).toSet().toList();
    final books = await bookDao.selectBooksByIds(bookIds);
    final bookMap = {for (final book in books) book.id: book};

    final records = <ReadingHistoryRecord>[];
    for (final entry in entries) {
      final book = bookMap[entry.bookId];
      if (book == null) {
        continue;
      }
      records.add(ReadingHistoryRecord(book: book, entry: entry));
    }
    return records;
  }
}
