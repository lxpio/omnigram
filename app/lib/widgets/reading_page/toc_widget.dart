import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/page/book_player/epub_player.dart';
import 'package:omnigram/widgets/reading_page/widgets/book_toc.dart';
import 'package:omnigram/widgets/reading_page/widgets/bookmark.dart';
import 'package:flutter/material.dart';

class TocWidget extends StatefulWidget {
  const TocWidget({
    super.key,
    required this.epubPlayerKey,
    required this.hideAppBarAndBottomBar,
    required this.closeDrawer,
  });

  final GlobalKey<EpubPlayerState> epubPlayerKey;
  final Function hideAppBarAndBottomBar;
  final VoidCallback closeDrawer;

  @override
  State<TocWidget> createState() => _TocWidgetState();
}

class _TocWidgetState extends State<TocWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: L10n.of(context).readingContents),
            Tab(text: L10n.of(context).readingBookmark),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TabBarView(
              controller: _tabController,
              children: [
                buildBookToc(),
                buildBookmarkList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBookmarkList() {
    return BookmarkWidget(
      epubPlayerKey: widget.epubPlayerKey,
      onNavigate: () {
        widget.hideAppBarAndBottomBar(false);
        widget.closeDrawer();
      },
    );
  }

  BookToc buildBookToc() {
    return BookToc(
      epubPlayerKey: widget.epubPlayerKey,
      hideAppBarAndBottomBar: widget.hideAppBarAndBottomBar,
      closeDrawer: widget.closeDrawer,
    );
  }
}
