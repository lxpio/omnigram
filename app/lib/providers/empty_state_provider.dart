import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/models/warmth_tier.dart';
import 'package:omnigram/providers/companion_provider.dart';
import 'package:omnigram/widgets/common/empty_state_config.dart';

part 'empty_state_provider.g.dart';

@riverpod
WarmthTier warmthTier(Ref ref) {
  final warmth = ref.watch(companionProvider).warmth;
  return WarmthTier.fromWarmth(warmth);
}

/// Returns EmptyStateData for a given page.
/// Call with context to access L10n: `emptyStateData(context, EmptyPageType.desk)`
EmptyStateData emptyStateData(BuildContext context, WarmthTier tier, EmptyPageType page) {
  return EmptyStateConfig.forPage(page, tier, L10n.of(context));
}
