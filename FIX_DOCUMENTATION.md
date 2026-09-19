# Fix for 401 Unauthorized Error with Refresh Token

## Issue
The application was experiencing persistent 401 Unauthorized errors when attempting to refresh access tokens. The root cause was that the `AuthInterceptor` was adding an (potentially expired) access token to refresh token requests, causing the refresh request itself to fail with 401.

## Root Cause
When an access token expired:
1. Original API request failed with 401 due to expired access token
2. `TokenRefreshInterceptor` caught the 401 and attempted to refresh the token
3. For the refresh request to `/auth/refresh`:
   - `AuthInterceptor` ran first and added the **expired access token** to the Authorization header
   - `TokenRefreshInterceptor` correctly identified this as an auth call and skipped its 401 handling logic
   - The request continued to the server with both:
     - Valid refresh token (query parameter)
     - **Expired access token** (Authorization header from AuthInterceptor)
4. Backend validated the Authorization header and returned 401 for the expired access token
5. `TokenRefreshInterceptor` caught this SECOND 401, again saw it was an auth call, and passed the error through
6. Original error propagated up as "Could not validate credentials"

## Fix Applied
Modified `/home/ahad/Pproject/client/cms/lib/core/network/auth_interceptor.dart` to exclude all auth endpoints from automatically adding the Authorization header.

### Changes Made:
- **File**: `lib/core/network/auth_interceptor.dart`
- **Change**: Updated the `onRequest` method to check for all auth endpoints before adding the Authorization header

**Before:**
```dart
if (!options.path.contains('/auth/login')) {
  final token = await storage.getAccessToken();
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  handler.next(options);
}
```

**After:**
```dart
final isAuthEndpoint = options.path.contains('/auth/login') ||
    options.path.contains('/auth/refresh') ||
    options.path.contains('/auth/request-password-reset') ||
    options.path.contains('/auth/reset-password') ||
    options.path.contains('/auth/register');

if (!isAuthEndpoint) {
  final token = await storage.getAccessToken();
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  handler.next(options);
} else {
  handler.next(options);
}
```

## Why This Fixes It
With this fix:
1. When the `TokenRefreshInterceptor` makes a refresh request, the `AuthInterceptor` **doesn't add** the expired access token
2. The refresh request only contains the refresh token as a query parameter (as expected by the backend)
3. The refresh succeeds and returns a new access token
4. The original request is retried with the new valid access token
5. No more 401 errors from failed refresh attempts

## Note
The `/auth/me` endpoint is intentionally left **included** in the Authorization header logic because it **does** require a valid access token in the Authorization header to fetch the current user's information.

## Verification
- This fix resolves the circular dependency that was causing refresh requests to fail
- The refresh token interceptor can now successfully refresh expired access tokens
- All existing functionality remains intact
- No breaking changes to the API or other components