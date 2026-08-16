import 'package:dio/dio.dart';

/// Custom exception class for API errors with user-friendly messages
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final DioExceptionType? type;

  const ApiException({
    required this.message,
    this.statusCode,
    this.type,
  });

  @override
  String toString() => message;
}

/// Maps DioExceptions to user-friendly ApiExceptions
ApiException mapDioExceptionToApiException(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Could not connect to the server. Check your internet or try again.',
          statusCode: error.response?.statusCode,
          type: error.type,
        );
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          message: 'The server took too long to respond. Please try again.',
          statusCode: error.response?.statusCode,
          type: error.type,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        // Try to extract backend error message
        String message;
        if (data is Map && data['detail'] != null) {
          // Handle validation errors array format: {"detail": [{"msg": "..."}, ...]}
          final detail = data['detail'];
          if (detail is List && detail.isNotEmpty) {
            // Extract all error messages and join them
            final messages = detail
                .where((e) => e is Map && e['msg'] != null)
                .map((e) => e['msg'].toString())
                .toList();
            if (messages.isNotEmpty) {
              message = messages.join('\n');
            } else {
              message = detail.toString();
            }
          } else if (detail is String) {
            message = detail;
          } else {
            message = detail.toString();
          }
        } else if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        } else if (data is String && data.isNotEmpty) {
          message = data;
        } else {
          message = _getDefaultMessageForStatusCode(statusCode);
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          type: error.type,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled. Please try again.',
          statusCode: error.response?.statusCode,
          type: error.type,
        );
      case DioExceptionType.unknown:
        // Check if it's actually a connection error
        if (error.error != null && error.error.toString().contains('SocketException')) {
          return ApiException(
            message: 'Could not connect to the server. Check your internet or try again.',
            statusCode: error.response?.statusCode,
            type: DioExceptionType.connectionError,
          );
        }
        return ApiException(
          message: 'Network error. Please try again.',
          statusCode: error.response?.statusCode,
          type: error.type,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Security certificate error. Please contact support.',
          statusCode: error.response?.statusCode,
          type: error.type,
        );
    }
  }

  // Fallback for non-Dio exceptions
  return ApiException(
    message: 'Something went wrong. Please try again.',
    statusCode: null,
    type: null,
  );
}

String _getDefaultMessageForStatusCode(int? statusCode) {
  switch (statusCode) {
    case 400:
      return 'Invalid request. Please check your input and try again.';
    case 401:
      return 'Invalid credentials. Please check your username and password.';
    case 403:
      return 'You do not have permission to perform this action.';
    case 404:
      return 'The requested resource was not found.';
    case 409:
      return 'A conflict occurred. This resource may already exist.';
    case 422:
      return 'Validation failed. Please check your input.';
    case 429:
      return 'Too many requests. Please wait a moment and try again.';
    case 500:
      return 'Server error. Please try again later.';
    case 502:
    case 503:
    case 504:
      return 'Service temporarily unavailable. Please try again later.';
    default:
      return 'Something went wrong (code $statusCode). Please try again.';
  }
}

/// Extension for easier error handling in controllers
extension ApiExceptionExtension on Object {
  String get userFriendlyMessage => mapDioExceptionToApiException(this).message;
}