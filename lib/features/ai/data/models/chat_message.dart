class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? toolUsed;
  final dynamic rawData;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.toolUsed,
    this.rawData,
    this.isError = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? toolUsed,
    dynamic rawData,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      toolUsed: toolUsed ?? this.toolUsed,
      rawData: rawData ?? this.rawData,
      isError: isError ?? this.isError,
    );
  }
}
