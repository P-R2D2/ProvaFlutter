# Implementation Tasks: Carteira de Investimentos

**Feature**: Carteira de Investimentos
**Branch**: `007-carteira-investimentos`
**Spec**: [spec.md](file:///d:/workspace/ProvaFlutter/specs/007-carteira-investimentos/spec.md)

## Phase 1: Setup

**Goal**: Initialize module and feature directories.

- [x] T001 Initialize backend module for Portfolios in `backend/src/modules/portfolios/portfolios.module.ts`
- [x] T002 Initialize backend module for Investments in `backend/src/modules/investments/investments.module.ts`
- [x] T003 Initialize frontend structure for Portfolios and Investments in `investment_agenda/lib/features/portfolios` and `investment_agenda/lib/features/investments`

## Phase 2: Foundational

**Goal**: Define the data models and run database migrations.

- [x] T004 Update Prisma schema with Portfolio and Investment models in `backend/prisma/schema.prisma`
- [x] T005 Generate Prisma client and run database migration
- [x] T006 Create Dart domain entities for Portfolio and Investment in `investment_agenda/lib/features/portfolios/domain/entities/portfolio_entity.dart` and `investment_agenda/lib/features/investments/domain/entities/investment_entity.dart`

## Phase 3: User Story 1 (Visualizar a Carteira e seus Investimentos)

**Goal**: Allow a user to view their portfolios and the investments inside them.
**Independent Test Criteria**: A user can log in and see a portfolio (even if empty) fetched from the backend.

- [x] T007 [US1] Create Portfolio repository in `backend/src/modules/portfolios/repositories/portfolios.repository.ts`
- [x] T008 [P] [US1] Create Portfolio service to fetch user portfolios in `backend/src/modules/portfolios/services/portfolios.service.ts`
- [x] T009 [US1] Create Portfolio controller endpoint to get portfolios in `backend/src/modules/portfolios/controllers/portfolios.controller.ts`
- [x] T010 [P] [US1] Create Dart models for Portfolio and Investment in `investment_agenda/lib/features/portfolios/data/models/portfolio_model.dart`
- [x] T011 [US1] Create Dart repository implementation for fetching portfolios in `investment_agenda/lib/features/portfolios/data/repositories/portfolio_repository_impl.dart`
- [x] T012 [US1] Create Provider for Portfolio state in `investment_agenda/lib/features/portfolios/presentation/providers/portfolio_provider.dart`
- [x] T013 [US1] Create Portfolio list page UI in `investment_agenda/lib/features/portfolios/presentation/pages/portfolio_list_page.dart`

## Phase 4: User Story 2 (Adicionar um Investimento Específico)

**Goal**: Allow a user to add a specific investment into a portfolio.
**Independent Test Criteria**: A user can fill out a form to add an investment (name, type, amount, price, date) and it saves correctly to the database.

- [x] T014 [US2] Create CreateInvestmentDto with validation in `backend/src/modules/investments/dtos/create-investment.dto.ts`
- [x] T015 [US2] Create Investment repository in `backend/src/modules/investments/repositories/investments.repository.ts`
- [x] T016 [US2] Create Investment service to add an investment in `backend/src/modules/investments/services/investments.service.ts`
- [x] T017 [US2] Create Investment controller endpoint in `backend/src/modules/investments/controllers/investments.controller.ts`
- [x] T018 [US2] Update Provider to support adding an investment via API in `investment_agenda/lib/features/portfolios/presentation/providers/portfolio_provider.dart`
- [x] T019 [US2] Create Add Investment page UI in `investment_agenda/lib/features/investments/presentation/pages/add_investment_page.dart`

## Phase 5: Polish & Cross-Cutting Concerns

**Goal**: Validation, edge cases, and UI perfection.

- [x] T020 Implement negative value validation for quantities and prices in `backend/src/modules/investments/dtos/create-investment.dto.ts` and frontend forms
- [x] T021 Validate strict portfolio-user isolation (authorization rules) in backend controllers/services

## Dependencies & Execution Strategy

- **Execution Order**: Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5
- **Parallel Opportunities**: Frontend entities (T006, T010) and Backend repositories (T007, T015) can be developed concurrently by different members if necessary.
- **Implementation Strategy**: Complete Phase 3 to establish the vertical slice (MVP) before adding the write operations in Phase 4.
