import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:omnigram/providers/ai_providers.dart';
import 'package:omnigram/service/ai/ai_key_rotator.dart';

part 'ai_availability_provider.g.dart';

@riverpod
bool aiAvailable(AiAvailableRef ref) {
  final providerList = ref.watch(aiProvidersProvider);
  if (providerList.isEmpty) return false;
  final notifier = ref.read(aiProvidersProvider.notifier);
  final selected = notifier.getSelectedProvider();
  return selected != null && AiKeyRotator.hasValidKey(selected);
}
