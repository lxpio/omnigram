import 'package:flutter/material.dart';
import 'package:omnigram/utils/constants.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Destination {
  const Destination(this.icon, this.label, this.route);
  final Icon icon;
  final String label;
  final String route;
}

const List<Destination> destinations = <Destination>[
  Destination(Icon(Icons.book), 'read', kHomePath),
  Destination(Icon(Icons.explore), 'discover', kDiscoverPath),
  Destination(Icon(Icons.messenger_outline_rounded), 'chat', kChatPath),
  Destination(Icon(Icons.person), 'profile', kProfilePath),
];
