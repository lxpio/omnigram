import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/models/user_prompt.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_prompts.g.dart';

/// User prompts provider - manages all user custom prompts
@riverpod
class UserPrompts extends _$UserPrompts {
  @override
  List<UserPrompt> build() {
    // Load from SharedPreferences and sort by order
    final prompts = Prefs().userPrompts;
    prompts.sort((a, b) => a.order.compareTo(b.order));
    return prompts;
  }

  /// Get enabled prompts
  List<UserPrompt> getEnabledPrompts() {
    return state.where((p) => p.enabled).toList();
  }

  /// Add a new prompt
  void addPrompt({
    required String name,
    required String content,
  }) {
    final now = DateTime.now();

    final newPrompt = UserPrompt(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      content: content,
      enabled: true,
      order: state.length, // Add to the end
      createdAt: now,
      updatedAt: now,
    );

    final updatedList = [...state, newPrompt];
    _saveAndUpdate(updatedList);
  }

  /// Update a prompt
  void updatePrompt(UserPrompt prompt) {
    final updatedList = state.map((p) {
      if (p.id == prompt.id) {
        return prompt.copyWith(updatedAt: DateTime.now());
      }
      return p;
    }).toList();

    _saveAndUpdate(updatedList);
  }

  /// Delete a prompt
  void deletePrompt(String id) {
    final updatedList = state.where((p) => p.id != id).toList();

    // Reorder remaining prompts
    for (int i = 0; i < updatedList.length; i++) {
      updatedList[i] = updatedList[i].copyWith(order: i);
    }

    _saveAndUpdate(updatedList);
  }

  /// Toggle prompt enabled status
  void toggleEnabled(String id) {
    final index = state.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final prompt = state[index];
    final newEnabledValue = !prompt.enabled;

    final updatedList = state.map((p) {
      if (p.id == id) {
        return p.copyWith(
          enabled: newEnabledValue,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();

    _saveAndUpdate(updatedList);
  }

  /// Move prompt up or down
  void movePrompt(String id, bool moveUp) {
    final index = state.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final newIndex = moveUp ? index - 1 : index + 1;
    if (newIndex < 0 || newIndex >= state.length) return;

    final updatedList = List<UserPrompt>.from(state);

    // Swap
    final temp = updatedList[index];
    updatedList[index] = updatedList[newIndex];
    updatedList[newIndex] = temp;

    // Update order values
    for (int i = 0; i < updatedList.length; i++) {
      updatedList[i] = updatedList[i].copyWith(
        order: i,
        updatedAt: DateTime.now(),
      );
    }

    _saveAndUpdate(updatedList);
  }

  /// Save to SharedPreferences and update state
  void _saveAndUpdate(List<UserPrompt> prompts) {
    Prefs().userPrompts = prompts;
    state = prompts;
  }

  /// Refresh from storage
  void refresh() {
    ref.invalidateSelf();
  }
}
