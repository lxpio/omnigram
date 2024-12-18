import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:omnigram/components/text_listtile_view.dart';
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
      body: SingleChildScrollView(
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
              if (kDebugMode) {
                debugPrint("ttsConfig.ttsType: ${ttsConfig.ttsType}");
              }

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
            TextListTileView(
              "tts_server_addr".tr(),
              icon: const Icon(Icons.cloud),
              subtitle: ttsConfig.endpoint,
              onSaved: (value) {
                if (kDebugMode) {
                  debugPrint("update tts_server_addr: $value");
                }
                ref.read(ttsConfigProvider.notifier).update(ttsConfig.copyWith(endpoint: value));
              },
            ),
          TextListTileView(
            "tts_voice_id".tr(),
            icon: const Icon(Icons.group_work),
            subtitle: ttsConfig.voiceId,
            onSaved: (value) {
              if (kDebugMode) {
                debugPrint("update tts_voice_id: $value");
              }
              ref.read(ttsConfigProvider.notifier).update(ttsConfig.copyWith(voiceId: value));
            },
          ),
          TextListTileView(
            "max_new_tokens".tr(),
            icon: const Icon(Icons.autofps_select),
            subtitle: ttsConfig.maxNewTokens.toString(),
            onSaved: (value) {
              if (kDebugMode) {
                debugPrint("update max_new_tokens: $value");
              }

              ref.read(ttsConfigProvider.notifier).update(ttsConfig.copyWith(maxNewTokens: int.parse(value)));
            },
          ),
          TextListTileView(
            "temperature".tr(),
            icon: const Icon(Icons.api),
            subtitle: ttsConfig.maxNewTokens.toString(),
            onSaved: (value) {
              if (kDebugMode) {
                debugPrint("update max_new_tokens: $value");
              }

              ref.read(ttsConfigProvider.notifier).update(ttsConfig.copyWith(temperature: double.parse(value)));
            },
          ),
          TextListTileView(
            "top_p".tr(),
            icon: const Icon(Icons.api),
            subtitle: ttsConfig.maxNewTokens.toString(),
            onSaved: (value) {
              if (kDebugMode) {
                debugPrint("update max_new_tokens: $value");
              }
              ref.read(ttsConfigProvider.notifier).update(ttsConfig.copyWith(topP: double.parse(value)));
            },
          ),
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
