import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/flavors/provider.dart';
import 'package:omnigram/providers/service/api_service.dart';
import 'package:omnigram/providers/service/provider.dart';
import 'package:omnigram/providers/user/user_model.dart';
import 'package:omnigram/utils/constants.dart';
import 'package:omnigram/utils/l10n.dart';
import 'package:omnigram/utils/show_snackbar.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulHookConsumerWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController serverController;
  TextEditingController apikeyController = TextEditingController();

  // final _serverFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final serverAddr = ref.watch(appConfigProvider).bookBaseUrl;
    serverController =
        TextEditingController(text: serverAddr.isEmpty ? null : serverAddr);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                  prefixIcon: Icon(Icons.dns_outlined),
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
                controller: apikeyController,
                decoration: InputDecoration(
                  labelText: context.l10n.server_apikey_label,
                  hintText: context.l10n.server_apikey_hint_text,
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
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () {
                  //尝试获取用户登陆信息 如果失败则弹窗
                  final apiservice = APIService(
                      baseUrl: serverController.text,
                      serviceHeader: {
                        'Authorization': "Bearer ${apikeyController.text}",
                      });

                  apiservice
                      .request<UserModel>('GET', '/user/info',
                          fromJsonT: UserModel.fromJson)
                      .then((value) {
                    if (value.code == 200) {
                      _savedata(value.data!);
                    } else {
                      showSnackBar(context, value.message);
                    }
                  }).onError((error, stackTrace) {
                    if (error is DioException) {
                      if (error.response?.statusCode == 401) {
                        // showSnackbar(context, error.response?.m);
                        showSnackBar(context, context.l10n.auth_error);
                      }
                    } else {
                      showSnackBar(context, context.l10n.network_error);
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

  Future<void> _savedata(UserModel user) async {
    await ref.read(userProvider.notifier).update(user);
    //see https://github.com/rrousselGit/riverpod/issues/815
    ref.read(userProvider);
    await ref
        .read(appConfigProvider.notifier)
        .updateSever(serverController.text, apikeyController.text);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
