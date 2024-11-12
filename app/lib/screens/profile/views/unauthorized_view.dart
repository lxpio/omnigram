import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:omnigram/utils/constants.dart';

class UnauthorizedView extends HookConsumerWidget {
  const UnauthorizedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                child: Lottie.asset("assets/files/animation-need-login.json"),
              ),
              Text(
                'login_for_more_features'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () {
                  //尝试获取用户登陆信息 如果失败则弹窗
                  //ref.read(authProvider.notifier).logout();
                  context.goNamed(kLoginPage);
                },
                style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    minimumSize: const Size.fromHeight(45)),
                child: Text(
                  'config_server'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
            ],
          ),
        ),
      ),
    );
  }
}
