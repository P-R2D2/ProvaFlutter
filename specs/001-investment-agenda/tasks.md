# Tasks: Investment Agenda

**Input**: Design documents from `specs/001-investment-agenda/`
**Prerequisites**: plan.md, spec.md, data-model.md, research.md, quickstart.md

**Tests**: Unit tests for Domain and Data layers are included by default for Clean Architecture compliance.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and architectural scaffolding.

- [X] T001 Add project dependencies (`provider`, `go_router`, `uuid`, `intl`) to `pubspec.yaml`
- [X] T002 Create Clean Architecture folder structure under `lib/features/investments/`
- [X] T003 [P] Configure app theme and shared styles in `lib/core/theme/app_theme.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core layers required for all user stories.

- [X] T004 [P] Create Investment Entity with UUID in `lib/features/investments/domain/entities/investment.dart`
- [X] T005 [P] Define Investment Repository interface in `lib/features/investments/domain/repositories/investment_repository.dart`
- [X] T006 Implement In-Memory Repository in `lib/features/investments/data/repositories/investment_repository_impl.dart`
- [X] T007 Initialize Base App Router using `go_router` in `lib/core/routes/app_router.dart`

---

## Phase 3: User Story 1 - Secure Access (Priority: P1) 🎯 MVP

**Goal**: Authenticate users using hardcoded credentials to access the app.

**Independent Test**: Enter `admin/admin` on the Login screen and confirm redirection to the Dashboard.

### Implementation for User Story 1

- [X] T008 [P] [US1] Create AuthProvider for hardcoded login logic in `lib/features/investments/presentation/providers/auth_provider.dart`
- [X] T009 [P] [US1] Build Login Page UI with Material widgets in `lib/features/investments/presentation/pages/login_page.dart`
- [X] T010 [US1] Implement login redirect and auth-guard in `lib/core/routes/app_router.dart`

**Checkpoint**: User Story 1 (Login) is functional.

---

## Phase 4: User Story 2 - Portfolio Dashboard (Priority: P1) 🎯 MVP

**Goal**: Display total invested amount and a list of investment cards.

**Independent Test**: Verify that the Dashboard shows a correctly formatted total and an illustrative empty state when no data exists.

### Implementation for User Story 2

- [X] T011 [P] [US2] Implement InvestmentProvider for list and total management in `lib/features/investments/presentation/providers/investment_provider.dart`
- [X] T012 [P] [US2] Create Investment Card widget with localized currency in `lib/features/investments/presentation/widgets/investment_card.dart`
- [X] T013 [P] [US2] Build Dashboard Page UI with Total amount header in `lib/features/investments/presentation/pages/dashboard_page.dart`
- [X] T014 [US2] Implement Illustrative Empty State with "Add" CTA on Dashboard Page

**Checkpoint**: User Story 2 (Dashboard) shows list and total.

---

## Phase 5: User Story 3 - Investment Management (Priority: P2)

**Goal**: Full CRUD lifecycle with confirmation dialogs and snackbar feedback.

**Independent Test**: Add an investment, edit it, and delete it. Confirm that a dialog appears before deletion and Snackbars show for each action.

### Implementation for User Story 3

- [X] T015 [P] [US3] Build Investment Form Page with inline validation in `lib/features/investments/presentation/pages/investment_form_page.dart`
- [X] T016 [US3] Implement Add and Update logic in `lib/features/investments/presentation/providers/investment_provider.dart`
- [X] T017 [US3] Create Delete Confirmation Dialog in `lib/features/investments/presentation/widgets/delete_confirmation_dialog.dart`
- [X] T018 [US3] Implement Delete logic and integrate Snackbar feedback (save/delete) in `lib/features/investments/presentation/pages/dashboard_page.dart`

**Checkpoint**: Full CRUD lifecycle is functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final refinements and quality checks.

- [X] T019 Apply micro-animations and final UI polish across all pages
- [X] T020 [P] Run final validation of local-first persistence during session lifecycle

---

## Dependencies & Execution Order

### Phase Dependencies
- **Setup (Phase 1)**: Must complete first.
- **Foundational (Phase 2)**: Depends on Setup.
- **User Stories (Phase 3-5)**: Can be worked on once Phase 2 is complete.
  - US1 and US2 are P1 and should be prioritized for MVP.
  - US3 depends on US2 (Dashboard) to exist for navigation and list display.

### Implementation Strategy
1. **MVP First**: Complete Phase 1-4. This delivers a working App with Login and a Dashboard that displays data.
2. **Phase 5**: Adds the capability to manage data, completing the product value loop.
