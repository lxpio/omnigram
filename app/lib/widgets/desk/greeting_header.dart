import 'package:flutter/material.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/theme/typography.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 6) return L10n.of(context).deskGreetingLateNight;
    if (hour < 12) return L10n.of(context).deskGreetingMorning;
    if (hour < 18) return L10n.of(context).deskGreetingAfternoon;
    return L10n.of(context).deskGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_greeting(context), style: OmnigramTypography.displayLarge(context)),
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
