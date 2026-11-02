import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/ai_chat_controller.dart';
import '../../application/ai_suggestions_controller.dart';
import '../../data/models/chat_message.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
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

  void _sendMessage([String? presetText]) {
    final query = presetText ?? _textController.text.trim();
    if (query.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }

    ref.read(aiChatControllerProvider.notifier).sendQuery(query);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatControllerProvider);
    final suggestionsAsync = ref.watch(aiSuggestionsControllerProvider);
    final theme = Theme.of(context);

    // Scroll to bottom when messages change or thinking state changes
    ref.listen(aiChatControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.isThinking != next.isThinking) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Campus Insights & Operations',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (chatState.messages.isNotEmpty)
            IconButton(
              tooltip: 'Start New Chat',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Conversation?'),
                    content: const Text(
                      'This will reset your current conversation and show suggestions again.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(aiChatControllerProvider.notifier).clearChat();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyStateWithSuggestions(suggestionsAsync)
                : _buildMessageList(chatState),
          ),
          _buildInputBar(chatState.isThinking),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWithSuggestions(
    AsyncValue<List<String>> suggestionsAsync,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'How can I help you today?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask questions about attendance, student fees, class schedules, or teacher availability.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'Suggested Questions',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Reload suggestions',
                  onPressed: () {
                    ref
                        .read(aiSuggestionsControllerProvider.notifier)
                        .refreshSuggestions();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          suggestionsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to load suggestions: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            data: (suggestions) {
              if (suggestions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('No suggestions available for your role.'),
                  ),
                );
              }

              return Column(
                children: suggestions.map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _sendMessage(suggestion),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(AiChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: state.messages.length + (state.isThinking ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isThinking) {
          return _buildThinkingBubble();
        }

        final message = state.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildThinkingBubble() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Analyzing campus records...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: message.isError
                    ? AppColors.error.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.15),
              ),
              child: Icon(
                message.isError
                    ? Icons.error_outline_rounded
                    : Icons.auto_awesome_rounded,
                color: message.isError ? AppColors.error : AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : message.isError
                        ? AppColors.error.withValues(alpha: 0.12)
                        : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : message.isError
                          ? AppColors.error.withValues(alpha: 0.4)
                          : AppColors.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tool used badge
                  if (!isUser && message.toolUsed != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            message.toolUsed!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Content text
                  SelectableText(
                    message.content,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : message.isError
                              ? AppColors.error
                              : theme.colorScheme.onSurface,
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                  ),

                  // Optional Raw Data Accordion
                  if (!isUser && message.rawData != null) ...[
                    const SizedBox(height: 10),
                    _RawDataView(rawData: message.rawData),
                  ],

                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isUser
                            ? Colors.white.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: const Icon(
                Icons.person_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isThinking) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textController,
              builder: (context, value, _) {
                if (value.text.length > 350) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6, right: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${value.text.length}/500',
                        style: TextStyle(
                          fontSize: 11,
                          color: value.text.length >= 500
                              ? AppColors.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: _focusNode,
                    builder: (context, _) {
                      final isFocused = _focusNode.hasFocus;
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isFocused
                                ? AppColors.primary
                                : AppColors.outline.withValues(alpha: 0.35),
                            width: isFocused ? 1.5 : 1.2,
                          ),
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          textInputAction: TextInputAction.send,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          minLines: 1,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: 'Ask AI a question...',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontSize: 14.5,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 13,
                            ),
                          ),
                          onSubmitted: (val) {
                            if (!isThinking) {
                              _sendMessage();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _textController,
                  builder: (context, value, child) {
                    final hasText = value.text.trim().isNotEmpty;
                    final canSend = hasText && !isThinking;

                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: canSend
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.25),
                        boxShadow: canSend
                            ? [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: isThinking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.arrow_upward_rounded, size: 22),
                        onPressed: canSend ? () => _sendMessage() : null,
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _RawDataView extends StatefulWidget {
  final dynamic rawData;

  const _RawDataView({required this.rawData});

  @override
  State<_RawDataView> createState() => _RawDataViewState();
}

class _RawDataViewState extends State<_RawDataView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String formatted;
    try {
      formatted = const JsonEncoder.withIndent('  ').convert(widget.rawData);
    } catch (_) {
      formatted = widget.rawData.toString();
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _expanded ? 'Hide Raw Data' : 'View Raw Tool Data',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (_expanded)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      tooltip: 'Copy JSON',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: formatted));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Raw data copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    formatted,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
