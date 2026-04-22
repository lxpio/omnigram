import 'dart:io';

import 'package:omnigram/dao/ai_cache.dart';
import 'package:omnigram/dao/book.dart';
import 'package:omnigram/dao/book_note.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/book_note.dart';
import 'package:omnigram/models/tag.dart';
import 'package:omnigram/providers/book_list.dart';
import 'package:omnigram/providers/tags.dart';
import 'package:omnigram/service/book.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:omnigram/utils/color/hash_color.dart';
import 'package:omnigram/widgets/book_detail/ai_summary_section.dart';
import 'package:omnigram/widgets/book_detail/audiobook_button.dart';
import 'package:omnigram/widgets/book_detail/cover_header.dart';
import 'package:omnigram/widgets/book_detail/notes_preview.dart';
import 'package:omnigram/widgets/bookshelf/book_cover.dart';
import 'package:omnigram/widgets/common/async_skeleton_wrapper.dart';
import 'package:omnigram/widgets/common/color_picker_sheet.dart';
import 'package:omnigram/widgets/common/tag_chip.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'book_notes_page.dart';

class BookDetail extends ConsumerStatefulWidget {
  const BookDetail({super.key, required this.book});

  final Book book;

  @override
  ConsumerState<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends ConsumerState<BookDetail> {
  late Book _book;
  bool isEditing = false;
  Color _dominantColor = Colors.grey;
  List<BookNote> _recentNotes = [];
  String? _aiSummary;
  final TextEditingController _newTagController = TextEditingController();
  Color? _pendingTagColor;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _extractDominantColor();
    _loadRecentNotes();
    _loadAiSummary();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  Future<void> _extractDominantColor() async {
    try {
      final file = File(_book.coverFullPath);
      if (!file.existsSync()) return;
      final scheme = await ColorScheme.fromImageProvider(
        provider: FileImage(file),
      );
      if (mounted) setState(() => _dominantColor = scheme.primary);
    } catch (_) {}
  }

  Future<void> _loadRecentNotes() async {
    final notes = await BookNoteDao().selectBookNotesByBookId(_book.id);
    if (mounted) setState(() => _recentNotes = notes);
  }

  Future<void> _loadAiSummary() async {
    try {
      final key = 'summary:bookId=${_book.id}';
      final entry = await aiCacheDao.get('summary', key);
      if (entry != null && mounted) setState(() => _aiSummary = entry.content);
    } catch (_) {}
  }

  void _toggleEdit() {
    if (isEditing) {
      // Save
      bookDao.updateBook(_book);
      ref.read(bookListProvider.notifier).refresh();
    }
    setState(() => isEditing = !isEditing);
  }

  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null) return;

    final image = File(result.files.single.path!);
    AnxLog.info('BookDetail: Image path: ${image.path}');

    final oldFile = File(_book.coverFullPath);
    if (await oldFile.exists()) await oldFile.delete();

    String oldName = _book.coverPath
        .split('-')
        .sublist(0, _book.coverPath.split('-').length - 1)
        .join('');
    if (!oldName.startsWith('cover/')) oldName = 'cover/$oldName';

    final newPath =
        '$oldName-${DateTime.now().millisecondsSinceEpoch}.png'.trim();
    AnxLog.info('BookDetail: New path: $newPath');

    final newFile = File(getBasePath(newPath));
    await newFile.writeAsBytes(await image.readAsBytes());

    setState(() {
      _book.coverPath = newPath;
      bookDao.updateBook(_book);
      ref.read(bookListProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(isEditing ? Icons.check : Icons.edit_outlined),
                onPressed: _toggleEdit,
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildCoverArea()),
          SliverToBoxAdapter(child: _buildContinueButton(l10n)),
          SliverToBoxAdapter(child: AudiobookButton(book: _book)),
          SliverToBoxAdapter(
            child: AiSummarySection(
              aiSummary: _aiSummary,
              description: _book.description,
            ),
          ),
          SliverToBoxAdapter(
            child: NotesPreview(
              notes: _recentNotes,
              onViewAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookNotesPage(
                    book: _book,
                    numberOfNotes: _recentNotes.length,
                    isMobile: true,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildTagSection()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                l10n.bookDetailImportedOn(
                  _book.createTime.toString().split(' ').first,
                ),
                style: OmnigramTypography.caption(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildCoverArea() {
    final coverWidget = GestureDetector(
      onTap: isEditing ? _pickCoverImage : null,
      child: Hero(
        tag: _book.coverFullPath,
        child: BookCover(book: _book, height: 170, width: 120),
      ),
    );

    if (isEditing) {
      return _buildEditableCoverArea(coverWidget);
    }

    return CoverHeader(
      title: _book.title,
      author: _book.author,
      progress: _book.readingPercentage,
      coverWidget: coverWidget,
      dominantColor: _dominantColor,
    );
  }

  Widget _buildEditableCoverArea(Widget coverWidget) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _dominantColor.withValues(alpha: 0.6),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                height: 170,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: coverWidget,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _book.title,
                      style: OmnigramTypography.titleLarge(context),
                      maxLines: null,
                      minLines: 1,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      onChanged: (v) => _book.title = v.replaceAll('\n', ' '),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _book.author,
                      style: OmnigramTypography.bodyMedium(context),
                      maxLines: null,
                      minLines: 1,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      onChanged: (v) => _book.author = v,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(L10n l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => pushToReadingPage(ref, context, _book),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _book.readingPercentage > 0
                ? l10n.bookDetailContinueReading
                : l10n.bookDetailStartReading,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildTagSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AsyncSkeletonWrapper(
        asyncValue: ref.watch(bookTagEditorProvider(_book.id)),
        builder: (state, _) {
          final notifier =
              ref.read(bookTagEditorProvider(_book.id).notifier);

          Future<void> showTagEditDialog(Tag tag) async {
            await TagChip.showEditDialog(
              context: context,
              initialName: tag.name,
              initialColor: tag.color ?? hashColor(tag.name),
              onRename: (newName) async {
                await ref
                    .read(tagListProvider.notifier)
                    .updateTag(tag.id, newName: newName);
                ref.read(bookListProvider.notifier).refresh();
                ref.invalidate(bookTagEditorProvider(_book.id));
              },
              onColorChange: (color) async {
                await ref
                    .read(tagListProvider.notifier)
                    .updateTag(tag.id, color: color);
                ref.read(bookListProvider.notifier).refresh();
                ref.invalidate(bookTagEditorProvider(_book.id));
              },
              onDelete: () async {
                await ref.read(tagListProvider.notifier).deleteTag(tag.id);
                await notifier.detach(tag);
                ref.read(bookListProvider.notifier).refresh();
                ref.invalidate(bookTagEditorProvider(_book.id));
              },
            );
          }

          Future<void> toggle(Tag tag) async {
            final attached = state.isAttached(tag.id);
            if (attached) {
              await notifier.detach(tag);
            } else {
              await notifier.attachExisting(tag);
            }
            ref.read(bookListProvider.notifier).refresh();
          }

          final attachedTags =
              state.tags.where((t) => state.isAttached(t.id)).toList();

          if (!isEditing) {
            return _buildReadOnlyTags(attachedTags);
          }
          return _buildEditableTags(state, attachedTags, toggle,
              showTagEditDialog, notifier);
        },
      ),
    );
  }

  Widget _buildReadOnlyTags(List<Tag> attachedTags) {
    final l10n = L10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tagsSectionTitle,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (attachedTags.isEmpty)
          Text(l10n.tagsEmptyHint)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attachedTags
                .map((t) => TagChip(
                    label: t.name, color: t.color, selected: true, dense: true))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildEditableTags(
    dynamic state,
    List<Tag> attachedTags,
    Future<void> Function(Tag) toggle,
    Future<void> Function(Tag) showTagEditDialog,
    dynamic notifier,
  ) {
    final l10n = L10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.tagsSectionTitle,
                style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: TextField(
                        controller: _newTagController,
                        decoration: InputDecoration(
                          hintText: l10n.tagNewPlaceholder,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onChanged: (_) {
                          setState(() {
                            final text = _newTagController.text.trim();
                            _pendingTagColor =
                                text.isEmpty ? null : hashColor(text);
                          });
                        },
                        onSubmitted: (value) async {
                          if (value.trim().isEmpty) return;
                          final color =
                              _pendingTagColor ?? hashColor(value.trim());
                          await notifier.createAndAttach(value.trim(),
                              color: color);
                          ref.read(bookListProvider.notifier).refresh();
                          _newTagController.clear();
                          _pendingTagColor = null;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(builder: (context) {
                    final text = _newTagController.text.trim();
                    final color = _pendingTagColor ??
                        (text.isEmpty ? hashColor('tag') : hashColor(text));
                    return IconButton(
                      tooltip: l10n.tagColorTooltip,
                      icon: Icon(Icons.circle, color: color),
                      onPressed: text.isEmpty
                          ? null
                          : () async {
                              final picked = await showRgbColorPicker(
                                context: context,
                                initialColor: color,
                                allowAlpha: false,
                              );
                              if (picked != null) {
                                setState(() => _pendingTagColor = picked);
                              }
                            },
                    );
                  }),
                  const SizedBox(width: 4),
                  OutlinedButton(
                    onPressed: () async {
                      final value = _newTagController.text.trim();
                      if (value.isEmpty) return;
                      final color = _pendingTagColor ?? hashColor(value);
                      await notifier.createAndAttach(value, color: color);
                      ref.read(bookListProvider.notifier).refresh();
                      _newTagController.clear();
                      _pendingTagColor = null;
                      setState(() {});
                    },
                    child: Text(l10n.tagAddButton),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.tags
              .map<Widget>(
                (tag) => TagChip(
                  label: tag.name,
                  color: tag.color,
                  selected: state.isAttached(tag.id),
                  onTap: () => toggle(tag),
                  onLongPress: () => showTagEditDialog(tag),
                  dense: false,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
