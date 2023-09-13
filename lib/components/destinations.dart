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
  Destination(Icon(Icons.messenger_outline_rounded), 'chat', kChatPath),
  Destination(Icon(Icons.music_video), 'music', kMusicPath),
  Destination(Icon(Icons.group_outlined), 'picture', kPhotoPath),
];
