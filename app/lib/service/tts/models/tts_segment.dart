import 'dart:typed_data';

import 'package:omnigram/service/tts/models/tts_sentence.dart';

class TtsSegment {
  TtsSegment({required this.sentence});

  final TtsSentence sentence;
  Uint8List? audio;
  bool isSilent = false;
  int fetchVersion =
      0; // Version to track if audio was fetched with current settings

  bool get isReady => isSilent || (audio != null && audio!.isNotEmpty);
}
