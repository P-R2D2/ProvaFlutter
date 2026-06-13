# Tasks: Refresh Token Authentication Flow

**Input**: Design documents from `/specs/006-refresh-token-auth/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Web app**: `backend/src/`, `investment_agenda/lib/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 [P] Add `flutter_secure_storage: ^9.2.2` to dependencies in `investment_agenda/pubspec.yaml`
- [x] T002 [P] Configure environment secrets `JWT_REFRESH_SECRET` in `backend/.env`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Update Prisma schema model `User` to add `refreshTokenHash` in `backend/prisma/schema.prisma`
- [x] T004 Run database migrations via `npx prisma migrate dev --name add_user_refresh_token_hash` in `backend/`
- [x] T005 [P] Update domain entity property `refreshTokenHash` in `backend/src/modules/users/domain/user.entity.ts` and update mapping in `backend/src/modules/users/data/prisma-user.repository.ts`
- [x] T006 Create `AuthenticatedHttpClient` class extending `http.BaseClient` in `investment_agenda/lib/core/network/authenticated_http_client.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Session Persistence on App Start (Priority: P1) 🎯 MVP

**Goal**: Automatically restore active session on application startup if tokens exist, navigating directly to Home.

**Independent Test**: Log in, close application, restart application. Check that Dashboard screen is presented directly without displaying Login screen.

### Tests for User Story 1

- [x] T007 [P] [US1] Write test for session restoration check in `investment_agenda/test/session_restoration_test.dart`

### Implementation for User Story 1

- [x] T008 [US1] Migrate token persistence from `SharedPreferences` to `FlutterSecureStorage` in `investment_agenda/lib/features/investments/presentation/providers/auth_provider.dart`
- [x] T009 [US1] Implement `_restoreSession` to check secure storage for tokens in `investment_agenda/lib/features/investments/presentation/providers/auth_provider.dart`
- [x] T010 [US1] Update application routing to load Dashboard optimistically on startup if tokens exist in `investment_agenda/lib/main.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently.

---

## Phase 4: User Story 2 - Automated Token Refresh on Expiry (Priority: P2)

**Goal**: Automatically trigger token refresh on access token expiry, updating credentials silently in the background.

**Independent Test**: Make an API call when the access token is expired but refresh token is valid. The request should complete successfully and update local tokens in secure storage.

### Tests for User Story 2

- [x] T011 [P] [US2] Write E2E test for `POST /auth/refresh` endpoint and token rotation in `backend/test/auth.e2e-spec.ts`
- [x] T012 [P] [US2] Write unit test for HTTP client refresh interceptor queueing in `investment_agenda/test/authenticated_http_client_test.dart`

### Implementation for User Story 2

- [x] T013 [US2] Update `AuthService` login and register logic to sign dual access and refresh tokens, saving the bcrypt hash of the refresh token in database in `backend/src/modules/auth/services/auth.service.ts`
- [x] T014 [US2] Implement `POST /auth/refresh` validation, token rotation, and RTR breach detection in `backend/src/modules/auth/services/auth.service.ts` and controller in `backend/src/modules/auth/controllers/auth.controller.ts`
- [x] T015 [US2] Add token refresh endpoint integration logic in `investment_agenda/lib/features/investments/data/services/auth_api_service.dart`
- [x] T016 [US2] Implement global interceptor 401 catch, async locking/mutex, and request retry logic in `investment_agenda/lib/core/network/authenticated_http_client.dart`

**Checkpoint**: At this point, User Stories 1 and 2 should both work independently.

---

## Phase 5: User Story 3 - Secure Logout & Session Invalidation (Priority: P3)

**Goal**: Wipe local storage and invalidate refresh token on backend on user logout.

**Independent Test**: Trigger logout, check that secure storage is empty, and database `refreshTokenHash` is null.

### Tests for User Story 3

- [x] T017 [P] [US3] Write E2E test for `POST /auth/logout` database hash invalidation in `backend/test/auth.e2e-spec.ts`

### Implementation for User Story 3

- [x] T018 [US3] Update logout method in `backend/src/modules/auth/controllers/auth.controller.ts` to invalidate/nullify `refreshTokenHash` in the database.
- [x] T019 [US3] Update logout flow in `investment_agenda/lib/features/investments/presentation/providers/auth_provider.dart` to clear all credentials from secure storage.

**Checkpoint**: All user stories should now be independently functional.

---

## Phase 6: Polish & Verification

- [ ] T020 [P] Conduct complete authentication flow manual verification as described in `specs/006-refresh-token-auth/quickstart.md`
- [x] T021 Code cleanup and lint correction across both project paths

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories.
- **User Stories (Phase 3+)**: All depend on Foundational phase completion.
  - User stories can then proceed in parallel or sequentially in priority order (P1 → P2 → P3).
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### Parallel Opportunities

- Setup tasks T001 and T002 can run in parallel.
- Foundational repository updates T005 and client structure T006 can run in parallel.
- Once Foundational phase is complete, US1, US2, and US3 implementation can progress in parallel.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories).
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: Verify persistent session startup locally.
