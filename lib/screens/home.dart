import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/home_body.dart';
import 'package:omnigram/components/destinations.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'chat.dart';
import 'photo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static String get routeName => 'home';
  static String get routeLocation => '/reader';

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    EpubPageBody(),
    ChatPageBody(),
    PhotoPageBody(),
    PhotoPageBody(),
  ];

  @override
  Widget build(BuildContext context) {
    // final name = ref.watch(authProvider.select(
    //   (value) => value.valueOrNull?.displayName,
    // ));

    return Scaffold(
      appBar: AppBar(
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(0),
        //   child: Container(
        //     height: 2,
        //   ),
        // ),
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
              // controller.focusNode.unfocus();
            },
            icon: const Icon(Icons.menu),
          );
        }),
        // title: Text(

        //   // controller.currentConversation?.displayName ?? 'new_chat'.tr,
        //   overflow: TextOverflow.ellipsis,
        //   maxLines: 1,
        // ),
        centerTitle: true,
        titleSpacing: 0,
        actions: [
          IconButton(
            // onPressed: ,
            icon: const Icon(
              Icons.search,
              size: 24,
            ),
            onPressed: () {
              print("press search");
            },
          ),
          IconButton(
            // onPressed: ,
            icon: const Icon(
              Icons.person,
              size: 24,
            ),
            onPressed: () {
              print("press person");
            },
          ),
          // const SizedBox(width: 16),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        destinations: destinations.map<NavigationDestination>((d) {
          return NavigationDestination(
            icon: Icon(d.icon),
            label: AppLocalizations.of(context)!.nav_name(d.label),
          );
        }).toList(),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
