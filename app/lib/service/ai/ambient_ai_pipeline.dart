import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:omnigram/dao/ai_cache.dart';
import 'package:omnigram/providers/companion_provider.dart';
import 'package:omnigram/service/ai/companion_prompt.dart';
import 'package:omnigram/service/ai/index.dart';

enum AmbientTaskType { contextBar, memoryBridge, autoTag, summary, glossary, recommendation, narrative }

class AmbientAiResult {
  final String content;
  final DateTime generatedAt;
  final bool fromCache;

  const AmbientAiResult({required this.content, required this.generatedAt, this.fromCache = false});
}

class AmbientAiPipeline {
  AmbientAiPipeline._();

  // L1: In-memory cache (hot, session-scoped)
  static final Map<String, AmbientAiResult> _cache = {};

  static String _cacheKey(AmbientTaskType type, Map<String, dynamic> params) {
    final sorted = params.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return '${type.name}:${sorted.map((e) => '${e.key}=${e.value}').join(',')}';
  }

  /// Check L1 (memory) then L2 (sqflite) cache for existing result
  static AmbientAiResult? getCached(AmbientTaskType type, Map<String, dynamic> params) {
    return _cache[_cacheKey(type, params)];
  }

  /// Check L2 (sqflite) cache — async, for when L1 misses
  static Future<AmbientAiResult?> _getCachedFromDb(AmbientTaskType type, Map<String, dynamic> params) async {
    try {
      final key = _cacheKey(type, params);
      final entry = await aiCacheDao.get(type.name, key);
      if (entry != null) {
        final result = AmbientAiResult(
          content: entry.content,
          generatedAt: DateTime.parse(entry.createdAt),
          fromCache: true,
        );
        // Promote to L1
        _cache[key] = result;
        return result;
      }
    } catch (_) {
      // Cache read failure is non-fatal
    }
    return null;
  }

  static void _cacheResult(AmbientTaskType type, Map<String, dynamic> params, String content, {int? bookId}) {
    final key = _cacheKey(type, params);
    final now = DateTime.now();
    _cache[key] = AmbientAiResult(content: content, generatedAt: now);

    // Write-through to L2 (sqflite), fire-and-forget
    final nowStr = now.toIso8601String();
    aiCacheDao.put(AiCacheEntry(
      type: type.name,
      bookId: bookId,
      cacheKey: key,
      content: content,
      createdAt: nowStr,
      updatedAt: nowStr,
    )).catchError((_) {});
  }

  /// Clear all cached results (L1 only; L2 persists across sessions)
  static void clearCache() => _cache.clear();

  /// Clear both L1 and L2 cache for a specific book
  static Future<void> clearCacheForBook(int bookId) async {
    _cache.removeWhere((key, _) => true); // conservative: clear all L1
    await aiCacheDao.invalidateByBook(bookId);
  }

  /// Execute an ambient AI task.
  /// Returns the result string, or null if AI is unavailable or failed.
  /// Ambient tasks never throw — they silently degrade.
  static Future<String?> execute({
    required AmbientTaskType type,
    required String prompt,
    required WidgetRef ref,
    Map<String, dynamic> cacheParams = const {},
    bool useCache = true,
    int? bookId,
  }) async {
    if (useCache) {
      // L1: in-memory
      final cached = getCached(type, cacheParams);
      if (cached != null) return cached.content;

      // L2: sqflite
      final dbCached = await _getCachedFromDb(type, cacheParams);
      if (dbCached != null) return dbCached.content;
    }

    try {
      final personality = ref.read(companionProvider);
      final systemPrompt = CompanionPrompt.buildSystemPrompt(personality);

      final messages = <ChatMessage>[ChatMessage.system(systemPrompt), ChatMessage.humanText(prompt)];

      final buffer = StringBuffer();
      await for (final chunk in aiGenerateStream(messages, ref: ref)) {
        buffer.write(chunk);
      }

      final result = buffer.toString().trim();
      if (result.isEmpty) return null;

      // Don't cache error messages from the AI layer
      if (result.startsWith('Error:')) return null;

      if (useCache) {
        _cacheResult(type, cacheParams, result, bookId: bookId);
      }
      return result;
    } catch (_) {
      // Ambient AI never throws — silently degrade
      return null;
    }
  }
}
