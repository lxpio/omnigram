import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'random_highlight_provider.g.dart';

class RandomHighlightData {
  const RandomHighlightData({
    required this.note,
    this.book,
  });

  final BookNote note;
  final Book? book;
}

@riverpod
class RandomHighlight extends _$RandomHighlight {
  @override
  Future<RandomHighlightData?> build() async {
    return _load();
  }

  Future<RandomHighlightData?> _load() async {
    final note = await bookNoteDao.selectRandomNote();
    if (note == null) {
      return null;
    }
    Book? book;
    try {
      book = await bookDao.selectBookById(note.bookId);
    } catch (_) {
      book = null;
    }
    return RandomHighlightData(note: note, book: book);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _load());
  }
}
