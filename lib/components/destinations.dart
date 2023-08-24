import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Destination {
  const Destination(this.icon, this.label);
  final IconData icon;
  final String label;
}

const List<Destination> destinations = <Destination>[
  Destination(Icons.inbox_rounded, 'read'),
  Destination(Icons.messenger_outline_rounded, 'chat'),
  Destination(Icons.messenger_outline_rounded, 'music'),
  Destination(Icons.group_outlined, 'picture'),
];
