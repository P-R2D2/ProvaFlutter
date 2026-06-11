# Tasks: Persistent Backend Storage & Authentication

**Input**: Design documents from `/specs/005-backend-persistence-auth/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths are provided in descriptions.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project directories for auth, users, portfolios, and investments modules in `backend/src/modules/`
- [ ] T002 Initialize PostgreSQL connection settings and JWT secret in `backend/.env`
- [ ] T003 [P] Add prisma, @prisma/client, @nestjs/jwt, @nestjs/passport, passport-jwt, bcrypt, class-validator, class-transformer to dependencies in `backend/package.json`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Implement PrismaService wrapper in `backend/src/prisma.service.ts` for connection management
- [ ] T005 [P] Define custom `@Public()` decorator in `backend/src/common/decorators/public.decorator.ts`
- [ ] T006 [P] Implement global `JwtAuthGuard` in `backend/src/common/guards/jwt-auth.guard.ts`
- [ ] T007 [P] Implement dynamic resource `OwnershipGuard` in `backend/src/common/guards/ownership.guard.ts`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Secure User Authentication & Registration (Priority: P1) 🎯 MVP

**Goal**: Secure account signup via bcrypt and session token generation via JWT.

**Independent Test**: Register a user with email and password, log in with valid credentials to get a token, and attempt to login with invalid credentials to verify failure.

### Tests for User Story 1
- [ ] T008 [P] [US1] Write e2e tests for registration and login authentication (including error cases) in `backend/test/auth.e2e-spec.ts`

### Implementation for User Story 1

- [ ] T009 [P] [US1] Create the User schema definition in `backend/prisma/schema.prisma` and run `npx prisma migrate dev --name create_user`
- [ ] T010 [P] [US1] Define Domain User entity and Repository Interface in `backend/src/modules/users/domain/`
- [ ] T011 [US1] Implement `PrismaUserRepository` using Prisma client in `backend/src/modules/users/data/prisma-user.repository.ts`
- [ ] T012 [US1] Create `UsersService` and export `UserRepository` provider in `backend/src/modules/users/users.module.ts`
- [ ] T013 [US1] Implement registration and login methods using bcrypt hashing in `backend/src/modules/auth/auth.service.ts`
- [ ] T014 [P] [US1] Configure passport JWT strategy in `backend/src/modules/auth/strategies/jwt.strategy.ts`
- [ ] T015 [US1] Implement AuthController with register/login routes in `backend/src/modules/auth/auth.controller.ts`

**Checkpoint**: At this point, User Story 1 is fully functional and testable independently.

---

## Phase 4: User Story 2 - Session Validation & Access Control (Priority: P1)

**Goal**: Authenticate and protect all routes by default, allowing selective public access.

**Independent Test**: Request resource list without authorization header and verify `401 Unauthorized` response; send a valid token and verify success.

### Implementation for User Story 2

- [ ] T016 [US2] Register the global `JwtAuthGuard` in `backend/src/main.ts` or `backend/src/app.module.ts`
- [ ] T017 [US2] Import JwtModule and PassportModule config in `backend/src/modules/auth/auth.module.ts`

**Checkpoint**: At this point, User Stories 1 AND 2 work independently.

---

## Phase 5: User Story 3 - Relational Portfolio & Investment Management (Priority: P1)

**Goal**: Store, query, and cascade-delete portfolios and investment assets with strict ownership check.

**Independent Test**: Create a portfolio, verify ownership is enforced, add investment transactions, verify cascade deletions, and verify isolation (User A cannot access User B's portfolio).

### Tests for User Story 3
- [ ] T018 [P] [US3] Write e2e tests for Portfolio CRUD and Investment CRUD (including ownership validation checks) in `backend/test/portfolio-investment.e2e-spec.ts`

### Implementation for User Story 3

- [ ] T019 [P] [US3] Add Portfolio and Investment schema definitions with cascade rules to `backend/prisma/schema.prisma` and run `npx prisma migrate dev --name add_portfolio_and_investment`
- [ ] T020 [P] [US3] Define Domain Portfolio entity and Repository Interface in `backend/src/modules/portfolios/domain/`
- [ ] T021 [US3] Implement `PrismaPortfolioRepository` in `backend/src/modules/portfolios/data/prisma-portfolio.repository.ts`
- [ ] T022 [P] [US3] Create DTOs (`CreatePortfolioDto`, `UpdatePortfolioDto`) in `backend/src/modules/portfolios/dtos/`
- [ ] T023 [US3] Implement CRUD methods and duplicate name validation in `backend/src/modules/portfolios/portfolios.service.ts`
- [ ] T024 [US3] Implement `PortfoliosController` applying `OwnershipGuard` to resource routes in `backend/src/modules/portfolios/portfolios.controller.ts`
- [ ] T025 [P] [US3] Define Domain Investment entity and Repository Interface in `backend/src/modules/investments/domain/`
- [ ] T026 [US3] Implement `PrismaInvestmentRepository` in `backend/src/modules/investments/data/prisma-investment.repository.ts`
- [ ] T027 [P] [US3] Create DTOs (`CreateInvestmentDto`, `UpdateInvestmentDto`) validating positive values in `backend/src/modules/investments/dtos/`
- [ ] T028 [US3] Implement CRUD logic in `backend/src/modules/investments/investments.service.ts`
- [ ] T029 [US3] Implement `InvestmentsController` checking ownership constraints in `backend/src/modules/investments/investments.controller.ts`

**Checkpoint**: All user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validation and system verification

- [ ] T030 [P] Bind ValidationPipe with `whitelist: true` globally in `backend/src/main.ts`
- [ ] T031 Execute sanity check using [quickstart.md](quickstart.md) instructions to verify end-to-end database operations

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational completion
- **Polish (Final Phase)**: Depends on all user stories completion

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel.
- Foundational guards and decorators marked [P] can run in parallel (T005, T006, T007).
- Once Foundational completes, User Story 1 can be developed.
- User Story 3 schemas and DTOs marked [P] can run in parallel.
