import 'package:cms/core/exceptions/api_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/chat_message.dart';
import '../data/models/ai_query_request.dart';
import 'ai_repository_provider.dart';

part 'ai_chat_controller.g.dart';

class AiChatState {
  final List<ChatMessage> messages;
  final bool isThinking;

  const AiChatState({
    this.messages = const [],
    this.isThinking = false,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

@riverpod
class AiChatController extends _$AiChatController {
  @override
  AiChatState build() {
    return const AiChatState();
  }

  Future<void> sendQuery(String queryText) async {
    final trimmed = queryText.trim();
    if (trimmed.isEmpty) return;

    if (trimmed.length < 3) {
      final errorMsg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: 'Query must be at least 3 characters long.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
      );
      return;
    }

    if (trimmed.length > 500) {
      final errorMsg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: 'Query exceeds maximum limit of 500 characters.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
      );
      return;
    }

    // Capture preceding conversation history (excluding error messages)
    final history = state.messages
        .where((m) => !m.isError && m.content.trim().isNotEmpty)
        .map((m) => ChatHistoryItem(
              role: m.isUser ? 'user' : 'assistant',
              content: m.content,
            ))
        .toList();

    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().microsecondsSinceEpoch}',
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isThinking: true,
    );

    try {
      final repo = ref.read(aiRepositoryProvider);
      final response = await repo.sendQuery(trimmed, history: history);

      final assistantMessage = ChatMessage(
        id: 'ai_${DateTime.now().microsecondsSinceEpoch}',
        content: response.displayContent,
        isUser: false,
        timestamp: DateTime.now(),
        toolUsed: response.toolUsed,
        rawData: response.rawData,
        isError: response.error != null && response.error!.isNotEmpty,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isThinking: false,
      );
    } catch (e) {
      final apiException = mapDioExceptionToApiException(e);
      final errorAssistantMessage = ChatMessage(
        id: 'ai_${DateTime.now().microsecondsSinceEpoch}',
        content: apiException.message,
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: [...state.messages, errorAssistantMessage],
        isThinking: false,
      );
    }
  }

  void clearChat() {
    state = const AiChatState();
  }
}
