class AiSuggestionsResponse {
  final List<String> suggestions;

  const AiSuggestionsResponse({required this.suggestions});

  factory AiSuggestionsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['suggestions'] as List<dynamic>? ?? [];
    return AiSuggestionsResponse(
      suggestions: list.map((e) => e.toString()).toList(),
    );
  }
}
