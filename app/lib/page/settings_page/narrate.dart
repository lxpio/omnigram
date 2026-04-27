import 'package:omnigram/config/shared_preference_provider.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/tts/tts_capability.dart';
import 'package:omnigram/page/settings_page/server_connection_page.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/providers/tts_capability_provider.dart';
import 'package:omnigram/providers/tts_providers.dart';
import 'package:omnigram/service/tts/tts_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:omnigram/service/tts/model_manager.dart' as tts_mm;
import 'package:omnigram/service/tts/online_tts.dart';
import 'package:omnigram/service/tts/system_tts.dart';
import 'package:omnigram/service/tts/tts_factory.dart';
import 'package:omnigram/service/tts/tts_model.dart' as tts_model;
import 'package:omnigram/service/tts/tts_service.dart' as tts_svc;
import 'package:omnigram/service/tts/voice_id.dart';
import 'package:omnigram/utils/log/common.dart';
import 'package:omnigram/widgets/settings/service_config_form.dart';
import 'package:omnigram/widgets/settings/voice_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NarrateSettings extends ConsumerStatefulWidget {
  const NarrateSettings({super.key});

  @override
  ConsumerState<NarrateSettings> createState() => _NarrateSettingsState();
}

class _NarrateSettingsState extends ConsumerState<NarrateSettings> {
  String _selectedFullId = '';
  String? _playingFullId;
  bool _previewLoading = false;
  final _previewTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedFullId = Prefs().migrateToVoiceFullId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_previewTextController.text.isEmpty) {
      _previewTextController.text = L10n.of(context).ttsPreviewText;
    }
  }

  @override
  void dispose() {
    _previewTextController.dispose();
    super.dispose();
  }

  Future<void> _selectVoice(TaggedVoice tv) async {
    final fullId = tv.fullId;
    setState(() => _selectedFullId = fullId);
    Prefs().selectedVoiceFullId = fullId;

    // Auto-switch engine
    await TtsFactory().switchToVoiceSource(tv.source);

    // Save voice for the service
    final service = tts_svc.getTtsService(tv.source);
    service.provider.setSelectedVoice(tv.voice.shortName);

    // Update riverpod service state
    ref.read(ttsServiceProvider.notifier).setService(tv.source);
  }

  Future<void> _previewVoice(TaggedVoice tv) async {
    setState(() {
      _playingFullId = tv.fullId;
      _previewLoading = true;
    });
    try {
      final text = _previewTextController.text;
      // Temporarily switch to this voice's engine for preview
      await TtsFactory().switchToVoiceSource(tv.source);
      final tts = TtsFactory().current;
      await tts.stop();
      if (tts is OnlineTts) {
        await tts.speakWithVoice(text, tv.voice.shortName);
      } else if (tts is SystemTts) {
        await tts.speakWithVoice(text, tv.voice.shortName);
      }
    } catch (e) {
      AnxLog.severe('TTS Preview Error: $e');
      if (mounted) {
        final errorColor = Theme.of(context).colorScheme.error;
        SmartDialog.show(
          useSystem: true,
          animationType: SmartAnimationType.centerFade_otherSlide,
          builder: (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: errorColor),
                const SizedBox(width: 8),
                Text(L10n.of(dialogContext).commonError),
              ],
            ),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => SmartDialog.dismiss(),
                child: Text(L10n.of(dialogContext).commonOk),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _playingFullId = null;
          _previewLoading = false;
        });
      }
    }
  }

  Future<void> _previewCurrentVoice() async {
    if (_previewLoading) return;
    setState(() => _previewLoading = true);
    try {
      final text = _previewTextController.text;
      final parsed = VoiceFullId.parse(_selectedFullId);
      await TtsFactory().switchToVoiceSource(parsed.source);
      final tts = TtsFactory().current;
      await tts.stop();
      if (tts is OnlineTts) {
        await tts.speakWithVoice(text, parsed.voiceId);
      } else if (tts is SystemTts) {
        await tts.speakWithVoice(text, parsed.voiceId);
      }
    } catch (e) {
      AnxLog.severe('TTS Preview Error: $e');
      if (mounted) {
        final errorColor = Theme.of(context).colorScheme.error;
        SmartDialog.show(
          useSystem: true,
          animationType: SmartAnimationType.centerFade_otherSlide,
          builder: (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: errorColor),
                const SizedBox(width: 8),
                Text(L10n.of(dialogContext).commonError),
              ],
            ),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => SmartDialog.dismiss(),
                child: Text(L10n.of(dialogContext).commonOk),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _previewLoading = false);
    }
  }

  void _downloadRecommendedModel() {
    final model = tts_model.builtInModels.firstWhere(
      (m) => m.id == 'kokoro-multi-lang-v1_0',
      orElse: () => tts_model.builtInModels.first,
    );
    tts_mm.TtsModelManager().downloadModel(model);
    setState(() {}); // Trigger rebuild to show progress
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final voicesAsync = ref.watch(allVoicesGroupedProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Preview
        _buildPreviewSection(l10n),
        const SizedBox(height: 16),

        // 2. Current voice
        _buildCurrentVoiceBanner(l10n),
        const SizedBox(height: 24),

        // 3. Voice sections
        Text(l10n.ttsSelectVoice,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        voicesAsync.when(
          data: (groups) => _buildVoiceSections(groups, l10n),
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),

        // Omnigram Server status banner — guides user to log in or enable TTS.
        const SizedBox(height: 16),
        _buildOmnigramServerStatusBanner(),

        // Adaptive routing surfaces — only meaningful for server-backed voices.
        const SizedBox(height: 16),
        _buildCapabilityCard(l10n),
        const SizedBox(height: 12),
        _buildDefaultModeSegmented(l10n),
        const SizedBox(height: 12),
        _buildExperimentalToggle(l10n),

        const SizedBox(height: 24),

        // 4. Advanced settings
        _buildAdvancedSection(l10n),
      ],
    );
  }

  Widget _buildOmnigramServerStatusBanner() {
    final statusAsync = ref.watch(omnigramServerTtsStatusProvider);
    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (status) {
        switch (status) {
          case OmnigramServerTtsStatus.available:
            return const SizedBox.shrink();
          case OmnigramServerTtsStatus.notLoggedIn:
            return Card(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
              child: ListTile(
                leading: const Icon(Icons.cloud_off),
                title: const Text('Omnigram Server'),
                subtitle: const Text('登录服务器后即可使用 Omnigram Server 的高级语音'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ServerConnectionPage()),
                  );
                },
              ),
            );
          case OmnigramServerTtsStatus.serviceUnavailable:
            return Card(
              color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: const Text('Omnigram Server 未启用 TTS'),
                subtitle: const Text('当前服务器未运行 TTS 服务，点此查看部署文档'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  final locale = Localizations.localeOf(context);
                  final url = locale.languageCode == 'zh'
                      ? 'https://omnigram.lxpio.com/docs/zh/getting-started/tts-setup/'
                      : 'https://omnigram.lxpio.com/docs/getting-started/tts-setup/';
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                },
              ),
            );
        }
      },
    );
  }

  Widget _buildPreviewSection(L10n l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _previewTextController,
                decoration: InputDecoration(
                  labelText: l10n.ttsPreview,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _previewLoading ? null : _previewCurrentVoice,
              icon: Icon(_previewLoading
                  ? Icons.hourglass_empty
                  : Icons.play_arrow),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentVoiceBanner(L10n l10n) {
    if (_selectedFullId.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.volume_off),
          title: Text(l10n.ttsNoVoiceSelected),
        ),
      );
    }
    final parsed = VoiceFullId.parse(_selectedFullId);
    return Card(
      color: Theme.of(context)
          .colorScheme
          .primaryContainer
          .withValues(alpha: 0.3),
      child: ListTile(
        leading: const Icon(Icons.volume_up),
        title: Text(l10n.ttsCurrentVoice),
        subtitle: Text('${parsed.voiceId} \u00b7 ${parsed.source}'),
        trailing: TextButton(
          onPressed: () {
            // Scroll down to voice sections — no-op for now, sections are visible
          },
          child: Text(l10n.ttsChangeVoice),
        ),
      ),
    );
  }

  Widget _buildVoiceSections(
      Map<String, List<TaggedVoice>> groups, L10n l10n) {
    Widget? sectionFor(String key, String title, IconData icon) {
      final voices = groups[key];
      if (voices == null || voices.isEmpty) return null;
      return VoiceSection(
        title: title,
        icon: icon,
        voices: voices,
        selectedFullId: _selectedFullId,
        playingFullId: _playingFullId,
        onSelect: _selectVoice,
        onPreview: _previewVoice,
      );
    }

    final children = <Widget>[
      // Local — shown even when empty so the download CTA is visible.
      VoiceSection(
        title: l10n.ttsLocalOffline,
        icon: Icons.smartphone,
        voices: groups['local'] ?? [],
        selectedFullId: _selectedFullId,
        playingFullId: _playingFullId,
        onSelect: _selectVoice,
        onPreview: _previewVoice,
        emptyState: _buildLocalEmptyState(l10n),
      ),
      // Online services — Server first when available, then paid clouds
      // (only those with credentials).
      ?sectionFor('server', 'Omnigram Server', Icons.dns),
      ?sectionFor('azure', 'Azure', Icons.cloud_outlined),
      ?sectionFor('openai', 'OpenAI', Icons.cloud_outlined),
      ?sectionFor('aliyun', 'Aliyun', Icons.cloud_outlined),
      ?sectionFor('system', l10n.ttsSystemVoice, Icons.phone_android),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          children[i],
        ],
      ],
    );
  }

  Widget _buildLocalEmptyState(L10n l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.download_outlined,
              size: 40, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 8),
          Text(l10n.ttsNoLocalModel),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _downloadRecommendedModel,
            child: Text(l10n.ttsDownloadRecommended),
          ),
          const SizedBox(height: 4),
          Text(l10n.ttsMoreModels,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline)),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(L10n l10n) {
    return ExpansionTile(
      title: Text(l10n.ttsAdvanced),
      leading: const Icon(Icons.settings),
      children: [
        // Model Management
        _buildModelManagement(l10n),
        const Divider(),
        // API configs for cloud services
        _buildApiConfigs(l10n),
        const Divider(),
        // Speed + mix audio
        _buildAudioParams(l10n),
      ],
    );
  }

  Widget _buildModelManagement(L10n l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.ttsLocalOffline,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...tts_model.builtInModels.map((model) =>
              _buildModelDownloadButton(model)),
        ],
      ),
    );
  }

  Widget _buildModelDownloadButton(tts_model.TtsModel model) {
    final modelId = model.id;

    return StreamBuilder<tts_mm.ModelDownloadProgress>(
      stream: tts_mm.TtsModelManager().progressStream,
      builder: (context, snapshot) {
        final progress = snapshot.data;
        final isThisModel = progress?.modelId == modelId;

        return FutureBuilder<tts_mm.ModelStatus>(
          future: tts_mm.TtsModelManager().getModelStatus(modelId),
          builder: (context, statusSnapshot) {
            final status = isThisModel
                ? (progress?.status ?? tts_mm.ModelStatus.notDownloaded)
                : (statusSnapshot.data ?? tts_mm.ModelStatus.notDownloaded);

            if (status == tts_mm.ModelStatus.downloaded) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${model.name} ready',
                          style: const TextStyle(color: Colors.green),
                          overflow: TextOverflow.ellipsis),
                    ),
                    TextButton(
                      onPressed: () async {
                        await tts_mm.TtsModelManager().deleteModel(modelId);
                        ref.invalidate(allVoicesGroupedProvider);
                        setState(() {});
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }

            if (status == tts_mm.ModelStatus.downloading) {
              final pct = isThisModel
                  ? (progress!.progress * 100).toStringAsFixed(0)
                  : '...';
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                        value: isThisModel ? progress!.progress : null),
                    const SizedBox(height: 4),
                    Text('Downloading $pct%'),
                  ],
                ),
              );
            }

            if (status == tts_mm.ModelStatus.failed) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Text(
                        'Download failed: ${progress?.error ?? "unknown"}',
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        tts_mm.TtsModelManager().downloadModel(model);
                        setState(() {});
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Not downloaded
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  tts_mm.TtsModelManager().downloadModel(model);
                  setState(() {});
                },
                icon: const Icon(Icons.download),
                label:
                    Text('Download ${model.name} (${model.sizeDisplay})'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApiConfigs(L10n l10n) {
    // Show config forms for cloud services that have config items
    final services = [
      tts_svc.TtsService.azure,
      tts_svc.TtsService.openai,
      tts_svc.TtsService.aliyun,
      tts_svc.TtsService.server,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: services.map((service) {
          final serviceId = service.toString().split('.').last;
          final configItems = service.provider.getConfigItems(context);
          if (configItems.isEmpty) return const SizedBox.shrink();

          final config =
              ref.watch(onlineTtsConfigProvider(serviceId));

          return ExpansionTile(
            title: Text(service.getLabel(context)),
            tilePadding: EdgeInsets.zero,
            children: [
              ServiceConfigForm(
                configItems: configItems,
                initialConfig: config,
                onConfigChanged: (newConfig) {
                  for (var entry in newConfig.entries) {
                    ref
                        .read(onlineTtsConfigProvider(serviceId).notifier)
                        .updateConfig(entry.key, entry.value);
                  }
                },
              ),
              if (service == tts_svc.TtsService.sherpaOnnx)
                _buildModelDownloadButtonFromConfig(config),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModelDownloadButtonFromConfig(Map<String, dynamic> config) {
    final modelId = config['model_id']?.toString() ?? '';
    if (modelId.isEmpty) return const SizedBox.shrink();

    final model =
        tts_model.builtInModels.where((m) => m.id == modelId).firstOrNull;
    if (model == null) return const SizedBox.shrink();

    return _buildModelDownloadButton(model);
  }

  Widget _buildAudioParams(L10n l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speed slider
          Row(
            children: [
              const Icon(Icons.speed, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Speed: ${Prefs().ttsRate.toStringAsFixed(1)}'),
                    Slider(
                      value: Prefs().ttsRate,
                      min: 0.1,
                      max: 2.0,
                      divisions: 19,
                      label: Prefs().ttsRate.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          Prefs().ttsRate = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Mix audio toggle
          SwitchListTile(
            title: Text(l10n.allowMixing),
            subtitle: Text(l10n.enableMixTip),
            value: Prefs().allowMixWithOtherAudio,
            onChanged: (value) {
              Prefs().allowMixWithOtherAudio = value;
              setState(() {});
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // ── Adaptive routing surfaces ──────────────────────────────────────

  Widget _buildCapabilityCard(L10n l10n) {
    final voiceFullId = Prefs().selectedVoiceFullId;
    final serverUrl = ref.watch(serverConnectionProvider).serverUrl ?? '';
    final cap = ref.watch(ttsCapabilityCacheProvider)['$serverUrl::$voiceFullId'];
    final canProbe = serverUrl.isNotEmpty && voiceFullId.startsWith('server:');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ttsCapabilityCardTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_capabilityLine(l10n, cap)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: !canProbe
                  ? null
                  : () async {
                      final cache = ref.read(ttsCapabilityCacheProvider.notifier);
                      await cache.probe(serverUrl: serverUrl, voiceFullId: voiceFullId);
                      if (mounted) setState(() {});
                    },
              child: Text(l10n.ttsCapabilityRecheck),
            ),
          ],
        ),
      ),
    );
  }

  String _capabilityLine(L10n l10n, TtsCapability? cap) {
    if (cap == null) return l10n.ttsCapabilityNeverProbed;
    final tier = switch (cap.tier) {
      TtsCapabilityTier.green => l10n.ttsCapabilityTierGreen,
      TtsCapabilityTier.yellow => l10n.ttsCapabilityTierYellow,
      TtsCapabilityTier.red => l10n.ttsCapabilityTierRed,
      TtsCapabilityTier.na => l10n.ttsCapabilityTierNa,
    };
    return l10n.ttsCapabilityLastProbed(
      cap.probedAt.toLocal().toString().split('.').first,
      tier,
      cap.firstByteMs,
      cap.rtf.toStringAsFixed(2),
    );
  }

  Widget _buildDefaultModeSegmented(L10n l10n) {
    final mode = TtsDefaultModeCodec.fromPref(Prefs().ttsDefaultMode);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ttsDefaultModeTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<TtsDefaultMode>(
              segments: [
                ButtonSegment(value: TtsDefaultMode.auto, label: Text(l10n.ttsDefaultModeAuto)),
                ButtonSegment(value: TtsDefaultMode.alwaysLive, label: Text(l10n.ttsDefaultModeAlwaysLive)),
                ButtonSegment(value: TtsDefaultMode.alwaysPregen, label: Text(l10n.ttsDefaultModeAlwaysPregen)),
                ButtonSegment(value: TtsDefaultMode.alwaysLocal, label: Text(l10n.ttsDefaultModeAlwaysLocal)),
              ],
              selected: {mode},
              onSelectionChanged: (s) {
                Prefs().ttsDefaultMode = s.first.prefValue;
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperimentalToggle(L10n l10n) {
    return Card(
      child: SwitchListTile(
        title: Text(l10n.ttsExperimentalAdaptiveTitle),
        subtitle: Text(l10n.ttsExperimentalAdaptiveSubtitle),
        value: Prefs().experimentalTtsAdaptiveRouting ?? false,
        onChanged: (v) {
          Prefs().experimentalTtsAdaptiveRouting = v;
          setState(() {});
        },
      ),
    );
  }
}
