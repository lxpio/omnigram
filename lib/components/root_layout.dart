// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' as go;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/routes/router.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import 'adaptive_navigation.dart';
import 'destinations.dart';
// import 'views.dart';

class RootLayout extends HookConsumerWidget {
  const RootLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  final Widget child;
  final int currentIndex;
  static const _switcherKey = ValueKey('switcherKey');
  static const _navigationRailKey = ValueKey('navigationRailKey');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onSelected(int index) {
      final destination = destinations[index];

      go.GoRouter.of(context).go(destination.route);
      // router.go(destination.route);
    }

    return AdaptiveScaffold(
      smallBreakpoint: const WidthPlatformBreakpoint(end: 600),
      mediumBreakpoint: const WidthPlatformBreakpoint(begin: 600, end: 1000),
      largeBreakpoint: const WidthPlatformBreakpoint(begin: 1000),
      destinations: destinations
          .map((e) => NavigationDestination(
                icon: e.icon,
                label: AppLocalizations.of(context)!.nav_name(e.label),
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
