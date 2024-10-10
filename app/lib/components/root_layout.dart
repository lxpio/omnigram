// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' as go;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:omnigram/utils/constants.dart';

// import 'views.dart';

class RootLayout extends HookConsumerWidget {
  const RootLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onSelected(int index) {
      final destination = destinations[index];
      go.GoRouter.of(context).go(destination.route);
    }

    return AdaptiveScaffold(
      smallBreakpoint: const WidthPlatformBreakpoint(end: 600),
      mediumBreakpoint: const WidthPlatformBreakpoint(begin: 600, end: 1000),
      largeBreakpoint: const WidthPlatformBreakpoint(begin: 1000),
      destinations: destinations
          .map((e) => NavigationDestination(
                icon: e.icon,
                label: e.label.tr(),
              ))
          .toList(),
      selectedIndex: currentIndex,
      onSelectedIndexChange: onSelected,
      // body: (_) => GridView.count(crossAxisCount: 2, children: children),
      smallBody: (_) => child,
      // Define a default secondaryBody.
      secondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 192),
      ),
      // Override the default secondaryBody during the smallBreakpoint to be
      // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
      // overridden.
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    );
  }
}



class Destination {
  const Destination(this.icon, this.label, this.route);
  final Icon icon;
  final String label;
  final String route;
}

const List<Destination> destinations = <Destination>[
  Destination(Icon(Icons.book), 'nav_read', kHomePath),
  Destination(Icon(Icons.explore), 'nav_discover', kDiscoverPath),
  Destination(Icon(Icons.messenger_outline_rounded), 'nav_chat', kChatPath),
  Destination(Icon(Icons.person), 'nav_profile', kProfilePath),
];
