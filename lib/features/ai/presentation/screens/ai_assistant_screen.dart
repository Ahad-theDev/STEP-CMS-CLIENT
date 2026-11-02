import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/campus_style.dart';
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

    // Scroll to bottom when messages change or thinking state changes
    ref.listen(aiChatControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.isThinking != next.isThinking) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FD),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFFE4DDF3),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF153D79), Color(0xFF2867A9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x20153D79),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CampusStyle.ink,
                    ),
                  ),
                  Text(
                    'Campus Insights & Operations',
                    style: TextStyle(
                      color: CampusStyle.muted,
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
              icon: const Icon(Icons.refresh_rounded, color: CampusStyle.accent),
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
                        style: FilledButton.styleFrom(
                          backgroundColor: CampusStyle.primary,
                        ),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: CampusBackground()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: chatState.messages.isEmpty
                      ? _buildEmptyStateWithSuggestions(suggestionsAsync)
                      : _buildMessageList(chatState),
                ),
                _buildInputBar(chatState.isThinking),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWithSuggestions(
    AsyncValue<List<String>> suggestionsAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Introduction Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: CampusStyle.card,
            child: Column(
              children: [
                // Glowing circular badge with oceanic gradient
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF253E7A), Color(0xFF554490)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33253E7A),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'How can I help you today?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CampusStyle.ink,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask questions about attendance, student fees, class schedules, or teacher availability.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: CampusStyle.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Campus status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE8F8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD6C8F2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Live Campus Assistant • Ready to help',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CampusStyle.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Suggested Questions Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE8F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: CampusStyle.accent,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Suggested Questions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CampusStyle.ink,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: CampusStyle.accent),
                tooltip: 'Reload suggestions',
                onPressed: () {
                  ref
                      .read(aiSuggestionsControllerProvider.notifier)
                      .refreshSuggestions();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          suggestionsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(CampusStyle.primary),
                ),
              ),
            ),
            error: (err, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFECDD3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error),
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDADDF4)),
                  ),
                  child: const Center(
                    child: Text(
                      'No suggestions available for your role.',
                      style: TextStyle(color: CampusStyle.muted),
                    ),
                  ),
                );
              }

              return Column(
                children: suggestions.map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _sendMessage(suggestion),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFDADDF4),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06253E7A),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE8F8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 18,
                                  color: CampusStyle.accent,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    color: CampusStyle.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: CampusStyle.muted,
                              ),
                            ],
                          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF253E7A), Color(0xFF554490)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22253E7A),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF7F3FF), Color(0xFFF0F5FE)],
                stops: [0, 0.55, 1],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: const Color(0xFFDADDF4),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C7C3AED),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(CampusStyle.primary),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Analyzing campus records...',
                  style: TextStyle(
                    color: CampusStyle.muted,
                    fontStyle: FontStyle.italic,
                    fontSize: 13.5,
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
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: message.isError
                    ? const LinearGradient(
                        colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF253E7A), Color(0xFF554490)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: message.isError
                        ? const Color(0x30E11D48)
                        : const Color(0x22253E7A),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                message.isError
                    ? Icons.error_outline_rounded
                    : Icons.auto_awesome_rounded,
                color: Colors.white,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF253E7A), Color(0xFF554490)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : (message.isError
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Color(0xFFF7F3FF), Color(0xFFF0F5FE)],
                            stops: [0, 0.55, 1],
                          )),
                color: message.isError ? const Color(0xFFFFF1F2) : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : (message.isError
                          ? const Color(0xFFFECDD3)
                          : const Color(0xFFDADDF4)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0x22253E7A)
                        : const Color(0x0C7C3AED),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tool used badge
                  if (!isUser && message.toolUsed != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE8F8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD6C8F2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 13,
                            color: CampusStyle.accent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            message.toolUsed!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: CampusStyle.accent,
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
                          : (message.isError
                              ? const Color(0xFFBE123C)
                              : CampusStyle.ink),
                      fontSize: 14.5,
                      height: 1.48,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // Optional Raw Data Accordion
                  if (!isUser && message.rawData != null) ...[
                    const SizedBox(height: 12),
                    _RawDataView(rawData: message.rawData),
                  ],

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isUser
                            ? const Color(0xB3FFFFFF)
                            : CampusStyle.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFE5DEFA),
                border: Border.all(color: const Color(0xFFD6C8F2)),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 20,
                color: CampusStyle.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isThinking) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFDADDF4),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A253E7A),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
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
                          fontWeight: FontWeight.w500,
                          color: value.text.length >= 500
                              ? AppColors.error
                              : CampusStyle.muted,
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
                          color: const Color(0xFFF8F7FD),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: isFocused
                                ? CampusStyle.accent
                                : const Color(0xFFD9DFF0),
                            width: isFocused ? 1.6 : 1.2,
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
                          style: const TextStyle(
                            color: CampusStyle.ink,
                            fontSize: 14.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ask AI a question...',
                            hintStyle: TextStyle(
                              color: CampusStyle.muted,
                              fontSize: 14.5,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
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
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: canSend
                            ? const LinearGradient(
                                colors: [Color(0xFF253E7A), Color(0xFF554490)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: canSend ? null : const Color(0xFFE2E4F0),
                        boxShadow: canSend
                            ? const [
                                BoxShadow(
                                  color: Color(0x35253E7A),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
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
                            : Icon(
                                Icons.arrow_upward_rounded,
                                size: 22,
                                color: canSend ? Colors.white : const Color(0xFF94A3B8),
                              ),
                        onPressed: canSend ? () => _sendMessage() : null,
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
    String formatted;
    try {
      formatted = const JsonEncoder.withIndent('  ').convert(widget.rawData);
    } catch (_) {
      formatted = widget.rawData.toString();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFDADDF4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: CampusStyle.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _expanded ? 'Hide Raw Tool Data' : 'View Raw Tool Data',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CampusStyle.accent,
                    ),
                  ),
                  const Spacer(),
                  if (_expanded)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      color: CampusStyle.accent,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2235),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    formatted,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFFE2E8F0),
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
