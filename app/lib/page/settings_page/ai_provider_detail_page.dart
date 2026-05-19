import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:omnigram/enums/ai_reasoning_effort.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/ai_provider.dart';
import 'package:omnigram/providers/ai_providers.dart';
import 'package:omnigram/service/ai/ai_model_service.dart';
import 'package:omnigram/service/ai/index.dart';
import 'package:omnigram/service/ai/prompt_generate.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/ai/ai_stream.dart';
import 'package:omnigram/widgets/common/anx_segmented_button.dart';
import 'package:omnigram/widgets/settings/choice_picker_page.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';
import 'package:uuid/uuid.dart';

/// AI provider detail / edit form — Liquid Glass layout per
/// docs/superpowers/specs/2026-05-19-settings-visual-contract.md P4b.
class AiProviderDetailPage extends ConsumerStatefulWidget {
  final String? providerId; // null for new provider

  const AiProviderDetailPage({super.key, required this.providerId});

  @override
  ConsumerState<AiProviderDetailPage> createState() =>
      _AiProviderDetailPageState();
}

class _AiProviderDetailPageState extends ConsumerState<AiProviderDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _modelController;

  AiProtocol _selectedProtocol = AiProtocol.openai;
  AiReasoningEffort _reasoningEffort = AiReasoningEffort.auto;
  List<AiApiKey> _apiKeys = [];
  bool _isModified = false;
  bool _isFetchingModels = false;
  final GlobalKey _fetchButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    final provider = widget.providerId != null
        ? ref
            .read(aiProvidersProvider)
            .firstWhere((p) => p.id == widget.providerId)
        : null;

    _nameController = TextEditingController(text: provider?.title ?? '');
    _urlController = TextEditingController(text: provider?.url ?? '');
    _modelController = TextEditingController(text: provider?.model ?? '');
    _selectedProtocol = provider?.protocol ?? AiProtocol.openai;
    _reasoningEffort = provider?.reasoningEffort ?? AiReasoningEffort.auto;
    _apiKeys = provider?.apiKeys.toList() ?? [];

    _nameController.addListener(() => setState(() => _isModified = true));
    _urlController.addListener(() => setState(() => _isModified = true));
    _modelController.addListener(() => setState(() => _isModified = true));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  // ------- enum labels -------
  String _reasoningLabel(BuildContext c, AiReasoningEffort e) {
    final l10n = L10n.of(c);
    switch (e) {
      case AiReasoningEffort.auto:
        return l10n.settingsAiProviderReasoningEffortAuto;
      case AiReasoningEffort.low:
        return l10n.settingsAiProviderReasoningEffortLow;
      case AiReasoningEffort.medium:
        return l10n.settingsAiProviderReasoningEffortMedium;
      case AiReasoningEffort.high:
        return l10n.settingsAiProviderReasoningEffortHigh;
    }
  }

  String _protocolLabel(BuildContext c, AiProtocol p) {
    final l10n = L10n.of(c);
    switch (p) {
      case AiProtocol.openai:
        return l10n.settingsAiProviderProtocolOpenai;
      case AiProtocol.claude:
        return l10n.settingsAiProviderProtocolClaude;
      case AiProtocol.gemini:
        return l10n.settingsAiProviderProtocolGemini;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final isExisting = widget.providerId != null;

    return Scaffold(
      appBar: AppGlassAppBar(
        title: Text(isExisting
            ? l10n.settingsAiProviderName
            : l10n.settingsAiProvidersAdd),
        actions: [
          if (_isModified)
            TextButton(
              onPressed: _saveProvider,
              child: Text(l10n.commonSave),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          SettingsSection(
            title: const Text('基本信息'),
            tiles: [
              CustomSettingsTile(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.settingsAiProviderName,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              CustomSettingsTile(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(l10n.settingsAiProviderProtocol,
                            style: OmnigramTypography.caption(context)),
                      ),
                      AnxSegmentedButton<AiProtocol>(
                        selected: {_selectedProtocol},
                        segments: [
                          SegmentButtonItem(
                            value: AiProtocol.openai,
                            label: _protocolLabel(context, AiProtocol.openai),
                          ),
                          SegmentButtonItem(
                            value: AiProtocol.claude,
                            label: _protocolLabel(context, AiProtocol.claude),
                          ),
                          SegmentButtonItem(
                            value: AiProtocol.gemini,
                            label: _protocolLabel(context, AiProtocol.gemini),
                          ),
                        ],
                        onSelectionChanged: (sel) {
                          setState(() {
                            _selectedProtocol = sel.first;
                            _isModified = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              CustomSettingsTile(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: l10n.settingsAiProviderUrl,
                      border: const OutlineInputBorder(),
                      isDense: true,
                      helperText: _selectedProtocol == AiProtocol.openai
                          ? l10n.settingsAiProviderUrlHint
                          : null,
                    ),
                  ),
                ),
              ),
              CustomSettingsTile(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _modelController,
                          decoration: InputDecoration(
                            labelText: l10n.settingsAiProviderModel,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_selectedProtocol == AiProtocol.openai) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          key: _fetchButtonKey,
                          onPressed: _isFetchingModels ? null : _fetchModels,
                          tooltip: l10n.settingsAiProviderFetchModels,
                          icon: _isFetchingModels
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.cloud_download_outlined),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 高级
          SettingsSection(
            title: Text(l10n.settingsAdvanced),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.tune_rounded),
                title: Text(l10n.settingsAiProviderReasoningEffort),
                value: Text(_reasoningLabel(context, _reasoningEffort)),
                description:
                    Text(l10n.settingsAiProviderReasoningEffortHelp),
                onPressed: (_) async {
                  final picked =
                      await pushChoicePicker<AiReasoningEffort>(
                    context,
                    title: l10n.settingsAiProviderReasoningEffort,
                    current: _reasoningEffort,
                    options: AiReasoningEffort.values
                        .map((e) => ChoiceOption(
                              value: e,
                              label: _reasoningLabel(context, e),
                            ))
                        .toList(),
                  );
                  if (picked != null) {
                    setState(() {
                      _reasoningEffort = picked;
                      _isModified = true;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // API Keys
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.settingsAiProviderApiKeys,
                    style: OmnigramTypography.titleMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addApiKey,
                  tooltip: l10n.settingsAiProviderAddKey,
                ),
              ],
            ),
          ),
          if (_apiKeys.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.key_off_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l10n.settingsAiProviderNoValidKeys,
                        style: OmnigramTypography.caption(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                  ),
                  TextButton.icon(
                    onPressed: _addApiKey,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.settingsAiProviderAddKey),
                  ),
                ],
              ),
            )
          else
            SettingsSection(
              tiles: [
                for (var i = 0; i < _apiKeys.length; i++)
                  CustomSettingsTile(child: _ApiKeyTile(
                    apiKey: _apiKeys[i],
                    index: i,
                    onChanged: (updated) {
                      setState(() {
                        _apiKeys[i] = updated;
                        _isModified = true;
                      });
                    },
                    onDelete: () => _deleteApiKey(i),
                  )),
              ],
            ),

          if (isExisting) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testConnection,
                  icon: const Icon(Icons.send_outlined),
                  label: Text(l10n.settingsAiProviderTestConnection),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _addApiKey() {
    final l10n = L10n.of(context);
    final labelController = TextEditingController();
    final keyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsAiProviderAddKey),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: l10n.settingsAiProviderKeyLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              if (keyController.text.isNotEmpty) {
                setState(() {
                  _apiKeys.add(AiApiKey(
                    id: const Uuid().v4(),
                    key: keyController.text,
                    enabled: true,
                    label: labelController.text.isNotEmpty
                        ? labelController.text
                        : null,
                    createdAt: DateTime.now(),
                  ));
                  _isModified = true;
                });
                Navigator.pop(context);
              }
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteApiKey(int index) async {
    final l10n = L10n.of(context);
    bool confirmed = false;

    await SmartDialog.show(
      builder: (_) => AlertDialog(
        title: Text(l10n.commonConfirm),
        content: Text(l10n.commonDelete),
        actions: [
          TextButton(
            onPressed: () {
              confirmed = false;
              SmartDialog.dismiss();
            },
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              confirmed = true;
              SmartDialog.dismiss();
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );

    if (confirmed) {
      setState(() {
        _apiKeys.removeAt(index);
        _isModified = true;
      });
    }
  }

  Future<void> _fetchModels() async {
    final l10n = L10n.of(context);
    final enabledKeys = _apiKeys.where((k) => k.enabled && k.key.isNotEmpty);
    if (enabledKeys.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsAiProviderNoValidKeys)),
      );
      return;
    }

    setState(() => _isFetchingModels = true);

    try {
      final models = await fetchAiModels(
        url: _urlController.text.trim(),
        apiKey: enabledKeys.first.key,
      );

      if (!mounted) return;
      setState(() => _isFetchingModels = false);

      if (models.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsAiProviderNoModelsFound)),
        );
        return;
      }

      final renderBox =
          _fetchButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
      final size = renderBox?.size ?? Size.zero;

      final selected = await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + size.height,
          offset.dx + size.width,
          offset.dy + size.height + 1,
        ),
        constraints: BoxConstraints(
          minWidth: 220,
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        items: models
            .map((modelId) => PopupMenuItem<String>(
                  value: modelId,
                  child: Text(modelId),
                ))
            .toList(),
      );

      if (selected != null) {
        _modelController.text = selected;
        setState(() => _isModified = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingModels = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                l10n.settingsAiProviderFetchModelsFailed(e.toString())),
          ),
        );
      }
    }
  }

  void _saveProvider() {
    final l10n = L10n.of(context);

    if (_nameController.text.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonFailed)),
      );
      return;
    }

    final provider = _buildProvider();
    if (widget.providerId == null) {
      ref.read(aiProvidersProvider.notifier).addProvider(provider);
    } else {
      ref.read(aiProvidersProvider.notifier).updateProvider(provider);
    }

    setState(() => _isModified = false);
    Navigator.pop(context);
  }

  AiProvider _buildProvider() {
    return AiProvider(
      id: widget.providerId ?? const Uuid().v4(),
      title: _nameController.text,
      url: _urlController.text,
      protocol: _selectedProtocol,
      enabled: true,
      isBuiltin: widget.providerId != null
          ? ref
              .read(aiProvidersProvider)
              .firstWhere((p) => p.id == widget.providerId)
              .isBuiltin
          : false,
      apiKeys: _apiKeys,
      model: _modelController.text,
      reasoningEffort: _reasoningEffort,
      keyIndex: 0,
      createdAt: widget.providerId != null
          ? ref
              .read(aiProvidersProvider)
              .firstWhere((p) => p.id == widget.providerId)
              .createdAt
          : DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _testConnection() {
    final l10n = L10n.of(context);

    if (_isModified) {
      if (_nameController.text.isEmpty || _urlController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonFailed)),
        );
        return;
      }
      final provider = _buildProvider();
      if (widget.providerId == null) {
        ref.read(aiProvidersProvider.notifier).addProvider(provider);
      } else {
        ref.read(aiProvidersProvider.notifier).updateProvider(provider);
      }
      setState(() => _isModified = false);
    }

    SmartDialog.show(
      onDismiss: () {
        cancelActiveAiRequest();
      },
      builder: (_) => AlertDialog(
        title: Text(l10n.commonTest),
        content: SizedBox(
          width: double.maxFinite,
          child: AiStream(
            prompt: generatePromptTest(),
            identifier: widget.providerId,
            regenerate: true,
          ),
        ),
      ),
    );
  }
}

class _ApiKeyTile extends StatefulWidget {
  const _ApiKeyTile({
    required this.apiKey,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  final AiApiKey apiKey;
  final int index;
  final ValueChanged<AiApiKey> onChanged;
  final VoidCallback onDelete;

  @override
  State<_ApiKeyTile> createState() => _ApiKeyTileState();
}

class _ApiKeyTileState extends State<_ApiKeyTile> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final label = widget.apiKey.label?.isNotEmpty == true
        ? widget.apiKey.label!
        : 'API Key ${widget.index + 1}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: OmnigramTypography.titleMedium(context)),
              ),
              Switch(
                value: widget.apiKey.enabled,
                onChanged: (v) {
                  widget.onChanged(AiApiKey(
                    id: widget.apiKey.id,
                    key: widget.apiKey.key,
                    enabled: v,
                    label: widget.apiKey.label,
                    createdAt: widget.apiKey.createdAt,
                  ));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: widget.onDelete,
                tooltip: l10n.commonDelete,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4, top: 4),
            child: TextFormField(
              initialValue: widget.apiKey.key,
              obscureText: _obscure,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onChanged: (v) {
                widget.onChanged(AiApiKey(
                  id: widget.apiKey.id,
                  key: v,
                  enabled: widget.apiKey.enabled,
                  label: widget.apiKey.label,
                  createdAt: widget.apiKey.createdAt,
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
