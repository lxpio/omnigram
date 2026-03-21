import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/ai_provider.dart';
import 'package:omnigram/service/ai/ai_model_service.dart';
import 'package:omnigram/widgets/common/anx_button.dart';
import 'package:flutter/material.dart';

/// A dialog that lets the user either type a model name manually or pick one
/// from the auto-fetched list (OpenAI-compatible `/v1/models` endpoint only).
///
/// Returns the selected/entered model string, or `null` if cancelled.
Future<String?> showModelPickerDialog({
  required BuildContext context,
  required AiProvider provider,
  String? currentModel,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _ModelPickerDialog(
      provider: provider,
      currentModel: currentModel,
    ),
  );
}

class _ModelPickerDialog extends StatefulWidget {
  const _ModelPickerDialog({
    required this.provider,
    this.currentModel,
  });

  final AiProvider provider;
  final String? currentModel;

  @override
  State<_ModelPickerDialog> createState() => _ModelPickerDialogState();
}

class _ModelPickerDialogState extends State<_ModelPickerDialog> {
  late TextEditingController _controller;
  List<String>? _fetchedModels;
  bool _isFetching = false;
  String? _fetchError;

  bool get _canFetch =>
      widget.provider.protocol == AiProtocol.openai &&
      widget.provider.hasValidKey &&
      widget.provider.url.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentModel ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchModels() async {
    setState(() {
      _isFetching = true;
      _fetchError = null;
      _fetchedModels = null;
    });

    try {
      final apiKey = widget.provider.currentApiKey ?? '';
      final models = await fetchAiModels(
        url: widget.provider.url,
        apiKey: apiKey,
      );
      if (mounted) {
        setState(() {
          _fetchedModels = models;
          _isFetching = false;
          if (models.isEmpty) {
            _fetchError = L10n.of(context).settingsAiProviderNoModelsFound;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetching = false;
          _fetchError = L10n.of(context)
              .settingsAiProviderFetchModelsFailed(e.toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.aiModelSwitchTitle),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manual input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: l10n.aiModelEnterManually,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    autofocus: !_canFetch,
                  ),
                ),
                if (_canFetch) ...[
                  const SizedBox(width: 8),
                  AnxButton(
                    onPressed: _isFetching ? null : _fetchModels,
                    isLoading: _isFetching,
                    child: Text(l10n.settingsAiProviderFetchModels),
                  ),
                ],
              ],
            ),

            // Error message
            if (_fetchError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _fetchError!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),

            // Fetched model list
            if (_fetchedModels != null && _fetchedModels!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Text(
                  l10n.aiModelOrSelectBelow,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _fetchedModels!.length,
                  itemBuilder: (context, index) {
                    final modelId = _fetchedModels![index];
                    final isSelected = _controller.text == modelId;
                    return ListTile(
                      dense: true,
                      title: Text(modelId),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary,
                      onTap: () {
                        setState(() => _controller.text = modelId);
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () {
            final text = _controller.text.trim();
            Navigator.pop(context, text.isEmpty ? null : text);
          },
          child: Text(l10n.commonConfirm),
        ),
      ],
    );
  }
}
