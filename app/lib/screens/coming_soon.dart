import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class PhotoPageBody extends StatefulWidget {
  const PhotoPageBody({super.key});

  @override
  State createState() => _PhotoPageBodyState();
}

class _PhotoPageBodyState extends State<PhotoPageBody> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: AppBar(),
          // body: Stack(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: 280,
                      height: 240,
                      child: Lottie.asset(
                        "assets/files/Animation-coming-soon.json",
                        // alignment: Alignment.topCenter,
                        // fit: BoxFit.contain,
                        // animation: "coding",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'coming_soon'.tr(),
                    // alignment: Alignment.topCenter,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
