import 'package:omnigram/constants/note_annotations.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_notes_state.freezed.dart';

enum NotesSortField { createdTime, cfi }

enum SortDirection { asc, desc }

@freezed
abstract class NotesSortMode with _$NotesSortMode {
  const factory NotesSortMode({
    required NotesSortField field,
    required SortDirection direction,
  }) = _NotesSortMode;

  const NotesSortMode._();

  NotesSortMode toggleDirection() {
    return copyWith(
      direction: direction == SortDirection.asc
          ? SortDirection.desc
          : SortDirection.asc,
    );
  }

  NotesSortMode changeField(NotesSortField newField) {
    if (field == newField) {
      return toggleDirection();
    }
    return copyWith(field: newField);
  }
}

@freezed
abstract class BookNotesState with _$BookNotesState {
  const BookNotesState._();

  const factory BookNotesState({
    required Book book,
    required List<BookNote> allNotes,
    required List<BookNote> visibleNotes,
    required NotesSortMode viewSortMode,
    required NotesSortMode exportSortMode,
    required bool showBookmarks,
    required Set<String> enabledTypeColors,
    required Set<int> selectedNoteIds,
  }) = _BookNotesState;

  int get totalNotes => allNotes.length;

  bool get isSelecting => selectedNoteIds.isNotEmpty;

  List<BookNote> get selectedNotes => allNotes
      .where((note) => note.id != null && selectedNoteIds.contains(note.id))
      .toList();

  bool get showAllNotes => visibleNotes.length == allNotes.length;
}

extension NoteFilterDefaults on BookNotesState {
  static Set<String> initialTypeColorSelection() {
    final Set<String> values = {};
    for (final type in notesType) {
      for (final color in notesColors) {
        values.add('${type.type}#$color');
      }
    }
    return values;
  }
}
