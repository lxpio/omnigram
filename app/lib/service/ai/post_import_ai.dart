import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ambient_tasks.dart';
import 'package:omnigram/utils/log/common.dart';

/// Fire-and-forget background AI processing after book import.
///
/// When connected to Omnigram Server: Server handles AI enhancement on upload,
/// so this is a no-op (Server's EnhanceMetadata runs automatically).
///
/// When in local-only mode: Falls back to client-side AI processing.
void triggerPostImportAi({required WidgetRef ref, required String title, required String author, String? description}) {
  // If connected to server, server handles AI on upload — skip client AI
  final connection = ref.read(serverConnectionProvider);
  if (connection.isConnected) {
    debugPrint('PostImportAI: Server connected — AI handled server-side');
    return;
  }

  // Local-only mode: use client-side AI
  if (!AiAvailability.isAvailable(ref)) return;

  final pseudoId = title.hashCode;

  // Fire and forget — ambient tasks never throw
  AmbientTasks.autoTag(ref: ref, bookId: pseudoId, title: title, author: author, description: description).then((tags) {
    if (tags != null) {
      AnxLog.info('PostImportAI: auto-tags for "$title": $tags');
    }
  });

  AmbientTasks.summary(ref: ref, bookId: pseudoId, title: title, author: author, description: description).then((
    summary,
  ) {
    if (summary != null) {
      AnxLog.info('PostImportAI: summary for "$title": $summary');
    }
  });
}

/// Fetch AI-generated metadata from Server for a book.
/// Returns null if not connected or book has no AI data.
Future<Map<String, dynamic>?> fetchServerAiResults({
  required WidgetRef ref,
  required String bookId,
}) async {
  try {
    final conn = ref.read(serverConnectionProvider.notifier);
    final api = conn.api;
    if (api == null) return null;

    final result = await api.get(
      '/reader/books/$bookId/ai',
      fromJson: (data) => data as Map<String, dynamic>,
    );
    return result;
  } catch (e) {
    debugPrint('fetchServerAiResults error: $e');
    return null;
  }
}
