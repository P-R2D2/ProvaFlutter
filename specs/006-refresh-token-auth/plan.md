# Implementation Plan: Refresh Token Authentication Flow

**Branch**: `006-refresh-token-auth` | **Date**: 2026-06-11 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/006-refresh-token-auth/spec.md`

## Summary

This feature improves session durability, security, and persistence across both client and server layers. We are transitioning the backend to issue dual tokens: a short-lived `access_token` (15-30m JWT) and a long-lived `refresh_token` (7d JWT). The backend will persist a bcrypt hash of the active refresh token to enable rotation (RTR) and revocation. The frontend (Flutter) will transition to using `flutter_secure_storage` to encrypt tokens locally, using a global HTTP client interceptor to catch HTTP 401s, silently refresh credentials, and replay failed requests.

## Technical Context

**Language/Version**: TypeScript (Node 18+ / NestJS 11), Dart 3.11+ (Flutter 3.16+)  
**Primary Dependencies**: `@nestjs/jwt`, `bcrypt`, `flutter_secure_storage: ^9.2.2`, `http: ^1.2.2`, `provider: ^6.1.5+1`  
**Storage**: PostgreSQL (using Prisma ORM), secure operating system keychains (Keystore/Keychain) on mobile  
**Testing**: Jest (Unit & E2E on backend), flutter_test (on frontend)  
**Target Platform**: Linux Server (Docker), Android & iOS mobile devices  
**Project Type**: Mobile Application + Web Service API  
**Performance Goals**: Token refresh operations completed in <1.5 seconds under 3G/4G connectivity  
**Constraints**: Zero plaintext token storage (SharedPreferences banned), strict single-active-session per user  
**Scale/Scope**: Scale to 10k+ concurrent active sessions  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] I. Clean Architecture: Separates Domain entities, Repository interfaces, Data repositories, and Controllers/Providers.
- [x] II. Feature-First/Modular: Auth modules on backend and investments/auth providers on frontend are isolated and modular.
- [x] III. Responsive UI: Home/Login transitions are responsive.
- [x] IV. Provider: AuthState and credentials are managed using Provider.
- [x] V. Data Abstraction & Repository Pattern: Database models and JWT encryption are kept in the Data layer, behind Repository interfaces.
- [x] VI. Code Quality: Descriptive naming and DRY principles applied.
- [x] VII. Backend Security: Hashed refresh token verification and JWT strategy applied.
- [x] VIII. Backend Modular Structure: Distinct modules maintained.
- [x] IX. Backend Persistence & ORM: Prisma schema database migrations verified.
- [x] X. Future Financial Integrations: Keeps financial adapters decoupled from core credentials.

## Project Structure

### Documentation (this feature)

```text
specs/006-refresh-token-auth/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Technical design decisions
├── data-model.md        # Database schema modifications
├── quickstart.md        # Environment setup guides
└── contracts/
    └── auth_api.md      # API request/response specifications
```

### Source Code Proposed Layout

```text
backend/
├── prisma/
│   └── schema.prisma                  # Add refreshTokenHash field to User model
├── src/
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── services/
│   │   │   │   └── auth.service.ts    # Generate/validate access + refresh tokens, support RTR
│   │   │   └── controllers/
│   │   │       └── auth.controller.ts # Expose POST /auth/refresh and POST /auth/logout
│   │   └── users/
│   │       ├── domain/
│   │       │   └── user.entity.ts     # Add refreshTokenHash property
│   │       └── data/
│   │           └── prisma-user.repository.ts # Map refreshTokenHash database field
└── test/
    └── auth.e2e-spec.ts               # E2E tests for refresh and logout flows

investment_agenda/
├── pubspec.yaml                       # Add flutter_secure_storage dependency
├── lib/
│   ├── core/
│   │   └── network/
│   │       └── authenticated_http_client.dart # NEW: Intercept 401, refresh token, retry request
│   ├── features/
│   │   └── investments/
│   │       ├── data/
│   │       │   └── services/
│   │       │       └── auth_api_service.dart # Support refresh token payload and api call
│   │       └── presentation/
│   │           └── providers/
│   │               └── auth_provider.dart # Secure storage migration, automatic startup check
```

**Structure Decision**: Web application option (frontend + backend split) with code paths organized cleanly under `backend/` and `investment_agenda/`.

## Proposed Changes

### Backend Changes

#### [MODIFY] [schema.prisma](file:///home/luis-eduardo-pierre/Projetos/estudo/ProvaFlutter/backend/prisma/schema.prisma)
- Add `refreshTokenHash String?` to the `User` model.

#### [MODIFY] [user.entity.ts](file:///home/luis-eduardo-pierre/Projetos/estudo/ProvaFlutter/backend/src/modules/users/domain/user.entity.ts)
- Replace `refreshToken` with `refreshTokenHash`.

#### [MODIFY] [prisma-user.repository.ts](file:///home/luis-eduardo-pierre/Projetos/estudo/ProvaFlutter/backend/src/modules/users/data/prisma-user.repository.ts)
- Update `mapToEntity`, `save`, and `update` methods to map `refreshTokenHash` database field to the Domain User entity.

#### [MODIFY] [auth.service.ts](file:///home/luis-eduardo-pierre/Projetos/estudo/ProvaFlutter/backend/src/modules/auth/services/auth.service.ts)
- Generate two JWTs (`accessToken` signed with access options, `refreshToken` signed with refresh options).
- Store bcrypt hash of the generated refresh token in `user.refreshTokenHash`.
- Implement `refresh(token: string)`:
  - Decode refresh token and verify signature using `JWT_REFRESH_SECRET`.
  - Fetch user, compare hash via `bcrypt.compare`.
  - Rotate: generate new access + refresh token pair, store new hash, return pair.
  - RTR Breach detection: if token is valid but hash doesn't match, invalidate all user sessions (set hash to null) and throw 401.

#### [MODIFY] [auth.controller.ts](file:///home/luis-eduardo-pierre/Projetos/estudo/ProvaFlutter/backend/src/modules/auth/controllers/auth.controller.ts)
- Add `POST /auth/refresh` endpoint (accepts `refreshToken` DTO, returns rotated token pair).
- Update `POST /auth/logout` endpoint to support explicit backend session revocation.

---

### Frontend Changes

#### [MODIFY] [pubspec.yaml](file:///home/luis-eduardo-pierre/Projetos/estudo/ProvaFlutter/investment_agenda/pubspec.yaml)
- Add dependency: `flutter_secure_storage: ^9.2.2`.

#### [NEW] [authenticated_http_client.dart](file:///home/luis-eduardo-pierre/Projetos/estudo/ProvaFlutter/investment_agenda/lib/core/network/authenticated_http_client.dart)
- Extend `http.BaseClient`.
- Intercept all calls to inject the Bearer token.
- Intercept `401 Unauthorized` responses:
  - Check lock/mutex.
  - Trigger token refresh via `AuthProvider.refreshSession()`.
  - Retry request with the new token.

#### [MODIFY] [auth_provider.dart](file:///home/luis-eduardo-pierre/Projetos/estudo/ProvaFlutter/investment_agenda/lib/features/investments/presentation/providers/auth_provider.dart)
- Replace `SharedPreferences` with `FlutterSecureStorage`.
- Store both `auth_token` and `refresh_token`.
- Implement `refreshSession()` which calls the refresh endpoint, saves new tokens, and returns success.
- On startup (`_restoreSession`): check for `refresh_token`, optimistically log in, and handle token updates in the background.

---

## Verification Plan

### Automated Tests
- **Backend Unit Tests**: Verify `AuthService.refresh` token generation, expiration limits, validation, and RTR breach isolation behavior.
- **Backend E2E Tests**: Test auth refresh endpoints (`POST /auth/refresh`), successful rotations, invalidation on logout, and 401 responses for expired tokens.
- **Frontend Unit Tests**: Verify `AuthenticatedHttpClient` correctly intercepts 401s, calls refresh, retries requests, and queues multiple concurrent calls.

### Manual Verification
- Launch the application, log in, close the application, and re-launch it to verify optimistic startup session restoration.
- Intentionally expire the access token in tests and execute a dashboard refresh to verify silent background token rotation.
- Log out of the application and verify that `flutter_secure_storage` is successfully wiped.
