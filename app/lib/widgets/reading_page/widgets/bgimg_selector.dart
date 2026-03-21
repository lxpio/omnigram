import 'dart:io';

import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/enums/bgimg_fit.dart';
import 'package:omnigram/enums/bgimg_theme_mode.dart';
import 'package:omnigram/enums/bgimg_type.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/bgimg.dart';
import 'package:omnigram/page/reading_page.dart';
import 'package:omnigram/providers/bgimg.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:omnigram/widgets/common/anx_segmented_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BgimgSelector extends ConsumerStatefulWidget {
  const BgimgSelector({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BgimgSelectorState();
}

class _BgimgSelectorState extends ConsumerState<BgimgSelector> {
  static const double _itemHeight = 120.0;
  // Diagonal offset: controls the diagonal angle, smaller value implies larger angle (closer to vertical)
  static const double _diagonalOffset = 32.0; // pixel value

  @override
  void initState() {
    super.initState();
    Prefs().addListener(_onPrefsChanged);
  }

  @override
  void dispose() {
    Prefs().removeListener(_onPrefsChanged);
    super.dispose();
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
  }

  void applyBgimg(BgimgModel bgimgModel, {bool useNight = false}) {
    // Save user's selected mode, preserve existing blur and opacity
    final current = Prefs().bgimg;
    final updatedBgimg = bgimgModel.copyWith(
      selectedMode: useNight ? BgimgThemeMode.night : BgimgThemeMode.day,
      blur: (current.path == bgimgModel.path) ? current.blur : bgimgModel.blur,
      opacity: (current.path == bgimgModel.path)
          ? current.opacity
          : bgimgModel.opacity,
    );
    Prefs().bgimg = updatedBgimg;
    epubPlayerKey.currentState?.changeStyle(null);
  }

  Widget buildImportBgimgItem() {
    return _buildBaseContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
          SizedBox(height: 10),
          Text(L10n.of(context).readingPageStyleImportBackgroundImage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              )),
        ],
      ),
      onTap: () {
        ref.read(bgimgProvider.notifier).importImg();
      },
    );
  }

  Widget buildNoneBgimgItem(BgimgModel bgimgModel) {
    return _buildBaseContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.not_interested,
              color: Theme.of(context).colorScheme.onSurface),
          SizedBox(height: 10),
          Text(L10n.of(context).readingPageStyleNoBackgroundImage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              )),
        ],
      ),
      onTap: () {
        Prefs().bgimg = bgimgModel;
        epubPlayerKey.currentState?.changeStyle(null);
      },
    );
  }

  Widget _buildBaseContainer({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: _itemHeight,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Build the Day/Night split background image item
  Widget _buildDayNightItem({
    required BgimgModel bgimgModel,
    required Widget dayImage,
    required Widget? nightImage,
    bool isLocalFile = false,
    bool isAsset = false,
  }) {
    final hasNightImg = bgimgModel.nightPath != null;
    // Built-in assets do not show the swap button
    final showSwapButton = hasNightImg && isLocalFile;
    // Whether to show the import night image button
    final showImportNightButton = !hasNightImg && isLocalFile;

    Widget itemContent = Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: _itemHeight,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bottom layer: Left side day image (use Positioned to cover left half plus middle)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 0,
                child: ClipPath(
                  clipper: _LeftDiagonalClipper(offset: _diagonalOffset),
                  child: GestureDetector(
                    onTap: () => applyBgimg(bgimgModel, useNight: false),
                    child: dayImage,
                  ),
                ),
              ),
              // Bottom layer: Right side night image or import button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 0,
                child: ClipPath(
                  clipper: _RightDiagonalClipper(offset: _diagonalOffset),
                  child: hasNightImg
                      ? GestureDetector(
                          onTap: () => applyBgimg(bgimgModel, useNight: true),
                          child: nightImage,
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                ),
              ),
              // Middle layer: Diagonal separator
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _DiagonalLinePainter(
                      color:
                          Theme.of(context).colorScheme.onSurface.withAlpha(80),
                      offset: _diagonalOffset,
                    ),
                  ),
                ),
              ),
              // Import night image button (placed on top of the right area)
              if (showImportNightButton)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref
                          .read(bgimgProvider.notifier)
                          .importNightImg(bgimgModel.path);
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: Theme.of(context).colorScheme.onSurface),
                          SizedBox(height: 4),
                          Text(
                            L10n.of(context).readingPageStyleImportNightImage,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Top layer: Labels
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Day label
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(left: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(180),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          L10n.of(context).readingPageStyleDayMode,
                          style: TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                      ),
                      // Night label
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(180),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          L10n.of(context).readingPageStyleNightMode,
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Floating swap button in the middle (only shown for local files with night images)
              if (showSwapButton)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        // Actually swap file contents
                        ref.read(bgimgProvider.notifier).swapBgimg(bgimgModel);

                        // Clear image cache to show new content
                        final bgimgDir = getBgimgDir().path;
                        final dayPath =
                            bgimgDir + Platform.pathSeparator + bgimgModel.path;
                        final nightPath = bgimgDir +
                            Platform.pathSeparator +
                            bgimgModel.nightPath!;

                        await FileImage(File(dayPath)).evict();
                        await FileImage(File(nightPath)).evict();

                        // If this background is currently in use, re-apply to refresh display
                        if (Prefs().bgimg.path == bgimgModel.path) {
                          epubPlayerKey.currentState?.changeStyle(null);
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(220),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.swap_horiz,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Local files support swipe to delete
    if (isLocalFile) {
      final List<Widget> actions = [
        SlidableAction(
          onPressed: (context) {
            ref.read(bgimgProvider.notifier).deleteBgimg(bgimgModel);
          },
          icon: Icons.delete,
          label: L10n.of(context).commonDelete,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ];

      // If there is a night image, add delete night image option
      if (hasNightImg) {
        actions.insert(
          0,
          SlidableAction(
            onPressed: (context) {
              ref.read(bgimgProvider.notifier).removeNightImg(bgimgModel.path);
            },
            icon: Icons.nightlight_outlined,
            label: L10n.of(context).readingPageStyleDeleteNightImage,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        );
      }

      final actionPane = ActionPane(
        motion: const StretchMotion(),
        children: actions,
      );
      return Slidable(
        key: ValueKey(bgimgModel.path),
        startActionPane: actionPane,
        endActionPane: actionPane,
        child: itemContent,
      );
    }

    return itemContent;
  }

  Widget buildAssetBgimgItem(BgimgModel bgimgModel) {
    final dayImage = Image.asset(
      bgimgModel.path,
      fit: BoxFit.cover,
      alignment: bgimgModel.alignment.alignment,
      width: double.infinity,
      height: _itemHeight,
    );

    Widget? nightImage;
    if (bgimgModel.nightPath != null) {
      nightImage = Image.asset(
        bgimgModel.nightPath!,
        fit: BoxFit.cover,
        alignment: bgimgModel.alignment.alignment,
        width: double.infinity,
        height: _itemHeight,
      );
    }

    return _buildDayNightItem(
      bgimgModel: bgimgModel,
      dayImage: dayImage,
      nightImage: nightImage,
      isLocalFile: false,
      isAsset: true,
    );
  }

  Widget buildLocalFileBgimgItem(BgimgModel bgimgModel) {
    // Listen for timestamp changes to force refresh image cache
    final timestamp = ref.watch(bgimgTimestampProvider);

    final bgimgDir = getBgimgDir().path;
    final dayPath = bgimgDir + Platform.pathSeparator + bgimgModel.path;

    final dayImage = Image.file(
      File(dayPath),
      key: ValueKey('${dayPath}_$timestamp'),
      fit: BoxFit.cover,
      alignment: bgimgModel.alignment.alignment,
      width: double.infinity,
      height: _itemHeight,
    );

    Widget? nightImage;
    if (bgimgModel.nightPath != null) {
      final nightPath =
          bgimgDir + Platform.pathSeparator + bgimgModel.nightPath!;
      nightImage = Image.file(
        File(nightPath),
        key: ValueKey('${nightPath}_$timestamp'),
        fit: BoxFit.cover,
        alignment: bgimgModel.alignment.alignment,
        width: double.infinity,
        height: _itemHeight,
      );
    }

    return _buildDayNightItem(
      bgimgModel: bgimgModel,
      dayImage: dayImage,
      nightImage: nightImage,
      isLocalFile: true,
      isAsset: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgimgList = ref.watch(bgimgProvider);
    final currentBgimg = Prefs().bgimg;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          _buildBgimgFitSelector(context),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.builder(
              itemCount: bgimgList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return buildImportBgimgItem();
                }
                final model = bgimgList[index - 1];
                final isSelected = model.type != BgimgType.none &&
                    currentBgimg.type != BgimgType.none &&
                    currentBgimg.path == model.path;
                final item = switch (model.type) {
                  BgimgType.none => buildNoneBgimgItem(model),
                  BgimgType.assets => buildAssetBgimgItem(model),
                  BgimgType.localFile => buildLocalFileBgimgItem(model),
                };
                if (isSelected) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      item,
                      _buildBlurOpacityControls(context),
                    ],
                  );
                }
                return item;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBgimgFitSelector(BuildContext context) {
    final l10n = L10n.of(context);
    final items = [
      SegmentButtonItem<BgimgFitEnum>(
        value: BgimgFitEnum.cover,
        label: l10n.readingPageStyleBgimgFitCover,
      ),
      SegmentButtonItem<BgimgFitEnum>(
        value: BgimgFitEnum.stretch,
        label: l10n.readingPageStyleBgimgFitStretch,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              l10n.readingPageStyleBgimgFit,
              style: TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: AnxSegmentedButton<BgimgFitEnum>(
              segments: items,
              selected: {Prefs().bgimgFit},
              showSelectedIcon: false,
              onSelectionChanged: (value) {
                final fit = value.first;
                Prefs().bgimgFit = fit;
                epubPlayerKey.currentState?.changeBgimgEffect();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurOpacityControls(BuildContext context) {
    final bgimg = Prefs().bgimg;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  L10n.of(context).readingPageStyleBgimgBlur,
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                child: Slider(
                  value: bgimg.blur,
                  min: 0.0,
                  max: 20.0,
                  divisions: 40,
                  label: bgimg.blur.toStringAsFixed(1),
                  onChanged: (value) {
                    Prefs().bgimg = Prefs().bgimg.copyWith(blur: value);
                    epubPlayerKey.currentState?.changeBgimgEffect();
                  },
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  bgimg.blur.toStringAsFixed(1),
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  L10n.of(context).readingPageStyleBgimgOpacity,
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                child: Slider(
                  value: bgimg.opacity,
                  min: 0.1,
                  max: 1.0,
                  divisions: 18,
                  label: '${(bgimg.opacity * 100).round()}%',
                  onChanged: (value) {
                    Prefs().bgimg = Prefs().bgimg.copyWith(opacity: value);
                    epubPlayerKey.currentState?.changeBgimgEffect();
                  },
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${(bgimg.opacity * 100).round()}%',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Left diagonal clipper: Covers left half to the middle diagonal line
class _LeftDiagonalClipper extends CustomClipper<Path> {
  final double offset;

  _LeftDiagonalClipper({required this.offset});

  @override
  Path getClip(Size size) {
    final path = Path();
    // Start from top-left, to top-right-ish middle, to bottom-left-ish middle, to bottom-left
    path.moveTo(0, 0);
    path.lineTo(size.width / 2 + offset, 0);
    path.lineTo(size.width / 2 - offset, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Right diagonal clipper: Covers right half starting from the middle diagonal line
class _RightDiagonalClipper extends CustomClipper<Path> {
  final double offset;

  _RightDiagonalClipper({required this.offset});

  @override
  Path getClip(Size size) {
    final path = Path();
    // Start from top-right-ish middle, to top-right, to bottom-right, to bottom-left-ish middle
    path.moveTo(size.width / 2 + offset, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2 - offset, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Diagonal line painter: Draws the separator line in the middle
class _DiagonalLinePainter extends CustomPainter {
  final Color color;
  final double offset;

  _DiagonalLinePainter({required this.color, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw diagonal line from top-right-ish middle to bottom-left-ish middle
    canvas.drawLine(
      Offset(size.width / 2 + offset, 0),
      Offset(size.width / 2 - offset, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
