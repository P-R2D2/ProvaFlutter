# Tasks: Portfolio Position Valuation

**Input**: Design documents from `/specs/004-portfolio-position-valuation/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project directory setup and structural wireframes

- [x] T001 [P] Setup backend investments module structural folders in `backend/src/modules/investments/`
- [x] T002 [P] Setup frontend investments structure under `investment_agenda/lib/features/investments/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core model infrastructure and security wireframes

- [x] T003 Implement backend `Investment` database entity at `backend/src/modules/investments/domain/investment.entity.ts`
- [x] T004 Define backend DTOs (`RegisterPositionDto`, `PortfolioValuationDto`, `PortfolioSummaryDto`) in `backend/src/modules/investments/dtos/`
- [x] T005 Create backend `InvestmentsService` skeleton at `backend/src/modules/investments/services/investments.service.ts`
- [x] T006 Create backend `InvestmentsController` with global JWT auth guards in `backend/src/modules/investments/controllers/investments.controller.ts`
- [x] T007 Register `Investment` entity and `InvestmentsModule` inside `backend/src/app.module.ts`

**Checkpoint**: Foundation ready - CRUD and valuation logic can now be implemented

---

## Phase 3: User Story 1 - Asset Position Registration (Priority: P1) 🎯 MVP

**Goal**: Allow users to search, select B3 tickers, specify positive quantity and average price, and persist position securely.

**Independent Test**: API registers `PETR4` with quantity `10` and price `30.00` and retrieves the exact persisted values.

### Implementation for User Story 1

- [x] T008 [US1] Implement `POST /api/investments` endpoint handling and validation guards (quantity > 0, price > 0)
- [x] T009 [US1] Implement position retrieval and `DELETE /api/investments/:id` in backend controllers/services
- [x] T010 [US1] Write backend unit tests for registration DTO validations and CRUD service operations
- [x] T011 [P] [US1] Update frontend `Investment` domain entity inside `investment_agenda/lib/features/investments/domain/entities/investment.dart`
- [x] T012 [US1] Implement `InvestmentsRemoteDataSource` at `investment_agenda/lib/features/investments/data/datasources/investments_remote_data_source.dart`
- [x] T013 [US1] Implement API integrations inside `investment_agenda/lib/features/investments/data/repositories/investment_repository_impl.dart`
- [x] T014 [US1] Bind authorization proxy providers inside `investment_agenda/lib/main.dart`
- [x] T015 [US1] Update state management triggers inside `investment_agenda/lib/features/investments/presentation/providers/investment_provider.dart`
- [x] T016 [US1] Redesign input controls inside `investment_agenda/lib/features/investments/presentation/pages/investment_form_page.dart`

**Checkpoint**: User Story 1 works as a fully functional independent MVP!

---

## Phase 4: User Story 2 - Portfolio Valuation Dashboard (Priority: P1)

**Goal**: Dynamic real-time asset pricing, calculation rounding, and total consolidated portfolio summary.

**Independent Test**: A GET request to `/api/investments` returns dynamically aggregated totals (Invested, Value, P/L, Return %) calculated from Brapi rates.

### Implementation for User Story 2

- [x] T017 [US2] Integrate `InvestmentsService` with `AssetsService` for concurrent price lookups via `Promise.all`
- [x] T018 [US2] Implement dynamic asset calculations (FR-002) and 2-decimal rounding rules on the backend
- [x] T019 [US2] Implement consolidated global Portfolio Summary computations (FR-003) on the backend
- [x] T020 [US2] Write backend math-precision unit tests asserting correct calculations and roundings
- [x] T021 [US2] Update frontend models mapping backend valuation response payloads
- [x] T022 [US2] Redesign cards inside `investment_agenda/lib/features/investments/presentation/widgets/investment_card.dart`
- [x] T023 [US2] Redesign layout inside `investment_agenda/lib/features/investments/presentation/pages/dashboard_page.dart`

**Checkpoint**: User Stories 1 and 2 work seamlessly together!

---

## Phase 5: User Story 3 - Graceful Handling of Price Glitches (Priority: P2)

**Goal**: Mitigate rate-limits and outages by falling back to cost bases and alerting users.

### Implementation for User Story 3

- [x] T024 [US3] Implement pricing hierarchy fallbacks and `isDelayed: true` flags inside `InvestmentsService`
- [x] T025 [US3] Add warning banners on frontend pages when delayed assets exist

---

## Phase 6: Polish

**Purpose**: Verify coverage, run automated suites, and document setup.

- [x] T026 Run automated backend and frontend test suites and verify quickstart instructions
