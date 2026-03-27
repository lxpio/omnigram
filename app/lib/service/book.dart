import 'dart:io';

import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/id_mapping.dart';
import 'package:omnigram/dao/theme.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/main.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/current_reading_state.dart';
import 'package:omnigram/page/home_page.dart';
import 'package:omnigram/providers/ai_chat.dart';
import 'package:omnigram/providers/chapter_content_bridge.dart';
import 'package:omnigram/providers/current_reading.dart';
import 'package:omnigram/providers/book_list.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/providers/toc_search.dart';
import 'package:omnigram/service/ai/post_import_ai.dart';
import 'package:omnigram/service/convert_to_epub/txt/convert_from_txt.dart';
import 'package:omnigram/service/md5_service.dart';
import 'package:omnigram/utils/webView/anx_headless_webview.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:omnigram/page/reading_page.dart';
import 'package:omnigram/utils/import_book.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:omnigram/utils/toast/common.dart';
import 'package:omnigram/utils/webView/gererate_url.dart';
import 'package:omnigram/utils/webView/webview_console_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import 'book_player/book_player_server.dart';

AnxHeadlessWebView? headlessInAppWebView;
final allowBookExtensions = ["epub", "mobi", "azw3", "fb2", "txt", "pdf"];

/// import book list and **delete file**
void importBookList(List<File> fileList, BuildContext context, WidgetRef ref) {
  AnxLog.info('importBook fileList: ${fileList.toString()}');

  List<File> supportedFiles = fileList.where((file) {
    return allowBookExtensions.contains(file.path.split('.').last.toLowerCase());
  }).toList();

  List<File> unsupportedFiles = fileList.where((file) {
    return !allowBookExtensions.contains(file.path.split('.').last.toLowerCase());
  }).toList();

  _checkDuplicatesAndShowDialog(supportedFiles, unsupportedFiles, fileList, context, ref);
}

void _checkDuplicatesAndShowDialog(
  List<File> supportedFiles,
  List<File> unsupportedFiles,
  List<File> fileList,
  BuildContext context,
  WidgetRef ref,
) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(L10n.of(context).md5Calculating),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(L10n.of(context).md5Calculating),
        ],
      ),
    ),
  );

  try {
    final filePaths = supportedFiles.map((f) => f.path).toList();
    final checkResults = await MD5Service.checkImportFiles(filePaths);

    Navigator.of(context).pop();

    List<File> duplicateFiles = [];
    List<File> uniqueFiles = [];
    Map<String, Book> duplicateInfo = {};

    for (int i = 0; i < supportedFiles.length; i++) {
      final file = supportedFiles[i];
      final result = checkResults[i];

      if (result.isDuplicate && result.duplicateBook != null) {
        duplicateFiles.add(file);
        duplicateInfo[file.path] = result.duplicateBook!;
      } else {
        uniqueFiles.add(file);
      }
    }

    _showImportDialog(uniqueFiles, duplicateFiles, duplicateInfo, unsupportedFiles, fileList, ref);
  } catch (e) {
    Navigator.of(navigatorKey.currentContext!).pop();
    AnxLog.severe('MD5 check failed: $e');
    _showImportDialog(supportedFiles, [], {}, unsupportedFiles, fileList, ref);
  }
}

void _showImportDialog(
  List<File> uniqueFiles,
  List<File> duplicateFiles,
  Map<String, Book> duplicateInfo,
  List<File> unsupportedFiles,
  List<File> fileList,
  WidgetRef ref,
) {
  // delete unsupported files
  for (var file in unsupportedFiles) {
    file.deleteSync();
  }

  BuildContext context = navigatorKey.currentContext!;

  Widget bookItem(
    String filePath,
    Widget icon, {
    bool isDuplicate = false,
    String? duplicateTitle,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 24, height: 24, child: icon),
            Expanded(
              child: Text(
                path.basename(filePath),
                style: TextStyle(fontWeight: FontWeight.w300, overflow: TextOverflow.ellipsis),
              ),
            ),
            if (errorMessage != null)
              IconButton(
                icon: const Icon(Icons.info_outline, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(L10n.of(context).commonError),
                      content: SelectableText(errorMessage),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text(L10n.of(context).commonOk)),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
        if (isDuplicate && duplicateTitle != null)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 2),
            child: Text(
              L10n.of(context).duplicateOf(duplicateTitle),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 2),
            child: Text(
              'Error: ${errorMessage.length > 50 ? "${errorMessage.substring(0, 50)}..." : errorMessage}',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }

  final supportedFiles = [...uniqueFiles, ...duplicateFiles];
  bool skipDuplicates = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      String currentHandlingFile = '';
      List<String> errorFiles = [];
      bool finished = false;
      Map<String, String> errorMessages = {};

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(L10n.of(context).importNBooksSelected(fileList.length)),
            contentPadding: const EdgeInsets.all(16),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L10n.of(context).importSupportTypes(allowBookExtensions.join(' / '))),

                  const SizedBox(height: 10),

                  // show unique files
                  for (var file in uniqueFiles)
                    file.path == currentHandlingFile
                        ? bookItem(
                            file.path,
                            Container(
                              padding: const EdgeInsets.all(3),
                              width: 20,
                              height: 20,
                              child: const CircularProgressIndicator(),
                            ),
                          )
                        : bookItem(
                            file.path,
                            errorFiles.contains(file.path) ? const Icon(Icons.error) : const Icon(Icons.done),
                            errorMessage: errorFiles.contains(file.path) ? errorMessages[file.path] : null,
                          ),

                  // show unsupported files
                  if (unsupportedFiles.isNotEmpty) ...[
                    Divider(),
                    SizedBox(height: 10),
                    Text(L10n.of(context).importNBooksNotSupport(unsupportedFiles.length)),
                  ],
                  for (var file in unsupportedFiles) bookItem(file.path, const Icon(Icons.error)),

                  // show duplicate files
                  if (duplicateFiles.isNotEmpty) ...[
                    Divider(),
                    const SizedBox(height: 10),
                    Text(L10n.of(context).duplicateFile),
                  ],
                  for (var file in duplicateFiles)
                    if (skipDuplicates)
                      bookItem(
                        file.path,
                        const Icon(Icons.double_arrow_rounded),
                        isDuplicate: true,
                        duplicateTitle: duplicateInfo[file.path]?.title,
                      )
                    else
                      file.path == currentHandlingFile
                          ? bookItem(
                              file.path,
                              Container(
                                padding: const EdgeInsets.all(3),
                                width: 20,
                                height: 20,
                                child: const CircularProgressIndicator(),
                              ),
                              isDuplicate: true,
                              duplicateTitle: duplicateInfo[file.path]?.title,
                            )
                          : bookItem(
                              file.path,
                              errorFiles.contains(file.path) ? const Icon(Icons.error) : const Icon(Icons.done),
                              isDuplicate: true,
                              duplicateTitle: duplicateInfo[file.path]?.title,
                              errorMessage: errorFiles.contains(file.path) ? errorMessages[file.path] : null,
                            ),

                  // select skip duplicates
                  if (duplicateFiles.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: skipDuplicates,
                          onChanged: (value) {
                            setState(() {
                              skipDuplicates = value ?? true;
                            });
                          },
                        ),
                        Expanded(child: Text(L10n.of(context).skipDuplicateFiles)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  for (var file in supportedFiles) {
                    file.deleteSync();
                  }
                },
                child: Text(L10n.of(context).commonCancel),
              ),
              if (uniqueFiles.isNotEmpty || (duplicateFiles.isNotEmpty && !skipDuplicates))
                TextButton(
                  onPressed: () async {
                    if (finished) {
                      Navigator.of(context).pop('dialog');
                      return;
                    }

                    List<File> filesToImport = [...uniqueFiles];
                    if (!skipDuplicates) {
                      filesToImport.addAll(duplicateFiles);
                    }

                    for (var file in filesToImport) {
                      AnxToast.show(path.basename(file.path));
                      setState(() {
                        currentHandlingFile = file.path;
                      });
                      try {
                        await importBook(file, ref);
                        setState(() {
                          currentHandlingFile = '';
                        });
                      } catch (e, stackTrace) {
                        AnxLog.severe('Failed to import ${file.path}: $e');
                        AnxLog.severe('Stack trace: $stackTrace');
                        setState(() {
                          errorFiles.add(file.path);
                          errorMessages[file.path] = e.toString();
                        });
                      }
                    }

                    // dumplicateFiles will be deleted if skipDuplicates is true
                    // if skipDuplicates is false, they will be imported
                    // and then deleted in the importBook function
                    if (skipDuplicates) {
                      for (var file in duplicateFiles) {
                        file.deleteSync();
                      }
                    }

                    setState(() {
                      finished = true;
                    });
                  },
                  child: Text(
                    finished
                        ? L10n.of(context).commonOk
                        : L10n.of(context).importImportNBooks(
                            uniqueFiles.length + (skipDuplicates ? 0 : duplicateFiles.length) - errorFiles.length,
                          ),
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}

Future<void> importBook(File file, WidgetRef ref) async {
  String? md5 = await MD5Service.calculateFileMd5(file.path);

  if (file.path.split('.').last == 'txt') {
    final tempFile = await convertFromTxt(file);
    file.deleteSync();
    file = tempFile;
  }

  await getBookMetadata(file, md5: md5, ref: ref);
  ref.read(bookListProvider.notifier).refresh();
}

/// Downloads a book file from the server on demand.
/// Shows a progress dialog during download.
/// Returns true if the download succeeded, false otherwise.
Future<bool> _downloadBookOnDemand(WidgetRef ref, BuildContext context, Book book) async {
  final conn = ref.read(serverConnectionProvider.notifier);
  final bookApi = conn.books;
  if (bookApi == null) {
    AnxToast.show(L10n.of(context).bookDeleted);
    return false;
  }

  final serverId = await IdMappingDao.getServerId(book.id.toString(), 'book');
  if (serverId == null) {
    if (context.mounted) AnxToast.show(L10n.of(context).bookDeleted);
    return false;
  }

  final progressNotifier = ValueNotifier<double>(0.0);
  bool cancelled = false;

  if (!context.mounted) return false;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(L10n.of(context).commonDownloading),
        content: ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (_, progress, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress > 0 ? progress : null),
              const SizedBox(height: 12),
              Text('${(progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              cancelled = true;
              Navigator.of(ctx).pop();
            },
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      ),
    ),
  );

  try {
    final fileDir = Directory(getBasePath('file'));
    if (!fileDir.existsSync()) {
      fileDir.createSync(recursive: true);
    }
    final savePath = 'file/${book.title.replaceAll(RegExp(r'[^\w\s\-.]'), '_')}-${DateTime.now().millisecondsSinceEpoch}.epub';
    final fullPath = getBasePath(savePath);

    await bookApi.downloadBook(serverId, fullPath, onReceiveProgress: (received, total) {
      if (total > 0) {
        progressNotifier.value = received / total;
      }
    });

    if (cancelled) {
      File(fullPath).deleteSync();
      return false;
    }

    // Update local DB with the file path
    book.filePath = savePath;
    await BookDao().updateBook(book);

    if (context.mounted) Navigator.of(context).pop();
    return true;
  } catch (e) {
    AnxLog.info('Download book failed: $e');
    if (context.mounted) Navigator.of(context).pop();
    if (context.mounted) AnxToast.show(L10n.of(context).downloadFailed);
    return false;
  } finally {
    progressNotifier.dispose();
  }
}

Future<void> pushToReadingPage(WidgetRef ref, BuildContext context, Book book, {String? cfi, String? heroTag}) async {
  if (book.isDeleted) {
    AnxToast.show(L10n.of(context).bookDeleted);
    return;
  }

  if (!File(book.fileFullPath).existsSync()) {
    // Try on-demand download from server
    final downloaded = await _downloadBookOnDemand(ref, context, book);
    if (!downloaded) return;
    // Reload book from DB to get updated filePath
    book = await BookDao().selectBookById(book.id);
  }

  ref.read(aiChatProvider.notifier).clear();
  final initialThemes = await themeDao.selectThemes();
  ref.read(currentReadingProvider.notifier).start(CurrentReadingState(book: book, cfi: cfi));

  final currentReading = ref.read(currentReadingProvider.notifier);
  final chapterContentBridge = ref.read(chapterContentBridgeProvider.notifier);
  final tocSearch = ref.read(tocSearchProvider.notifier);

  await Navigator.push(
    navigatorKey.currentContext!,
    CupertinoPageRoute(
      builder: (c) =>
          ReadingPage(key: readingPageKey, book: book, cfi: cfi, initialThemes: initialThemes, heroTag: heroTag),
    ),
  ).then((_) {
    AnxLog.info('ReadingPage: poped: ${book.title}');
    currentReading.finish();
    chapterContentBridge.state = null;
    tocSearch.clear();
    AnxLog.info('Pop successfully ReadingPage: ${book.title}');
  });
}

void updateBookRating(Book book, double rating) {
  book.rating = rating;
  bookDao.updateBook(book);
}

Future<void> resetBookCover(Book book) async {
  File file = File(book.fileFullPath);
  getBookMetadata(file);
}

Future<void> saveBook(
  File file,
  String title,
  String author,
  String description,
  String? md5,
  String cover, {
  Book? provideBook,
}) async {
  // Extract original filename (without extension)
  final fileNameWithoutExt = path.basenameWithoutExtension(file.path);

  // Use original filename if title is invalid
  final effectiveTitle = (title == 'Unknown' || title.trim().isEmpty) ? fileNameWithoutExt : title;

  final newBookName =
      '${effectiveTitle.length > 20 ? effectiveTitle.substring(0, 20) : effectiveTitle}-${DateTime.now().millisecondsSinceEpoch}'
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

  final extension = file.path.split('.').last;

  final dbFilePath = 'file/$newBookName.$extension';
  final filePath = getBasePath(dbFilePath);
  String? dbCoverPath = 'cover/$newBookName';
  // final coverPath = getBasePath(dbCoverPath);

  await file.copy(filePath);
  // remove cached file
  file.delete();

  dbCoverPath = await saveImageToLocal(cover, dbCoverPath);
  if (md5 != null) {
    provideBook ??= await bookDao.getBookByMd5(md5);
  }

  Book book = Book(
    id: provideBook != null ? provideBook.id : -1,
    title: provideBook?.title ?? effectiveTitle,
    coverPath: dbCoverPath,
    filePath: dbFilePath,
    lastReadPosition: provideBook?.lastReadPosition ?? '',
    readingPercentage: provideBook?.readingPercentage ?? 0,
    author: provideBook?.author ?? author,
    isDeleted: false,
    rating: provideBook?.rating ?? 0.0,
    md5: md5,
    createTime: provideBook?.createTime ?? DateTime.now(),
    updateTime: DateTime.now(),
  );

  book.id = await bookDao.insertBook(book);
  final ctx = navigatorKey.currentContext;
  AnxToast.show(ctx != null ? L10n.of(ctx).serviceImportSuccess : 'Import success');
  await headlessInAppWebView?.dispose();
  headlessInAppWebView = null;
  return;
}

Future<void> getBookMetadata(File file, {Book? book, String? md5, WidgetRef? ref}) async {
  String serverFileName = Server().setTempFile(file);

  String cfi = '';

  String bookUrl = "http://127.0.0.1:${Server().port}/$serverFileName";
  AnxLog.info("import start: book url: $bookUrl");

  AnxHeadlessWebView webview = AnxHeadlessWebView(
    webViewEnvironment: webViewEnvironment,
    initialUrlRequest: URLRequest(url: WebUri(generateUrl(bookUrl, cfi, importing: true))),
    onLoadStop: (controller, url) async {
      controller.addJavaScriptHandler(
        handlerName: 'onMetadata',
        callback: (args) async {
          Map<String, dynamic> metadata = args[0];
          String title = metadata['title'] ?? 'Unknown';
          dynamic authorData = metadata['author'];
          String author = authorData is String
              ? authorData
              : authorData?.map((author) => author is String ? author : author['name'])?.join(', ') ?? 'Unknown';

          // base64 cover
          String cover = metadata['cover'] ?? '';
          String description = metadata['description'] ?? '';
          saveBook(file, title, author, description, md5, cover, provideBook: book);
          ref?.read(bookListProvider.notifier).refresh();
          // Background AI processing — fire and forget
          if (ref != null) {
            triggerPostImportAi(ref: ref, title: title, author: author, description: description);
          }
          // return;
        },
      );
    },
    onConsoleMessage: (controller, consoleMessage) {
      if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
        headlessInAppWebView?.dispose();
        headlessInAppWebView = null;
        throw Exception('Webview: ${consoleMessage.message}');
      }
      webviewConsoleMessage(controller, consoleMessage);
    },
  );

  await webview.run();
  headlessInAppWebView = webview;
  // max 30s
  int count = 0;
  while (count < 300) {
    if (headlessInAppWebView == null) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    count++;
  }
  await headlessInAppWebView?.dispose();
  headlessInAppWebView = null;
  throw Exception('Import: Get book metadata timeout');
}
