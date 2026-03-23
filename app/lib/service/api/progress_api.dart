import '../../models/server/server_progress.dart';
import 'omnigram_api.dart';

/// Reading progress & sessions API.
class ProgressApi {
  ProgressApi(this._api);
  final OmnigramApi _api;

  /// Get reading progress for a book.
  Future<ServerReadProgress> getProgress(String bookId) async {
    return _api.get('/reader/books/$bookId/progress', fromJson: (data) => ServerReadProgress.fromJson(data));
  }

  /// Update reading progress for a book.
  Future<void> updateProgress(String bookId, {required String cfi, required double percentage}) async {
    await _api.putVoid('/reader/books/$bookId/progress', data: {'cfi': cfi, 'percentage': percentage});
  }

  /// Record a reading session.
  Future<void> recordSession(ServerReadingSession session) async {
    await _api.postVoid('/reader/sessions', data: session.toJson());
  }
}
