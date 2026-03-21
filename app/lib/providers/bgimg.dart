import 'dart:io';

import 'package:omnigram/enums/bgimg_alignment.dart';
import 'package:omnigram/enums/bgimg_type.dart';
import 'package:omnigram/models/bgimg.dart';
import 'package:omnigram/utils/get_path/get_base_path.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bgimg.g.dart';

final bgimgTimestampProvider =
    StateProvider<int>((ref) => DateTime.now().millisecondsSinceEpoch);

@Riverpod(keepAlive: true)
class Bgimg extends _$Bgimg {
  static const assetsImgPrefix = 'assets/images/bgimg/';

  @override
  List<BgimgModel> build() {
    final localImg = listLocal();

    return [
      BgimgModel(
          type: BgimgType.none, path: 'none', alignment: BgimgAlignment.center),
      ...localImg,
      // Built-in assets pairing: bg1+bg6, bg2+bg5, bg3+bg4
      BgimgModel(
          type: BgimgType.assets,
          path: '${assetsImgPrefix}bg1.jpg',
          nightPath: '${assetsImgPrefix}bg6.jpg',
          alignment: BgimgAlignment.bottom),
      BgimgModel(
          type: BgimgType.assets,
          path: '${assetsImgPrefix}bg2.jpg',
          nightPath: '${assetsImgPrefix}bg5.jpg',
          alignment: BgimgAlignment.center),
      BgimgModel(
          type: BgimgType.assets,
          path: '${assetsImgPrefix}bg3.jpg',
          nightPath: '${assetsImgPrefix}bg4.jpg',
          alignment: BgimgAlignment.center),
    ];
  }

  List<BgimgModel> listLocal() {
    final bgimgDir = getBgimgDir();
    if (!bgimgDir.existsSync()) {
      return [];
    }

    final files = bgimgDir.listSync().whereType<File>().toList();
    final fileNames =
        files.map((e) => e.path.split(Platform.pathSeparator).last).toList();

    // Filter out images with _night suffix, they will be used as paired images
    final dayImages = fileNames.where((name) => !_isNightImage(name)).toList();

    return dayImages.map((dayName) {
      final nightName = _getNightImageName(dayName);
      final hasNight = fileNames.contains(nightName);

      return BgimgModel(
        type: BgimgType.localFile,
        path: dayName,
        nightPath: hasNight ? nightName : null,
        alignment: BgimgAlignment.center,
      );
    }).toList();
  }

  /// Check if it is a night image (with _night suffix)
  bool _isNightImage(String fileName) {
    final nameWithoutExt = fileName.split('.').first;
    return nameWithoutExt.endsWith('_night');
  }

  /// Generate corresponding night image name based on day image name
  String _getNightImageName(String dayName) {
    final parts = dayName.split('.');
    if (parts.length < 2) return '${dayName}_night';
    final ext = parts.last;
    final nameWithoutExt = parts.sublist(0, parts.length - 1).join('.');
    return '${nameWithoutExt}_night.$ext';
  }

  void deleteBgimg(BgimgModel bgimgModel) {
    final bgimgDir = getBgimgDir();
    final path = bgimgDir.path + Platform.pathSeparator + bgimgModel.path;
    if (File(path).existsSync()) {
      File(path).deleteSync();
    }
    // Also delete night image
    if (bgimgModel.nightPath != null) {
      final nightPath =
          bgimgDir.path + Platform.pathSeparator + bgimgModel.nightPath!;
      if (File(nightPath).existsSync()) {
        File(nightPath).deleteSync();
      }
    }
    ref.invalidateSelf();
  }

  /// Import day image
  Future<void> importImg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null) {
      return;
    }

    File image = File(result.files.single.path!);

    AnxLog.info('BookDetail: Image path: ${image.path}');

    final extName = image.path.split('.').last;
    final newName = '${DateTime.now().millisecondsSinceEpoch}.$extName';
    final newPath = '${getBgimgDir().path}${Platform.pathSeparator}$newName';

    await image.copy(newPath);
    ref.invalidateSelf();
  }

  /// Import night version for specified day image
  Future<void> importNightImg(String dayImagePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null) {
      return;
    }

    File image = File(result.files.single.path!);
    AnxLog.info('Bgimg: Import night image for $dayImagePath');

    final nightName = _getNightImageName(dayImagePath);
    final newPath = '${getBgimgDir().path}${Platform.pathSeparator}$nightName';

    await image.copy(newPath);
    ref.invalidateSelf();
  }

  /// Delete night version of specified day image
  void removeNightImg(String dayImagePath) {
    final nightName = _getNightImageName(dayImagePath);
    final nightPath =
        '${getBgimgDir().path}${Platform.pathSeparator}$nightName';
    if (File(nightPath).existsSync()) {
      File(nightPath).deleteSync();
      ref.invalidateSelf();
    }
  }

  /// Swap day and night images (by renaming files)
  void swapBgimg(BgimgModel bgimgModel) {
    if (bgimgModel.nightPath == null) return;

    final bgimgDir = getBgimgDir().path;
    final dayPath = bgimgDir + Platform.pathSeparator + bgimgModel.path;
    final nightPath = bgimgDir + Platform.pathSeparator + bgimgModel.nightPath!;

    final dayFile = File(dayPath);
    final nightFile = File(nightPath);

    if (dayFile.existsSync() && nightFile.existsSync()) {
      final tempPath = '$dayPath.temp';
      dayFile.renameSync(tempPath);
      nightFile.renameSync(dayPath);
      File(tempPath).renameSync(nightPath);

      ref.read(bgimgTimestampProvider.notifier).state =
          DateTime.now().millisecondsSinceEpoch;
      ref.invalidateSelf();
    }
  }
}
