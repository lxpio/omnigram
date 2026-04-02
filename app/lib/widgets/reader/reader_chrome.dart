// app/lib/widgets/reader/reader_chrome.dart
import 'package:flutter/material.dart';
import 'package:omnigram/widgets/reader/reader_app_bar.dart';
import 'package:omnigram/widgets/reader/reader_bottom_bar.dart';

/// Orchestrates reader chrome: top bar + bottom bar as a unified overlay.
/// Manages slide-in/slide-out animation.
class ReaderChrome extends StatelessWidget {
  final bool visible;
  final Animation<Offset> topSlide;
  final Animation<Offset> bottomSlide;
  final VoidCallback onDismiss;

  // AppBar props
  final String chapterTitle;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onToggleBookmark;
  final VoidCallback onShowCompanion;
  final VoidCallback onShowMenu;

  // BottomBar props
  final double progress;
  final int currentPage;
  final int totalPages;
  final ValueChanged<double>? onSeek;
  final VoidCallback onShowToc;
  final VoidCallback onShowNotes;
  final VoidCallback onShowProgress;
  final VoidCallback onShowStyle;
  final VoidCallback onShowTts;

  // Sub-panel content (notes, style, TTS, etc.)
  final Widget? activePanel;

  const ReaderChrome({
    super.key,
    required this.visible,
    required this.topSlide,
    required this.bottomSlide,
    required this.onDismiss,
    required this.chapterTitle,
    required this.isBookmarked,
    required this.onBack,
    required this.onToggleBookmark,
    required this.onShowCompanion,
    required this.onShowMenu,
    required this.progress,
    required this.currentPage,
    required this.totalPages,
    this.onSeek,
    required this.onShowToc,
    required this.onShowNotes,
    required this.onShowProgress,
    required this.onShowStyle,
    required this.onShowTts,
    this.activePanel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dim overlay
        if (visible)
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withValues(alpha: 0.12)),
            ),
          ),
        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: topSlide,
            child: ReaderAppBar(
              chapterTitle: chapterTitle,
              isBookmarked: isBookmarked,
              onBack: onBack,
              onToggleBookmark: onToggleBookmark,
              onShowCompanion: onShowCompanion,
              onShowMenu: onShowMenu,
            ),
          ),
        ),
        // Bottom bar + active panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: bottomSlide,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (activePanel != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: activePanel!,
                      ),
                    ReaderBottomBar(
                      progress: progress,
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onSeek: onSeek,
                      hideProgress: activePanel != null,
                      onShowToc: onShowToc,
                      onShowNotes: onShowNotes,
                      onShowProgress: onShowProgress,
                      onShowStyle: onShowStyle,
                      onShowTts: onShowTts,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
