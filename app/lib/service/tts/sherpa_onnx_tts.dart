import 'dart:typed_data';

import 'package:omnigram/service/tts/model_manager.dart';
import 'package:omnigram/service/tts/models/tts_voice.dart';
import 'package:omnigram/service/tts/tts_model.dart';
import 'package:omnigram/service/tts/tts_service.dart';
import 'package:omnigram/service/tts/tts_service_provider.dart';
import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:flutter/widgets.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// On-device TTS provider using sherpa-onnx (Piper / Kokoro models).
///
/// The user downloads a model via [TtsModelManager], then selects it here.
/// Audio is synthesised locally — no network required after model download.
class SherpaOnnxProvider extends TtsServiceProvider {
  static final SherpaOnnxProvider _instance = SherpaOnnxProvider._();

  factory SherpaOnnxProvider() => _instance;

  SherpaOnnxProvider._();

  sherpa.OfflineTts? _tts;
  String? _loadedModelId;

  @override
  TtsService get service => TtsService.sherpaOnnx;

  @override
  String getLabel(BuildContext context) => 'On-Device (sherpa-onnx)';

  @override
  List<ConfigItem> getConfigItems(BuildContext context) {
    return [
      ConfigItem(
        key: 'model_id',
        label: 'Model',
        description: 'Select a downloaded model',
        type: ConfigItemType.text,
        defaultValue: '',
      ),
      ConfigItem(
        key: 'speaker_id',
        label: 'Speaker ID',
        description: 'Speaker index (for multi-speaker models)',
        type: ConfigItemType.text,
        defaultValue: '0',
      ),
    ];
  }

  @override
  Map<String, dynamic> getConfig() {
    final config = Prefs().getOnlineTtsConfig(serviceId);
    return {'model_id': config['model_id'] ?? '', 'speaker_id': config['speaker_id'] ?? '0'};
  }

  @override
  void saveConfig(Map<String, dynamic> config) {
    Prefs().saveOnlineTtsConfig(serviceId, config);
  }

  /// Load (or reload) the sherpa-onnx model from the local file system.
  Future<void> _ensureModel(String modelId) async {
    if (_tts != null && _loadedModelId == modelId) return;

    // Dispose previous model
    _tts?.free();
    _tts = null;
    _loadedModelId = null;

    final modelPath = await TtsModelManager().getModelPath(modelId);
    if (modelPath == null) {
      throw Exception('Model "$modelId" not downloaded');
    }

    final model = builtInModels.firstWhere(
      (m) => m.id == modelId,
      orElse: () => throw Exception('Unknown model: $modelId'),
    );

    sherpa.OfflineTtsConfig config;

    if (model.engine == 'piper') {
      config = sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          vits: sherpa.OfflineTtsVitsModelConfig(
            model: '$modelPath/${model.files['model']}',
            tokens: '$modelPath/${model.files['tokens']}',
            dataDir: '$modelPath/${model.files['dataDir'] ?? 'espeak-ng-data'}',
          ),
        ),
      );
    } else if (model.engine == 'kokoro') {
      // Build comma-separated lexicon paths (relative filenames → absolute)
      final lexiconFiles = (model.files['lexicon'] ?? '')
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => '$modelPath/${s.trim()}')
          .join(',');

      config = sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          kokoro: sherpa.OfflineTtsKokoroModelConfig(
            model: '$modelPath/${model.files['model']}',
            tokens: '$modelPath/${model.files['tokens']}',
            voices: '$modelPath/${model.files['voices']}',
            dictDir: model.files['dictDir'] != null ? '$modelPath/${model.files['dictDir']}' : '',
            lexicon: lexiconFiles,
          ),
        ),
      );
    } else {
      throw Exception('Unsupported engine: ${model.engine}');
    }

    _tts = sherpa.OfflineTts(config);
    _loadedModelId = modelId;
    AnxLog.info('SherpaOnnx: loaded model $modelId');
  }

  @override
  Future<Uint8List> speak(String text, String? voice, double rate, double pitch) async {
    final config = getConfig();
    final modelId = config['model_id']?.toString() ?? '';
    if (modelId.isEmpty) {
      throw Exception('No model selected – download one in Settings → TTS');
    }

    final speakerId = int.tryParse(config['speaker_id']?.toString() ?? '0') ?? 0;

    await _ensureModel(modelId);

    final audio = _tts!.generate(text: text, sid: speakerId, speed: rate);

    // sherpa-onnx returns raw PCM samples (Float32). Encode as WAV.
    return _encodeWav(audio.samples, audio.sampleRate);
  }

  /// Encode raw PCM float samples into a WAV byte array.
  static Uint8List _encodeWav(Float32List samples, int sampleRate) {
    final numChannels = 1;
    final bitsPerSample = 16;
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = samples.length * blockAlign;
    final fileSize = 36 + dataSize;

    final buffer = ByteData(44 + dataSize);
    var offset = 0;

    // RIFF header
    void writeString(String s) {
      for (var i = 0; i < s.length; i++) {
        buffer.setUint8(offset++, s.codeUnitAt(i));
      }
    }

    writeString('RIFF');
    buffer.setUint32(offset, fileSize, Endian.little);
    offset += 4;
    writeString('WAVE');

    // fmt sub-chunk
    writeString('fmt ');
    buffer.setUint32(offset, 16, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // PCM
    offset += 2;
    buffer.setUint16(offset, numChannels, Endian.little);
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    buffer.setUint16(offset, blockAlign, Endian.little);
    offset += 2;
    buffer.setUint16(offset, bitsPerSample, Endian.little);
    offset += 2;

    // data sub-chunk
    writeString('data');
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // PCM data (float32 → int16)
    for (var i = 0; i < samples.length; i++) {
      var s = (samples[i] * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(offset, s, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  @override
  Future<List<TtsVoice>> getVoices() async {
    // Return voices from all downloaded models
    final downloaded = await TtsModelManager().getDownloadedModels();
    final voices = <TtsVoice>[];

    for (final modelId in downloaded) {
      final model = builtInModels.where((m) => m.id == modelId).firstOrNull;
      if (model != null) {
        voices.add(
          TtsVoice(shortName: model.id, name: '${model.name} (${model.engine})', locale: model.language, gender: ''),
        );
      }
    }

    // Also list not-yet-downloaded models for discovery
    for (final model in builtInModels) {
      if (!downloaded.contains(model.id)) {
        voices.add(TtsVoice(shortName: model.id, name: '${model.name} ⬇️', locale: model.language, gender: ''));
      }
    }

    return voices;
  }

  @override
  TtsVoice convertVoiceModel(dynamic voiceData) {
    if (voiceData is TtsVoice) return voiceData;
    if (voiceData is Map<String, dynamic>) {
      return TtsVoice.fromMap(voiceData);
    }
    return const TtsVoice(shortName: '', name: '', locale: '');
  }

  /// Release native resources.
  void dispose() {
    _tts?.free();
    _tts = null;
    _loadedModelId = null;
  }
}
