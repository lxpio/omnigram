import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/auth.provider.dart';
import 'package:omnigram/providers/book.provider.dart';
import 'package:omnigram/providers/tts.player.provider.dart';
import 'package:omnigram/screens/home/views/book_liked_group_view.dart';
import 'package:omnigram/screens/home/views/book_reading_group_view.dart';

import '../views/stackbar.dart';

class HomeSmallScreen extends HookConsumerWidget {
  const HomeSmallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final booknav = ref.watch(bookProvider);

    final ttsState = ref.watch(ttsPlayerProvider);

    return Column(
      children: [
        const Expanded(child: HomeSmallView()),
        if (ttsState.showbar) const StackbarWidget(),
      ],
    );
  }
}

class HomeSmallView extends HookConsumerWidget {
  const HomeSmallView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('build HomeSmallView');

    final scrollController = useScrollController();

    final isScrolled = useState(false);
    final authState = ref.watch(authProvider);

    useEffect(() {
      if (authState.isAuthenticated) {
        debugPrint('authState.isAuthenticated then syncBooksToDB');
        Future(() => ref.read(bookNotifierProvider.notifier).syncBooksToDB());
      }

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
            stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
            centerTitle: false,
            title: AnimatedOpacity(
              opacity: isScrolled.value ? 1.0 : 0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                child: Text('nav_read'.tr()),
              ),
            ),
            background: Container(
                // height: 250,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image:
                        const DecorationImage(image: AssetImage("assets/images/girl_reading.png"), fit: BoxFit.cover),
                    boxShadow: const [BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(0, 10))])),
          ),
          // bottom: AppBar(actions: const []),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            BookReadingGroup('keepreading'.tr(), 'viewmore'.tr(), BookQuery.readings),
            BookGroup('likedbooks'.tr(), 'viewmore'.tr(), BookQuery.likes),
            // CategoryGroup(),
          ]),
        ),
      ],
      controller: scrollController,
    );
  }
}
