import 'package:isar/isar.dart';
import 'package:logging/logging.dart';
import 'package:omnigram/entities/note.entity.dart';
import 'package:omnigram/providers/db.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final noteServiceProvider = Provider(
  (ref) => NoteService(ref.watch(dbProvider)),
);

class NoteService {
  final log = Logger('NoteService');
  final Isar _isar;

  NoteService(this._isar);

  List<NoteEntity> loadNoteTree({int? parentId}) {
    final root = (parentId == null)
        ? _isar.noteEntitys.where().parentIdIsNull().sortByPriority().findAll()
        : _isar.noteEntitys.where().parentIdEqualTo(parentId).sortByPriority().findAll();

    for (var i = 0; i < root.length; i++) {
      if (root[i].shouldRenderChildren) {
        final subNotes = loadNoteTree(parentId: root[i].id);
        root[i] = root[i].copyWith(children: subNotes);
      }
    }

    return root;
  }

  List<NoteEntity> search({String? keyword}) {
    final nodes = (keyword == null)
        ? _isar.noteEntitys.where().sortByCtimeDesc().findAll()
        : _isar.noteEntitys.where().titleContains(keyword, caseSensitive: false).sortByCtimeDesc().findAll();

    return nodes;
  }

  int loadChildren(List<NoteEntity> notes, int noteId) {
    for (var i = 0; i < notes.length; i++) {
      if (notes[i].id == noteId) {
        final subNotes = _isar.noteEntitys.where().parentIdEqualTo(noteId).sortByPriority().findAll();
        notes[i] = notes[i].copyWith(children: subNotes);
        log.severe('loadChildren:  $noteId , children count: ${subNotes.length}');
        return subNotes.length;
      }
    }
    return 0;
  }

  void deleteNote(List<NoteEntity> notes, int noteId) {
    var found = false;
    for (var i = 0; i < notes.length; i++) {
      if (notes[i].id == noteId) {
        notes.removeAt(i);
        found = true;
        break;
      }
    }

    if (found) {
      final idsToDelete = <int>[];
      _collectIds(noteId, idsToDelete);

      _isar.write((db) {
        log.severe('Deleting notes: $idsToDelete');
        return db.noteEntitys.deleteAll(idsToDelete);
      });
    }
  }

  void updateNote(NoteEntity note) {
    _isar.write((isar) {
      isar.noteEntitys.put(note);
    });
  }

  void updateNoteOrder(List<NoteEntity> notes) {
    _isar.write((isar) async {
      isar.noteEntitys.putAll(notes);
    });
  }

  void _collectIds(int parentId, List<int> idsToDelete) {
    idsToDelete.add(parentId);
    final children = _isar.noteEntitys.where().parentIdEqualTo(parentId).findAll();
    for (final child in children) {
      _collectIds(child.id, idsToDelete);
    }
  }
}
