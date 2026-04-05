import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:omnigram/dao/companion_chat.dart';
import 'package:omnigram/l10n/generated/L10n.dart';
import 'package:omnigram/models/companion_personality.dart';
import 'package:omnigram/models/empty_state_data.dart';
import 'package:omnigram/providers/companion_provider.dart';
import 'package:omnigram/providers/empty_state_provider.dart';
import 'package:omnigram/service/ai/companion_prompt.dart';
import 'package:omnigram/service/ai/index.dart';
import 'package:omnigram/widgets/common/empty_state.dart';
import 'package:omnigram/widgets/markdown/styled_markdown.dart';

/// Companion Panel — bidirectional conversation with reading companion.
/// Slides up from bottom, context-aware, persistent chat history.
class CompanionPanel extends ConsumerStatefulWidget {
  const CompanionPanel({
    super.key,
    required this.bookId,
    required this.bookTitle,
    this.currentChapter,
    this.currentCfi,
    this.chapterContent,
    this.selectedText,
  });

  final int bookId;
  final String bookTitle;
  final String? currentChapter;
  final String? currentCfi;
  final String? chapterContent;
  final String? selectedText;

  @override
  ConsumerState<CompanionPanel> createState() => _CompanionPanelState();
}

class _CompanionPanelState extends ConsumerState<CompanionPanel> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  List<CompanionMessage> _messages = [];
  bool _isStreaming = false;
  String _streamingContent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final messages = await companionChatDao.getRecent(widget.bookId, limit: 50);
    if (mounted) {
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isStreaming) return;

    final trimmed = text.trim();
    _inputController.clear();

    // Add user message
    final now = DateTime.now().toIso8601String();
    final userMsg = CompanionMessage(
      bookId: widget.bookId,
      role: ChatRole.user.name,
      content: trimmed,
      chapter: widget.currentChapter,
      cfi: widget.currentCfi,
      createdAt: now,
    );
    await companionChatDao.addMessage(userMsg);

    setState(() {
      _messages.add(userMsg);
      _isStreaming = true;
      _streamingContent = '';
    });
    _scrollToBottom();

    try {
      final personality = ref.read(companionProvider);
      final systemPrompt = _buildContextualPrompt(personality);

      // Build conversation history for AI context
      final chatMessages = <ChatMessage>[
        ChatMessage.system(systemPrompt),
        // Include recent history for context continuity
        ..._messages.where((m) => m.isUser || m.isCompanion).takeLast(10).map((m) {
          if (m.isUser) return ChatMessage.humanText(m.content);
          return ChatMessage.ai(m.content);
        }),
      ];

      final buffer = StringBuffer();
      await for (final chunk in aiGenerateStream(chatMessages, ref: ref)) {
        buffer.write(chunk);
        if (mounted) {
          setState(() {
            _streamingContent = buffer.toString();
          });
          _scrollToBottom();
        }
      }

      final result = buffer.toString().trim();
      if (result.isNotEmpty) {
        final companionMsg = CompanionMessage(
          bookId: widget.bookId,
          role: ChatRole.companion.name,
          content: result,
          chapter: widget.currentChapter,
          cfi: widget.currentCfi,
          createdAt: DateTime.now().toIso8601String(),
        );
        await companionChatDao.addMessage(companionMsg);

        if (mounted) {
          setState(() {
            _messages.add(companionMsg);
            _isStreaming = false;
            _streamingContent = '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _streamingContent = '';
        });
      }
    }
    _scrollToBottom();
  }

  String _buildContextualPrompt(CompanionPersonality personality) {
    final base = CompanionPrompt.buildSystemPrompt(personality);
    final contextParts = <String>[base];

    contextParts.add('\nReading context:');
    contextParts.add('Book: "${widget.bookTitle}"');

    if (widget.currentChapter != null) {
      contextParts.add('Current chapter: ${widget.currentChapter}');
    }
    if (widget.selectedText != null) {
      contextParts.add('Selected text: "${widget.selectedText}"');
    }
    if (widget.chapterContent != null && widget.chapterContent!.length <= 2000) {
      contextParts.add('Chapter excerpt: ${widget.chapterContent}');
    }

    contextParts.add(
      '\nYou are having a conversation about this book. '
      'Be contextual — reference the current chapter and reading position. '
      'Keep responses concise (2-3 paragraphs max) unless the user asks for detail.',
    );

    return contextParts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personality = ref.watch(companionProvider);

    return Column(
      children: [
        // Header
        _buildHeader(theme, personality),
        const Divider(height: 1),
        // Messages
        Expanded(child: _buildMessageList(theme)),
        // Input
        _buildInput(theme),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, CompanionPersonality personality) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(personality.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                if (widget.currentChapter != null)
                  Text(
                    widget.currentChapter!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: L10n.of(context).commonDelete,
              onPressed: _confirmClearHistory,
            ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_messages.isEmpty && !_isStreaming) {
      return _buildEmptyState(context, ref);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isStreaming) {
          // Streaming message
          return _buildMessageBubble(
            theme,
            content: _streamingContent.isEmpty ? '...' : _streamingContent,
            isUser: false,
            isStreaming: true,
          );
        }
        final msg = _messages[index];
        return _buildMessageBubble(theme, content: msg.content, isUser: msg.isUser);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(warmthTierProvider);
    final data = emptyStateData(context, tier, EmptyPageType.companion);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EmptyState.fromData(data),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _quickPrompts.map((prompt) {
              return ActionChip(
                label: Text(prompt, style: theme.textTheme.bodySmall),
                onPressed: () => _sendMessage(prompt),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<String> get _quickPrompts => [
        L10n.of(context).companionQuickSummarize,
        L10n.of(context).companionQuickExplain,
        L10n.of(context).companionQuickConnect,
        L10n.of(context).companionQuickMissed,
      ];

  Widget _buildMessageBubble(
    ThemeData theme, {
    required String content,
    required bool isUser,
    bool isStreaming = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.auto_awesome, size: 14, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: isUser
                  ? Text(content, style: theme.textTheme.bodyMedium)
                  : StyledMarkdown(data: content, selectable: true),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInput(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor.withAlpha(40))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                textInputAction: TextInputAction.send,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: L10n.of(context).aiHintInputPlaceholder,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                onSubmitted: _isStreaming ? null : (text) => _sendMessage(text),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: _isStreaming
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                    )
                  : const Icon(Icons.send, size: 18),
              onPressed: _isStreaming ? null : () => _sendMessage(_inputController.text),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.of(context).commonDelete),
        content: const Text('Clear conversation history for this book?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(L10n.of(context).commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(L10n.of(context).commonConfirm)),
        ],
      ),
    );
    if (confirmed == true) {
      await companionChatDao.clearBook(widget.bookId);
      if (mounted) {
        setState(() => _messages.clear());
      }
    }
  }
}

/// Extension to take last N elements from an Iterable.
extension _TakeLast<T> on Iterable<T> {
  Iterable<T> takeLast(int n) {
    final list = toList();
    if (list.length <= n) return list;
    return list.sublist(list.length - n);
  }
}
