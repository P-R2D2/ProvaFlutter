# Implementation Plan: Portfolio Position Valuation

**Branch**: `004-portfolio-position-valuation` | **Date**: 2026-05-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-portfolio-position-valuation/spec.md`

## Summary

The Portfolio Position Valuation feature allows users to track the financial performance (capital gains/losses) of their asset holdings in real time. We will implement a NestJS backend module (`investments`) to handle persistent database records, integrate with the existing `AssetsService` (Brapi proxy), and compute dynamic valuation data (invested amount, current position value, absolute and percent returns) along with global portfolio aggregates on request. The Flutter frontend will be updated to fetch and render these backend calculations, replacing the initial local in-memory investment list with a dynamic API-driven dashboard.

## Technical Context

**Language/Version**: TypeScript Node v18+ (Backend) | Dart 3.x / Flutter 3.x (Frontend)  
**Primary Dependencies**: NestJS (@nestjs/common, @nestjs/typeorm, @nestjs/cache-manager), TypeORM, Axios, Better-SQLite3 (Backend) | flutter, provider, go_router, http (Frontend)  
**Storage**: SQLite relational database (`database.sqlite`) via TypeORM  
**Testing**: Jest unit tests (Backend) | flutter_test (Frontend)  
**Target Platform**: Linux server (Backend) | iOS / Android / Web (Frontend)  
**Project Type**: Web/Mobile Application (Frontend + Backend)  
**Performance Goals**: Dashboard endpoint response time < 500ms; UI render latency < 800ms  
**Constraints**: Dynamic calculations strictly on backend; 1-minute caching on asset details; exact 2 decimal places rounding on return percentages; JWT auth enforced on all actions  
**Scale/Scope**: Dynamic multi-position user portfolios with real-time B3 price sync  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] I. Clean Architecture: Does the design strictly separate Domain, Data, and Presentation/Controllers?
- [x] II. Feature-First/Modular: Is the logic organized under `features/` or backend `modules/`?
- [x] III. Responsive UI: Are Material design and responsiveness prioritized (Frontend)?
- [x] IV. Provider: Is state management handled via Provider (Frontend)?
- [x] V. Repository Pattern: Are data sources abstracted behind Repositories?
- [x] VI. Code Quality: Are names meaningful and logic DRY?
- [x] VII. Backend Security: Is JWT used for authentication and class-validator for DTOs?
- [x] VIII. Backend Modular Structure: Are Auth and Users modules isolated in NestJS?

## Project Structure

### Documentation (this feature)

```text
specs/004-portfolio-position-valuation/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── checklists/
│   └── requirements.md  # Specification Checklist
└── contracts/
    └── portfolio.md     # Interface Contracts (API spec)
```

### Source Code (repository root)

```text
backend/
├── src/
│   ├── app.module.ts
│   └── modules/
│       ├── assets/      # Existing Brapi proxy
│       └── investments/ # New dynamic investment valuation module
│           ├── controllers/
│           │   └── investments.controller.ts
│           ├── services/
│           │   └── investments.service.ts
│           ├── domain/
│           │   └── investment.entity.ts
│           ├── dtos/
│           │   ├── register-position.dto.ts
│           │   └── portfolio-valuation.dto.ts
│           └── investments.module.ts
└── tests/

investment_agenda/
├── lib/
│   ├── main.dart
│   └── features/
│       ├── assets/
│       └── investments/
│           ├── data/
│           │   ├── datasources/
│           │   │   └── investments_remote_data_source.dart
│           │   └── repositories/
│           │       └── investment_repository_impl.dart
│           ├── domain/
│           │   ├── entities/
│           │   │   └── investment.dart
│           │   └── repositories/
│           │       └── investment_repository.dart
│           └── presentation/
│               ├── pages/
│               │   ├── dashboard_page.dart
│               │   └── investment_form_page.dart
│               ├── widgets/
│               │   └── investment_card.dart
│               └── providers/
│                   └── investment_provider.dart
└── test/
```

**Structure Decision**: Option 2 (Web application format) was selected to represent clean division between `backend` NestJS and `investment_agenda` Flutter client structures.

## Complexity Tracking

*All constitution checks are fully passed. No complexity-tracking entries required.*
