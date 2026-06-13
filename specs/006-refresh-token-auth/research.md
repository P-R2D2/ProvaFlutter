# Research: Refresh Token Authentication Flow

## Decided Solutions

### 1. Token Cryptography & Longevity
- **Access Token**: JWT containing the user ID in the `sub` claim. Expiration set to **15 minutes**. Signed with the existing JWT secret.
- **Refresh Token**: JWT containing a custom payload (e.g., user ID, random session ID) signed with a separate secret `JWT_REFRESH_SECRET` or distinct options. Expiration set to **7 days**.
- **Rotation (RTR)**: Refresh Token Rotation is enabled. Every time a refresh is requested, the client sends the active refresh token. The server verifies it, invalidates it, and generates a brand new access and refresh token pair.

### 2. Backend Storage & Session Revocation
- **Hashed Storage**: The backend stores the bcrypt hash of the active refresh token in the `users` table (`refreshTokenHash` column).
- **Validation**: On refresh requests, the server extracts the user ID from the refresh token, retrieves the user from the database, and uses `bcrypt.compare` to match the token.
- **Replay Attack Detection (RTR Breach)**: If a refresh token is reused, it indicates a replay attack. The server will immediately invalidate all sessions for that user by setting `refreshTokenHash` to `null` to protect the account.
- **Cleanup**: Inactive/expired sessions are retained in the database until manual purging.

### 3. Client Storage (Flutter)
- **Library**: `flutter_secure_storage` is used exclusively. Plaintext options like `SharedPreferences` are prohibited.
- **Platform Encryption**:
  - **iOS**: Keychain services.
  - **Android**: AES encryption using EncryptedSharedPreferences (under the hood of `flutter_secure_storage` with KeyStore keys).

### 4. HTTP Interceptor & Token Refresh (Flutter)
- **Implementation**: A custom wrapper class `AuthenticatedHttpClient` that extends `http.BaseClient`.
- **Flow**:
  1. Intercepts outgoing requests and appends the `Authorization: Bearer <accessToken>` header.
  2. If the request returns `401 Unauthorized`, it acquires an async lock (mutex) to prevent parallel refresh calls.
  3. Checks if the token was already refreshed by another concurrent request. If not, it fires the `/auth/refresh` API request with the stored refresh token.
  4. On success, it updates `flutter_secure_storage` and `AuthProvider` memory state, and retries the original request with the new access token.
  5. If validation fails (401 on refresh), it wipes local storage, triggers an unauthenticated status in `AuthProvider`, and redirects the user to the Login screen.

---

## Alternatives Considered

### 1. Stateless Refresh Tokens (JWT without Database Tracking)
- **Pros**: Zero database reads or writes during token refresh operations.
- **Cons**: Impossible to revoke a session before expiration (e.g. on logout) and impossible to detect replay attacks if a refresh token is stolen.
- **Verdict**: Rejected for security reasons.

### 2. Plaintext SharedPreferences
- **Pros**: Already added as a dependency in the project.
- **Cons**: Stored in plaintext XML files on Android. Stolen devices with root access could leak active refresh tokens.
- **Verdict**: Rejected. `flutter_secure_storage` is mandatory.
