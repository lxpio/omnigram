import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/note.entity.dart';
import 'package:omnigram/services/note.service.dart';

class NoteItemView extends ConsumerWidget {
  const NoteItemView({super.key, required this.service});

  // final List<NoteEntity> notes;
  final NoteService service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = service.loadNoteTree();

    return ReorderableListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteTreeItem(
          key: ValueKey(notes[index].id),
          note: notes[index],
          level: 0,
        );
      },
      onReorder: (oldIndex, newIndex) async {
        if (oldIndex < newIndex) newIndex--;
        final movedNote = notes.removeAt(oldIndex);
        notes.insert(newIndex, movedNote);
        // await noteProvider.updateNoteOrder(notes);
      },
    );
  }
}

class NoteTreeItem extends StatefulWidget {
  final NoteEntity note;
  final int level;

  const NoteTreeItem({
    super.key,
    required this.note,
    this.level = 0,
  });

  @override
  State<NoteTreeItem> createState() => _NoteTreeItemState();
}

class _NoteTreeItemState extends State<NoteTreeItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 16.0 * widget.level),
          leading: widget.note.children?.isNotEmpty == true
              ? IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                )
              : const SizedBox(width: 40),
          title: Text(widget.note.title),
          onTap: () {
            // Handle note selection
          },
        ),
        if (_isExpanded && widget.note.children?.isNotEmpty == true)
          ...widget.note.children!.map(
            (child) => NoteTreeItem(
              note: child,
              level: widget.level + 1,
            ),
          ),
      ],
    );
  }
}
