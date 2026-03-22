import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/service/ai/ai_availability.dart';
import 'package:omnigram/service/ai/ambient_tasks.dart';
import 'package:omnigram/utils/log/common.dart';

/// Fire-and-forget background AI processing after book import.
/// Uses title hashCode as pseudo-bookId since actual ID isn't available yet.
void triggerPostImportAi({required WidgetRef ref, required String title, required String author, String? description}) {
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
