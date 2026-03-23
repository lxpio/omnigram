import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:omnigram/providers/companion_provider.dart';
import 'package:omnigram/service/ai/companion_prompt.dart';
import 'package:omnigram/service/ai/index.dart';

enum AmbientTaskType { contextBar, memoryBridge, autoTag, summary, glossary, recommendation }

class AmbientAiResult {
  final String content;
  final DateTime generatedAt;
  final bool fromCache;

  const AmbientAiResult({required this.content, required this.generatedAt, this.fromCache = false});
}

class AmbientAiPipeline {
  AmbientAiPipeline._();

  // In-memory cache for ambient results
  static final Map<String, AmbientAiResult> _cache = {};

  static String _cacheKey(AmbientTaskType type, Map<String, dynamic> params) {
    final sorted = params.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return '${type.name}:${sorted.map((e) => '${e.key}=${e.value}').join(',')}';
  }

  /// Check cache for existing result
  static AmbientAiResult? getCached(AmbientTaskType type, Map<String, dynamic> params) {
    return _cache[_cacheKey(type, params)];
  }

  static void _cacheResult(AmbientTaskType type, Map<String, dynamic> params, String content) {
    _cache[_cacheKey(type, params)] = AmbientAiResult(content: content, generatedAt: DateTime.now());
  }

  /// Clear all cached results
  static void clearCache() => _cache.clear();

  /// Execute an ambient AI task.
  /// Returns the result string, or null if AI is unavailable or failed.
  /// Ambient tasks never throw — they silently degrade.
  static Future<String?> execute({
    required AmbientTaskType type,
    required String prompt,
    required WidgetRef ref,
    Map<String, dynamic> cacheParams = const {},
    bool useCache = true,
  }) async {
    if (useCache) {
      final cached = getCached(type, cacheParams);
      if (cached != null) return cached.content;
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
        _cacheResult(type, cacheParams, result);
      }
      return result;
    } catch (_) {
      // Ambient AI never throws — silently degrade
      return null;
    }
  }
}
