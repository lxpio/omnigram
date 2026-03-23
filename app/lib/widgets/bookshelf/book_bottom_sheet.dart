import 'dart:io';
import 'dart:math';

import 'package:omnigram/dao/book.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/page/book_detail.dart';
import 'package:omnigram/providers/book_list.dart';
import 'package:omnigram/service/convert_to_epub/txt/convert_from_txt.dart';
import 'package:omnigram/service/md5_service.dart';
import 'package:omnigram/service/book.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:omnigram/utils/share_file.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/widgets/bookshelf/book_cover.dart';
import 'package:omnigram/widgets/delete_confirm.dart';
import 'package:omnigram/widgets/icon_and_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:path/path.dart' as p;

class BookBottomSheet extends ConsumerWidget {
  const BookBottomSheet({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> handleDelete(BuildContext context) async {
      Navigator.pop(context);
      await bookDao.updateBook(
        Book(
          id: book.id,
          title: book.title,
          coverPath: book.coverPath,
          filePath: book.filePath,
          lastReadPosition: book.lastReadPosition,
          readingPercentage: book.readingPercentage,
          author: book.author,
          isDeleted: true,
          description: book.description,
          rating: book.rating,
          md5: book.md5,
          createTime: book.createTime,
          updateTime: DateTime.now(),
        ),
      );
      ref.read(bookListProvider.notifier).refresh();
      File(book.fileFullPath).delete();
      File(book.coverFullPath).delete();
    }

    void handleDetail(BuildContext context) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetail(book: book)));
    }

    Future<void> handleShare() async {
      await shareFile(title: '${book.title}.${book.filePath.split('.').last}', filePath: book.fileFullPath);
    }

    String formatSize(int bytes) {
      if (bytes <= 0) return '0 B';
      const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
      var i = (log(bytes) / log(1024)).floor();
      return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
    }

    Future<void> handleReplace(BuildContext context) async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);

      if (result == null) return;
      PlatformFile newFile = result.files.first;
      String extension = p.extension(newFile.name).replaceAll('.', '').toLowerCase();
      if (!allowBookExtensions.contains(extension)) {
        AnxToast.show(L10n.of(context).bookBottomSheetUnsupportedFileFormat(extension));
        return;
      }

      File newFileObj = File(newFile.path!);

      if (!context.mounted) return;

      int newSize = await newFileObj.length();
      int oldSize = 0;
      if (await File(book.fileFullPath).exists()) {
        oldSize = await File(book.fileFullPath).length();
      }

      bool? confirm = await SmartDialog.show(
        builder: (context) => AlertDialog(
          title: Text(L10n.of(context).commonAttention),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.of(context).bookBottomSheetOriginalFileSize(formatSize(oldSize))),
              Text(L10n.of(context).bookBottomSheetNewFileSize(formatSize(newSize))),
              const SizedBox(height: 10),
              Text(L10n.of(context).bookBottomSheetReplaceWarning, style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                SmartDialog.dismiss(result: false);
              },
              child: Text(L10n.of(context).commonCancel),
            ),
            TextButton(
              onPressed: () {
                SmartDialog.dismiss(result: true);
              },
              child: Text(L10n.of(context).commonConfirm),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        String extension = p.extension(newFile.name);
        File fileToProcess = newFileObj;

        // Convert TXT to EPUB if needed
        if (extension.toLowerCase() == '.txt') {
          fileToProcess = await convertFromTxt(newFileObj);
          extension = '.epub';
        }

        String title = book.title;
        String nameWithoutExtension =
            '${title.length > 20 ? title.substring(0, 20) : title}-${DateTime.now().millisecondsSinceEpoch}'
                .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
                .replaceAll('\n', '')
                .replaceAll('\r', '')
                .trim();
        String newFileName = '$nameWithoutExtension$extension';
        String newRelativePath = 'file/$newFileName';
        String newDestPath = getBasePath(newRelativePath);

        // Copy new file
        await fileToProcess.copy(newDestPath);

        // Calculate MD5
        String? newMd5 = await MD5Service.calculateFileMd5(newDestPath);

        // Update DB
        await bookDao.updateBook(book.copyWith(filePath: newRelativePath, md5: newMd5, updateTime: DateTime.now()));

        // Delete old file if path is different
        if (book.fileFullPath != newDestPath) {
          final oldFile = File(book.fileFullPath);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        }

        // Clean up temporary file if TXT conversion happened
        if (fileToProcess != newFileObj) {
          if (await fileToProcess.exists()) {
            await fileToProcess.delete();
          }
        }

        ref.read(bookListProvider.notifier).refresh();
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        AnxToast.show(L10n.of(context).bookBottomSheetReplaceFailed(e.toString()));
      }
    }

    final actions = [
      {"icon": EvaIcons.share, "text": L10n.of(context).shareFile, "onTap": () => handleShare()},
      {
        "icon": EvaIcons.refresh,
        "text": L10n.of(context).bookBottomSheetReplaceFile,
        "onTap": () => handleReplace(context),
      },
      {"icon": EvaIcons.more_vertical, "text": L10n.of(context).notesPageDetail, "onTap": () => handleDetail(context)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BookCover(book: book, width: 40),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(child: Text(book.title, style: Theme.of(context).textTheme.titleMedium)),
          ),
          DeleteConfirm(
            delete: () {
              handleDelete(context);
            },
            deleteIcon: IconAndText(icon: const Icon(EvaIcons.trash), text: L10n.of(context).commonDelete),
            confirmIcon: IconAndText(
              icon: const Icon(EvaIcons.checkmark_circle_2, color: Colors.red),
              text: L10n.of(context).commonConfirm,
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return actions.map((action) {
                return PopupMenuItem(
                  onTap: () {
                    (action["onTap"] as Function())();
                  },
                  child: Row(
                    children: [
                      Icon(action["icon"] as IconData),
                      const SizedBox(width: 8),
                      Text(action["text"] as String),
                    ],
                  ),
                );
              }).toList();
            },
            child: IconAndText(icon: const Icon(EvaIcons.more_vertical), text: L10n.of(context).more),
          ),
        ],
      ),
    );
  }
}
