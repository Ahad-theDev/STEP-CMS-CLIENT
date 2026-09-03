import 'package:dio/dio.dart';
import 'dart:convert';
import '../exceptions/api_exception.dart';

String friendlyErrorMessage(Object error) {
  // Handle ApiException (which already contains user-friendly message)
  if (error is ApiException) {
    return error.message;
  }

  if (error is DioException) {
    final data = error.response?.data;
    Map? parsedData;

    // Handle if data is a JSON string that needs parsing
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          parsedData = decoded;
        }
      } catch (e) {
        // If JSON parsing fails, parsedData remains null
      }
    } else if (data is Map) {
      // If data is already a Map, use it directly
      parsedData = data;
    }

    // Process the parsed data (whether from string or direct Map)
    if (parsedData != null) {
      // Handle nested error format with details: {"error": {"message": "...", "details": [{...}]}}
      if (parsedData['error'] != null && parsedData['error'] is Map) {
        final errorMap = parsedData['error'] as Map;
        // Check if error object has details array with specific validation messages
        if (errorMap['details'] != null && errorMap['details'] is List) {
          final detailsList = errorMap['details'] as List;
          if (detailsList.isNotEmpty) {
            // Extract all error messages from details and join them
            final messages = detailsList
                .where((e) => e is Map && e['msg'] != null)
                .map((e) => e['msg'].toString())
                .toList();
            if (messages.isNotEmpty) {
              return messages.join('\n');
            }
            // Fall through to check for error message if details don't contain usable messages
          }
        }
        // Handle nested error format: {"error": {"message": "..."}}
        if (errorMap['message'] != null) {
          return errorMap['message'].toString();
        }
      }
      // Legacy FastAPI shape: {"detail": "..."}
      if (parsedData['detail'] != null) {
        return parsedData['detail'].toString();
      }
      // Direct message format: {"message": "..."}
      if (parsedData['message'] != null) {
        return parsedData['message'].toString();
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The request timed out. Check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Check your connection and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}