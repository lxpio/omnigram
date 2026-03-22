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
  });
}

const String _ghBase = 'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models';
const String _mirrorBase = 'https://hf-mirror.com/csukuangfj/sherpa-onnx-models/resolve/main';
const String _hfBase = 'https://huggingface.co/csukuangfj/sherpa-onnx-models/resolve/main';

/// Built-in curated model list.
/// Phase 2 focuses on Piper + Kokoro models compatible with sherpa-onnx.
const List<TtsModel> builtInModels = [
  // ---------------------------------------------------------------------------
  // Piper models (small, fast, real-time)
  // ---------------------------------------------------------------------------
  TtsModel(
    id: 'piper-en-us-amy-medium',
    name: 'Amy',
    engine: 'piper',
    language: 'en-US',
    sizeBytes: 63 * 1024 * 1024,
    description: 'English (US) female voice – medium quality',
    downloadUrls: [
      '$_ghBase/vits-piper-en_US-amy-medium.tar.bz2',
      '$_mirrorBase/vits-piper-en_US-amy-medium.tar.bz2',
      '$_hfBase/vits-piper-en_US-amy-medium.tar.bz2',
    ],
    sha256: 'placeholder',
    files: {'model': 'en_US-amy-medium.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),
  TtsModel(
    id: 'piper-en-us-lessac-medium',
    name: 'Lessac',
    engine: 'piper',
    language: 'en-US',
    sizeBytes: 63 * 1024 * 1024,
    description: 'English (US) male voice – medium quality',
    downloadUrls: [
      '$_ghBase/vits-piper-en_US-lessac-medium.tar.bz2',
      '$_mirrorBase/vits-piper-en_US-lessac-medium.tar.bz2',
      '$_hfBase/vits-piper-en_US-lessac-medium.tar.bz2',
    ],
    sha256: 'placeholder',
    files: {'model': 'en_US-lessac-medium.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),
  TtsModel(
    id: 'piper-zh-cn-huayan-medium',
    name: 'Huayan (花妍)',
    engine: 'piper',
    language: 'zh-CN',
    sizeBytes: 63 * 1024 * 1024,
    description: 'Chinese (Mandarin) female voice – medium quality',
    downloadUrls: [
      '$_ghBase/vits-piper-zh_CN-huayan-medium.tar.bz2',
      '$_mirrorBase/vits-piper-zh_CN-huayan-medium.tar.bz2',
      '$_hfBase/vits-piper-zh_CN-huayan-medium.tar.bz2',
    ],
    sha256: 'placeholder',
    files: {'model': 'zh_CN-huayan-medium.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),
  TtsModel(
    id: 'piper-de-de-thorsten-medium',
    name: 'Thorsten',
    engine: 'piper',
    language: 'de-DE',
    sizeBytes: 63 * 1024 * 1024,
    description: 'German male voice – medium quality',
    downloadUrls: [
      '$_ghBase/vits-piper-de_DE-thorsten-medium.tar.bz2',
      '$_mirrorBase/vits-piper-de_DE-thorsten-medium.tar.bz2',
      '$_hfBase/vits-piper-de_DE-thorsten-medium.tar.bz2',
    ],
    sha256: 'placeholder',
    files: {'model': 'de_DE-thorsten-medium.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),
  TtsModel(
    id: 'piper-fr-fr-siwis-medium',
    name: 'Siwis',
    engine: 'piper',
    language: 'fr-FR',
    sizeBytes: 63 * 1024 * 1024,
    description: 'French female voice – medium quality',
    downloadUrls: [
      '$_ghBase/vits-piper-fr_FR-siwis-medium.tar.bz2',
      '$_mirrorBase/vits-piper-fr_FR-siwis-medium.tar.bz2',
      '$_hfBase/vits-piper-fr_FR-siwis-medium.tar.bz2',
    ],
    sha256: 'placeholder',
    files: {'model': 'fr_FR-siwis-medium.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),
  TtsModel(
    id: 'piper-ja-jp-kokoro-medium',
    name: 'Kokoro (JA)',
    engine: 'piper',
    language: 'ja-JP',
    sizeBytes: 63 * 1024 * 1024,
    description: 'Japanese female voice – medium quality',
    downloadUrls: [
      '$_ghBase/vits-piper-ja_JP-kokoro-medium.tar.bz2',
      '$_mirrorBase/vits-piper-ja_JP-kokoro-medium.tar.bz2',
      '$_hfBase/vits-piper-ja_JP-kokoro-medium.tar.bz2',
    ],
    sha256: 'placeholder',
    files: {'model': 'ja_JP-kokoro-medium.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),
  TtsModel(
    id: 'piper-es-es-carlfm-medium',
    name: 'Carlfm',
    engine: 'piper',
    language: 'es-ES',
    sizeBytes: 63 * 1024 * 1024,
    description: 'Spanish male voice – medium quality',
    downloadUrls: [
      '$_ghBase/vits-piper-es_ES-carlfm-medium.tar.bz2',
      '$_mirrorBase/vits-piper-es_ES-carlfm-medium.tar.bz2',
      '$_hfBase/vits-piper-es_ES-carlfm-medium.tar.bz2',
    ],
    sha256: 'placeholder',
    files: {'model': 'es_ES-carlfm-medium.onnx', 'tokens': 'tokens.txt', 'dataDir': 'espeak-ng-data'},
  ),

  // ---------------------------------------------------------------------------
  // Kokoro models (high quality, larger)
  // ---------------------------------------------------------------------------
  TtsModel(
    id: 'kokoro-v1-q8',
    name: 'Kokoro v1 (Q8)',
    engine: 'kokoro',
    language: 'multi',
    sizeBytes: 80 * 1024 * 1024,
    description: 'Multi-language high-quality voice – quantised int8',
    downloadUrls: [
      '$_ghBase/kokoro-v1-q8.tar.bz2',
      '$_mirrorBase/kokoro-v1-q8.tar.bz2',
      '$_hfBase/kokoro-v1-q8.tar.bz2',
    ],
    sha256: 'placeholder',
    files: {'model': 'model.onnx', 'tokens': 'tokens.txt', 'voices': 'voices.bin'},
  ),
  TtsModel(
    id: 'kokoro-v1-fp16',
    name: 'Kokoro v1 (FP16)',
    engine: 'kokoro',
    language: 'multi',
    sizeBytes: 300 * 1024 * 1024,
    description: 'Multi-language high-quality voice – float16',
    downloadUrls: [
      '$_ghBase/kokoro-v1-fp16.tar.bz2',
      '$_mirrorBase/kokoro-v1-fp16.tar.bz2',
      '$_hfBase/kokoro-v1-fp16.tar.bz2',
    ],
    sha256: 'placeholder',
    files: {'model': 'model.onnx', 'tokens': 'tokens.txt', 'voices': 'voices.bin'},
  ),
];
