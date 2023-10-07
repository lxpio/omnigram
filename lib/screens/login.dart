import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/utils/l10n.dart';
import 'package:rive/rive.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final name = ref.watch(authProvider.select(
    //   (value) => value.valueOrNull?.displayName,
    // ));
    int activeIndex = 0;
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const SizedBox(
              height: 350,
              width: 350,
              child: RiveAnimation.asset(
                "assets/files/113-173-loading-book.riv",
                // alignment: Alignment.topCenter,
                // fit: BoxFit.contain,
                // animation: "coding",
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              // cursorColor: Colors.black,
              decoration: InputDecoration(
                // contentPadding: EdgeInsets.all(0.0),
                labelText: context.l10n.server_address_label,
                hintText: context.l10n.server_address_hint_text,
                // labelStyle: TextStyle(
                //   color: Colors.black,
                //   fontSize: 14.0,
                //   fontWeight: FontWeight.w400,
                // ),
                // hintStyle: TextStyle(
                //   color: Colors.grey,
                //   fontSize: 14.0,
                // ),
                prefixIcon: Icon(Icons.dns_outlined),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceVariant),
                  // borderRadius: BorderRadius.circular(16.0),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  // borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              // cursorColor: Colors.black,
              decoration: InputDecoration(
                labelText: context.l10n.server_apikey_label,
                hintText: context.l10n.server_apikey_hint_text,
                prefixIcon: Icon(Icons.key),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceVariant),
                  // borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  // borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    context.l10n.need_help,
                    // style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 14.0,
                    //     fontWeight: FontWeight.w400),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            FilledButton(
              onPressed: _onPressedNext,
              child: Text(
                context.l10n.next,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              style: FilledButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  minimumSize: const Size.fromHeight(45)),
            ),
          ],
        ),
      ),
    ));
  }

  void _onPressedNext() {
    


  }
}
