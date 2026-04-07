import 'package:flutter/material.dart';
import 'package:omnigram/dao/thought.dart';
import 'package:omnigram/l10n/generated/L10n.dart';

Future<Thought?> showRecordThoughtSheet(
  BuildContext context, {
  String? topic,
  int? edgeId,
  int? bookId,
}) async {
  return showModalBottomSheet<Thought>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _RecordThoughtContent(topic: topic, edgeId: edgeId, bookId: bookId),
  );
}

class _RecordThoughtContent extends StatefulWidget {
  final String? topic;
  final int? edgeId;
  final int? bookId;
  const _RecordThoughtContent({this.topic, this.edgeId, this.bookId});

  @override
  State<_RecordThoughtContent> createState() => _RecordThoughtContentState();
}

class _RecordThoughtContentState extends State<_RecordThoughtContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final thought = Thought(
      content: text,
      conceptName: widget.topic,
      bookId: widget.bookId,
      edgeId: widget.edgeId,
      createdAt: DateTime.now().toIso8601String(),
    );
    await ThoughtDao().insert(thought);
    if (mounted) Navigator.pop(context, thought);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.topic != null) ...[
            Text(l10n.insightsThoughtAbout(widget.topic!),
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _controller,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.insightsThoughtPlaceholder,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: Text(l10n.insightsSave)),
        ],
      ),
    );
  }
}
