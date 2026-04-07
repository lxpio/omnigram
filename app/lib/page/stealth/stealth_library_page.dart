import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:omnigram/dao/stealth/stealth_book_dao.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/widgets/library/book_grid_item.dart';
import 'package:path/path.dart' as p;

class StealthLibraryPage extends StatefulWidget {
  final String encryptionKey;

  const StealthLibraryPage({super.key, required this.encryptionKey});

  @override
  State<StealthLibraryPage> createState() => _StealthLibraryPageState();
}

class _StealthLibraryPageState extends State<StealthLibraryPage> {
  late final StealthBookDao _bookDao;
  List<Book> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bookDao = StealthBookDao(widget.encryptionKey);
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await _bookDao.selectBooks();
    if (mounted) {
      setState(() {
        _books = books;
        _loading = false;
      });
    }
  }

  Future<void> _importBooks() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final now = DateTime.now();
    for (final file in result.files) {
      final title = p.basenameWithoutExtension(file.name);
      final book = Book(
        id: -1,
        title: title,
        author: '',
        coverPath: '',
        filePath: file.path ?? '',
        lastReadPosition: '',
        readingPercentage: 0.0,
        isDeleted: false,
        rating: 0.0,
        createTime: now,
        updateTime: now,
      );
      await _bookDao.insertBook(book);
    }
    await _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _importBooks,
              icon: const Icon(Icons.add),
              label: Text(L10n.of(context).stealthImportBooks),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return BookGridItem(
          book: book,
          onTap: () {
            // TODO: open stealth reader
          },
        );
      },
    );
  }
}
