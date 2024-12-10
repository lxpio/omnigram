import 'package:omnigram/entities/setting.entity.dart';
import 'package:omnigram/providers/tts/tts.service.dart';

import 'fishtts.service.dart';

extension TTSServiceEnumHelper on TTSServiceEnum {
  TTS getService(TTSConfig config) {
    switch (this) {
      case TTSServiceEnum.fishtts:
        return FishTTSService(config);
      default:
        throw UnimplementedError('Not implemented');
    }
  }
}
