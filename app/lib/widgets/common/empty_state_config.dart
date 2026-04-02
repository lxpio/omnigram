import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/models/warmth_tier.dart';

class EmptyStateConfig {
  static EmptyStateData forPage(EmptyPageType page, WarmthTier tier, L10n l10n) {
    return EmptyStateData(
      message: _message(page, tier, l10n),
      visualType: _visual(page, tier),
      actionLabel: _actionLabel(page, l10n),
    );
  }

  static String _message(EmptyPageType page, WarmthTier tier, L10n l10n) {
    return switch ((page, tier)) {
      (EmptyPageType.desk, WarmthTier.high) => l10n.emptyStateDeskHigh,
      (EmptyPageType.desk, WarmthTier.mid) => l10n.emptyStateDeskMid,
      (EmptyPageType.desk, WarmthTier.low) => l10n.emptyStateDeskLow,
      (EmptyPageType.library, WarmthTier.high) => l10n.emptyStateLibraryHigh,
      (EmptyPageType.library, WarmthTier.mid) => l10n.emptyStateLibraryMid,
      (EmptyPageType.library, WarmthTier.low) => l10n.emptyStateLibraryLow,
      (EmptyPageType.insights, WarmthTier.high) => l10n.emptyStateInsightsHigh,
      (EmptyPageType.insights, WarmthTier.mid) => l10n.emptyStateInsightsMid,
      (EmptyPageType.insights, WarmthTier.low) => l10n.emptyStateInsightsLow,
      (EmptyPageType.companion, WarmthTier.high) => l10n.emptyStateCompanionHigh,
      (EmptyPageType.companion, WarmthTier.mid) => l10n.emptyStateCompanionMid,
      (EmptyPageType.companion, WarmthTier.low) => l10n.emptyStateCompanionLow,
    };
  }

  static EmptyVisualType _visual(EmptyPageType page, WarmthTier tier) {
    return switch (tier) {
      WarmthTier.high => EmptyVisualLottie('assets/img/empty_states/${page.name}_high.json'),
      WarmthTier.mid => EmptyVisualSvg('assets/img/empty_states/${page.name}_mid.svg'),
      WarmthTier.low => EmptyVisualIcon(_iconForPage(page)),
    };
  }

  static String? _actionLabel(EmptyPageType page, L10n l10n) {
    return switch (page) {
      EmptyPageType.desk => l10n.navBarBookshelf,
      EmptyPageType.library => l10n.emptyStateLibraryAction,
      _ => null,
    };
  }

  static IconData _iconForPage(EmptyPageType page) {
    return switch (page) {
      EmptyPageType.desk => Icons.auto_stories_outlined,
      EmptyPageType.library => Icons.library_books_outlined,
      EmptyPageType.insights => Icons.insights_outlined,
      EmptyPageType.companion => Icons.chat_bubble_outline,
    };
  }
}
