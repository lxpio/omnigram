import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/entities/setting.entity.dart';
import 'package:omnigram/providers/tts/extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;

part 'tts.service.g.dart';

abstract class TTS {
  bool _downloading = false;

  // final String cacheDir;

  Future<Stream> gen(String content);

  static Future<Directory> getCacheDir() async =>
      Directory(p.join((await getTemporaryDirectory()).path, 'tts_audio_cache'));

  static Future<File> _getCacheFile(final String key, final String fileType) async => File(p.joinAll([
        (await TTS.getCacheDir()).path,
        '$key.$fileType',
      ]));

  Future<String> saveToFile(String key, String fileType, String content) async {
    if (_downloading) {
      throw Exception("Cannot download while download is in progress");
    }

    _downloading = true;

    final file = await TTS._getCacheFile(key, fileType);
    if (file.existsSync()) {
      return file.path;
    }

    try {
      final stream = await gen(content);

      final IOSink sink = file.openWrite();

      await stream.pipe(sink);

      await sink.close();
      // await stream.forEach((element) {
      //   sink.add(element);
      // });

      return file.path;
    } catch (e) {
      //clear file
      if (file.existsSync()) {
        file.deleteSync();
      }
      rethrow;
    } finally {
      _downloading = false;
    }
  }

  // static Future<void> clearAssetCache() async {
  //   if (kIsWeb) return;
  //   await for (var file in (await _getCacheDir()).list()) {
  //     await file.delete(recursive: true);
  //   }
  // }

  // clean cache
  Future<void> clearCache() async {
    if (kIsWeb) return;

    if (_downloading) {
      throw Exception("Cannot clear cache while download is in progress");
    }

    await for (var file in (await getCacheDir()).list()) {
      await file.delete(recursive: true);
    }
  }
}

@Riverpod(keepAlive: true)
TTS ttsService(TtsServiceRef ref) {
  final ttsConfig = ref.watch(ttsConfigProvider);
  return ttsConfig.ttsType.getService(ttsConfig);
}

@Riverpod(keepAlive: true)
class TtsConfig extends _$TtsConfig {
  @override
  TTSConfig build() {
    // TODO: implement build
    final ttsConfig = IsarStore.get(
        StoreKey.ttsConfig, TTSConfig(enabled: false, ttsType: TTSServiceEnum.fishtts, endpoint: '', accessToken: ''));

    return ttsConfig;
  }

  void update(TTSConfig ttsConfig) {
    IsarStore.put(StoreKey.ttsConfig, ttsConfig);

    state = ttsConfig;
  }
}
