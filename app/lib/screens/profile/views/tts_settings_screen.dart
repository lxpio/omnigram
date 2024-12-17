import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/entities/setting.entity.dart';

import 'package:omnigram/providers/tts/tts.service.dart';

class TtsSettingsScreen extends ConsumerWidget {
  const TtsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsConfig = ref.watch(ttsConfigProvider);

//  final bool enabled;
//   final String endpoint;
//   final String? accessToken;
//   final String? voiceId;
//   final int maxNewTokens;
//   final double topP;
//   final double temperature;
//   final double repetitionRenalty;
//   final TTSServiceEnum ttsType;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('TTS'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(
              Icons.headphones,
              // size: 64,
            ),
            title: Text("settings_tts_subtitle".tr()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                    value: ttsConfig.enabled,
                    onChanged: (bool value) =>
                        ref.read(ttsConfigProvider.notifier).update(ttsConfig.copyWith(enabled: value))),
                SizedBox(width: 8),
                // Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.memory),
            title: Text("settings_tts_subtitle".tr()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Theme.of(context).colorScheme.primary.withAlpha(20)),
                  child: Text(
                    ttsConfig.ttsType.i18nName.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      // color: Color(
                      //     int.parse("0xff${job.experienceLevelColor}")),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () async {
              final result = await showDialog(
                  builder: (context) {
                    return _TTSServcieEnumSelectDialogView(ttsConfig.ttsType);
                  },
                  context: context);

              final selectType = result as TTSServiceEnum?;

              if (selectType != null && selectType != ttsConfig.ttsType) {
                debugPrint("themeMode: $selectType");
                ref.read(ttsConfigProvider.notifier).update(ttsConfig.copyWith(ttsType: selectType));
              }
            },
          ),
          if (ttsConfig.ttsType != TTSServiceEnum.device)
            ListTile(
              leading: const Icon(
                Icons.cloud,
                // size: 64,
              ),
              title: Text("tts_server_addr".tr()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("tts_engine_desc".tr(), style: Theme.of(context).textTheme.bodyMedium),
                  // Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text("tts_engine_desc".tr(), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text("tts_engine_default".tr(), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text("tts_engine_google".tr(), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _TTSServcieEnumSelectDialogView extends HookConsumerWidget {
  const _TTSServcieEnumSelectDialogView(this.srvType, {super.key});

  final TTSServiceEnum? srvType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = useState(srvType ?? TTSServiceEnum.fishtts);

    return AlertDialog(
      title: Text('select_tts_service'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: TTSServiceEnum.values.map((service) {
          return RadioListTile<TTSServiceEnum>(
            title: Text(service.i18nName.tr()),
            value: service,
            groupValue: selectedType.value,
            onChanged: (TTSServiceEnum? value) {
              selectedType.value = value ?? TTSServiceEnum.fishtts;
            },
          );
        }).toList(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, srvType),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedType.value);
          },
          child: Text('confirm'.tr()),
        ),
      ],
    );
  }
}
