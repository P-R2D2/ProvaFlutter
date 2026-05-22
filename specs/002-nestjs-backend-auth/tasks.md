---
description: "Task list template for feature implementation"
---

# Tasks: NestJS Backend Authentication

**Input**: Design documents from `specs/002-nestjs-backend-auth/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Initialize NestJS project in `backend/` directory
- [x] T002 Configure global `ValidationPipe` (class-validator) in `backend/src/main.ts`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Install dependencies: `@nestjs/jwt`, `@nestjs/passport`, `passport`, `passport-jwt`, `bcrypt`, `class-validator`, `class-transformer`
- [x] T004 [P] Create Users module structure in `backend/src/modules/users/users.module.ts`
- [x] T005 [P] Create Auth module structure in `backend/src/modules/auth/auth.module.ts`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - User Registration (Priority: P1) 🎯 MVP

**Goal**: Allow a new user to create an account with email and password.

**Independent Test**: Submit a valid JSON payload to `/auth/register` and verify user is saved in memory and password is encrypted.

### Implementation for User Story 1

- [x] T006 [P] [US1] Define `User` entity and interface in `backend/src/modules/users/domain/user.entity.ts`
- [x] T007 [P] [US1] Create `RegisterDto` with strict password rules in `backend/src/modules/auth/dtos/register.dto.ts`
- [x] T008 [US1] Implement `UserRepository` interface and `InMemoryUserRepository` in `backend/src/modules/users/data/in-memory-user.repository.ts`
- [x] T009 [US1] Implement `UsersService` to hash passwords (bcrypt cost 10) and save users in `backend/src/modules/users/services/users.service.ts`
- [x] T010 [US1] Implement `AuthController.register` endpoint in `backend/src/modules/auth/controllers/auth.controller.ts`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - User Login (Priority: P1)

**Goal**: Allow a registered user to authenticate and receive an access token and refresh token.

**Independent Test**: Submit valid credentials to `/auth/login` and receive a JWT access token (15m expiry) and refresh token.

### Implementation for User Story 2

- [x] T011 [P] [US2] Create `LoginDto` in `backend/src/modules/auth/dtos/login.dto.ts`
- [x] T012 [P] [US2] Define `AuthToken` return type in `backend/src/modules/auth/domain/auth-token.type.ts`
- [x] T013 [US2] Update `UsersService` with `findByEmail` method in `backend/src/modules/users/services/users.service.ts`
- [x] T014 [US2] Configure `JwtModule` with secret and expiration in `backend/src/modules/auth/auth.module.ts`
- [x] T015 [US2] Implement `AuthService.login` to validate password and generate tokens in `backend/src/modules/auth/services/auth.service.ts`
- [x] T016 [US2] Implement `AuthController.login` endpoint in `backend/src/modules/auth/controllers/auth.controller.ts`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Secure Route Access (Priority: P2)

**Goal**: Protect API endpoints using a global JWT Guard that defaults to secure.

**Independent Test**: Access a protected route without a token (fails), then access with a valid token (succeeds).

### Implementation for User Story 3

- [x] T017 [P] [US3] Implement `JwtStrategy` (passport-jwt) in `backend/src/modules/auth/strategies/jwt.strategy.ts`
- [x] T018 [P] [US3] Create `@Public()` decorator in `backend/src/modules/auth/decorators/public.decorator.ts`
- [x] T019 [US3] Implement `JwtAuthGuard` in `backend/src/modules/auth/guards/jwt-auth.guard.ts`
- [x] T020 [US3] Apply global `APP_GUARD` in `backend/src/app.module.ts` and add `@Public()` to register/login routes in `backend/src/modules/auth/controllers/auth.controller.ts`

**Checkpoint**: All routes are secure by default, and public auth routes remain accessible.

---

## Phase 6: User Story 4 - User Logout (Priority: P2)

**Goal**: Provide an endpoint to securely log out the user by invalidating their refresh token.

**Independent Test**: Log out using a valid access token and ensure the corresponding refresh token is removed from server memory.

### Implementation for User Story 4

- [x] T021 [P] [US4] Update `InMemoryUserRepository` to track the active refresh token for a user.
- [x] T022 [US4] Implement `AuthService.logout` to remove the refresh token in `backend/src/modules/auth/services/auth.service.ts`
- [x] T023 [US4] Implement `AuthController.logout` endpoint (protected by default) in `backend/src/modules/auth/controllers/auth.controller.ts`

**Checkpoint**: Users can fully complete the registration, login, data access, and logout lifecycle securely.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T024 [P] Test all endpoints using the `contracts/api.yaml` specification and `curl` commands in `quickstart.md`
- [x] T025 Resolve any import issues and clean up unused code.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: Must execute sequentially based on priorities (Registration -> Login -> Route Access -> Logout) as each builds heavily upon the state/tokens created by the previous.

### Parallel Opportunities

- Module setup (T004, T005)
- DTO creation and entity definitions (T006, T007, T011, T012)
- Security utility files (T017, T018)

---

## Implementation Strategy

### MVP First (User Story 1 & 2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: Registration
4. Complete Phase 4: Login
5. **STOP and VALIDATE**: Ensure a user can register and receive a JWT.

### Incremental Delivery

1. Complete Route Access (Phase 5) to secure the API globally.
2. Complete Logout (Phase 6) to solidify session termination.
