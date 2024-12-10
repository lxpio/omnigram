import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/entities/setting.entity.dart';
import 'package:omnigram/providers/tts/extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;

part 'tts.service.g.dart';

abstract class TTS {
  Future<Stream> gen(String content);

  static Future<File> getCacheFile(final String key, final String fileType) async => File(p.joinAll([
        (await getTemporaryDirectory()).path,
        'tts_cache_files',
        '$key.$fileType',
      ]));
}

@Riverpod(keepAlive: true)
class TtsService extends _$TtsService {
  @override
  TTS build() {
    // TODO: implement build
    // final ttsConfig = IsarStore.get(StoreKey.ttsConfig);

    return _init();
  }

  TTS _init() {
    final ttsConfig = IsarStore.get(StoreKey.ttsConfig);

    return ttsConfig.ttsType.getService(ttsConfig);
  }

  void update() {
    state = _init();
  }
}
