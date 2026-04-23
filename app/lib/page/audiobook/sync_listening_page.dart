import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/book.dart';
import 'package:omnigram/models/server/server_tts.dart';
import 'package:omnigram/page/book_player/epub_player.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/service/audiobook/audiobook_player.dart';
import 'package:omnigram/service/audiobook/sync_controller.dart';

/// Integrated EPUB + audiobook experience:
///
/// - Top: `EpubPlayer` webview rendering the book page with sentence highlight
/// - Bottom: mini-player (play/pause, progress, chapter title, speed)
///
/// On mount it fetches the book's audiobook manifest, downloads chapter 0's
/// MP3 + alignment JSON to app docs dir, then kicks the `AudiobookPlayer`
/// off and attaches the `AudiobookSyncController` so every position tick
/// drives a highlight update on the rendered page.
class SyncListeningPage extends ConsumerStatefulWidget {
  const SyncListeningPage({super.key, required this.book});

  final Book book;

  @override
  ConsumerState<SyncListeningPage> createState() => _SyncListeningPageState();
}

class _SyncListeningPageState extends ConsumerState<SyncListeningPage> {
  final GlobalKey<EpubPlayerState> _epubKey = GlobalKey<EpubPlayerState>();
  final AudiobookPlayer _player = AudiobookPlayer();
  AudiobookSyncController? _sync;

  AudiobookIndex? _index;
  int _currentChapter = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  String? _error;
  bool _bootstrapped = false;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<void>? _compSub;

  @override
  void initState() {
    super.initState();
    _posSub = _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _compSub = _player.completionStream.listen((_) => _onChapterComplete());
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _compSub?.cancel();
    _sync?.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Bootstrap once EpubPlayer has finished loading ─────────────

  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    final conn = ref.read(serverConnectionProvider);
    if (!conn.isConnected) {
      setState(() => _error = L10n.of(context).audiobookNeedsServer);
      return;
    }
    final tts = ref.read(serverConnectionProvider.notifier).tts;
    if (tts == null) {
      setState(() => _error = 'TTS API unavailable');
      return;
    }

    try {
      final index = await tts.getAudiobookIndex(widget.book.id.toString());
      if (index.chapters.isEmpty) {
        setState(() => _error = L10n.of(context).audiobookEmpty);
        return;
      }
      _index = index;
      await _loadChapter(0);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _loadChapter(int chapterIdx) async {
    final tts = ref.read(serverConnectionProvider.notifier).tts;
    final idx = _index;
    if (tts == null || idx == null || chapterIdx >= idx.chapters.length) return;
    final meta = idx.chapters[chapterIdx];
    if (meta.audioFile.isEmpty) {
      setState(() => _error = 'Chapter not generated yet');
      return;
    }

    final bookDir = await _bookDir();
    final mp3Path = '${bookDir.path}/chapter_${chapterIdx.toString().padLeft(3, '0')}.mp3';

    if (!File(mp3Path).existsSync()) {
      await tts.downloadChapter(widget.book.id.toString(), chapterIdx, mp3Path);
    }

    final alignment = await tts.getChapterAlignment(widget.book.id.toString(), chapterIdx);

    // Initialise sync controller lazily (first chapter): needs the epub state.
    final epubState = _epubKey.currentState;
    if (epubState != null) {
      _sync ??= AudiobookSyncController(player: _player, epubState: epubState);
      _sync!.setAlignment(alignment);
      _sync!.attach();
      _sync!.onSentenceChange = (_, _) {
        // Reserved for Phase 6 polish: auto-page-flip hook when sentence
        // crosses the currently visible page range.
      };
    }

    await _player.loadLocal(mp3Path);
    final total = await _player.totalDuration;
    if (mounted) {
      setState(() {
        _currentChapter = chapterIdx;
        _duration = total ?? Duration(milliseconds: meta.durationMs);
      });
    }

    await _player.play();
    if (mounted) setState(() => _isPlaying = true);
  }

  Future<Directory> _bookDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/audiobooks/${widget.book.id}');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  void _onChapterComplete() {
    final idx = _index;
    if (idx == null) return;
    if (_currentChapter + 1 >= idx.chapters.length) {
      // End of book
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    _loadChapter(_currentChapter + 1);
  }

  // ── Controls ─────────────────────────────────────────────────────

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    if (mounted) setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _seekTo(Duration pos) async {
    await _player.seek(pos);
    await _sync?.highlightAt(pos.inMilliseconds);
  }

  Future<void> _changeSpeed(double rate) async {
    await _player.setSpeed(rate);
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_index?.chapters.isNotEmpty == true
            ? _index!.chapters[_currentChapter].title
            : widget.book.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, textAlign: TextAlign.center),
                    ),
                  )
                : EpubPlayer(
                    key: _epubKey,
                    book: widget.book,
                    showOrHideAppBarAndBottomBar: (bool _) {},
                    onLoadEnd: () {
                      // Defer bootstrap to next frame so EpubPlayer state is ready.
                      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
                    },
                    initialThemes: const [],
                    updateParent: () {},
                  ),
          ),
          _MiniPlayer(
            title: _index?.chapters.isNotEmpty == true
                ? _index!.chapters[_currentChapter].title
                : '',
            position: _position,
            duration: _duration,
            isPlaying: _isPlaying,
            onTogglePlayPause: _togglePlayPause,
            onSeek: _seekTo,
            onSpeedChange: _changeSpeed,
            hint: l10n.audiobookPageTitle,
          ),
        ],
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({
    required this.title,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onTogglePlayPause,
    required this.onSeek,
    required this.onSpeedChange,
    required this.hint,
  });

  final String title;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final VoidCallback onTogglePlayPause;
  final Future<void> Function(Duration) onSeek;
  final Future<void> Function(double) onSpeedChange;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = duration.inMilliseconds.clamp(1, 1 << 30);
    final progress = (position.inMilliseconds / total).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                  iconSize: 44,
                  color: theme.colorScheme.primary,
                  onPressed: onTogglePlayPause,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title.isEmpty ? hint : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '${_fmt(position)} / ${_fmt(duration)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<double>(
                  tooltip: 'Speed',
                  initialValue: 1.0,
                  icon: const Icon(Icons.speed),
                  onSelected: onSpeedChange,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 0.75, child: Text('0.75×')),
                    PopupMenuItem(value: 1.0, child: Text('1.0×')),
                    PopupMenuItem(value: 1.25, child: Text('1.25×')),
                    PopupMenuItem(value: 1.5, child: Text('1.5×')),
                    PopupMenuItem(value: 2.0, child: Text('2.0×')),
                  ],
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: progress,
                onChanged: (v) {
                  final target = Duration(milliseconds: (v * total).round());
                  onSeek(target);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }
}
