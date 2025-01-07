import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:logging/logging.dart';
import 'package:omnigram/entities/note.entity.dart';
import 'package:omnigram/services/note.service.dart';
import 'package:omnigram/utils/build_config.dart';

void main() {
  test('notes should be orderd', () async {
    await Isar.initialize('/Users/liuyou/Workspace/libisar_macos.dylib');
    WidgetsFlutterBinding.ensureInitialized();

    final db = await loadDb('/tmp/note_test.db');

    var log = Logger("OmmigramErrorLogger");

    // create test notes
    List<NoteEntity> notes = [
      NoteEntity(
          id: 1,
          title: 'N1',
          parentId: null,
          levelPath: '1',
          priority: 1,
          shouldRenderChildren: true,
          isHoverEnabled: false),
      NoteEntity(id: 2, title: 'N2', parentId: 1, levelPath: '1,2', shouldRenderChildren: true, isHoverEnabled: false),
      NoteEntity(
          id: 3, title: 'N3', parentId: 16, levelPath: '17,16,3', shouldRenderChildren: true, isHoverEnabled: false),
      NoteEntity(
          id: 4, title: 'N4', parentId: 3, levelPath: '17,16,3,4', shouldRenderChildren: true, isHoverEnabled: false),
      NoteEntity(
          id: 10,
          title: 'N10',
          parentId: null,
          levelPath: '10',
          priority: 1,
          shouldRenderChildren: false,
          isHoverEnabled: false),
      NoteEntity(
          id: 11, title: 'N11', parentId: 10, levelPath: '10,11', shouldRenderChildren: true, isHoverEnabled: false),
      NoteEntity(
          id: 12,
          title: 'N12',
          parentId: 10,
          levelPath: '10,12',
          priority: 3,
          shouldRenderChildren: true,
          isHoverEnabled: false),
      NoteEntity(
          id: 13,
          title: 'N13',
          parentId: 10,
          levelPath: '10,13',
          priority: 0,
          shouldRenderChildren: true,
          isHoverEnabled: false),
      NoteEntity(
          id: 14, title: 'N14', parentId: 13, levelPath: '10,13,14', shouldRenderChildren: true, isHoverEnabled: false),
      NoteEntity(
          id: 15, title: 'N15', parentId: 10, levelPath: '15', shouldRenderChildren: true, isHoverEnabled: false),
      NoteEntity(
          id: 16, title: 'N16', parentId: 17, levelPath: '17,16', shouldRenderChildren: true, isHoverEnabled: false),
      NoteEntity(
          id: 17, title: 'N17', parentId: null, levelPath: '17', shouldRenderChildren: true, isHoverEnabled: false),
    ];
    db.write((db) {
      db.noteEntitys.putAll(notes);
    });

    // //get notes
    // var orders = db.noteEntitys.where().sortByLevelPath().thenByPriority().findAll();

    // for (var note in orders) {
    //   //println
    //   print(
    //       'id: ${note.id} \t title: ${note.title} \t parentId: ${note.parentId} \t levelPath: ${note.levelPath} \t priority: ${note.priority}');
    // }

    final srv = NoteService(db);

    final saved = srv.loadNoteTree();

    printNoteTree(saved);

    print('-------------------------------------------------------');

    srv.loadChildren(saved, 10);
    printNoteTree(saved);
    print('-------------------------------------------------------');

    srv.deleteNote(saved, 17);
    printNoteTree(saved);
    print('-------------------------------------------------------');
    final saved2 = srv.loadNoteTree();
    printNoteTree(saved2);
    //update note
  });
}

void printNoteTree(List<NoteEntity> list) {
  for (var note in list) {
    print(
        'id: ${note.id} \t title: ${note.title} \t parentId: ${note.parentId} \t levelPath: ${note.levelPath} \t priority: ${note.priority}');

    if (note.children != null) {
      printNoteTree(note.children!);
    }
  }
}
