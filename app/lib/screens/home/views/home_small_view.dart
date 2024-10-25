import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/book.entity.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:omnigram/screens/home/views/category_view.dart';
import 'package:omnigram/screens/reader/views/book_group_view.dart';
import 'package:omnigram/screens/reader/views/book_group_view_v2.dart';

// import 'package:omnigram/screens/home/views/category_view.dart';

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

    final List<CategoryData> categorys = [
      CategoryData(Icon(Icons.book), 'category1 one '.tr()),
      CategoryData(Icon(Icons.book), 'category1  '.tr()),
      CategoryData(Icon(Icons.book), 'shot'.tr()),
      CategoryData(Icon(Icons.book), 'loooooooooooooong'.tr()),
      CategoryData(Icon(Icons.book), 'category1'.tr()),
      CategoryData(Icon(Icons.book), 'category1'.tr()),
      CategoryData(Icon(Icons.book), 'category1'.tr()),
      CategoryData(Icon(Icons.book), 'category1'.tr())
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300.0,
          elevation: 0,
          pinned: true,
          floating: false,
          stretch: true,
          backgroundColor: Colors.grey.shade50,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[400],
                // backgroundImage: NetworkImage(
                //     'https://randomuser.me/api/portraits/men/81.jpg'),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            // titlePadding:
            //     const EdgeInsets.only(left: 20, right: 30, bottom: 100),
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle
            ],
            centerTitle: false,
            title: AnimatedOpacity(
              opacity: isScrolled.value ? 1.0 : 0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                child: const Text(
                  "HOOOOME",
                  // style: TextStyle(
                  //   color: Colors,
                  //   fontSize: 30.0,
                  // ),
                ),
              ),
            ),
            background: Container(
                // height: 250,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: AssetImage("assets/images/girl_reading.png"),
                        fit: BoxFit.cover),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white,
                          blurRadius: 10,
                          offset: Offset(0, 10))
                    ])),
          ),
          // bottom: AppBar(actions: const []),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            CategoryGroup(categorys),
            BookReadingGroup('keepreading'.tr(), 'viewmore'.tr(), nav.readings),
            BookGroup('likedbooks'.tr(), 'viewmore'.tr(), nav.likes),
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
