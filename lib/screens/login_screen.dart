import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/providers/provider.dart';
import 'package:omnigram/providers/service/provider.dart';

import 'package:omnigram/providers/user/oauth_model.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/utils/l10n.dart';
import 'package:omnigram/utils/show_snackbar.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends HookConsumerWidget {
  // const LoginScreen({super.key});
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverAddr = ref.watch(appConfigProvider).baseUrl;

    final serverController =
        useTextEditingController(text: serverAddr.isEmpty ? null : serverAddr);

    final accountController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: [
              const SizedBox(height: 50),
              SizedBox(
                height: 350,
                width: 350,
                child:
                    Lottie.asset("assets/files/Animation-reading-woman.json"),
              ),
              const SizedBox(height: 40),
              TextFormField(
                // key: _serverFormKey,

                // cursorColor: Colors.black,
                controller: serverController,

                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return context.l10n.server_address_error;
                  }
                  final urlPattern =
                      RegExp(r'^(https?|ftp)://[^\s/$.?#].[^\s]*$');

                  return urlPattern.hasMatch(text)
                      ? null
                      : context.l10n.server_address_error;
                },
                onEditingComplete: () => {},
                decoration: InputDecoration(
                  // contentPadding: EdgeInsets.all(0.0),
                  labelText: context.l10n.server_address_label,
                  hintText: serverAddr.isNotEmpty
                      ? serverAddr
                      : context.l10n.server_address_hint_text,
                  prefixIcon: const Icon(Icons.dns_outlined),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.surfaceVariant),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                // cursorColor: Colors.black,
                controller: accountController,
                decoration: InputDecoration(
                  labelText: context.l10n.account_label,
                  hintText: context.l10n.account_hint_text,
                  prefixIcon: const Icon(Icons.person),
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
              TextFormField(
                // cursorColor: Colors.black,
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: context.l10n.password_label,
                  hintText: context.l10n.password_hint_text,
                  prefixIcon: const Icon(Icons.key),
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
                    child: Text(context.l10n.need_help),
                  )
                ],
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () {
                  //尝试获取用户登陆信息 如果失败则弹窗
                  getOauthToken(
                    serverController.text,
                    accountController.text,
                    passwordController.text,
                  ).then((value) {
                    _savedata(ref, value, serverController.text);
                  }).onError((error, stackTrace) {
                    if (error is DioException) {
                      showSnackBar(context, context.l10n.network_error);
                    } else {
                      showSnackBar(context, error.toString());
                    }
                  });
                },
                style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    minimumSize: const Size.fromHeight(45)),
                child: Text(
                  context.l10n.next,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savedata(
      WidgetRef ref, OauthModel oauth, String baseUrl) async {
    await ref
        .read(appConfigProvider.notifier)
        .updateSever(apiserver: baseUrl, apikey: oauth.accessToken);
    // get server config
    await ref.read(serverProvider.notifier).update();
    // get user config
    await ref.read(userProvider.notifier).update();
  }
}
