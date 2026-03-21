import 'package:omnigram/dao/book.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/current_notes_detail.dart';
import 'package:omnigram/providers/notes_statistics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notes_page_current_book.g.dart';

@riverpod
class NotesPageCurrentBook extends _$NotesPageCurrentBook {
  @override
  Future<CurrentNotesDetail> build() async {
    final idAndNotes = await ref.watch(bookIdAndNotesProvider.future);

    Book book = await bookDao.selectBookById(idAndNotes[0]['bookId']!);

    return CurrentNotesDetail(
        book: book, numberOfNotes: idAndNotes[0]['numberOfNotes']!);
  }

  void setData(Book book, int number) {
    state =
        AsyncValue.data(CurrentNotesDetail(book: book, numberOfNotes: number));
  }
}
