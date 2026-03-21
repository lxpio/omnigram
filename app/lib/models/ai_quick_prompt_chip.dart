import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_quick_prompt_chip.freezed.dart';

@freezed
abstract class AiQuickPromptChip with _$AiQuickPromptChip {
  const factory AiQuickPromptChip({
    required IconData icon,
    required String label,
    required String prompt,
  }) = _AiQuickPromptChip;
}
