import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'tts_model.dart';

enum ModelStatus { notDownloaded, downloading, downloaded, failed }

class ModelDownloadProgress {
  final String modelId;
  final int downloadedBytes;
  final int totalBytes;
  final ModelStatus status;
  final String? error;

  double get progress => totalBytes > 0 ? downloadedBytes / totalBytes : 0;

  const ModelDownloadProgress({
    required this.modelId,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.status = ModelStatus.notDownloaded,
    this.error,
  });
}

class TtsModelManager {
  static final TtsModelManager _instance = TtsModelManager._();
  factory TtsModelManager() => _instance;
  TtsModelManager._();

  final _progressController = StreamController<ModelDownloadProgress>.broadcast();

  /// Stream of download progress updates for the UI.
  Stream<ModelDownloadProgress> get progressStream => _progressController.stream;

  /// Cancellation flags keyed by model ID.
  final Map<String, bool> _cancelFlags = {};

  /// Active download clients keyed by model ID (for cancellation).
  final Map<String, http.Client> _activeClients = {};

  // ---------------------------------------------------------------------------
  // Storage helpers
  // ---------------------------------------------------------------------------

  /// Local storage directory for downloaded models.
  Future<Directory> get _modelsDir async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory('${appDir.path}/tts_models');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  File _completeMarker(Directory modelDir) => File('${modelDir.path}/.complete');

  // ---------------------------------------------------------------------------
  // Status queries
  // ---------------------------------------------------------------------------

  /// Check whether a model has been downloaded.
  Future<ModelStatus> getModelStatus(String modelId) async {
    final dir = Directory('${(await _modelsDir).path}/$modelId');
    if (!await dir.exists()) return ModelStatus.notDownloaded;
    if (await _completeMarker(dir).exists()) return ModelStatus.downloaded;
    return ModelStatus.notDownloaded;
  }

  /// Return all model IDs that are fully downloaded.
  Future<List<String>> getDownloadedModels() async {
    final base = await _modelsDir;
    if (!await base.exists()) return [];
    final result = <String>[];
    await for (final entity in base.list()) {
      if (entity is Directory) {
        final id = entity.path.split(Platform.pathSeparator).last;
        if (await _completeMarker(entity).exists()) {
          result.add(id);
        }
      }
    }
    return result;
  }

  /// Local path to a downloaded model's directory, or `null` if not available.
  Future<String?> getModelPath(String modelId) async {
    final dir = Directory('${(await _modelsDir).path}/$modelId');
    if (await _completeMarker(dir).exists()) return dir.path;
    return null;
  }

  /// Total bytes consumed by all downloaded models.
  Future<int> getTotalDownloadedSize() async {
    final base = await _modelsDir;
    if (!await base.exists()) return 0;
    var total = 0;
    await for (final entity in base.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  // ---------------------------------------------------------------------------
  // Download
  // ---------------------------------------------------------------------------

  /// Download [model] with progress reporting.
  ///
  /// Tries each URL in [TtsModel.downloadUrls] in order until one succeeds.
  /// Supports HTTP Range headers for resuming partial downloads.
  Future<void> downloadModel(TtsModel model) async {
    if (_cancelFlags.containsKey(model.id)) return; // already in progress

    final dir = Directory('${(await _modelsDir).path}/${model.id}');
    if (!await dir.exists()) await dir.create(recursive: true);

    _cancelFlags[model.id] = false;
    _emit(model.id, ModelStatus.downloading);

    final tempFile = File('${dir.path}/_download.tmp');
    var downloadedBytes = 0;
    if (await tempFile.exists()) {
      downloadedBytes = await tempFile.length();
    }

    String? lastError;

    for (final url in model.downloadUrls) {
      if (_isCancelled(model.id)) break;

      final client = http.Client();
      _activeClients[model.id] = client;

      try {
        final request = http.Request('GET', Uri.parse(url));
        if (downloadedBytes > 0) {
          request.headers['Range'] = 'bytes=$downloadedBytes-';
        }

        final response = await client.send(request);

        if (response.statusCode != 200 && response.statusCode != 206) {
          lastError = 'HTTP ${response.statusCode} from $url';
          client.close();
          continue; // try next mirror
        }

        final totalBytes = response.statusCode == 206
            ? downloadedBytes + response.contentLength!
            : (response.contentLength ?? model.sizeBytes);

        final sink = tempFile.openWrite(
          mode: downloadedBytes > 0 && response.statusCode == 206 ? FileMode.append : FileMode.write,
        );

        if (response.statusCode == 200) {
          downloadedBytes = 0; // server ignored Range – restart
        }

        try {
          await for (final chunk in response.stream) {
            if (_isCancelled(model.id)) break;
            sink.add(chunk);
            downloadedBytes += chunk.length;
            _emit(model.id, ModelStatus.downloading, downloaded: downloadedBytes, total: totalBytes);
          }
        } finally {
          await sink.flush();
          await sink.close();
        }

        client.close();
        _activeClients.remove(model.id);

        if (_isCancelled(model.id)) {
          _cleanup(model.id);
          return;
        }

        // Verify SHA-256 if a real hash is provided.
        if (model.sha256.isNotEmpty && model.sha256 != 'placeholder') {
          final digest = await sha256.bind(tempFile.openRead()).first;
          if (digest.toString() != model.sha256) {
            lastError = 'SHA-256 mismatch';
            await tempFile.delete();
            downloadedBytes = 0;
            continue; // try next mirror
          }
        }

        // Mark complete.
        await _completeMarker(dir).writeAsString(DateTime.now().toIso8601String());
        await tempFile.delete().catchError((_) => tempFile);

        _emit(model.id, ModelStatus.downloaded, downloaded: totalBytes, total: totalBytes);
        _cleanup(model.id);
        return; // success
      } catch (e) {
        lastError = e.toString();
        client.close();
        _activeClients.remove(model.id);
        // try next mirror
      }
    }

    // All mirrors failed.
    _emit(model.id, ModelStatus.failed, error: lastError);
    _cleanup(model.id);
  }

  // ---------------------------------------------------------------------------
  // Delete / Cancel
  // ---------------------------------------------------------------------------

  /// Delete a downloaded model and its files.
  Future<void> deleteModel(String modelId) async {
    cancelDownload(modelId);
    final dir = Directory('${(await _modelsDir).path}/$modelId');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    _emit(modelId, ModelStatus.notDownloaded);
  }

  /// Cancel an in-progress download.
  void cancelDownload(String modelId) {
    _cancelFlags[modelId] = true;
    _activeClients[modelId]?.close();
    _activeClients.remove(modelId);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  bool _isCancelled(String modelId) => _cancelFlags[modelId] == true;

  void _cleanup(String modelId) {
    _cancelFlags.remove(modelId);
    _activeClients.remove(modelId);
  }

  void _emit(String modelId, ModelStatus status, {int downloaded = 0, int total = 0, String? error}) {
    _progressController.add(
      ModelDownloadProgress(
        modelId: modelId,
        downloadedBytes: downloaded,
        totalBytes: total,
        status: status,
        error: error,
      ),
    );
  }
}
