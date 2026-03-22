/// Represents a downloadable TTS model (for sherpa-onnx integration).
class TtsModel {
  final String id;
  final String name;
  final String engine;
  final String language;
  final int sizeBytes;
  final String description;
  final List<String> downloadUrls;
  final String sha256;
  final Map<String, String> files;
  /// Top-level directory name inside the tar.bz2 archive.
  final String archiveDir;

  /// Human-readable size string, e.g. "15 MB", "1.2 GB".
  String get sizeDisplay {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(sizeBytes / (1024 * 1024)).round()} MB';
  }

  const TtsModel({
    required this.id,
    required this.name,
    required this.engine,
    required this.language,
    required this.sizeBytes,
    this.description = '',
    this.downloadUrls = const [],
    this.sha256 = '',
    this.files = const {},
    this.archiveDir = '',
  });
}

const String _ghBase = 'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models';
const String _mirrorBase = 'https://hf-mirror.com/csukuangfj/sherpa-onnx-models/resolve/main';
const String _hfBase = 'https://huggingface.co/csukuangfj/sherpa-onnx-models/resolve/main';

/// Built-in curated model list.
/// Uses int8 quantised models for mobile (smaller download, faster inference).
const List<TtsModel> builtInModels = [
  // ---------------------------------------------------------------------------
  // Piper models (int8 quantised, ~20 MB, real-time on mobile)
  // ---------------------------------------------------------------------------
  TtsModel(
    id: 'piper-en-us-amy-low-int8',
    name: 'Amy (EN)',
    engine: 'piper',
    language: 'en-US',
    sizeBytes: 20 * 1024 * 1024,
    description: 'English (US) female – compact int8',
    archiveDir: 'vits-piper-en_US-amy-low-int8',
    downloadUrls: [
      '$_ghBase/vits-piper-en_US-amy-low-int8.tar.bz2',
      '$_mirrorBase/vits-piper-en_US-amy-low-int8.tar.bz2',
      '$_hfBase/vits-piper-en_US-amy-low-int8.tar.bz2',
    ],
    files: {'model': 'en_US-amy-low.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),
  TtsModel(
    id: 'piper-en-us-lessac-medium',
    name: 'Lessac (EN)',
    engine: 'piper',
    language: 'en-US',
    sizeBytes: 64 * 1024 * 1024,
    description: 'English (US) male – medium quality',
    archiveDir: 'vits-piper-en_US-lessac-medium',
    downloadUrls: [
      '$_ghBase/vits-piper-en_US-lessac-medium.tar.bz2',
      '$_mirrorBase/vits-piper-en_US-lessac-medium.tar.bz2',
      '$_hfBase/vits-piper-en_US-lessac-medium.tar.bz2',
    ],
    files: {'model': 'en_US-lessac-medium.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),
  TtsModel(
    id: 'piper-zh-cn-huayan-medium',
    name: 'Huayan 花妍 (ZH)',
    engine: 'piper',
    language: 'zh-CN',
    sizeBytes: 64 * 1024 * 1024,
    description: 'Chinese (Mandarin) female – medium quality',
    archiveDir: 'vits-piper-zh_CN-huayan-medium',
    downloadUrls: [
      '$_ghBase/vits-piper-zh_CN-huayan-medium.tar.bz2',
      '$_mirrorBase/vits-piper-zh_CN-huayan-medium.tar.bz2',
      '$_hfBase/vits-piper-zh_CN-huayan-medium.tar.bz2',
    ],
    files: {'model': 'zh_CN-huayan-medium.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),

  // ---------------------------------------------------------------------------
  // Kokoro models (high quality, multi-language)
  // ---------------------------------------------------------------------------
  TtsModel(
    id: 'kokoro-int8-multi-lang-v1_0',
    name: 'Kokoro v1.0 (Multi-lang, INT8)',
    engine: 'kokoro',
    language: 'multi',
    sizeBytes: 126 * 1024 * 1024,
    description: 'Multi-language high-quality – quantised int8 (EN/ZH/JA/KO/FR/DE/ES)',
    archiveDir: 'kokoro-int8-multi-lang-v1_0',
    downloadUrls: [
      '$_ghBase/kokoro-int8-multi-lang-v1_0.tar.bz2',
      '$_mirrorBase/kokoro-int8-multi-lang-v1_0.tar.bz2',
      '$_hfBase/kokoro-int8-multi-lang-v1_0.tar.bz2',
    ],
    files: {
      'model': 'model.int8.onnx',
      'tokens': 'tokens.txt',
      'voices': 'voices.bin',
      'dictDir': 'dict',
      'lexicon': 'lexicon-us-en.txt,lexicon-zh.txt',
    },
  ),
  TtsModel(
    id: 'kokoro-multi-lang-v1_0',
    name: 'Kokoro v1.0 (Multi-lang, FP32)',
    engine: 'kokoro',
    language: 'multi',
    sizeBytes: 333 * 1024 * 1024,
    description: 'Multi-language highest quality – full precision (EN/ZH/JA/KO/FR/DE/ES)',
    archiveDir: 'kokoro-multi-lang-v1_0',
    downloadUrls: [
      '$_ghBase/kokoro-multi-lang-v1_0.tar.bz2',
      '$_mirrorBase/kokoro-multi-lang-v1_0.tar.bz2',
      '$_hfBase/kokoro-multi-lang-v1_0.tar.bz2',
    ],
    files: {
      'model': 'model.onnx',
      'tokens': 'tokens.txt',
      'voices': 'voices.bin',
      'dictDir': 'dict',
      'lexicon': 'lexicon-us-en.txt,lexicon-zh.txt',
    },
  ),
];
