import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EpubPageBody extends StatefulHookConsumerWidget {
  const EpubPageBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EpubPageBodyState();
}

class _EpubPageBodyState extends ConsumerState<EpubPageBody> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> foods = [
      {
        "image": "assets/images/logo-green.png",
        "isFavorite": false,
      },
      {
        "image": "assets/images/logo-green.png",
        "isFavorite": false,
      },
      {
        "image": "assets/images/logo-green.png",
        "isFavorite": false,
      }
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.keepreading,
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              AppLocalizations.of(context)!.viewmore,
              style: TextStyle(
                  color: Colors.blue[700],
                  // fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            // padding: EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            height: 230,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: foods.length,
                itemBuilder: (context, index) => makeItem(
                    image: foods[index]["image"],
                    isFavorite: foods[index]["isFavorite"],
                    index: index)),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  Widget makeItem({image, isFavorite, index}) {
    return AspectRatio(
      aspectRatio: 2.4 / 3,
      child: GestureDetector(
        child: Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              )),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient:
                    LinearGradient(begin: Alignment.bottomCenter, stops: const [
                  .1,
                  .8
                ], colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.1),
                ])),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        // foods[index]["isFavorite"] =
                        //     !foods[index]["isFavorite"];
                      });
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                width: 1.5,
                                color: isFavorite
                                    ? Colors.red
                                    : Colors.transparent,
                              )),
                          child: isFavorite
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                )),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "LLM Chain",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      LinearProgressIndicator(
                        value:
                            0.5, // Change this value to represent the progress
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.grey), // Set to gray
                        backgroundColor: Colors.grey[300],
                        // color:,
                        // style: TextStyle(color: Colors.white, fontSize: 14),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// class ReaderBody extends HookConsumerWidget {
//   const ReaderBody({super.key});

//   final bool _textVisible = true;
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
   
// }
