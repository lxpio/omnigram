import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/constants/note_annotations.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/models/book_notes_state.dart';
import 'package:omnigram/providers/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book_notes.g.dart';

@riverpod
class BookNotesController extends _$BookNotesController {
  NotesSortMode _viewSortFromPrefs() {
    final prefs = Prefs();
    return NotesSortMode(
      field: prefs.notesViewSortFieldPref,
      direction: prefs.notesViewSortDirectionPref,
    );
  }

  NotesSortMode _exportSortFromPrefs() {
    final prefs = Prefs();
    return NotesSortMode(
      field: prefs.notesExportSortFieldPref,
      direction: prefs.notesExportSortDirectionPref,
    );
  }

  void _persistViewSort(NotesSortMode mode) {
    final prefs = Prefs();
    prefs.notesViewSortFieldPref = mode.field;
    prefs.notesViewSortDirectionPref = mode.direction;
  }

  void _persistExportSort(NotesSortMode mode) {
    final prefs = Prefs();
    prefs.notesExportSortFieldPref = mode.field;
    prefs.notesExportSortDirectionPref = mode.direction;
  }

  @override
  Future<BookNotesState> build(Book book) async {
    final notes = await bookNoteDao.selectBookNotesByBookId(book.id);
    return _createState(
      book: book,
      notes: notes,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    try {
      final notes = await bookNoteDao.selectBookNotesByBookId(book.id);
      state = AsyncValue.data(
        _createState(
          book: book,
          notes: notes,
          previous: current,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void toggleSelection(BookNote note) {
    final current = state.valueOrNull;
    if (current == null || note.id == null) {
      return;
    }
    final updatedSelection = Set<int>.from(current.selectedNoteIds);
    if (updatedSelection.contains(note.id)) {
      updatedSelection.remove(note.id);
    } else {
      updatedSelection.add(note.id!);
    }
    _emit(
      current.copyWith(
        selectedNoteIds: updatedSelection,
      ),
    );
  }

  void clearSelection() {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.selectedNoteIds.isEmpty) return;
    _emit(
      current.copyWith(
        selectedNoteIds: {},
      ),
    );
  }

  void selectAllVisible() {
    final current = state.valueOrNull;
    if (current == null) return;
    final ids = current.visibleNotes
        .where((note) => note.id != null)
        .map((note) => note.id!)
        .toSet();
    _emit(
      current.copyWith(selectedNoteIds: ids),
    );
  }

  void toggleShowBookmarks() {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = current.copyWith(showBookmarks: !current.showBookmarks);
    _emit(
      next.copyWith(
        visibleNotes: _filterAndSort(
          next.allNotes,
          next.enabledTypeColors,
          next.showBookmarks,
          next.viewSortMode,
        ),
      ),
    );
  }

  void toggleTypeColors(String type) {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = Set<String>.from(current.enabledTypeColors);
    for (final color in notesColors) {
      final key = _filterKey(type, color);
      if (updated.contains(key)) {
        updated.remove(key);
      } else {
        updated.add(key);
      }
    }
    _emit(
      _recomputeVisible(
        current.copyWith(enabledTypeColors: updated),
      ),
    );
  }

  void toggleTypeColor(String type, String color) {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = Set<String>.from(current.enabledTypeColors);
    final key = _filterKey(type, color);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    _emit(
      _recomputeVisible(
        current.copyWith(enabledTypeColors: updated),
      ),
    );
  }

  void resetFilters() {
    final current = state.valueOrNull;
    if (current == null) return;
    final defaults = NoteFilterDefaults.initialTypeColorSelection();
    _emit(
      _recomputeVisible(
        current.copyWith(
          enabledTypeColors: defaults,
          showBookmarks: true,
        ),
      ),
    );
  }

  void toggleViewSort(NotesSortField field) {
    final current = state.valueOrNull;
    if (current == null) return;
    final newMode = current.viewSortMode.field == field
        ? current.viewSortMode.toggleDirection()
        : current.viewSortMode.copyWith(field: field).toggleDirection();
    _persistViewSort(newMode);
    _emit(
      current.copyWith(
        viewSortMode: newMode,
        visibleNotes: _filterAndSort(
          current.allNotes,
          current.enabledTypeColors,
          current.showBookmarks,
          newMode,
        ),
      ),
    );
  }

  void setExportSortField(NotesSortField field) {
    final current = state.valueOrNull;
    if (current == null) return;
    final newMode = current.exportSortMode.copyWith(field: field);
    _persistExportSort(newMode);
    _emit(
      current.copyWith(exportSortMode: newMode),
    );
  }

  void toggleExportSortDirection() {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.exportSortMode.toggleDirection();
    _persistExportSort(updated);
    _emit(
      current.copyWith(
        exportSortMode: updated,
      ),
    );
  }

  Future<void> updateNote(BookNote note) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await bookNoteDao.updateBookNoteById(note);
    // await Sync().syncData(
    //   SyncDirection.upload,
    //   null,
    //   trigger: SyncTrigger.manual,
    // );
    await refresh();
  }

  Future<void> deleteNotes(List<BookNote> notesToDelete) async {
    if (notesToDelete.isEmpty) {
      return;
    }
    for (final note in notesToDelete) {
      if (note.id != null) {
        await bookNoteDao.deleteBookNoteById(note.id!);
      }
    }

    // await Sync().syncData(
    //   SyncDirection.upload,
    //   null,
    //   trigger: SyncTrigger.auto,
    // );

    ref.read(BookmarkProvider(book.id).notifier).refreshBookmarks();

    await refresh();
  }

  List<BookNote> notesForExport({
    required bool selectedOnly,
    List<BookNote>? custom,
  }) {
    final current = state.valueOrNull;
    if (current == null) {
      return const [];
    }
    final baseList =
        custom ?? (selectedOnly ? current.selectedNotes : current.allNotes);
    return _sortNotes(baseList, current.exportSortMode);
  }

  BookNotesState _recomputeVisible(BookNotesState state) {
    return state.copyWith(
      visibleNotes: _filterAndSort(
        state.allNotes,
        state.enabledTypeColors,
        state.showBookmarks,
        state.viewSortMode,
      ),
    );
  }

  BookNotesState _createState({
    required Book book,
    required List<BookNote> notes,
    BookNotesState? previous,
  }) {
    final enabledTypeColors = previous?.enabledTypeColors ??
        NoteFilterDefaults.initialTypeColorSelection();
    final showBookmarks = previous?.showBookmarks ?? true;
    final viewSort = previous?.viewSortMode ?? _viewSortFromPrefs();
    final exportSort = previous?.exportSortMode ?? _exportSortFromPrefs();
    final validSelection = (previous?.selectedNoteIds ?? {})
        .where((id) => notes.any((note) => note.id == id))
        .toSet();
    return BookNotesState(
      book: book,
      allNotes: notes,
      visibleNotes: _filterAndSort(
        notes,
        enabledTypeColors,
        showBookmarks,
        viewSort,
      ),
      viewSortMode: viewSort,
      exportSortMode: exportSort,
      showBookmarks: showBookmarks,
      enabledTypeColors: enabledTypeColors,
      selectedNoteIds: validSelection,
    );
  }

  void _emit(BookNotesState newState) {
    state = AsyncValue.data(newState);
  }
}

String _filterKey(String type, String color) => '$type#${color.toUpperCase()}';

List<BookNote> _filterAndSort(
  List<BookNote> notes,
  Set<String> enabledTypeColors,
  bool showBookmarks,
  NotesSortMode sortMode,
) {
  final filtered = <BookNote>[];
  for (final note in notes) {
    if (note.type == 'bookmark') {
      if (showBookmarks) {
        filtered.add(note);
      }
      continue;
    }

    final match = notesType
        .firstWhere(
          (option) => option.type == note.type,
          orElse: () => const NoteTypeOption(type: '', icon: Icons.bookmark),
        )
        .type;

    if (match.isEmpty) {
      continue;
    }

    final key = _filterKey(note.type, note.color);
    if (enabledTypeColors.contains(key)) {
      filtered.add(note);
    }
  }

  return _sortNotes(filtered, sortMode);
}

List<BookNote> _sortNotes(List<BookNote> notes, NotesSortMode mode) {
  final sorted = List<BookNote>.from(notes);
  sorted.sort((a, b) {
    int comparison;
    if (mode.field == NotesSortField.createdTime) {
      comparison = _compareDate(a.createTime, b.createTime);
    } else {
      comparison = _compareCfi(a.cfi, b.cfi);
    }

    if (mode.direction == SortDirection.asc) {
      return comparison;
    }
    return -comparison;
  });
  return sorted;
}

int _compareDate(DateTime? a, DateTime? b) {
  final aTime = a ?? DateTime.fromMillisecondsSinceEpoch(0);
  final bTime = b ?? DateTime.fromMillisecondsSinceEpoch(0);
  return aTime.compareTo(bTime);
}

int _compareCfi(String a, String b) {
  List<String> replace(String str) {
    return str
        .replaceAll('epubcfi(/', '')
        .replaceAll(')', '')
        .replaceAll(',', '')
        .split('/');
  }

  final componentsA = replace(a);
  final componentsB = replace(b);

  for (int i = 0; i < componentsA.length && i < componentsB.length; i++) {
    final compA = componentsA[i];
    final compB = componentsB[i];

    if (compA.isEmpty || compB.isEmpty) {
      continue;
    }
    if (compA != compB) {
      if (compA.contains(':') && compB.contains(':')) {
        final locA = int.tryParse(compA.split(':')[1]) ?? 0;
        final locB = int.tryParse(compB.split(':')[1]) ?? 0;
        return locA.compareTo(locB);
      } else {
        final numA = int.tryParse(compA.replaceAll('!', '')) ?? 0;
        final numB = int.tryParse(compB.replaceAll('!', '')) ?? 0;
        return numA.compareTo(numB);
      }
    }
  }

  return componentsA.length.compareTo(componentsB.length);
}
