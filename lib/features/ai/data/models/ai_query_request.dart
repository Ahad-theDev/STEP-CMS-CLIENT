class ChatHistoryItem {
  final String role;
  final String content;

  const ChatHistoryItem({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class AiQueryRequest {
  final String query;
  final List<ChatHistoryItem> history;

  const AiQueryRequest({
    required this.query,
    this.history = const [],
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'history': history.map((e) => e.toJson()).toList(),
      };
}
