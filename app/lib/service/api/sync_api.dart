import 'omnigram_api.dart';

/// Sync API — incremental delta sync.
class SyncApi {
  SyncApi(this._api);
  final OmnigramApi _api;

  /// Full data sync.
  Future<Map<String, dynamic>> fullSync(Map<String, dynamic> payload) async {
    return _api.post('/sync/full', data: payload, fromJson: (data) => data as Map<String, dynamic>);
  }

  /// Delta (incremental) sync — send changes since last sync.
  Future<Map<String, dynamic>> deltaSync(Map<String, dynamic> payload) async {
    return _api.post('/sync/delta', data: payload, fromJson: (data) => data as Map<String, dynamic>);
  }

  /// Annotation batch sync (upsert).
  Future<void> syncAnnotations(List<Map<String, dynamic>> annotations) async {
    await _api.postVoid('/sync/annotations', data: annotations);
  }
}

/// Reading statistics API.
class StatsApi {
  StatsApi(this._api);
  final OmnigramApi _api;

  /// Get reading stats overview.
  Future<Map<String, dynamic>> getOverview() async {
    return _api.get('/reader/stats/overview', fromJson: (data) => data as Map<String, dynamic>);
  }

  /// Get daily reading stats.
  Future<List<Map<String, dynamic>>> getDailyStats() async {
    final response = await _api.dio.get('/reader/stats/daily');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  /// Get top books by reading time.
  Future<List<Map<String, dynamic>>> getBookStats() async {
    final response = await _api.dio.get('/reader/stats/books');
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}
