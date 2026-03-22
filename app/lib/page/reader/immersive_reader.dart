import 'package:flutter/material.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/read_theme.dart';
import 'package:omnigram/dao/theme.dart';
import 'package:omnigram/page/reading_page.dart';

/// Full-screen immersive reader.
/// Sprint 1: Thin wrapper around existing ReadingPage.
/// Sprint 2+: Replace chrome with new reader_app_bar, reader_bottom_bar.
class ImmersiveReader extends StatelessWidget {
  final Book book;

  const ImmersiveReader({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReadTheme>>(
      future: ThemeDao().selectThemes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return ReadingPage(key: readingPageKey, book: book, initialThemes: snapshot.data!);
      },
    );
  }
}
