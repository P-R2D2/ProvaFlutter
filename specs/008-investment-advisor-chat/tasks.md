# Tasks: Intelligent Investment Advisor Chat

**Input**: Design documents from `/specs/008-investment-advisor-chat/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Initialize advisor module structure in backend/src/modules/advisor/
- [ ] T002 [P] Initialize advisor feature structure in investment_agenda/lib/features/advisor/
- [ ] T003 Setup environment variables for AI provider in backend/.env

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Setup Prisma schema with ChatSession, ChatMessage, and ProactiveInsight in backend/prisma/schema.prisma
- [ ] T005 Create Prisma migration and update client in backend/
- [ ] T006 [P] Implement LLM provider abstraction in backend/src/modules/advisor/services/ai-integration.service.ts
- [ ] T007 Implement base Domain Entities in investment_agenda/lib/features/advisor/domain/entities/chat_session.dart
- [ ] T008 [P] Implement base Domain Entities in investment_agenda/lib/features/advisor/domain/entities/chat_message.dart
- [ ] T009 Implement base Data Models in investment_agenda/lib/features/advisor/data/models/chat_session_model.dart
- [ ] T010 [P] Implement base Data Models in investment_agenda/lib/features/advisor/data/models/chat_message_model.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Context-Aware Beginner Guidance (Priority: P1) 🎯 MVP

**Goal**: A user with no current investments opens the chat to get started with investing and the assistant automatically guides them.

**Independent Test**: Can be fully tested by creating a new user with an investor profile but empty portfolio, opening the chat, and verifying the assistant proactively guides them.

### Tests for User Story 1 ⚠️

- [ ] T011 [P] [US1] Integration test for AI context generation in backend/test/advisor.e2e-spec.ts
- [ ] T012 [P] [US1] Unit test for ChatProvider state in investment_agenda/test/features/advisor/presentation/providers/chat_provider_test.dart

### Implementation for User Story 1

- [ ] T013 [P] [US1] Create Prompt Builder Service in backend/src/modules/advisor/services/prompt-builder.service.ts
- [ ] T014 [US1] Create Conversation Service in backend/src/modules/advisor/services/conversation.service.ts
- [ ] T015 [US1] Implement Chat Controller endpoint in backend/src/modules/advisor/controllers/advisor.controller.ts
- [ ] T016 [P] [US1] Define Chat Repository Interface in investment_agenda/lib/features/advisor/domain/repositories/chat_repository.dart
- [ ] T017 [US1] Implement Chat Use Case in investment_agenda/lib/features/advisor/domain/usecases/send_message_usecase.dart
- [ ] T018 [US1] Implement Chat Repository in investment_agenda/lib/features/advisor/data/repositories/chat_repository_impl.dart
- [ ] T019 [US1] Implement Chat Remote Data Source in investment_agenda/lib/features/advisor/data/datasources/chat_remote_data_source.dart
- [ ] T020 [US1] Implement Chat Provider in investment_agenda/lib/features/advisor/presentation/providers/chat_provider.dart
- [ ] T021 [US1] Create Chat Screen UI in investment_agenda/lib/features/advisor/presentation/pages/chat_page.dart
- [ ] T022 [US1] Implement streaming markdown renderer widget in investment_agenda/lib/features/advisor/presentation/widgets/markdown_message_widget.dart
- [ ] T023 [US1] Implement typing animation and loading states in investment_agenda/lib/features/advisor/presentation/widgets/typing_indicator.dart

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Automated Portfolio Analysis (Priority: P1)

**Goal**: An experienced user with multiple investments opens the chat to understand the health of their portfolio.

**Independent Test**: Can be tested by logging in as a user with a diverse portfolio, opening the chat, and asking "How is my portfolio doing?".

### Implementation for User Story 2

- [ ] T024 [P] [US2] Create Portfolio Analyzer Service in backend/src/modules/advisor/services/portfolio-analyzer.service.ts
- [ ] T025 [US2] Update Prompt Builder to inject all distinct portfolios in backend/src/modules/advisor/services/prompt-builder.service.ts
- [ ] T026 [US2] Integrate portfolio analysis into Conversation Service in backend/src/modules/advisor/services/conversation.service.ts

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Proactive Insights (Priority: P2)

**Goal**: The system automatically detects that a user's portfolio has deviated significantly and generates insights.

**Independent Test**: Can be tested by simulating a portfolio deviation and verifying the chat interface presents a proactive alert.

### Implementation for User Story 3

- [ ] T027 [P] [US3] Create Proactive Insights Service in backend/src/modules/advisor/services/proactive-insights.service.ts
- [ ] T028 [US3] Implement daily cron job in backend/src/modules/advisor/services/proactive-insights.service.ts
- [ ] T029 [US3] Create ProactiveInsight Entity and Model in investment_agenda/lib/features/advisor/domain/entities/proactive_insight.dart
- [ ] T030 [US3] Update Chat Provider to fetch insights in investment_agenda/lib/features/advisor/presentation/providers/chat_provider.dart
- [ ] T031 [US3] Update Chat Screen to display proactive alerts in investment_agenda/lib/features/advisor/presentation/pages/chat_page.dart

**Checkpoint**: All core features including background jobs are functional

---

## Phase 6: User Story 4 - Continuous and Persistent Chat Experience (Priority: P2)

**Goal**: A user navigates between different screens in the application while having a conversation with the assistant.

**Independent Test**: Can be tested by starting a conversation, navigating across different application pages, and verifying the chat state remains intact.

### Implementation for User Story 4

- [ ] T032 [P] [US4] Create floating chat widget wrapper in investment_agenda/lib/features/advisor/presentation/widgets/floating_chat_widget.dart
- [ ] T033 [US4] Implement collapsible behavior in investment_agenda/lib/features/advisor/presentation/widgets/floating_chat_widget.dart
- [ ] T034 [US4] Update main layout to include floating chat globally in investment_agenda/lib/core/presentation/layouts/main_layout.dart

**Checkpoint**: All user stories should now be independently functional

---

## Phase 7: Advanced Backend Architecture

**Purpose**: Implement resilient parsing, validation, context caching, and prompt optimization.

### Parsing
- [ ] T035 [P] Create AIResponseParser service in backend/src/modules/advisor/services/ai-response-parser.service.ts
- [ ] T036 Implement MarkdownCleaner utility in AIResponseParser
- [ ] T037 Implement JSONExtractor utility in AIResponseParser
- [ ] T038 Implement ResponseSchemaValidator in AIResponseParser
- [ ] T039 Implement SafeFallbackHandler in AIResponseParser

### Recommendation Validation
- [ ] T040 [P] Create RecommendationValidationService in backend/src/modules/advisor/services/recommendation-validation.service.ts
- [ ] T041 Validate investor profile compatibility in RecommendationValidationService
- [ ] T042 Validate diversification recommendations in RecommendationValidationService
- [ ] T043 Reject unsafe recommendations in RecommendationValidationService
- [ ] T044 Append financial disclaimer in RecommendationValidationService

### Portfolio Summary
- [ ] T045 [P] Create PortfolioSummaryService in backend/src/modules/advisor/services/portfolio-summary.service.ts
- [ ] T046 Generate summarized portfolio context in PortfolioSummaryService
- [ ] T047 Calculate allocation metrics in PortfolioSummaryService
- [ ] T048 Calculate diversification metrics in PortfolioSummaryService
- [ ] T049 Cache generated summaries in PortfolioSummaryService
- [ ] T050 Invalidate cache after portfolio updates in PortfolioSummaryService

### Prompt Optimization
- [ ] T051 [P] Create PromptOptimizerService in backend/src/modules/advisor/services/prompt-optimizer.service.ts
- [ ] T052 Remove duplicated context in PromptOptimizerService
- [ ] T053 Reduce prompt size in PromptOptimizerService
- [ ] T054 Optimize token usage in PromptOptimizerService

---

## Phase 8: Integration & Performance Testing

**Purpose**: Ensure the architecture meets performance constraints and components integrate seamlessly.

### Integration Tests
- [ ] T055 [P] Implement AI parsing integration tests in backend/test/ai-parsing.e2e-spec.ts
- [ ] T056 [P] Implement Recommendation validation integration tests in backend/test/validation.e2e-spec.ts
- [ ] T057 [P] Implement Portfolio summary generation integration tests in backend/test/portfolio-summary.e2e-spec.ts
- [ ] T058 [P] Implement Prompt optimization integration tests in backend/test/prompt-optimization.e2e-spec.ts

### Performance Benchmarks
- [ ] T059 [P] Add benchmark tests for overall architecture in backend/test/benchmark.e2e-spec.ts
- [ ] T060 Measure context assembly time in benchmark tests
- [ ] T061 Measure parser performance in benchmark tests
- [ ] T062 Measure summary generation time in benchmark tests

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T063 [P] Create suggested prompts widget in investment_agenda/lib/features/advisor/presentation/widgets/suggested_prompts.dart
- [ ] T064 Refactor conversation history logic to enforce 30-day rolling window purge in backend/src/modules/advisor/services/conversation.service.ts
- [ ] T065 Validate recommendation consistency and AI context generation thoroughly in backend/test/advisor.e2e-spec.ts

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
- **Advanced Architecture (Phase 7)**: Services can be built in parallel with US1, but integrated sequentially.
- **Testing (Phase 8)**: Depends on Phase 7 completion.
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### Parallel Opportunities

- Foundational DB tasks and LLM provider abstractions can run in parallel.
- User Story 1 frontend and backend implementations can run in parallel once contracts (DTOs/Interfaces) are agreed upon.
- User Stories 2, 3, and 4 can largely be developed in parallel by different team members once Phase 2 is complete.
