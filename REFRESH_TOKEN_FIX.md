# Fix for Refresh Token Issue

## Issue
The application was experiencing persistent 401 Unauthorized errors even after successfully refreshing the access token. The root cause was that the backend's `/auth/refresh` endpoint was returning the access token as an array `[token_string, jti_string]` instead of just a string, but the client code was expecting a string.

## Root Cause
Two locations in the client code were attempting to cast a List to String when processing the refresh token response:

1. **AuthRepository.refreshAccessToken** in `/home/ahad/Pproject/client/cms/lib/features/auth/data/auth_repository.dart`
2. **TokenRefreshInterceptor.onError** in `/home/ahad/Pproject/client/cms/lib/core/network/token_refresh_interceptor.dart`

When the backend returned:
```json
{
  "access_token": ["actual_jwt_token", "jti_string"],
  "token_type": "bearer"
}
```

Both code locations attempted to cast the List to String, which would throw a BadCastException. This exception was being caught, which would then clear the token storage and propagate the original error, causing the 401 to persist.

## Fix Applied
Modified both files to properly handle the array response from the backend:

### 1. AuthRepository.refreshAccessToken
**File:** `/home/ahad/Pproject/client/cms/lib/features/auth/data/auth_repository.dart`

**Before:**
```dart
Future<String> refreshAccessToken(String refreshToken) async {
  final response = await dio.post(
    ApiConstants.refresh,
    queryParameters: {'refresh_token': refreshToken},
  );
  return response.data['access_token'] as String;
}
```

**After:**
```dart
Future<String> refreshAccessToken(String refreshToken) async {
  final response = await dio.post(
    ApiConstants.refresh,
    queryParameters: {'refresh_token': refreshToken},
  );
  final accessTokenData = response.data['access_token'];
  // Handle case where backend returns [token, jti] array
  if (accessTokenData is List && accessTokenData.isNotEmpty) {
    return accessTokenData[0] as String;
  }
  return accessTokenData as String;
}
```

### 2. TokenRefreshInterceptor.onError
**File:** `/home/ahad/Pproject/client/cms/lib/core/network/token_refresh_interceptor.dart`

**Before:**
```dart
final refreshResponse = await dio.post(
  ApiConstants.refresh,
  queryParameters: {'refresh_token': refreshToken},
);
final newAccessToken = refreshResponse.data['access_token'] as String;

// Backend doesn't rotate the refresh token on /auth/refresh — reuse the one we have.
await storage.saveToken(accessToken: newAccessToken, refreshToken: refreshToken);
```

**After:**
```dart
final refreshResponse = await dio.post(
  ApiConstants.refresh,
  queryParameters: {'refresh_token': refreshToken},
);
final accessTokenData = refreshResponse.data['access_token'];
// Handle case where backend returns [token, jti] array
final newAccessToken = accessTokenData is List && accessTokenData.isNotEmpty
    ? accessTokenData[0] as String
    : accessTokenData as String;

// Backend doesn't rotate the refresh token on /auth/refresh — reuse the one we have.
await storage.saveToken(accessToken: newAccessToken, refreshToken: refreshToken);
```

## Why This Fixes It
1. When the refresh request succeeds, the code now correctly extracts the JWT token (first element) from the array
2. The token is properly saved to storage via `storage.saveToken()`
3. The Authorization header is set correctly on the retry request
4. The original request is retried with the new valid access token
5. No more 401 errors from failed token refreshes

## Backward Compatibility
The fix includes a fallback to the original behavior in case the backend ever returns to sending just a string token, ensuring compatibility with both response formats.

## Verification
- The refresh token interceptor can now successfully refresh expired access tokens
- The extracted JWT token is properly stored and used for subsequent requests
- All existing functionality remains intact