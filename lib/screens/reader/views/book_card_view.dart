// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/outlined_card.dart';
import 'package:omnigram/flavors/app_config.dart';
import 'package:omnigram/flavors/provider.dart';
import 'package:omnigram/screens/reader/models/book_model.dart';
// import '../../../shared/classes/classes.dart';
// import '../../../shared/extensions.dart';
// import '../../../shared/views/outlined_card.dart';
// import '../../../shared/views/views.dart';

class BookCard extends HookConsumerWidget {
  const BookCard({
    super.key,
    required this.book,
  });

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Song nowPlaying = artist.songs[Random().nextInt(artist.songs.length)];

    final appConfig = ref.read(appConfigProvider);

    return OutlinedCard(
      child: LayoutBuilder(
        builder: (context, dimens) => Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(16), topEnd: Radius.circular(16)),
                image: DecorationImage(
                  // image: CachedNetworkImageProvider(
                  //   appConfig.bookBaseUrl + book.image,
                  //   headers: {"Authorization": "Bearer ${appConfig.bookToken}"},
                  // ),
                  // image: NetworkImage(
                  //   appConfig.bookBaseUrl + book.image,
                  //   headers: {"Authorization": "Bearer ${appConfig.bookToken}"},
                  // ),
                  image: AssetImage('assets/images/logo-white.png'),
                  // ),
                  fit: BoxFit.fill,
                ),
              ),
              height: dimens.maxHeight * .7,
              width: dimens.maxWidth * 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(16),
                      topEnd: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    stops: const [.1, .5],
                    colors: [
                      Colors.black.withOpacity(.1),
                      Colors.black.withOpacity(.05),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value:
                                0.5, // Change this value to represent the progress
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.grey), // Set to gray
                            backgroundColor: Colors.grey[300],
                            // color:,
                            // style: TextStyle(color: Colors.white, fontSize: 14),
                          )
                        ]),
                  ),
                  // Row(
                  //   children: [
                  //     HoverableSongPlayButton(
                  //       size: const Size(50, 50),
                  //       song: nowPlaying,
                  //       child: Icon(Icons.play_circle,
                  //           color: context.colors.tertiary),
                  //     ),
                  //     Text(
                  //       nowPlaying.title,
                  //       maxLines: 1,
                  //       overflow: TextOverflow.clip,
                  //       style: context.labelMedium,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
