class AiQueryResponse {
  final String? answer;
  final String? toolUsed;
  final dynamic rawData;
  final String? error;
  final String? message;

  const AiQueryResponse({
    this.answer,
    this.toolUsed,
    this.rawData,
    this.error,
    this.message,
  });

  factory AiQueryResponse.fromJson(Map<String, dynamic> json) {
    return AiQueryResponse(
      answer: json['answer'] as String?,
      toolUsed: json['tool_used'] as String?,
      rawData: json['raw_data'] ?? json['data'],
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }

  bool get isSuccess => error == null && (answer != null || rawData != null || message != null);

  String get displayContent {
    if (error != null && error!.isNotEmpty) return error!;
    if (answer != null && answer!.isNotEmpty) return answer!;
    if (message != null && message!.isNotEmpty) return message!;
    return 'No response generated.';
  }
}
