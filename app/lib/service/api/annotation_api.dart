import '../../models/server/server_annotation.dart';
import 'omnigram_api.dart';

/// Annotation (highlights, notes, bookmarks) API.
class AnnotationApi {
  AnnotationApi(this._api);
  final OmnigramApi _api;

  /// List annotations for a book.
  Future<List<ServerAnnotation>> listAnnotations(String bookId) async {
    final response = await _api.dio.get('/reader/books/$bookId/annotations');
    final data = response.data;
    final list = (data is Map ? (data['data'] as List?) ?? [] : data as List?) ?? [];
    return list.map((e) => ServerAnnotation.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Create an annotation.
  Future<ServerAnnotation> createAnnotation(String bookId, ServerAnnotation annotation) async {
    return _api.post(
      '/reader/books/$bookId/annotations',
      data: annotation.toJson(),
      fromJson: (data) => ServerAnnotation.fromJson(data),
    );
  }

  /// Update an annotation.
  Future<ServerAnnotation> updateAnnotation(String bookId, int annotationId, Map<String, dynamic> fields) async {
    return _api.put(
      '/reader/books/$bookId/annotations/$annotationId',
      data: fields,
      fromJson: (data) => ServerAnnotation.fromJson(data),
    );
  }

  /// Delete an annotation.
  Future<void> deleteAnnotation(String bookId, int annotationId) async {
    await _api.delete('/reader/books/$bookId/annotations/$annotationId');
  }

  /// Batch sync annotations (upsert).
  Future<void> syncAnnotations(List<ServerAnnotation> annotations) async {
    await _api.postVoid('/sync/annotations', data: annotations.map((a) => a.toJson()).toList());
  }
}
