import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/widgets/book_notes/book_notes_list.dart';
import 'package:omnigram/widgets/reading_page/widget_title.dart';
import 'package:flutter/material.dart';

import 'package:omnigram/models/book.dart';

class ReadingNotes extends StatelessWidget {
  const ReadingNotes({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: MediaQuery.of(context).size.height - 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widgetTitle(L10n.of(context).navBarNotes, null),
          Expanded(
            child:
                ListView(children: [BookNotesList(book: book, reading: true)]),
          ),
        ],
      ),
    );
  }
}
