import 'package:cms/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'models/ai_query_request.dart';
import 'models/ai_query_response.dart';
import 'models/ai_suggestions_response.dart';

class AiRepository {
  final Dio dio;

  AiRepository(this.dio);

  Future<AiQueryResponse> sendQuery(
    String query, {
    List<ChatHistoryItem> history = const [],
  }) async {
    final response = await dio.post(
      ApiConstants.aiQuery,
      data: AiQueryRequest(query: query, history: history).toJson(),
    );
    if (response.data is Map<String, dynamic>) {
      return AiQueryResponse.fromJson(response.data as Map<String, dynamic>);
    }
    return AiQueryResponse(message: response.data?.toString());
  }

  Future<List<String>> getSuggestions() async {
    final response = await dio.get(ApiConstants.aiSuggestions);
    if (response.data is Map<String, dynamic>) {
      return AiSuggestionsResponse.fromJson(
        response.data as Map<String, dynamic>,
      ).suggestions;
    }
    return [];
  }
}
