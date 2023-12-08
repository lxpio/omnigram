import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/screens/reader/providers/books.dart';
import 'package:omnigram/screens/reader/providers/select_book.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:omnigram/screens/reader/views/book_group_view.dart';
import 'package:omnigram/utils/l10n.dart';

class HomeSmallView extends HookConsumerWidget {
  const HomeSmallView({Key? key, required this.nav}) : super(key: key);

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
            title: AnimatedOpacity(
              opacity: isScrolled.value ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                "Find your 2021 Collections",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28.0,
                ),
              ),
            ),
            background: Image.asset("assets/images/girl_reading.png",
                fit: BoxFit.cover),
          ),
          bottom: AppBar(actions: []),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            BookGroup(
                context.l10n.keepreading, context.l10n.viewmore, nav.reading),
            BookGroup(
                context.l10n.recentbooks, context.l10n.viewmore, nav.recent),
            BookGroup(
                context.l10n.randombooks, context.l10n.viewmore, nav.random),
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
