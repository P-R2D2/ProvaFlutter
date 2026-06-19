# Implementation Plan: Intelligent Investment Advisor Chat

**Branch**: `008-investment-advisor-chat` | **Date**: 2026-06-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-investment-advisor-chat/spec.md`

## Summary

Implement an AI-powered financial assistant capable of analyzing user investor profiles and portfolios. The technical approach involves a Flutter floating chat interface supporting streaming and markdown, backed by a NestJS module that orchestrates context aggregation, LLM tool-calling, and proactive batch analysis, using PostgreSQL for history persistence.

## Technical Context

**Language/Version**: Dart 3 (Flutter), TypeScript (NestJS)
**Primary Dependencies**: Flutter, Provider, NestJS, Prisma, AI Provider SDK, class-validator
**Storage**: PostgreSQL (Prisma)
**Testing**: flutter_test, jest
**Target Platform**: iOS/Android (Flutter), Node.js server (NestJS)
**Project Type**: Mobile App + API
**Performance Goals**: Context assembly < 1s, AI response streaming starts < 2s
**Constraints**: Client never communicates directly with LLM. API keys secured in backend.
**Scale/Scope**: Rolling window 30-day conversation history, batch cron jobs for proactive insights.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] I. Clean Architecture: Does the design strictly separate Domain, Data, and Presentation/Controllers?
- [x] II. Feature-First/Modular: Is the logic organized under `features/` or backend `modules/`?
- [x] III. Responsive UI: Are Material design and responsiveness prioritized (Frontend)?
- [x] IV. Provider: Is state management handled via Provider (Frontend)?
- [x] V. Data Abstraction & Repository Pattern: Are database and API interactions abstracted behind Repository interfaces?
- [x] VI. Code Quality: Are names meaningful and logic DRY?
- [x] VII. Backend Security: Is JWT used for authentication, bcrypt for password hashing, and class-validator for DTOs?
- [x] VIII. Backend Modular Structure: Are modules (Auth, Users, Portfolios, Investments) modular and isolated in NestJS?
- [x] IX. Backend Persistence & ORM: Does the backend use PostgreSQL with Prisma ORM, keeping business logic strictly separated?
- [x] X. Future Financial Integrations: Are external integrations decoupled via adapters/gateways defined in the Domain layer?
- [x] XI. Robust AI Integrations: Are external AI integrations using robust parsing and handling errors gracefully?

## Backend Services & Responsibilities

- **AIResponseParser**: Extract JSON from LLM responses, remove Markdown, validate schemas, recover malformed responses, and return safe fallback objects.
- **RecommendationValidationService**: Validate recommendations against the investor profile, reject unsafe suggestions, append mandatory disclaimers, and validate investment categories.
- **PortfolioSummaryService**: Generate summarized portfolio context, calculate diversification metrics, calculate allocation by category, calculate largest positions, cache summaries, and regenerate summaries only after portfolio modifications.
- **PromptOptimizerService**: Reduce unnecessary prompt size, remove duplicated information, and optimize token usage.

## Testing Plan

- **Parser tests**: Validate JSON extraction, Markdown stripping, schema validation, error recovery, and fallback mechanisms.
- **Recommendation validation tests**: Verify rejection of unsafe/unsupported advice and verify disclaimer injection.
- **Summary generation tests**: Ensure accurate metric calculations and accurate context generation.
- **Cache tests**: Validate caching behavior and cache invalidation upon portfolio updates.
- **Prompt optimization tests**: Validate token reduction and removal of duplicates without context loss.
- **Performance benchmarks**: Ensure <1s context assembly and <2s time to first token.

## Project Structure

### Documentation (this feature)

```text
specs/008-investment-advisor-chat/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
└── quickstart.md        # Phase 1 output
```

### Source Code (repository root)

```text
backend/
├── src/
│   ├── modules/
│   │   ├── advisor/
│   │   │   ├── controllers/
│   │   │   ├── services/
│   │   │   │   ├── ai-integration.service.ts
│   │   │   │   ├── ai-response-parser.service.ts
│   │   │   │   ├── prompt-builder.service.ts
│   │   │   │   ├── prompt-optimizer.service.ts
│   │   │   │   ├── conversation.service.ts
│   │   │   │   ├── portfolio-summary.service.ts
│   │   │   │   ├── proactive-insights.service.ts
│   │   │   │   └── recommendation-validation.service.ts
│   │   │   └── dto/
└── tests/

investment_agenda/
├── lib/
│   ├── features/
│   │   └── advisor/
│   │       ├── presentation/
│   │       │   ├── widgets/floating_chat.dart
│   │       │   └── providers/chat_provider.dart
│   │       ├── domain/
│   │       └── data/
└── test/
```

**Structure Decision**: Mobile + API. We will add an `advisor` module to the NestJS backend and an `advisor` feature to the Flutter frontend.
