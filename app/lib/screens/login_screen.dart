import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/providers/api.provider.dart';
import 'package:omnigram/providers/auth.provider.dart';
import 'package:omnigram/screens/profile/views/unauthorized_view.dart';
import 'package:omnigram/utils/constants.dart';

import 'package:omnigram/utils/show_snackbar.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends HookConsumerWidget {
  // const LoginScreen({super.key});
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverAddr = IsarStore.tryGet(StoreKey.serverEndpoint);

    final serverController = useTextEditingController(text: serverAddr);

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
                controller: serverController,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'server_address_error'.tr();
                  }
                  final urlPattern =
                      RegExp(r'^(https?|ftp)://[^\s/$.?#].[^\s]*$');

                  return urlPattern.hasMatch(text)
                      ? null
                      : 'server_address_error'.tr();
                },
                onEditingComplete: () => {},
                decoration: InputDecoration(
                  // contentPadding: EdgeInsets.all(0.0),
                  labelText: 'server_address_label'.tr(),
                  hintText: serverAddr ?? 'server_address_hint_text'.tr(),
                  prefixIcon: const Icon(Icons.dns_outlined),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest),
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
                  labelText: 'account_label'.tr(),
                  hintText: 'account_hint_text'.tr(),
                  prefixIcon: const Icon(Icons.person),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest),
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
                  labelText: 'password_label'.tr(),
                  hintText: 'password_hint_text'.tr(),
                  prefixIcon: const Icon(Icons.key),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest),
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
                    child: Text('need_help'.tr()),
                  )
                ],
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () async {
                  //尝试获取用户登陆信息 如果失败则弹窗

                  final loginStatus = await ref
                      .read(authProvider.notifier)
                      .login(accountController.text, passwordController.text,
                          serverController.text);

                  if (!loginStatus && context.mounted) {
                    showSnackBar(context, 'network_error'.tr());
                    return;
                  }

                  ref.read(apiServiceProvider.notifier).setEndpoint();

                  final authState = await ref
                      .read(authProvider.notifier)
                      .setSuccessLoginInfo();

                  if (context.mounted) {
                    if (authState) {
                      context.goNamed(kHomePage);
                    } else {
                      showSnackBar(context, 'get_user_info_error'.tr());
                    }
                  }
                },
                style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    minimumSize: const Size.fromHeight(45)),
                child: Text(
                  'login'.tr(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    minimumSize: const Size.fromHeight(45)),
                child: Text(
                  'next'.tr(),
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
}
