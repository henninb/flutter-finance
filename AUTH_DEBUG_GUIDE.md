# Authentication Debugging Guide

Comprehensive logging has been added to all authentication components to help diagnose issues.

---

## How to See the Logs

### Option 1: Run with Flutter in Terminal
```bash
flutter run
```

All logs will appear in the terminal with emoji prefixes for easy identification.

### Option 2: VS Code Debug Console
If using VS Code, run the app in debug mode and logs will appear in the Debug Console.

### Option 3: Android Studio/IntelliJ
Run the app and check the "Run" tab for console output.

---

## Log Symbols & What They Mean

### General Symbols
- 🔐 Authentication flow started
- 🔍 Checking/searching for something
- 📤 Sending data to server
- 📥 Receiving data from server
- 💾 Saving to storage
- 🔑 Token operations
- 👤 User operations
- 🌐 HTTP requests
- 🚪 Logout operations
- 🔒 Security/interceptor operations
- 🗑️ Deleting/clearing data

### Status Symbols
- ✅ Success
- ❌ Error/Failure
- ⚠️ Warning
- ℹ️ Information

---

## Authentication Flow Logs

### Successful Login Flow

When you attempt to login, you should see logs in this order:

```
🔐 AuthNotifier: Login started for user: <username>
📤 AuthNotifier: Calling auth repository login
🔐 AuthRepository: Starting login for user: <username>
📤 AuthRepository: Sending POST /login request
🌐 HTTP Request: POST https://finance.bhenning.com/api/login
📤 Request headers: {Content-Type: application/json, ...}
📤 Request data: {username: xxx, password: xxx}
📥 HTTP Response: 200 https://finance.bhenning.com/api/login
📥 Response headers: {...}
📥 Response data: {token: xxx, ...}
📥 AuthRepository: Login response received - Status: 200
📥 AuthRepository: Response data type: _Map<String, dynamic>
📥 AuthRepository: Response data: {token: xxx, expiresIn: xxx}
🔑 AuthRepository: Extracted token: eyJhbGciOiJIUzI1NiIs...
✅ AuthRepository: Token extracted successfully, expires at: 2025-12-06 XX:XX:XX
💾 AuthNotifier: Saving token to secure storage
💾 SecureStorage: Saving auth token
💾 SecureStorage: Token (first 20 chars): eyJhbGciOiJIUzI1NiIs...
💾 SecureStorage: Expires at: 2025-12-06 XX:XX:XX
✅ SecureStorage: Token saved successfully
👤 AuthNotifier: Fetching user information
👤 AuthRepository: Fetching current user info
🔒 AuthInterceptor: Intercepting request to /me
✅ AuthInterceptor: Added Bearer token to request: /me
🌐 HTTP Request: GET https://finance.bhenning.com/api/me
📥 HTTP Response: 200 https://finance.bhenning.com/api/me
📥 AuthRepository: User info response: {username: xxx, email: xxx}
✅ AuthRepository: User info retrieved - Username: xxx
✅ AuthNotifier: Login successful for user: xxx
```

### Failed Login Flow

If login fails, look for these error logs:

```
🔐 AuthNotifier: Login started for user: <username>
📤 AuthNotifier: Calling auth repository login
🔐 AuthRepository: Starting login for user: <username>
📤 AuthRepository: Sending POST /login request
🌐 HTTP Request: POST https://finance.bhenning.com/api/login
❌ HTTP Error: 401 https://finance.bhenning.com/api/login
   Error type: DioExceptionType.badResponse
   Error message: ...
   Response data: ...
❌ AuthRepository: DioException during login
   Status code: 401
   Response data: ...
   Message: ...
❌ AuthNotifier: Login failed: Invalid username or password
```

---

## Common Issues & What to Look For

### Issue 1: "No token received from server"

**Look for:**
```
📥 AuthRepository: Response data: {...}
❌ AuthRepository: No token found in response
```

**Diagnosis:**
- The server is not returning a `token` or `access_token` field in the response
- Check the actual response data in the logs
- Your Spring Boot backend might be returning the token in a different field name

**Fix:**
Update `lib/data/repositories/auth_repository.dart:37` to look for the correct field name from your backend.

### Issue 2: Network/Connection Error

**Look for:**
```
❌ HTTP Error: null https://finance.bhenning.com/api/login
   Error type: DioExceptionType.connectionTimeout
   Error message: Connection timeout
```

**Diagnosis:**
- Backend is not reachable
- URL is incorrect
- Network connectivity issues
- CORS issues (if backend requires specific headers)

**Fix:**
- Verify backend is running: `curl https://finance.bhenning.com/api/login`
- Check `lib/core/config/env_config.dart:15` for correct API URL
- Ensure your Spring Boot backend allows requests from mobile apps

### Issue 3: 401 Unauthorized

**Look for:**
```
❌ HTTP Error: 401 https://finance.bhenning.com/api/login
   Response data: {error: "Invalid credentials"}
```

**Diagnosis:**
- Username/password is incorrect
- Backend authentication logic failing

**Fix:**
- Verify credentials are correct
- Check Spring Boot logs to see what the backend is receiving
- Ensure password is being sent correctly (not hashed on client)

### Issue 4: Response Format Mismatch

**Look for:**
```
📥 AuthRepository: Response data type: String
```
or
```
❌ AuthRepository: Unexpected error during login: type 'String' is not a subtype of type 'Map<String, dynamic>'
```

**Diagnosis:**
- Backend is not returning JSON
- Backend is returning HTML error page
- Content-Type header mismatch

**Fix:**
- Check what the backend is actually returning
- Ensure Spring Boot endpoint returns JSON with `@ResponseBody`
- Verify Content-Type header is `application/json`

### Issue 5: Token Not Being Added to Requests

**Look for:**
```
⚠️ AuthInterceptor: No valid token available for request: /me
```

**Diagnosis:**
- Token was not saved properly
- Token expired
- SecureStorage failing

**Fix:**
- Check previous logs for token save operation
- Look for `💾 SecureStorage: Saving auth token` and `✅ SecureStorage: Token saved successfully`
- If not present, SecureStorage might have permission issues

### Issue 6: getCurrentUser() Failing After Login

**Look for:**
```
✅ AuthRepository: Token extracted successfully
💾 SecureStorage: Token saved successfully
👤 AuthNotifier: Fetching user information
❌ HTTP Error: 401 https://finance.bhenning.com/api/me
```

**Diagnosis:**
- Token is valid but `/me` endpoint is rejecting it
- Token is not being added to Authorization header
- Backend requires different authentication format

**Fix:**
- Check if `✅ AuthInterceptor: Added Bearer token` appears before the request
- Verify your Spring Boot `/me` endpoint accepts Bearer tokens
- Check if backend expects cookie instead of Authorization header

---

## Backend Response Format Expected

Your Flutter app expects this response from `POST /api/login`:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 3600
}
```

And from `GET /api/me`:

```json
{
  "username": "testuser",
  "email": "test@example.com"
}
```

If your Spring Boot backend returns a different format, you'll need to update:
- `lib/data/repositories/auth_repository.dart:37-49` for login response
- `lib/data/models/user_model.dart:14-19` for user response

---

## Testing Your Backend Directly

Before testing in the app, verify your backend works with curl:

### Test Login
```bash
curl -X POST https://finance.bhenning.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass"}' \
  -v
```

Expected response should include a JWT token.

### Test Get User (with token from above)
```bash
curl -X GET https://finance.bhenning.com/api/me \
  -H "Authorization: Bearer <token-from-login>" \
  -v
```

Expected response should include user data.

---

## Enabling More Verbose Logging

The logger package is already configured to show all levels (DEBUG, INFO, WARNING, ERROR).

If you want to change log levels, edit the Logger constructor in each file.

Current log levels being used:
- `_logger.d()` - Debug (detailed technical info)
- `_logger.i()` - Info (general flow info)
- `_logger.w()` - Warning (non-critical issues)
- `_logger.e()` - Error (critical failures)

---

## Files with Logging

All authentication components now have comprehensive logging:

1. **lib/data/repositories/auth_repository.dart** - API calls and responses
2. **lib/data/services/secure_storage_service.dart** - Token storage operations
3. **lib/presentation/providers/auth_provider.dart** - State management flow
4. **lib/data/data_sources/remote/dio_provider.dart** - HTTP interceptors

---

## Next Steps

1. **Run the app**: `flutter run`
2. **Try to login** with test credentials
3. **Watch the logs** in your terminal/console
4. **Identify the issue** using the patterns above
5. **Share the relevant logs** if you need help debugging

All logs are prefixed with emojis and component names for easy identification!
