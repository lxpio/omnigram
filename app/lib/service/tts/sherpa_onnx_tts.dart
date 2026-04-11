import 'dart:isolate';
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

/// Run TTS generation in a background isolate to avoid blocking the UI.
/// This is a top-level function so it can be used with [Isolate.run].
Uint8List _generateInBackground(Map<String, dynamic> params) {
  final engine = params['engine'] as String;
  final modelPath = params['modelPath'] as String;
  final files = Map<String, String>.from(params['files'] as Map);
  final text = params['text'] as String;
  final sid = params['sid'] as int;
  final speed = params['speed'] as double;

  sherpa.initBindings();

  sherpa.OfflineTtsConfig config;
  if (engine == 'piper') {
    config = sherpa.OfflineTtsConfig(
      model: sherpa.OfflineTtsModelConfig(
        vits: sherpa.OfflineTtsVitsModelConfig(
          model: '$modelPath/${files['model']}',
          tokens: '$modelPath/${files['tokens']}',
          dataDir: '$modelPath/${files['dataDir'] ?? 'espeak-ng-data'}',
        ),
      ),
    );
  } else {
    // kokoro
    final lexiconFiles = (files['lexicon'] ?? '')
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => '$modelPath/${s.trim()}')
        .join(',');
    config = sherpa.OfflineTtsConfig(
      model: sherpa.OfflineTtsModelConfig(
        kokoro: sherpa.OfflineTtsKokoroModelConfig(
          model: '$modelPath/${files['model']}',
          tokens: '$modelPath/${files['tokens']}',
          voices: '$modelPath/${files['voices']}',
          dataDir: '$modelPath/espeak-ng-data',
          dictDir: files['dictDir'] != null ? '$modelPath/${files['dictDir']}' : '',
          lexicon: lexiconFiles,
        ),
      ),
    );
  }

  final tts = sherpa.OfflineTts(config);
  var audio = tts.generate(text: text, sid: sid, speed: speed);

  if (audio.samples.isNotEmpty && _hasNaN(audio.samples) && speed != 1.0) {
    // Kokoro models may produce NaN with non-1.0 speed on some devices.
    // Retry with speed=1.0 as fallback.
    // ignore: avoid_print
    print('[SherpaOnnx] NaN detected at speed=$speed, retrying with speed=1.0');
    audio = tts.generate(text: text, sid: sid, speed: 1.0);
  }

  tts.free();

  if (audio.samples.isEmpty) {
    return Uint8List(0);
  }

  // Log diagnostic info
  final nanCount = audio.samples.where((s) => s.isNaN || s.isInfinite).length;
  // ignore: avoid_print
  print('[SherpaOnnx] samples=${audio.samples.length} sampleRate=${audio.sampleRate} '
      'nanCount=$nanCount speed=$speed sid=$sid');

  if (nanCount > 0 || audio.samples.every((s) => s == 0.0)) {
    final marker = Uint8List(4);
    marker[0] = 78; // N
    marker[1] = 65; // A
    marker[2] = 78; // N
    marker[3] = 83; // S
    return marker;
  }

  return SherpaOnnxProvider._encodeWav(audio.samples, audio.sampleRate);
}

bool _hasNaN(Float32List samples) {
  for (final s in samples) {
    if (s.isNaN || s.isInfinite) return true;
  }
  return false;
}

/// Kokoro speaker names → IDs mapping.
const Map<String, int> _kokoroVoices = {
  'zf_xiaobei (女·中文)': 45,
  'zf_xiaoni (女·中文)': 46,
  'zf_xiaoxiao (女·中文)': 47,
  'zf_xiaoyi (女·中文)': 48,
  'zm_yunjian (男·中文)': 49,
  'zm_yunxi (男·中文)': 50,
  'zm_yunxia (男·中文)': 51,
  'zm_yunyang (男·中文)': 52,
  'af_alloy (Female·EN)': 0,
  'af_heart (Female·EN)': 3,
  'af_nova (Female·EN)': 7,
  'af_sarah (Female·EN)': 9,
  'am_adam (Male·EN)': 11,
  'am_michael (Male·EN)': 16,
  'am_onyx (Male·EN)': 17,
  'jf_alpha (女·日本語)': 37,
  'jm_kumo (男·日本語)': 41,
  'ff_siwis (Femme·FR)': 30,
};

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
  String? _loadedModelPath;
  TtsModel? _loadedModel;
  bool _bindingsInitialized = false;

  @override
  TtsService get service => TtsService.sherpaOnnx;

  @override
  String get audioMimeType => 'audio/wav';

  @override
  String getLabel(BuildContext context) => 'On-Device (sherpa-onnx)';

  @override
  List<ConfigItem> getConfigItems(BuildContext context) {
    final modelOptions = builtInModels.map((m) {
      return {
        'label': '${m.name} (${m.sizeDisplay})',
        'value': m.id,
      };
    }).toList();

    // Build voice options from Kokoro voice map
    final voiceOptions = _kokoroVoices.entries.map((e) {
      return {'label': e.key, 'value': e.value.toString()};
    }).toList();

    return [
      ConfigItem(
        key: 'model_id',
        label: 'Model',
        description: 'Select a model, then download it below',
        type: ConfigItemType.select,
        defaultValue: builtInModels.first.id,
        options: modelOptions,
      ),
      ConfigItem(
        key: 'speaker_id',
        label: 'Voice',
        description: 'Speaker voice (Kokoro multi-speaker; Piper ignores this)',
        type: ConfigItemType.select,
        defaultValue: '50', // zm_yunxi – good default for Chinese
        options: voiceOptions,
      ),
    ];
  }

  @override
  Map<String, dynamic> getConfig() {
    final config = Prefs().getOnlineTtsConfig(serviceId);
    return {'model_id': config['model_id'] ?? '', 'speaker_id': config['speaker_id'] ?? '50'};
  }

  @override
  void saveConfig(Map<String, dynamic> config) {
    Prefs().saveOnlineTtsConfig(serviceId, config);
  }

  /// Load (or reload) the sherpa-onnx model from the local file system.
  Future<void> _ensureModel(String modelId) async {
    if (_tts != null && _loadedModelId == modelId) return;

    // Initialize native bindings once
    if (!_bindingsInitialized) {
      sherpa.initBindings();
      _bindingsInitialized = true;
    }

    // Dispose previous model
    _tts?.free();
    _tts = null;
    _loadedModelId = null;
    _loadedModelPath = null;
    _loadedModel = null;

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
            dataDir: '$modelPath/espeak-ng-data',
            dictDir: model.files['dictDir'] != null ? '$modelPath/${model.files['dictDir']}' : '',
            lexicon: lexiconFiles,
          ),
        ),
      );
    } else {
      throw Exception('Unsupported engine: ${model.engine}');
    }

    AnxLog.info('SherpaOnnx: creating OfflineTts with config: ${config.model}');
    _tts = sherpa.OfflineTts(config);
    _loadedModelId = modelId;
    _loadedModelPath = modelPath;
    _loadedModel = model;
    AnxLog.info('SherpaOnnx: loaded model $modelId (sampleRate=${_tts!.sampleRate}, numSpeakers=${_tts!.numSpeakers})');
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

    AnxLog.info('SherpaOnnx: generating audio in background isolate (text=${text.length} chars, sid=$speakerId)');

    // Run the blocking FFI generate() call in a background isolate
    // so the UI thread stays responsive.
    final wav = await Isolate.run(() => _generateInBackground({
      'engine': _loadedModel!.engine,
      'modelPath': _loadedModelPath!,
      'files': _loadedModel!.files,
      'text': text,
      'sid': speakerId,
      'speed': rate,
    }));

    if (wav.isEmpty) {
      throw Exception('TTS generated empty audio');
    }

    // Detect NaN marker from isolate (model produces invalid samples on this device)
    if (wav.length == 4 && wav[0] == 78 && wav[1] == 65 && wav[2] == 78 && wav[3] == 83) {
      AnxLog.severe('SherpaOnnx: model produced NaN/zero samples – model may be incompatible with this device');
      throw Exception('Model produced invalid audio. Try re-downloading the model, or switch to a different model (e.g. Piper).');
    }

    AnxLog.info('SherpaOnnx: generated ${wav.length} bytes WAV');
    return wav;
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

    // PCM data (float32 → int16), guard against NaN/Infinity
    for (var i = 0; i < samples.length; i++) {
      final sample = samples[i];
      int s;
      if (sample.isNaN || sample.isInfinite) {
        s = 0;
      } else {
        s = (sample * 32767).round().clamp(-32768, 32767);
      }
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
    _loadedModelPath = null;
    _loadedModel = null;
  }
}
