import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:omnigram/screens/reader/views/book_group_view.dart';

import '../../reader/views/book_group_view_v2.dart';

class HomeSmallView extends HookConsumerWidget {
  const HomeSmallView({super.key, required this.nav});

  final BookNav nav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

    final isScrolled = useState(false);

    useEffect(() {
      someCallback() {
        if (scrollController.offset >= 100.0) {
          isScrolled.value = true;
        } else {
          isScrolled.value = false;
        }
      }

      scrollController.addListener(someCallback);
      return () => scrollController.removeListener(someCallback);
    }, [scrollController]);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300.0,
          elevation: 0,
          pinned: true,
          floating: true,
          stretch: true,
          backgroundColor: Colors.grey.shade50,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            titlePadding:
                const EdgeInsets.only(left: 20, right: 30, bottom: 100),
            stretchModes: const [
              StretchMode.zoomBackground,
              // StretchMode.fadeTitle
            ],
            // title: AnimatedOpacity(
            //   opacity: isScrolled.value ? 0.0 : 1.0,
            //   duration: const Duration(milliseconds: 500),
            //   child: Container(
            //     child: Text(
            //       "Start your reading today",
            //       style: TextStyle(
            //         color: Colors.black,
            //         fontSize: 20.0,
            //       ),
            //     ),
            //   ),
            // ),
            background: Image.asset("assets/images/girl_reading.png",
                fit: BoxFit.cover),
          ),
          bottom: AppBar(actions: const []),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            BookReadingGroup(
                'keepreading'.tr(), 'viewmore'.tr(), nav.readings),
            BookGroup(
                'likedbooks'.tr(), 'viewmore'.tr(), nav.likes),
            // BookGroup(
            //     'randombooks'.tr(), 'viewmore'.tr(), nav.random),
          ]),
        ),
      ],
      controller: scrollController,
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     elevation: 0,
    //     leading: Builder(builder: (context) {
    //       return IconButton(
    //         onPressed: () {
    //           Scaffold.of(context).openDrawer();
    //           // controller.focusNode.unfocus();
    //         },
    //         icon: const Icon(Icons.menu),
    //       );
    //     }),
    //     centerTitle: true,
    //     titleSpacing: 0,
    //     actions: [
    //       IconButton(
    //         // onPressed: ,
    //         icon: const Icon(
    //           Icons.search,
    //           size: 24,
    //         ),
    //         onPressed: () {
    //           print("press search");
    //         },
    //       ),
    //       IconButton(
    //         // onPressed: ,
    //         icon: const Icon(
    //           Icons.person,
    //           size: 24,
    //         ),
    //         onPressed: () {
    //           ref.read(userProvider.notifier).logout();

    //           print("press person");
    //         },
    //       ),
    //       // const SizedBox(width: 16),
    //     ],
    //   ),
    //   body: const Stackbar(child: EpubIndexView()),
    // );
  }
}
