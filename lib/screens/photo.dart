import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

import 'package:omnigram/utils/l10n.dart';

class PhotoPageBody extends StatefulWidget {
  const PhotoPageBody({Key? key}) : super(key: key);

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
            child: Container(
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      child: Lottie.asset(
                        "assets/files/Animation-coming-soon.json",
                        // alignment: Alignment.topCenter,
                        // fit: BoxFit.contain,
                        // animation: "coding",
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    context.l10n.coming_soon,
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
