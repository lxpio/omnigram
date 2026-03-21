import 'package:omnigram/service/ai/ai_history.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiHistoryProvider = StateNotifierProvider<AiHistoryNotifier,
    AsyncValue<List<AiChatHistoryEntry>>>((ref) {
  return AiHistoryNotifier();
});

class AiHistoryNotifier
    extends StateNotifier<AsyncValue<List<AiChatHistoryEntry>>> {
  AiHistoryNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final history = await AiHistoryStore.readHistory();
      state = AsyncValue.data(history);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }

  Future<void> upsert(AiChatHistoryEntry entry) async {
    await AiHistoryStore.upsertEntry(entry);
    await _load();
  }

  Future<void> remove(String id) async {
    await AiHistoryStore.removeEntry(id);
    await _load();
  }

  Future<void> clear() async {
    await AiHistoryStore.clear();
    state = const AsyncValue.data([]);
  }

  AiChatHistoryEntry? findById(String id) {
    return state.maybeWhen(
      data: (entries) {
        for (final entry in entries) {
          if (entry.id == id) {
            return entry;
          }
        }
        return null;
      },
      orElse: () => null,
    );
  }
}
